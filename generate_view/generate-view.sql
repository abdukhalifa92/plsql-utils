CREATE OR REPLACE PROCEDURE generate_views(
    p_table_list IN SYS.ODCIVARCHAR2LIST,
    p_view_name  IN VARCHAR2,
    p_execute    IN VARCHAR2 DEFAULT 'Y'
) AS
    TYPE t_table_alias_map IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(128);
    TYPE t_column_set IS TABLE OF BOOLEAN INDEX BY VARCHAR2(128);

    v_sql           CLOB := 'CREATE OR REPLACE VIEW ' || p_view_name || ' AS' || CHR(10) || 'SELECT' || CHR(10);
    v_select_cols   CLOB := '';
    v_from_clause   CLOB := '';
    v_used_columns  t_column_set;
    v_table_alias   t_table_alias_map;
    v_alias_index   INTEGER := 1;
    v_joined_tables SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST();

    PROCEDURE split_schema_table (
        full_name IN VARCHAR2,
        schema OUT VARCHAR2,
        tbl OUT VARCHAR2
    ) IS
    BEGIN
        IF INSTR(full_name, '.') > 0 THEN
            schema := UPPER(SUBSTR(full_name, 1, INSTR(full_name, '.') - 1));
            tbl := UPPER(SUBSTR(full_name, INSTR(full_name, '.') + 1));
        ELSE
            schema := USER;
            tbl := UPPER(full_name);
        END IF;
    END;

    PROCEDURE add_columns(p_schema VARCHAR2, p_table VARCHAR2, p_alias VARCHAR2) IS
    BEGIN
        FOR col IN (
            SELECT column_name
            FROM all_tab_columns
            WHERE table_name = p_table
              AND owner = p_schema
            ORDER BY column_id
        ) LOOP
            IF NOT v_used_columns.EXISTS(col.column_name) THEN
                IF v_select_cols IS NOT NULL THEN
                    v_select_cols := v_select_cols || ',' || CHR(10);
                END IF;
                v_select_cols := v_select_cols || '    ' || p_alias || '.' || col.column_name;
                v_used_columns(col.column_name) := TRUE;
            END IF;
        END LOOP;
    END;

    FUNCTION find_join_condition(
        s1 VARCHAR2, t1 VARCHAR2, a1 VARCHAR2,
        s2 VARCHAR2, t2 VARCHAR2, a2 VARCHAR2
    ) RETURN VARCHAR2 IS
    BEGIN
        FOR j IN (
            SELECT a.column_name col1, b.column_name col2
            FROM all_constraints c
            JOIN all_cons_columns a ON c.constraint_name = a.constraint_name AND c.owner = a.owner
            JOIN all_constraints r ON c.r_constraint_name = r.constraint_name AND c.owner = r.owner
            JOIN all_cons_columns b ON r.constraint_name = b.constraint_name AND a.position = b.position AND r.owner = b.owner
            WHERE c.constraint_type = 'R'
              AND a.table_name = t1 AND a.owner = s1
              AND b.table_name = t2 AND b.owner = s2
        ) LOOP
            RETURN a1 || '.' || j.col1 || ' = ' || a2 || '.' || j.col2;
        END LOOP;

        FOR j IN (
            SELECT a.column_name
            FROM all_tab_columns a
            JOIN all_tab_columns b ON a.column_name = b.column_name
            WHERE a.table_name = t1 AND a.owner = s1
              AND b.table_name = t2 AND b.owner = s2
        ) LOOP
            RETURN a1 || '.' || j.column_name || ' = ' || a2 || '.' || j.column_name;
        END LOOP;

        RETURN NULL;
    END;

BEGIN
    FOR i IN 1 .. p_table_list.COUNT LOOP
        DECLARE
            full_name VARCHAR2(128) := p_table_list(i);
            schema_name VARCHAR2(30);
            table_name  VARCHAR2(30);
            alias       VARCHAR2(10) := 't' || v_alias_index;
            fully_qualified_name VARCHAR2(200);
        BEGIN
            split_schema_table(full_name, schema_name, table_name);
            fully_qualified_name := '"' || schema_name || '"."' || table_name || '"';
            v_table_alias(full_name) := alias;
            v_alias_index := v_alias_index + 1;

            IF i = 1 THEN
                v_from_clause := '    ' || fully_qualified_name || ' ' || alias;
                add_columns(schema_name, table_name, alias);
                v_joined_tables.EXTEND;
                v_joined_tables(v_joined_tables.COUNT) := full_name;
            ELSE
                FOR j IN 1 .. v_joined_tables.COUNT LOOP
                    DECLARE
                        prev_full     VARCHAR2(128) := v_joined_tables(j);
                        prev_schema   VARCHAR2(30);
                        prev_table    VARCHAR2(30);
                        cond          VARCHAR2(1000);
                    BEGIN
                        split_schema_table(prev_full, prev_schema, prev_table);
                        cond := find_join_condition(
                            schema_name, table_name, alias,
                            prev_schema, prev_table, v_table_alias(prev_full)
                        );
                        IF cond IS NULL THEN
                            cond := find_join_condition(
                                prev_schema, prev_table, v_table_alias(prev_full),
                                schema_name, table_name, alias
                            );
                        END IF;

                        IF cond IS NOT NULL THEN
                            v_from_clause := v_from_clause || CHR(10) || '    JOIN ' || fully_qualified_name || ' ' || alias || ' ON ' || cond;
                            add_columns(schema_name, table_name, alias);
                            v_joined_tables.EXTEND;
                            v_joined_tables(v_joined_tables.COUNT) := full_name;
                            EXIT;
                        END IF;
                    END;
                END LOOP;
            END IF;
        END;
    END LOOP;

    -- Final SQL
    v_sql := v_sql || v_select_cols || CHR(10) || 'FROM' || CHR(10) || v_from_clause;

    -- Output
    DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    DBMS_OUTPUT.PUT_LINE('-- Generated View Script');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    DBMS_OUTPUT.PUT_LINE(v_sql);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------');

    -- Execute if allowed
    IF UPPER(p_execute) = 'Y' THEN
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('✅ View "' || p_view_name || '" created.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠️ View not created. Execution skipped as per input.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
END;

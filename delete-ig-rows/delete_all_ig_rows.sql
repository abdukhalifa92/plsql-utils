-- =====================================================================
-- Delete All Rows in Interactive Grid - APEX 24.2 (PL/SQL Server-Side)
-- 
-- Collection of PL/SQL procedures and functions for server-side deletion
-- of Interactive Grid rows in Oracle APEX 24.2
-- 
-- Author: PL/SQL Utils
-- Version: 1.0
-- Date: 2024
-- =====================================================================

-- =====================================================================
-- Procedure: DELETE_ALL_IG_ROWS
-- Description: Generic procedure to delete all rows from a table
-- Parameters:
--   p_table_name: Name of the table to delete from
--   p_where_clause: Optional WHERE clause for conditional deletion
-- =====================================================================
PROCEDURE delete_all_ig_rows(
    p_table_name   IN VARCHAR2,
    p_where_clause IN VARCHAR2 DEFAULT NULL
) IS
    l_sql VARCHAR2(4000);
    l_count NUMBER := 0;
BEGIN
    -- Validate table name to prevent SQL injection
    IF p_table_name IS NULL OR LENGTH(p_table_name) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Table name cannot be null or empty');
    END IF;
    
    -- Get count before deletion
    l_sql := 'SELECT COUNT(*) FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name);
    IF p_where_clause IS NOT NULL THEN
        l_sql := l_sql || ' WHERE ' || p_where_clause;
    END IF;
    
    EXECUTE IMMEDIATE l_sql INTO l_count;
    
    -- Perform deletion
    l_sql := 'DELETE FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name);
    IF p_where_clause IS NOT NULL THEN
        l_sql := l_sql || ' WHERE ' || p_where_clause;
    END IF;
    
    EXECUTE IMMEDIATE l_sql;
    
    -- Log the action
    apex_debug.message('Deleted ' || SQL%ROWCOUNT || ' rows from table: ' || p_table_name);
    apex_debug.message('Original count was: ' || l_count);
    
    COMMIT;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_debug.error('Error in delete_all_ig_rows: ' || SQLERRM);
    RAISE;
END delete_all_ig_rows;

-- =====================================================================
-- Procedure: DELETE_USER_IG_ROWS
-- Description: Delete rows with user/session context filtering
-- Parameters:
--   p_table_name: Name of the table to delete from
--   p_user_column: Column name that contains user information
--   p_user_value: User value to filter by (defaults to current APEX user)
-- =====================================================================
PROCEDURE delete_user_ig_rows(
    p_table_name  IN VARCHAR2,
    p_user_column IN VARCHAR2 DEFAULT 'CREATED_BY',
    p_user_value  IN VARCHAR2 DEFAULT NULL
) IS
    l_sql VARCHAR2(4000);
    l_user_val VARCHAR2(255);
    l_count NUMBER := 0;
BEGIN
    -- Validate parameters
    IF p_table_name IS NULL OR p_user_column IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Table name and user column cannot be null');
    END IF;
    
    -- Use provided user value or default to current APEX user
    l_user_val := NVL(p_user_value, COALESCE(apex_application.g_user, USER));
    
    -- Get count before deletion
    l_sql := 'SELECT COUNT(*) FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name) ||
             ' WHERE ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_user_column) || ' = :user_val';
    
    EXECUTE IMMEDIATE l_sql INTO l_count USING l_user_val;
    
    -- Perform deletion
    l_sql := 'DELETE FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name) ||
             ' WHERE ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_user_column) || ' = :user_val';
    
    EXECUTE IMMEDIATE l_sql USING l_user_val;
    
    -- Log the action
    apex_debug.message('Deleted ' || SQL%ROWCOUNT || ' rows from table: ' || p_table_name);
    apex_debug.message('User filter: ' || p_user_column || ' = ' || l_user_val);
    apex_debug.message('Original count was: ' || l_count);
    
    COMMIT;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_debug.error('Error in delete_user_ig_rows: ' || SQLERRM);
    RAISE;
END delete_user_ig_rows;

-- =====================================================================
-- Procedure: DELETE_SESSION_IG_ROWS
-- Description: Delete rows filtered by current APEX session
-- Parameters:
--   p_table_name: Name of the table to delete from
--   p_session_column: Column name that contains session information
-- =====================================================================
PROCEDURE delete_session_ig_rows(
    p_table_name     IN VARCHAR2,
    p_session_column IN VARCHAR2 DEFAULT 'APEX_SESSION_ID'
) IS
    l_sql VARCHAR2(4000);
    l_session_id NUMBER;
    l_count NUMBER := 0;
BEGIN
    -- Validate parameters
    IF p_table_name IS NULL OR p_session_column IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'Table name and session column cannot be null');
    END IF;
    
    -- Get current APEX session ID
    l_session_id := apex_application.g_instance;
    
    IF l_session_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'No active APEX session found');
    END IF;
    
    -- Get count before deletion
    l_sql := 'SELECT COUNT(*) FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name) ||
             ' WHERE ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_session_column) || ' = :session_id';
    
    EXECUTE IMMEDIATE l_sql INTO l_count USING l_session_id;
    
    -- Perform deletion
    l_sql := 'DELETE FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name) ||
             ' WHERE ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_session_column) || ' = :session_id';
    
    EXECUTE IMMEDIATE l_sql USING l_session_id;
    
    -- Log the action
    apex_debug.message('Deleted ' || SQL%ROWCOUNT || ' rows from table: ' || p_table_name);
    apex_debug.message('Session filter: ' || p_session_column || ' = ' || l_session_id);
    apex_debug.message('Original count was: ' || l_count);
    
    COMMIT;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_debug.error('Error in delete_session_ig_rows: ' || SQLERRM);
    RAISE;
END delete_session_ig_rows;

-- =====================================================================
-- Function: DELETE_IG_ROWS_JSON
-- Description: Delete rows and return JSON response for AJAX calls
-- Parameters:
--   p_table_name: Name of the table to delete from
--   p_where_clause: Optional WHERE clause
-- Returns: JSON string with status and message
-- =====================================================================
FUNCTION delete_ig_rows_json(
    p_table_name   IN VARCHAR2,
    p_where_clause IN VARCHAR2 DEFAULT NULL
) RETURN CLOB IS
    l_count NUMBER := 0;
    l_deleted NUMBER := 0;
    l_sql VARCHAR2(4000);
    l_result CLOB;
BEGIN
    -- Validate table name
    IF p_table_name IS NULL OR LENGTH(p_table_name) = 0 THEN
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('status', 'error');
        apex_json.write('message', 'Table name cannot be null or empty');
        apex_json.close_object;
        RETURN apex_json.get_clob_output;
    END IF;
    
    -- Get count before deletion
    l_sql := 'SELECT COUNT(*) FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name);
    IF p_where_clause IS NOT NULL THEN
        l_sql := l_sql || ' WHERE ' || p_where_clause;
    END IF;
    
    EXECUTE IMMEDIATE l_sql INTO l_count;
    
    -- Perform deletion
    l_sql := 'DELETE FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name);
    IF p_where_clause IS NOT NULL THEN
        l_sql := l_sql || ' WHERE ' || p_where_clause;
    END IF;
    
    EXECUTE IMMEDIATE l_sql;
    l_deleted := SQL%ROWCOUNT;
    
    COMMIT;
    
    -- Build JSON response
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'Successfully deleted ' || l_deleted || ' rows');
    apex_json.write('rows_deleted', l_deleted);
    apex_json.write('original_count', l_count);
    apex_json.write('table_name', p_table_name);
    apex_json.close_object;
    
    l_result := apex_json.get_clob_output;
    apex_json.free_output;
    
    RETURN l_result;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('status', 'error');
    apex_json.write('message', 'Error deleting rows: ' || SQLERRM);
    apex_json.write('error_code', SQLCODE);
    apex_json.close_object;
    
    l_result := apex_json.get_clob_output;
    apex_json.free_output;
    
    RETURN l_result;
END delete_ig_rows_json;

-- =====================================================================
-- Procedure: BATCH_DELETE_IG_ROWS
-- Description: Delete rows in batches to handle large datasets
-- Parameters:
--   p_table_name: Name of the table to delete from
--   p_where_clause: Optional WHERE clause
--   p_batch_size: Number of rows to delete per batch (default: 1000)
-- =====================================================================
PROCEDURE batch_delete_ig_rows(
    p_table_name   IN VARCHAR2,
    p_where_clause IN VARCHAR2 DEFAULT NULL,
    p_batch_size   IN NUMBER DEFAULT 1000
) IS
    l_sql VARCHAR2(4000);
    l_total_deleted NUMBER := 0;
    l_batch_deleted NUMBER := 0;
    l_batch_count NUMBER := 0;
BEGIN
    -- Validate parameters
    IF p_table_name IS NULL OR p_batch_size <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Invalid parameters for batch delete');
    END IF;
    
    -- Build base SQL
    l_sql := 'DELETE FROM ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_table_name);
    IF p_where_clause IS NOT NULL THEN
        l_sql := l_sql || ' WHERE ' || p_where_clause;
    END IF;
    l_sql := l_sql || ' AND ROWNUM <= :batch_size';
    
    -- Delete in batches
    LOOP
        EXECUTE IMMEDIATE l_sql USING p_batch_size;
        l_batch_deleted := SQL%ROWCOUNT;
        l_total_deleted := l_total_deleted + l_batch_deleted;
        l_batch_count := l_batch_count + 1;
        
        -- Log progress
        apex_debug.message('Batch ' || l_batch_count || ': Deleted ' || l_batch_deleted || ' rows');
        
        -- Commit each batch
        COMMIT;
        
        -- Exit if no more rows to delete
        EXIT WHEN l_batch_deleted = 0;
        
        -- Small delay to prevent system overload
        IF l_batch_count > 10 THEN
            DBMS_SESSION.SLEEP(0.1);
        END IF;
        
    END LOOP;
    
    -- Final log
    apex_debug.message('Batch delete completed. Total rows deleted: ' || l_total_deleted);
    apex_debug.message('Total batches processed: ' || l_batch_count);
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_debug.error('Error in batch_delete_ig_rows: ' || SQLERRM);
    RAISE;
END batch_delete_ig_rows;

-- =====================================================================
-- APEX Process Examples for use in APEX Application Processes
-- =====================================================================

/*
-- Example 1: Simple APEX Process for deleting all rows
-- Process Name: DELETE_ALL_ROWS
-- Process Point: Ajax Callback
BEGIN
    delete_all_ig_rows(
        p_table_name => 'EMPLOYEES',
        p_where_clause => 'CREATED_BY = :APP_USER'
    );
    
    -- Return success message
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'All rows deleted successfully');
    apex_json.close_object;
    
EXCEPTION WHEN OTHERS THEN
    apex_json.open_object;
    apex_json.write('status', 'error');
    apex_json.write('message', 'Error: ' || SQLERRM);
    apex_json.close_object;
END;
*/

/*
-- Example 2: JSON Response APEX Process
-- Process Name: DELETE_ALL_ROWS_JSON
-- Process Point: Ajax Callback
DECLARE
    l_result CLOB;
BEGIN
    l_result := delete_ig_rows_json(
        p_table_name => 'MY_TABLE',
        p_where_clause => 'SESSION_ID = :APP_SESSION'
    );
    
    htp.p(l_result);
END;
*/

/*
-- Example 3: User-specific deletion APEX Process
-- Process Name: DELETE_USER_ROWS
-- Process Point: Ajax Callback
BEGIN
    delete_user_ig_rows(
        p_table_name => 'USER_DATA',
        p_user_column => 'USERNAME',
        p_user_value => :APP_USER
    );
    
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'User data deleted successfully');
    apex_json.close_object;
    
EXCEPTION WHEN OTHERS THEN
    apex_json.open_object;
    apex_json.write('status', 'error');
    apex_json.write('message', SQLERRM);
    apex_json.close_object;
END;
*/

/*
-- Example 4: Session-specific deletion APEX Process
-- Process Name: DELETE_SESSION_ROWS
-- Process Point: Ajax Callback
BEGIN
    delete_session_ig_rows(
        p_table_name => 'TEMP_DATA',
        p_session_column => 'APEX_SESSION_ID'
    );
    
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'Session data cleared successfully');
    apex_json.close_object;
    
EXCEPTION WHEN OTHERS THEN
    apex_json.open_object;
    apex_json.write('status', 'error');
    apex_json.write('message', SQLERRM);
    apex_json.close_object;
END;
*/

-- =====================================================================
-- Security and Best Practices Notes:
-- 
-- 1. Always use DBMS_ASSERT to validate SQL names
-- 2. Use bind variables to prevent SQL injection
-- 3. Include appropriate WHERE clauses for user/session filtering
-- 4. Log all deletion activities for audit purposes
-- 5. Test thoroughly in development environment
-- 6. Consider backup/recovery strategies
-- 7. Implement proper error handling and rollback logic
-- 8. Use batch processing for large datasets
-- 9. Monitor system performance during large deletions
-- 10. Ensure proper privileges and security policies
-- =====================================================================
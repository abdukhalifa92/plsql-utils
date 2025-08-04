# 🧩 Oracle View Generator

A PL/SQL procedure that automatically generates and (optionally) executes a `VIEW` by joining multiple related tables using foreign key constraints or matching column names.

---

## ✨ Features

- Auto-detects `JOIN` conditions between tables via:
  - Foreign key constraints (preferred)
  - Matching column names (fallback)
- Supports schema-qualified table names (e.g., `HR.EMPLOYEES`)
- Deduplicates column names in the `SELECT` list
- Orders columns by `COLUMN_ID` for better readability
- Generates clean and formatted SQL
- Supports preview mode without creating the view
- ✅ **Automatically avoids name collision** by appending `_V1`, `_V2`, etc. when a view with the same name already exists
- ❌ Optionally raises an error instead of overwriting if auto-renaming is disabled

---

## 🚀 Usage

### Basic Usage – Create View

```sql
BEGIN
    generate_views(
        p_table_list => SYS.ODCIVARCHAR2LIST('EMPLOYEES', 'DEPARTMENTS'),
        p_view_name  => 'EMP_DEPT_VIEW'
    );
END;
/
```

---

## 🧾 Parameters

| Parameter        | Type                   | Description                                                                                   |
|------------------|------------------------|-----------------------------------------------------------------------------------------------|
| `p_table_list`   | `SYS.ODCIVARCHAR2LIST` | List of tables to include in the view (may use schema-qualified names like `'HR.EMPLOYEES'`) |
| `p_view_name`    | `VARCHAR2`             | Name of the view to be created (e.g., `'EMP_DEPT_VIEW'`)                                     |
| `p_execute`      | `VARCHAR2`             | `'Y'` to execute and create the view (default), `'N'` to only display the generated SQL       |
| `p_auto_rename`  | `VARCHAR2`             | `'Y'` (default) to auto-suffix view name if it already exists, `'N'` to raise an error       |

---

## ⚙️ How It Works

The procedure analyzes the tables in the order they are listed and attempts to join them intelligently:

- **Assigns Aliases:** Each table is assigned an alias (`t1`, `t2`, `t3`, ...).
- **Adds Columns:** Only unique column names are included in the `SELECT` clause, ordered by their `COLUMN_ID` to reflect their natural table order.
- **Joins Tables:**
  - First, it looks for foreign key relationships between tables using `ALL_CONSTRAINTS`.
  - If no foreign key is found, it tries to match column names between tables as a fallback.
- **Generates View SQL:**
  - Uses clean formatting with indentation and new lines.
  - Outputs the final `CREATE OR REPLACE VIEW` SQL script via `DBMS_OUTPUT`.
  - Optionally executes the SQL if `p_execute = 'Y'`.
- **Manages Existing View Conflicts:**
  - If `p_auto_rename = 'Y'`, it will generate a new name like `EMP_DEPT_VIEW_V1`, `EMP_DEPT_VIEW_V2`, etc.
  - If `p_auto_rename = 'N'`, and the view exists, it raises an error.

---

## 🧾 Sample Output

When run, the procedure outputs a formatted, readable `CREATE VIEW` statement showing selected columns and join conditions.

You can either copy this output and use it manually, or let the procedure create the view automatically.

```sql
CREATE OR REPLACE VIEW EMPLOYEE_DETAILS_VW AS
SELECT
    t1.EMPLOYEE_ID,
    t1.FIRST_NAME,
    t1.LAST_NAME,
    t2.DEPARTMENT_NAME,
    t3.CITY
FROM
    "HR"."EMPLOYEES" t1
    JOIN "HR"."DEPARTMENTS" t2 ON t1.DEPARTMENT_ID = t2.DEPARTMENT_ID
    JOIN "HR"."LOCATIONS" t3 ON t2.LOCATION_ID = t3.LOCATION_ID;
```

---

## ✅ Requirements

- Oracle Database 11g or later
- Access to:
  - `ALL_TAB_COLUMNS`
  - `ALL_CONSTRAINTS`, `ALL_CONS_COLUMNS`
- Privileges:
  - `SELECT` on all listed tables
  - `CREATE VIEW` (if `p_execute = 'Y'`)

---

## ⚠️ Limitations

- Supports only `INNER JOIN`s.
- Complex or indirect relationships may not be fully resolved.
- No support for:
  - `LEFT/RIGHT OUTER JOIN`
  - Filters (`WHERE` clauses)
  - Custom column aliases or expressions
- Table names are case-sensitive in the input list.

---

## 📄 License

MIT License – Free to use, modify, and distribute.

---

## 🙌 Contributing

Pull requests and suggestions are welcome! Some ideas for improvement:

- Support for custom join conditions
- Support for outer joins and filters
- Add options for column aliasing and exclusion
- Output SQL to file or a log table

# Oracle Auto-Join View Generator

A powerful Oracle PL/SQL stored procedure that automatically creates database views by intelligently joining multiple tables based on foreign key relationships and common column names.

## 🚀 Features

- **Automatic Join Detection**: Automatically detects relationships between tables using:
  - Foreign key constraints (primary method)
  - Common column names (fallback method)
- **Smart Column Selection**: Includes all unique columns from joined tables, avoiding duplicates
- **Flexible Schema Support**: Works with tables across different schemas
- **Dry Run Mode**: Preview generated SQL before execution
- **Error Handling**: Comprehensive error reporting with user-friendly messages
- **Schema-Qualified Output**: Generates properly quoted, schema-qualified table names

## 📋 Prerequisites

- Oracle Database 11g or higher
- `CREATE VIEW` privileges on target schema
- `SELECT` privileges on `ALL_TAB_COLUMNS`, `ALL_CONSTRAINTS`, and `ALL_CONS_COLUMNS` system views
- Access to tables you want to join

## 🔧 Installation

1. Connect to your Oracle database as a user with procedure creation privileges
2. Execute the procedure definition in your SQL client
3. Grant necessary permissions if deploying for other users:

```sql
-- Grant execute permission to other users
GRANT EXECUTE ON create_auto_join_view TO [username];
```

## 📖 Usage

### Basic Syntax

```sql
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('table1', 'table2', 'table3'),
    p_view_name  => 'my_joined_view',
    p_execute    => 'Y'  -- Optional: 'Y' to execute, 'N' for dry run
);
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `p_table_list` | `SYS.ODCIVARCHAR2LIST` | Yes | - | Array of table names to join. Can include schema prefixes (e.g., 'SCHEMA.TABLE') |
| `p_view_name` | `VARCHAR2` | Yes | - | Name of the view to create |
| `p_execute` | `VARCHAR2` | No | 'Y' | 'Y' = Create the view, 'N' = Generate SQL only (dry run) |

## 💡 Examples

### Example 1: Basic Join (Same Schema)

```sql
-- Join orders, customers, and products tables
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('ORDERS', 'CUSTOMERS', 'PRODUCTS'),
    p_view_name  => 'ORDER_DETAILS_VIEW',
    p_execute    => 'Y'
);
```

**Generated Output:**
```sql
CREATE OR REPLACE VIEW ORDER_DETAILS_VIEW AS 
SELECT t1.order_id, t1.customer_id, t1.order_date, t1.total_amount, 
       t2.customer_name, t2.email, t2.phone,
       t3.product_id, t3.product_name, t3.price
FROM "SCHEMA"."ORDERS" t1 
JOIN "SCHEMA"."CUSTOMERS" t2 ON t1.customer_id = t2.customer_id
JOIN "SCHEMA"."PRODUCTS" t3 ON t1.product_id = t3.product_id
```

### Example 2: Cross-Schema Join

```sql
-- Join tables from different schemas
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('HR.EMPLOYEES', 'PAYROLL.SALARIES', 'HR.DEPARTMENTS'),
    p_view_name  => 'EMPLOYEE_SALARY_VIEW',
    p_execute    => 'Y'
);
```

### Example 3: Dry Run (Preview Only)

```sql
-- Generate SQL without creating the view
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('INVENTORY', 'SUPPLIERS', 'CATEGORIES'),
    p_view_name  => 'INVENTORY_DETAILS_VIEW',
    p_execute    => 'N'  -- Just show the SQL
);
```

## 🔍 How It Works

### Join Detection Algorithm

1. **Primary Method - Foreign Keys**: The procedure first attempts to find foreign key relationships between tables using Oracle's constraint metadata
2. **Fallback Method - Common Columns**: If no foreign keys exist, it looks for columns with identical names between tables
3. **Join Order**: Tables are joined in the order provided, with each new table being connected to any previously joined table where a relationship exists

### Column Selection Logic

- Scans all columns from each successfully joined table
- Adds columns to the SELECT clause only if the column name hasn't been used before
- Uses table aliases (t1, t2, t3, etc.) to avoid naming conflicts
- Maintains the order of tables as specified in the input list

## ⚠️ Important Notes

### Limitations

- **Single Path Joins**: The procedure finds the first available join condition between tables. Complex many-to-many relationships may require manual adjustment
- **Column Name Conflicts**: When multiple tables have the same column name, only the first occurrence is included in the view
- **No Custom Join Logic**: Cannot specify custom join conditions or WHERE clauses
- **Linear Join Strategy**: Tables must form a connected graph; isolated tables without relationships will be skipped

### Best Practices

1. **Order Matters**: Place your "central" or most connected table first in the list
2. **Test with Dry Run**: Always use `p_execute => 'N'` first to review the generated SQL
3. **Check Relationships**: Ensure proper foreign key constraints exist, or use consistent column naming
4. **Schema Permissions**: Verify you have SELECT access to all specified tables and schemas

## 🐛 Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Table or view does not exist" | Missing table or insufficient privileges | Check table names and grant SELECT privileges |
| "No join condition found" | No foreign keys or common columns | Add foreign key constraints or ensure common column names |
| "View not created" | Insufficient CREATE VIEW privileges | Grant CREATE VIEW privilege to user |

### Error Messages

- ✅ **Success**: `View "view_name" created.`
- ⚠️ **Dry Run**: `View not created. Execution skipped as per input.`
- ❌ **Error**: `Error: [Oracle error message]`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Enhancement Ideas

- Support for LEFT/RIGHT/FULL OUTER joins
- Custom WHERE clause conditions
- Column aliasing and selection control
- Performance optimization for large table sets
- Integration with Oracle Data Dictionary views

## 📄 License

This project is open source. Please ensure compliance with your organization's database policies and Oracle licensing terms.

## 🔗 Related Resources

- [Oracle PL/SQL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/)
- [Oracle Data Dictionary Views](https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/)
- [SQL JOIN Operations](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Joins.html)

---

**Created with ❤️ for Oracle Database Developers**

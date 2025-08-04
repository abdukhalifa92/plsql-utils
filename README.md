# Auto-Join View Creator

A powerful Oracle PL/SQL procedure that automatically creates database views by intelligently joining multiple tables based on foreign key relationships or common column names.

## Overview

The `create_auto_join_view` procedure eliminates the tedious task of manually writing complex JOIN statements by automatically detecting relationships between tables and generating optimized SQL views. It supports both foreign key-based joins and column name matching fallbacks.

## Features

- ✅ **Automatic Join Detection**: Discovers table relationships via foreign keys
- ✅ **Fallback Column Matching**: Uses common column names when FK relationships aren't found
- ✅ **Duplicate Column Handling**: Prevents duplicate columns in the final view
- ✅ **Schema Support**: Works with tables across different schemas
- ✅ **Dry Run Mode**: Preview generated SQL without executing
- ✅ **Intelligent Aliasing**: Auto-generates clean table aliases
- ✅ **Error Handling**: Comprehensive error reporting and validation

## Installation

1. Connect to your Oracle database as a user with `CREATE PROCEDURE` privileges
2. Execute the procedure code in your SQL client

```sql
-- Copy and paste the entire procedure code here
CREATE OR REPLACE PROCEDURE create_auto_join_view (...)
```

## Usage

### Basic Syntax

```sql
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('table1', 'table2', 'table3'),
    p_view_name  => 'my_joined_view',
    p_execute    => 'Y'  -- Optional: 'Y' to execute, 'N' to preview only
);
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `p_table_list` | `SYS.ODCIVARCHAR2LIST` | Yes | - | List of tables to join (supports schema.table format) |
| `p_view_name` | `VARCHAR2` | Yes | - | Name for the generated view |
| `p_execute` | `VARCHAR2` | No | `'Y'` | `'Y'` = Create view, `'N'` = Preview SQL only |

## Examples

### Example 1: Basic Join with Related Tables

```sql
-- Join customers, orders, and order_items tables
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('customers', 'orders', 'order_items'),
    p_view_name  => 'customer_order_summary'
);
```

**Generated Output:**
```sql
CREATE OR REPLACE VIEW customer_order_summary AS 
SELECT t1.customer_id, t1.customer_name, t1.email, 
       t2.order_id, t2.order_date, t2.total_amount,
       t3.item_id, t3.quantity, t3.unit_price
FROM "HR"."CUSTOMERS" t1 
JOIN "HR"."ORDERS" t2 ON t1.customer_id = t2.customer_id 
JOIN "HR"."ORDER_ITEMS" t3 ON t2.order_id = t3.order_id
```

### Example 2: Cross-Schema Join

```sql
-- Join tables from different schemas
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('hr.employees', 'sales.territories', 'finance.budgets'),
    p_view_name  => 'employee_territory_budget'
);
```

### Example 3: Preview Mode (Dry Run)

```sql
-- Preview the generated SQL without creating the view
EXEC create_auto_join_view(
    p_table_list => SYS.ODCIVARCHAR2LIST('products', 'categories', 'suppliers'),
    p_view_name  => 'product_catalog',
    p_execute    => 'N'
);
```

## How It Works

### 1. Join Detection Algorithm

The procedure uses a two-tier approach to find table relationships:

**Primary Method - Foreign Key Detection:**
- Queries `all_constraints` and `all_cons_columns` system views
- Identifies foreign key relationships between tables
- Generates JOIN conditions based on FK constraints

**Fallback Method - Column Name Matching:**
- When FK relationships aren't found, matches tables by common column names
- Useful for tables without formal FK constraints but logical relationships

### 2. Column Selection Strategy

- Iterates through each table's columns via `all_tab_columns`
- Prevents duplicate columns using an internal tracking mechanism
- Prefixes columns with table aliases for clarity

### 3. SQL Generation Process

1. **Table Processing**: Processes tables in the order provided
2. **Alias Assignment**: Generates unique aliases (t1, t2, t3, etc.)
3. **Join Chain Building**: Sequentially joins each table to the existing chain
4. **SQL Assembly**: Combines SELECT, FROM, and JOIN clauses

## Output Format

The procedure provides detailed console output:

```
--------------------------------------
-- Generated View Script
--------------------------------------
CREATE OR REPLACE VIEW my_view AS SELECT ...
--------------------------------------
✅ View "my_view" created.
```

## Error Handling

The procedure includes comprehensive error handling:

- **Invalid table names**: Reports tables that don't exist
- **Missing permissions**: Handles access control issues
- **Circular references**: Prevents infinite join loops
- **No join conditions**: Reports when tables can't be related

## Prerequisites

- Oracle Database 11g or higher
- `SELECT` access to system views (`all_tab_columns`, `all_constraints`, etc.)
- `CREATE VIEW` privilege in target schema
- Tables must exist and be accessible

## Limitations

- Maximum of 999 tables per join (Oracle collection limit)
- View name must follow Oracle naming conventions
- Cannot handle self-joins or complex join logic
- Limited to equi-joins only

## Best Practices

1. **Test with Preview Mode**: Always use `p_execute => 'N'` first to review generated SQL
2. **Order Tables Logically**: Place the main/parent table first in the list
3. **Use Qualified Names**: Specify schema names for cross-schema joins
4. **Review Output**: Check the generated SQL for correctness before execution
5. **Index Considerations**: Ensure proper indexes exist on join columns

## Troubleshooting

### Common Issues

**No join condition found:**
```sql
-- Ensure tables have either:
-- 1. Foreign key relationships, OR
-- 2. Common column names
```

**Permission denied:**
```sql
-- Grant necessary privileges:
GRANT SELECT ON all_tab_columns TO your_user;
GRANT SELECT ON all_constraints TO your_user;
```

**View already exists:**
- The procedure uses `CREATE OR REPLACE`, so existing views will be overwritten

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Create an issue in this repository
- Include the complete error message
- Provide table structure examples when relevant

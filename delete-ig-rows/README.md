# 🗑️ Delete All Rows in Interactive Grid - APEX 24.2

> **Utility for deleting all rows in Oracle APEX Interactive Grid components**

This utility provides multiple approaches to delete all rows in an Interactive Grid in Oracle APEX 24.2, including client-side JavaScript methods and server-side PL/SQL procedures.

## 📋 Table of Contents

- [Client-Side JavaScript Solutions](#client-side-javascript-solutions)
- [Server-Side PL/SQL Solutions](#server-side-plsql-solutions)
- [Dynamic Action Implementation](#dynamic-action-implementation)
- [Process Implementation](#process-implementation)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)

## 🚀 Client-Side JavaScript Solutions

### Method 1: Using Interactive Grid API (Recommended)

```javascript
// Get the Interactive Grid region
var ig = apex.region('your_ig_static_id');
var model = ig.call('getViews').grid.model;

// Delete all records
model.forEach(function(record, index, id) {
    model.deleteRecord(id);
});

// Refresh the grid to reflect changes
ig.refresh();
```

### Method 2: Using APEX 24.2 Enhanced API

```javascript
// For APEX 24.2+ with enhanced Interactive Grid API
var ig = apex.region('your_ig_static_id');
var view = ig.call('getCurrentView');

// Select all rows
view.selectAll();

// Delete selected rows
ig.call('getActions').invoke('selection-delete');
```

### Method 3: Programmatic Row Selection and Deletion

```javascript
// Get all visible rows and delete them
var ig = apex.region('your_ig_static_id');
var model = ig.call('getViews').grid.model;
var records = [];

// Collect all record IDs
model.forEach(function(record, index, id) {
    records.push(id);
});

// Delete each record
records.forEach(function(id) {
    model.deleteRecord(id);
});

// Save changes if auto-save is disabled
// ig.call('getActions').invoke('save');
```

## 🔧 Server-Side PL/SQL Solutions

### Method 1: Direct Table Truncation

```sql
-- Use with caution - this removes ALL data permanently
PROCEDURE delete_all_ig_rows(p_table_name IN VARCHAR2) IS
BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM ' || p_table_name;
    COMMIT;
END delete_all_ig_rows;
```

### Method 2: Conditional Deletion with User Context

```sql
-- Safer approach with user/session filtering
PROCEDURE delete_user_ig_rows(
    p_table_name IN VARCHAR2,
    p_user_filter IN VARCHAR2 DEFAULT NULL
) IS
    l_sql VARCHAR2(4000);
BEGIN
    l_sql := 'DELETE FROM ' || p_table_name;
    
    IF p_user_filter IS NOT NULL THEN
        l_sql := l_sql || ' WHERE ' || p_user_filter;
    END IF;
    
    EXECUTE IMMEDIATE l_sql;
    COMMIT;
    
    -- Log the action
    apex_debug.message('Deleted rows from ' || p_table_name || 
                      ' for user: ' || apex_application.g_user);
END delete_user_ig_rows;
```

## ⚡ Dynamic Action Implementation

### Step-by-Step Setup

1. **Create a Dynamic Action**
   - Event: Click
   - Selection Type: Button
   - Button: Your delete button

2. **Add True Action**
   - Action: Execute JavaScript Code
   - Code: (Use one of the JavaScript methods above)

3. **Add Second True Action** (Optional)
   - Action: Refresh
   - Selection Type: Region
   - Region: Your Interactive Grid

### Complete Dynamic Action JavaScript

```javascript
// Complete solution with confirmation and error handling
var ig = apex.region('&IG_STATIC_ID.');

if (ig) {
    // Show confirmation dialog
    apex.message.confirm('Are you sure you want to delete all rows?', function(result) {
        if (result) {
            try {
                var model = ig.call('getViews').grid.model;
                var deletedCount = 0;
                
                // Count and delete all records
                model.forEach(function(record, index, id) {
                    model.deleteRecord(id);
                    deletedCount++;
                });
                
                // Show success message
                apex.message.showPageSuccess('Successfully deleted ' + deletedCount + ' rows.');
                
                // Refresh the grid
                ig.refresh();
                
            } catch (error) {
                apex.message.showErrors(['Error deleting rows: ' + error.message]);
            }
        }
    });
} else {
    apex.message.showErrors(['Interactive Grid region not found.']);
}
```

## 🔄 Process Implementation

### APEX Process Code

```sql
DECLARE
    l_count NUMBER := 0;
BEGIN
    -- Get count before deletion
    SELECT COUNT(*) INTO l_count FROM your_table_name;
    
    -- Delete all rows (modify WHERE clause as needed)
    DELETE FROM your_table_name 
    WHERE created_by = :APP_USER; -- Add appropriate filters
    
    -- Commit the changes
    COMMIT;
    
    -- Return success message
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'Successfully deleted ' || l_count || ' rows.');
    apex_json.close_object;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_json.open_object;
    apex_json.write('status', 'error');
    apex_json.write('message', 'Error: ' || SQLERRM);
    apex_json.close_object;
END;
```

## 📝 Usage Examples

### Example 1: Simple Delete Button

```javascript
// Add to button action or dynamic action
apex.region('emp_ig').call('getViews').grid.model.forEach(function(rec, idx, id) {
    apex.region('emp_ig').call('getViews').grid.model.deleteRecord(id);
});
```

### Example 2: With User Confirmation

```javascript
apex.message.confirm('Delete all rows?', function(result) {
    if (result) {
        var ig = apex.region('my_ig');
        var model = ig.call('getViews').grid.model;
        var ids = [];
        
        model.forEach(function(record, index, id) {
            ids.push(id);
        });
        
        ids.forEach(function(id) {
            model.deleteRecord(id);
        });
        
        apex.message.showPageSuccess('All rows deleted successfully.');
    }
});
```

### Example 3: AJAX Process Call

```javascript
apex.server.process('DELETE_ALL_ROWS', {}, {
    success: function(data) {
        if (data.status === 'success') {
            apex.message.showPageSuccess(data.message);
            apex.region('my_ig').refresh();
        } else {
            apex.message.showErrors([data.message]);
        }
    },
    error: function(xhr, status, error) {
        apex.message.showErrors(['AJAX Error: ' + error]);
    }
});
```

## ✅ Best Practices

### 1. **Always Confirm Before Deletion**
```javascript
apex.message.confirm('This will delete all rows. Continue?', function(result) {
    if (result) {
        // Perform deletion
    }
});
```

### 2. **Handle Errors Gracefully**
```javascript
try {
    // Deletion code
} catch (error) {
    apex.message.showErrors(['Error: ' + error.message]);
}
```

### 3. **Provide User Feedback**
```javascript
apex.message.showPageSuccess('Successfully deleted ' + count + ' rows.');
```

### 4. **Use Appropriate Filters**
```sql
-- Don't delete all data - use appropriate WHERE clauses
DELETE FROM my_table WHERE session_id = :APP_SESSION;
```

### 5. **Consider Performance**
- For large datasets, consider batch processing
- Use APEX collections for temporary data
- Implement proper indexing on filter columns

## 🔒 Security Considerations

1. **Validate User Permissions**: Ensure users can only delete their own data
2. **Use Bind Variables**: Prevent SQL injection in dynamic SQL
3. **Audit Trail**: Log deletion activities
4. **Backup Strategy**: Ensure data can be recovered if needed

## 🐛 Troubleshooting

### Common Issues:

1. **"Region not found" error**
   - Check the Static ID of your Interactive Grid
   - Ensure the region is rendered on the page

2. **"Model is undefined" error**
   - Verify the Interactive Grid is properly initialized
   - Check if the grid has data source

3. **Changes not persisting**
   - Ensure the Interactive Grid has a primary key
   - Check if auto-save is enabled or call save manually

### Debug Code:
```javascript
// Check if IG exists and has model
var ig = apex.region('your_ig_static_id');
console.log('IG exists:', !!ig);
console.log('Model exists:', !!ig.call('getViews').grid.model);
```

## 📚 Additional Resources

- [Oracle APEX 24.2 Documentation](https://docs.oracle.com/en/database/oracle/apex/)
- [Interactive Grid JavaScript API](https://docs.oracle.com/en/database/oracle/apex/24.2/aexjs/)
- [APEX Dynamic Actions Guide](https://docs.oracle.com/en/database/oracle/apex/24.2/htmdb/)
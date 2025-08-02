# 🚀 Quick Reference: Delete All Rows in Interactive Grid (APEX 24.2)

## 📌 Most Common Methods

### 1. **Simple JavaScript (Copy & Paste Ready)**

```javascript
// Replace 'your_ig_static_id' with your Interactive Grid's Static ID
var ig = apex.region('your_ig_static_id');
var model = ig.call('getViews').grid.model;

model.forEach(function(record, index, id) {
    model.deleteRecord(id);
});

ig.refresh();
apex.message.showPageSuccess('All rows deleted successfully.');
```

### 2. **With User Confirmation**

```javascript
apex.message.confirm('Delete all rows?', function(result) {
    if (result) {
        var ig = apex.region('your_ig_static_id');
        var model = ig.call('getViews').grid.model;
        
        model.forEach(function(record, index, id) {
            model.deleteRecord(id);
        });
        
        ig.refresh();
        apex.message.showPageSuccess('All rows deleted successfully.');
    }
});
```

### 3. **APEX 24.2 Enhanced Method**

```javascript
// Using the new selectAll and selection-delete actions
var ig = apex.region('your_ig_static_id');
var view = ig.call('getCurrentView');

view.selectAll();
ig.call('getActions').invoke('selection-delete');
```

### 4. **Server-Side APEX Process**

```sql
-- Create an APEX Process (Ajax Callback)
BEGIN
    DELETE FROM your_table_name 
    WHERE created_by = :APP_USER; -- Add appropriate filters
    
    COMMIT;
    
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'All rows deleted successfully');
    apex_json.close_object;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    apex_json.open_object;
    apex_json.write('status', 'error');
    apex_json.write('message', 'Error: ' || SQLERRM);
    apex_json.close_object;
END;
```

## 🔧 Dynamic Action Setup

### Step 1: Create Dynamic Action
- **Event:** Click
- **Selection Type:** Button
- **Button:** [Your Delete Button]

### Step 2: Add True Action
- **Action:** Execute JavaScript Code
- **Code:** Use any of the JavaScript methods above

### Step 3: Optional - Add Refresh Action
- **Action:** Refresh
- **Selection Type:** Region
- **Region:** [Your Interactive Grid]

## ⚡ Ready-to-Use Function

```javascript
function deleteAllIGRows(staticId) {
    apex.message.confirm('Are you sure you want to delete all rows?', function(result) {
        if (result) {
            try {
                var ig = apex.region(staticId);
                var model = ig.call('getViews').grid.model;
                var count = 0;
                
                model.forEach(function(record, index, id) {
                    model.deleteRecord(id);
                    count++;
                });
                
                ig.refresh();
                apex.message.showPageSuccess('Successfully deleted ' + count + ' rows.');
                
            } catch (error) {
                apex.message.showErrors(['Error: ' + error.message]);
            }
        }
    });
}

// Usage: deleteAllIGRows('my_ig_static_id');
```

## 🛡️ Important Notes

1. **Replace `your_ig_static_id`** with your actual Interactive Grid Static ID
2. **Always test in development** before using in production
3. **Consider user permissions** and data security
4. **Add appropriate WHERE clauses** for server-side deletions
5. **Backup your data** before implementing bulk deletions

## 🔍 Find Your Interactive Grid Static ID

1. Go to your APEX page
2. Select your Interactive Grid region
3. Look for **Static ID** in the region properties
4. If not set, create one (e.g., `emp_ig`, `data_grid`, etc.)

## 📞 Support

For more advanced scenarios, refer to the complete documentation in the main README file.
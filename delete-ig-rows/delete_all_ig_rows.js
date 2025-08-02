/**
 * Delete All Rows in Interactive Grid - APEX 24.2
 * 
 * Collection of JavaScript functions to delete all rows in Oracle APEX Interactive Grid
 * Compatible with APEX 24.2 and later versions
 * 
 * @author PL/SQL Utils
 * @version 1.0
 * @date 2024
 */

/**
 * Method 1: Simple delete all rows using Interactive Grid API
 * @param {string} staticId - Static ID of the Interactive Grid region
 */
function deleteAllIGRows(staticId) {
    try {
        var ig = apex.region(staticId);
        if (!ig) {
            apex.message.showErrors(['Interactive Grid region "' + staticId + '" not found.']);
            return false;
        }

        var model = ig.call('getViews').grid.model;
        var deletedCount = 0;

        // Delete all records
        model.forEach(function(record, index, id) {
            model.deleteRecord(id);
            deletedCount++;
        });

        // Refresh the grid
        ig.refresh();
        
        apex.message.showPageSuccess('Successfully deleted ' + deletedCount + ' rows.');
        return true;

    } catch (error) {
        apex.message.showErrors(['Error deleting rows: ' + error.message]);
        return false;
    }
}

/**
 * Method 2: Delete all rows with user confirmation
 * @param {string} staticId - Static ID of the Interactive Grid region
 * @param {string} confirmMessage - Custom confirmation message (optional)
 */
function deleteAllIGRowsWithConfirmation(staticId, confirmMessage) {
    var message = confirmMessage || 'Are you sure you want to delete all rows? This action cannot be undone.';
    
    apex.message.confirm(message, function(result) {
        if (result) {
            deleteAllIGRows(staticId);
        }
    });
}

/**
 * Method 3: Enhanced delete with batch processing for large datasets
 * @param {string} staticId - Static ID of the Interactive Grid region
 * @param {number} batchSize - Number of rows to process at once (default: 100)
 */
function deleteAllIGRowsBatch(staticId, batchSize) {
    batchSize = batchSize || 100;
    
    try {
        var ig = apex.region(staticId);
        if (!ig) {
            apex.message.showErrors(['Interactive Grid region "' + staticId + '" not found.']);
            return false;
        }

        var model = ig.call('getViews').grid.model;
        var allIds = [];
        var deletedCount = 0;

        // Collect all record IDs
        model.forEach(function(record, index, id) {
            allIds.push(id);
        });

        // Process in batches
        for (var i = 0; i < allIds.length; i += batchSize) {
            var batch = allIds.slice(i, i + batchSize);
            
            batch.forEach(function(id) {
                model.deleteRecord(id);
                deletedCount++;
            });
            
            // Small delay for large datasets to prevent browser freezing
            if (allIds.length > 1000 && i > 0) {
                setTimeout(function() {}, 10);
            }
        }

        // Refresh the grid
        ig.refresh();
        
        apex.message.showPageSuccess('Successfully deleted ' + deletedCount + ' rows.');
        return true;

    } catch (error) {
        apex.message.showErrors(['Error deleting rows: ' + error.message]);
        return false;
    }
}

/**
 * Method 4: APEX 24.2 Enhanced API using selectAll and selection-delete
 * @param {string} staticId - Static ID of the Interactive Grid region
 */
function deleteAllIGRowsAPEX242(staticId) {
    try {
        var ig = apex.region(staticId);
        if (!ig) {
            apex.message.showErrors(['Interactive Grid region "' + staticId + '" not found.']);
            return false;
        }

        // Get current view
        var view = ig.call('getCurrentView');
        
        // Select all rows
        view.selectAll();
        
        // Delete selected rows using APEX 24.2 enhanced API
        ig.call('getActions').invoke('selection-delete');
        
        apex.message.showPageSuccess('All rows have been deleted successfully.');
        return true;

    } catch (error) {
        apex.message.showErrors(['Error deleting rows: ' + error.message]);
        return false;
    }
}

/**
 * Method 5: Advanced delete with progress indicator
 * @param {string} staticId - Static ID of the Interactive Grid region
 * @param {boolean} showProgress - Whether to show progress indicator
 */
function deleteAllIGRowsWithProgress(staticId, showProgress) {
    showProgress = showProgress !== false; // Default to true
    
    apex.message.confirm('Are you sure you want to delete all rows?', function(result) {
        if (result) {
            try {
                var ig = apex.region(staticId);
                if (!ig) {
                    apex.message.showErrors(['Interactive Grid region "' + staticId + '" not found.']);
                    return false;
                }

                var model = ig.call('getViews').grid.model;
                var allIds = [];
                var deletedCount = 0;

                // Show loading indicator
                if (showProgress) {
                    apex.util.showSpinner();
                }

                // Collect all record IDs
                model.forEach(function(record, index, id) {
                    allIds.push(id);
                });

                // Delete records with progress updates
                allIds.forEach(function(id, index) {
                    model.deleteRecord(id);
                    deletedCount++;
                    
                    // Update progress for large datasets
                    if (showProgress && allIds.length > 50 && index % 50 === 0) {
                        var percent = Math.round((index / allIds.length) * 100);
                        console.log('Deletion progress: ' + percent + '%');
                    }
                });

                // Hide loading indicator
                if (showProgress) {
                    apex.util.hideSpinner();
                }

                // Refresh the grid
                ig.refresh();
                
                apex.message.showPageSuccess('Successfully deleted ' + deletedCount + ' rows.');
                return true;

            } catch (error) {
                if (showProgress) {
                    apex.util.hideSpinner();
                }
                apex.message.showErrors(['Error deleting rows: ' + error.message]);
                return false;
            }
        }
    });
}

/**
 * Method 6: Server-side deletion using AJAX process
 * @param {string} staticId - Static ID of the Interactive Grid region
 * @param {string} processName - Name of the APEX process to call
 * @param {object} additionalData - Additional data to send to process (optional)
 */
function deleteAllIGRowsServerSide(staticId, processName, additionalData) {
    additionalData = additionalData || {};
    
    apex.message.confirm('Are you sure you want to delete all rows?', function(result) {
        if (result) {
            apex.util.showSpinner();
            
            apex.server.process(processName, additionalData, {
                success: function(data) {
                    apex.util.hideSpinner();
                    
                    if (data.status === 'success') {
                        apex.message.showPageSuccess(data.message);
                        apex.region(staticId).refresh();
                    } else {
                        apex.message.showErrors([data.message]);
                    }
                },
                error: function(xhr, status, error) {
                    apex.util.hideSpinner();
                    apex.message.showErrors(['AJAX Error: ' + error]);
                },
                dataType: 'json'
            });
        }
    });
}

/**
 * Utility function: Check if Interactive Grid exists and is ready
 * @param {string} staticId - Static ID of the Interactive Grid region
 * @returns {boolean} - True if IG exists and is ready
 */
function checkIGExists(staticId) {
    try {
        var ig = apex.region(staticId);
        if (!ig) {
            console.log('Interactive Grid region "' + staticId + '" not found.');
            return false;
        }
        
        var model = ig.call('getViews').grid.model;
        if (!model) {
            console.log('Interactive Grid model not available.');
            return false;
        }
        
        console.log('Interactive Grid "' + staticId + '" is ready.');
        return true;
        
    } catch (error) {
        console.log('Error checking Interactive Grid: ' + error.message);
        return false;
    }
}

/**
 * Utility function: Get row count in Interactive Grid
 * @param {string} staticId - Static ID of the Interactive Grid region
 * @returns {number} - Number of rows in the grid
 */
function getIGRowCount(staticId) {
    try {
        var ig = apex.region(staticId);
        if (!ig) {
            return 0;
        }
        
        var model = ig.call('getViews').grid.model;
        var count = 0;
        
        model.forEach(function(record, index, id) {
            count++;
        });
        
        return count;
        
    } catch (error) {
        console.log('Error getting row count: ' + error.message);
        return 0;
    }
}

// Export functions for use in APEX Dynamic Actions or other contexts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        deleteAllIGRows: deleteAllIGRows,
        deleteAllIGRowsWithConfirmation: deleteAllIGRowsWithConfirmation,
        deleteAllIGRowsBatch: deleteAllIGRowsBatch,
        deleteAllIGRowsAPEX242: deleteAllIGRowsAPEX242,
        deleteAllIGRowsWithProgress: deleteAllIGRowsWithProgress,
        deleteAllIGRowsServerSide: deleteAllIGRowsServerSide,
        checkIGExists: checkIGExists,
        getIGRowCount: getIGRowCount
    };
}

/**
 * Example usage in APEX Dynamic Action:
 * 
 * // Simple usage
 * deleteAllIGRows('my_ig_static_id');
 * 
 * // With confirmation
 * deleteAllIGRowsWithConfirmation('my_ig_static_id');
 * 
 * // Using APEX 24.2 enhanced API
 * deleteAllIGRowsAPEX242('my_ig_static_id');
 * 
 * // With progress indicator
 * deleteAllIGRowsWithProgress('my_ig_static_id', true);
 * 
 * // Server-side deletion
 * deleteAllIGRowsServerSide('my_ig_static_id', 'DELETE_ALL_PROCESS');
 * 
 * // Check if IG is ready first
 * if (checkIGExists('my_ig_static_id')) {
 *     deleteAllIGRows('my_ig_static_id');
 * }
 */
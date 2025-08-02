# 📦 plsql-utils

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
![PL/SQL](https://img.shields.io/badge/oracle-plsql-blue.svg)
[![GitHub stars](https://img.shields.io/github/stars/abdukhalifa92/plsql-utils.svg?style=social)](https://github.com/abdukhalifa92/plsql-utils/stargazers)

> 🛠️ **Collection of useful PL/SQL functions and utilities for Oracle developers**

This repository provides reusable PL/SQL snippets for everyday Oracle tasks — from working with JSON and CLOBs to identifying MIME types, and more.

---

## 🧩 Included Utilities

| Utility              | Description                                                                        |
|----------------------|------------------------------------------------------------------------------------|
| `EXTRACT_JSON_VALUE` | Extracts the value of a specific key from a flat JSON string using regex          |
| `GET_MIMETYPE`       | Returns the appropriate MIME type for a given file extension                      |
| `PRINT_CLOB`         | Outputs large CLOB content safely using `DBMS_OUTPUT`                             |
| `DELETE_IG_ROWS`     | Delete all rows in Oracle APEX Interactive Grid (24.2+) with multiple methods     |

---

## 🚀 Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/abdukhalifa92/plsql-utils.git
Open any .sql file in your favorite PL/SQL editor.

Execute it in your Oracle environment (SQL*Plus, SQLcl, SQL Developer, APEX, etc.).

Start using the utility in your PL/SQL codebase.

## 🙌 Contribute
Found it useful? Want to improve or add your own utility?
Feel free to fork, enhance, and send a pull request!

## 📝 License
This project is licensed under the MIT License.

# 🧾 PRINT_CLOB

A PL/SQL utility procedure to safely print the contents of a `CLOB` variable to `DBMS_OUTPUT`.

---

## 🔍 Purpose

Oracle's `DBMS_OUTPUT.PUT_LINE` has a limit of 32,767 characters. If you want to display or debug CLOB content, this utility reads and prints it in manageable chunks.

---

## 💡 Features

- Splits and prints large CLOBs in `32,767`-character chunks
- Safe loop handling for any CLOB size
- Useful for debugging CLOB columns or outputs in Oracle APEX, logging, or scripts

---

## 📥 Input

| Parameter | Type | Description                  |
|-----------|------|------------------------------|
| `P_CLOB`  | CLOB | The CLOB you want to print   |

---

## ✅ Example Usage

```sql
DECLARE
   l_clob CLOB;
BEGIN
   -- Assign some large content
   l_clob := TO_CLOB('Line 1' || CHR(10) || RPAD('X', 50000, 'X'));

   -- Print it
   print_clob(l_clob);
END;
/
```

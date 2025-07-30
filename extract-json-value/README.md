# 📦 EXTRACT_JSON_VALUE

A simple PL/SQL function to extract string values from a flat JSON string using regular expressions.

---

## 🔍 Purpose

This function allows you to extract the value of a specific key from a JSON string without using Oracle's native JSON functions — making it useful for older versions of Oracle Database or lightweight parsing needs.

---

## 🧠 Function Definition

```sql
CREATE OR REPLACE FUNCTION EXTRACT_JSON_VALUE (
   P_JSON_STRING IN VARCHAR2,
   P_KEY         IN VARCHAR2
)
RETURN VARCHAR2
IS
   V_JSON_VALUE   VARCHAR2(1000);
BEGIN
   SELECT REGEXP_SUBSTR (
             REGEXP_SUBSTR (
                P_JSON_STRING,
                '"' || P_KEY || '"\s*:\s*("[^"]*")',
                1,
                1,
                NULL,
                1
             ),
             '[^"]+',
             1,
             1
          ) INTO V_JSON_VALUE
     FROM DUAL;

   RETURN V_JSON_VALUE;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;
```

## 📥 Parameters
Name	Type	Description
P_JSON_STRING	VARCHAR2	The JSON string to be parsed.
P_KEY	VARCHAR2	The key whose value to extract.

## 📤 Returns
VARCHAR2: The string value associated with the key, if found.

NULL: If the key is not found or if an error occurs (e.g., malformed JSON).


## 📘 Examples

### 🔹 Example 1: Extract a simple string value

```sql
SELECT EXTRACT_JSON_VALUE(
  '{"name": "Abdulrahman", "age": "33", "city": "Dubai"}',
  'city'
) AS value
FROM DUAL;

-- Result: 'Dubai'
```


### 🔹 Example 2: Key not found sql

```sql
SELECT EXTRACT_JSON_VALUE(
  '{"name": "Abdulrahman", "age": "33"}',
  'country'
) AS value
FROM DUAL;

-- Result: NULL
```


### 🔹 Example 3: Numeric value (not supported)

```sql
SELECT EXTRACT_JSON_VALUE(
  '{"age": 30}',
  'age'
) AS value
FROM DUAL;

-- Result: NULL
```



### 🔹 Example 4: Extract value with hyphenated key

```sql
SELECT EXTRACT_JSON_VALUE(
  '{"user-id": "U123", "status": "active"}',
  'user-id'
) AS value
FROM DUAL;

-- Result: 'U123'
```


### 🔹 Example 5:  Extract first name from full JSON

```sql
SELECT EXTRACT_JSON_VALUE(
  '{"first_name": "Abdulrahman", "last_name": "Khalifa"}',
  'first_name'
) AS value
FROM DUAL;

-- Result: 'Abdulrahman'
```


### 🔹 Example 6:   Key appears later in JSON

```sql
SELECT EXTRACT_JSON_VALUE(
  '{"a": "x", "b": "y", "target": "found"}',
  'target'
) AS value
FROM DUAL;

-- Result: 'found'
```


### 🔹 Example 7: JSON with whitespaces and tabs

```sql
SELECT EXTRACT_JSON_VALUE(
  '{ "name" :     "Abdulrahman",     "city" : "Cairo" }',
  'name'
) AS value
FROM DUAL;

-- Result: 'Abdulrahman'
```

## ⚠️ Limitations
Only extracts string values (enclosed in quotes).

Case-sensitive key matching.

No support for nested or complex JSON structures.

Does not handle arrays or numeric/boolean/null values.

## 🛠 Use Case
This function is ideal for lightweight JSON parsing in Oracle PL/SQL environments where:

You cannot rely on JSON_VALUE or JSON_EXISTS (e.g., older Oracle versions).

You only need to extract simple key-value pairs from a flat JSON string.

# 📄 GET_MIMETYPE
A PL/SQL utility function to determine the MIME type of a file based on its extension.

## 🔍 Purpose
This function maps a given file extension (like .jpg, .pdf, .xlsx, etc.) to its standard MIME type. It is useful when uploading or generating files and needing to correctly identify the Content-Type for HTTP headers, database records, etc.

## 📥 Input
p_file_extension – The file extension as VARCHAR2. It can be with or without the leading dot (e.g., .pdf or pdf).
## 📤 Output
Returns the corresponding MIME type as a VARCHAR2.
Returns 'text/plain' as a default for unknown extensions.
Returns NULL if an error occurs.
## ✅ Example Usage
BEGIN
   DBMS_OUTPUT.put_line(get_mimetype('.jpg'));   -- image/jpeg
   DBMS_OUTPUT.put_line(get_mimetype('xlsx'));   -- application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
   DBMS_OUTPUT.put_line(get_mimetype('unknown'));-- text/plain
END;
## 📌 Notes
Internally trims leading dot (.) and lowercases the extension for normalization.

Easily extendable using the CASE statement.

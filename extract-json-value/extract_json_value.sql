CREATE OR REPLACE FUNCTION EXTRACT_JSON_VALUE (P_JSON_STRING   IN VARCHAR2,
                                               P_KEY           IN VARCHAR2)
    RETURN VARCHAR2
IS
    V_JSON_VALUE   VARCHAR2 (1000);
BEGIN
    SELECT REGEXP_SUBSTR (REGEXP_SUBSTR (P_JSON_STRING,
                                         '"' || P_KEY || '"\s*:\s*("[^"]*")',
                                         1,
                                         1,
                                         NULL,
                                         1),
                          '[^"]+',
                          1,
                          1)
      INTO V_JSON_VALUE
      FROM DUAL;
    RETURN V_JSON_VALUE;
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN NULL;
END;

create or replace PROCEDURE PRINT_CLOB (P_CLOB IN CLOB)
   IS
      L_BUFFER   VARCHAR2 (32767);
      L_AMOUNT   BINARY_INTEGER := 32767;
      L_POSTION  INTEGER := 1;
   BEGIN
      --__________________________________________________________________________________________________--
      LOOP
         DBMS_LOB.READ (P_CLOB,
                        L_AMOUNT,
                        L_POSTION,
                        L_BUFFER);
         DBMS_OUTPUT.PUT_LINE (L_BUFFER);
         L_POSTION := L_POSTION + L_AMOUNT;
         EXIT WHEN L_POSTION > DBMS_LOB.GETLENGTH (P_CLOB);
      END LOOP;
   --__________________________________________________________________________________________________--
   END;

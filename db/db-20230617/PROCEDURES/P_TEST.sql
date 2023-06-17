--------------------------------------------------------
--  DDL for Procedure P_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "IGTP"."P_TEST" is 
begin 
   sys_p_global.seter('P_TEST','HOLA ORACLE');
end p_test; 

/

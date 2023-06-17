--------------------------------------------------------
--  DDL for Procedure XINSERTPARAMETER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "IGTP"."XINSERTPARAMETER" ( p_parameter varchar2, p_value varchar2 ) is  
begin 
    insert into database_parameters( parameter, value ) values( p_parameter, p_value );
end;    

/

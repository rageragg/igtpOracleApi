--------------------------------------------------------
--  DDL for Table table_database_parameters
--------------------------------------------------------
CREATE TABLE "IGTP"."DATABASE_PARAMETERS" (	
   "PARAMETER"    VARCHAR2(128 BYTE), 
   "VALUE"        VARCHAR2(256 BYTE)
) SEGMENT CREATION IMMEDIATE 
   PCTFREE 10 
   PCTUSED 40 
   INITRANS 1 
   MAXTRANS 255 
   NOCOMPRESS LOGGING
   STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 
      FREELIST GROUPS 1
      BUFFER_POOL DEFAULT 
      FLASH_CACHE DEFAULT 
      CELL_FLASH_CACHE DEFAULT
) TABLESPACE "TS_IGTP_DAT" ;

--------------------------------------------------------
--  DDL for Table ROUTE_LOCATIONS
--------------------------------------------------------

  CREATE TABLE "IGTP"."ROUTE_LOCATIONS" 
   (	"ID" NUMBER(8,0), 
	"ROUTE_ID" NUMBER(8,0), 
	"LOCATION_ID" NUMBER(8,0), 
	"DESCRIPTION" VARCHAR2(80 BYTE), 
	"USER_ID" NUMBER(8,0), 
	"CREATED_AT" DATE DEFAULT sysdate, 
	"UPDATED_AT" DATE DEFAULT sysdate
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 0 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TS_IGTP_DAT" ;

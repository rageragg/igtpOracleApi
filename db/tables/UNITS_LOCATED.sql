--------------------------------------------------------
--  DDL for Table UNITS_LOCATED
--------------------------------------------------------

  CREATE TABLE "IGTP"."UNITS_LOCATED" 
   (	"ID" NUMBER(20,0) GENERATED BY DEFAULT AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"LOCATED_IN_DATE" DATE DEFAULT sysdate, 
	"LOCATED_OUT_DATE" DATE, 
	"EMPLOYEE_ID" NUMBER(20,0), 
	"TRUCK_ID" NUMBER(20,0), 
	"TRAILER_ID" NUMBER(20,0), 
	"LOCATION_ID" NUMBER(20,0), 
	"K_STATUS" VARCHAR2(20 BYTE) DEFAULT 'AVAILABLE', 
	"NOTE" VARCHAR2(80 BYTE), 
	"USER_ID" NUMBER(20,0), 
	"CREATED_AT" DATE DEFAULT sysdate, 
	"UPDATED_AT" DATE DEFAULT sysdate
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 0 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE( INITIAL 65536 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TS_IGTP_DAT" ;

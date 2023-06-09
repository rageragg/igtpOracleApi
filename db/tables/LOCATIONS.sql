--------------------------------------------------------
--  DDL for Table LOCATIONS
--------------------------------------------------------

  CREATE TABLE "IGTP"."LOCATIONS" 
   (	"ID" NUMBER(8,0), 
	"LOCATION_CO" VARCHAR2(10 BYTE), 
	"DESCRIPTION" VARCHAR2(80 BYTE), 
	"POSTAL_CO" VARCHAR2(10 BYTE), 
	"CITY_ID" NUMBER(8,0), 
	"NU_GPS_LAT" NUMBER(8,4), 
	"NU_GPS_LON" NUMBER(8,4), 
	"UUID" VARCHAR2(60 BYTE), 
	"SLUG" VARCHAR2(60 BYTE), 
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

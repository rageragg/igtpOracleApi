--------------------------------------------------------
--  DDL for Table PARTNERS
--------------------------------------------------------

  CREATE TABLE "IGTP"."PARTNERS" 
   (	"ID" NUMBER(20,0) GENERATED BY DEFAULT AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"PARTNER_CO" VARCHAR2(10 BYTE), 
	"DESCRIPTION" VARCHAR2(80 BYTE), 
	"ADDRESS" VARCHAR2(250 BYTE), 
	"TELEFONE_CO" VARCHAR2(50 BYTE), 
	"FAX_CO" VARCHAR2(50 BYTE), 
	"EMAIL_CO" VARCHAR2(60 BYTE), 
	"FISCAL_DOCUMENT_CO" VARCHAR2(20 BYTE), 
	"NAME_CONTACT" VARCHAR2(60 BYTE), 
	"TELEPHONE_CONTACT" VARCHAR2(60 BYTE), 
	"EMAIL_CONTACT" VARCHAR2(60 BYTE), 
	"LOCATION_ID" NUMBER(20,0), 
	"USER_ID" NUMBER(20,0), 
	"CREATED_AT" DATE DEFAULT sysdate, 
	"UPDATED_AT" DATE DEFAULT sysdate
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 0 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TS_IGTP_DAT" ;

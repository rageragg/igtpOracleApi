--------------------------------------------------------
--  DDL for Table SUBSIDIARIES
--------------------------------------------------------

CREATE TABLE "IGTP"."SUBSIDIARIES"(	
   "ID"              NUMBER(8,0), 
   "SUBSIDIARY_CO"   VARCHAR2(10 BYTE), 
   "CUSTOMER_ID"     NUMBER(8,0), 
   "SHOP_ID"         NUMBER(8,0), 
   "USER_ID"         NUMBER(8,0), 
   "UUID"            VARCHAR2(60 BYTE), 
   "SLUG"            VARCHAR2(60 BYTE), 
   "CREATED_AT"      DATE DEFAULT sysdate, 
   "UPDATED_AT"      DATE DEFAULT sysdate
) 
SEGMENT CREATION IMMEDIATE 
   PCTFREE 10 
   PCTUSED 0 
   INITRANS 1 
   MAXTRANS 255 
   NOCOMPRESS LOGGING
   STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 FREELIST GROUPS 1
      BUFFER_POOL DEFAULT 
      FLASH_CACHE DEFAULT 
      CELL_FLASH_CACHE DEFAULT
   )
   TABLESPACE "TS_IGTP_DAT" ;

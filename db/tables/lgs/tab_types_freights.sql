--------------------------------------------------------
--  DDL for Table TYPE_FREIGHTS
--------------------------------------------------------

CREATE TABLE "IGTP"."TYPE_FREIGHTS" (	
   "ID"                 NUMBER(8,0) DEFAULT IGTP.TYPE_FREIGHTS_SEQ.NEXTVAL, 
   "TYPE_FREIGHT_CO"    VARCHAR2(5 BYTE), 
   "DESCRIPTION"        VARCHAR2(80 BYTE), 
   "K_MULTI_LOAD"       CHAR(1 BYTE) DEFAULT 'N', 
   "K_MULTI_DELIVERY"   CHAR(1 BYTE) DEFAULT 'N', 
   "USER_ID"            NUMBER(8,0), 
   "CREATED_AT"         DATE DEFAULT sysdate, 
   "UPDATED_AT"         DATE DEFAULT sysdate
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
      FREELISTS 1 
      FREELIST GROUPS 1
      BUFFER_POOL DEFAULT 
      FLASH_CACHE DEFAULT 
      CELL_FLASH_CACHE DEFAULT
   )
   TABLESPACE "TS_IGTP_DAT" ;
--------------------------------------------------------
--  DDL for Table PROVINCES
--------------------------------------------------------

CREATE TABLE "IGTP"."PROVINCES"(	
   "ID"           NUMBER(8,0) DEFAULT IGTP.PROVINCES_SEQ.NEXTVAL, 
	"PROVINCE_CO"  VARCHAR2(10 BYTE), 
	"DESCRIPTION"  VARCHAR2(80 BYTE), 
	"SLUG"         VARCHAR2(60 BYTE), 
	"UUID"         VARCHAR2(60 BYTE), 
	"REGION_ID"    NUMBER(8,0), 
	"USER_ID"      NUMBER(8,0), 
	"CREATED_AT"   DATE DEFAULT sysdate, 
	"UPDATED_AT"   DATE DEFAULT sysdate
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

COMMENT ON TABLE "IGTP"."PROVINCES"  IS 'Provincias de una region';
COMMENT ON COLUMN "IGTP"."PROVINCES"."ID" IS 'Identificador correlativo unico';
COMMENT ON COLUMN "IGTP"."PROVINCES"."PROVINCE_CO" IS 'Codigo externo';
COMMENT ON COLUMN "IGTP"."PROVINCES"."DESCRIPTION" IS 'Descripcion de la provincia';
COMMENT ON COLUMN "IGTP"."PROVINCES"."SLUG" IS 'Identificativo de URL';
COMMENT ON COLUMN "IGTP"."PROVINCES"."UUID" IS 'Identificador unico y universal';
COMMENT ON COLUMN "IGTP"."PROVINCES"."USER_ID" IS 'Usuario que actualiza el registro';
COMMENT ON COLUMN "IGTP"."PROVINCES"."CREATED_AT" IS 'Fecha que se creo el registro';
COMMENT ON COLUMN "IGTP"."PROVINCES"."UPDATED_AT" IS 'Fecha que se actualizo el registro';

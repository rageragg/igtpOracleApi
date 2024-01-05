--------------------------------------------------------
--  DDL for Table REGIONS
--------------------------------------------------------

CREATE TABLE "IGTP"."REGIONS" (	
   "ID"           NUMBER(8,0) DEFAULT IGTP.REGIONS_SEQ.NEXTVAL, 
   "REGION_CO"    VARCHAR2(10 BYTE), 
	"DESCRIPTION"  VARCHAR2(80 BYTE), 
	"COUNTRY_ID"   NUMBER(8,0), 
	"UUID"         VARCHAR2(60 BYTE), 
	"SLUG"         VARCHAR2(60 BYTE), 
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
      BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
   )
   TABLESPACE "TS_IGTP_DAT" ;

   COMMENT ON TABLE "IGTP"."REGIONS"  IS 'Regiones';
   COMMENT ON COLUMN "IGTP"."REGIONS"."ID" IS 'Identificador correlativo unico';
   COMMENT ON COLUMN "IGTP"."REGIONS"."REGION_CO" IS 'Codigo externo de la region';
   COMMENT ON COLUMN "IGTP"."REGIONS"."DESCRIPTION" IS 'Descripcion de la Region';
   COMMENT ON COLUMN "IGTP"."REGIONS"."COUNTRY_ID" IS 'Identificador del pais al que pertenece';
   COMMENT ON COLUMN "IGTP"."REGIONS"."UUID" IS 'Codigo Unico Universal';
   COMMENT ON COLUMN "IGTP"."REGIONS"."SLUG" IS 'Identificativo de URL';
   COMMENT ON COLUMN "IGTP"."REGIONS"."USER_ID" IS 'Usuario que actualiza el registro';
   COMMENT ON COLUMN "IGTP"."REGIONS"."CREATED_AT" IS 'Fecha que se creo el registro';
   COMMENT ON COLUMN "IGTP"."REGIONS"."UPDATED_AT" IS 'Fecha que se actualizo el registro';

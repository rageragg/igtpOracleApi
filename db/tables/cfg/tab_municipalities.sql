--------------------------------------------------------
--  DDL for Table MUNICIPALITIES
--------------------------------------------------------

CREATE TABLE "IGTP"."MUNICIPALITIES"(	
   "ID"              NUMBER(8,0) DEFAULT IGTP.MUNICIPALITIES_SEQ.NEXTVAL,  
   "MUNICIPALITY_CO" VARCHAR2(10 BYTE), 
   "DESCRIPTION"     VARCHAR2(80 BYTE), 
   "PROVINCE_ID"     NUMBER(8,0), 
   "SLUG"            VARCHAR2(60 BYTE), 
   "UUID"            VARCHAR2(60 BYTE), 
   "USER_ID"         NUMBER(8,0), 
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
      FREELISTS 1 
      FREELIST GROUPS 1
      BUFFER_POOL DEFAULT 
      FLASH_CACHE DEFAULT 
      CELL_FLASH_CACHE DEFAULT
   )
   TABLESPACE "TS_IGTP_DAT" ;

COMMENT ON TABLE "IGTP"."MUNICIPALITIES"  IS 'Provincias de una region';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."ID" IS 'Identificador correlativo unico';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."MUNICIPALITY_CO" IS 'Codigo de la Municipalidad';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."DESCRIPTION" IS 'Descripcion de la Municipalidad';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."PROVINCE_ID" IS 'Identificador de la provincia a que pertenece';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."SLUG" IS 'Identificativo de URL';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."UUID" IS 'Codigo Unico Universal';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."USER_ID" IS 'Usuario que actualiza el registro';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."CREATED_AT" IS 'Fecha que se creo el registro';
COMMENT ON COLUMN "IGTP"."MUNICIPALITIES"."UPDATED_AT" IS 'Fecha que se actualizo el registro';

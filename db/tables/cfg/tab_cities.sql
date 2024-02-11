--------------------------------------------------------
--  DDL for Table CITIES
--------------------------------------------------------

CREATE TABLE "IGTP"."CITIES" (	
   "ID"              NUMBER(8,0) DEFAULT IGTP.CITIES_SEQ.NEXTVAL, 
   "CITY_CO"         VARCHAR2(10 BYTE), 
   "DESCRIPTION"     VARCHAR2(80 BYTE), 
   "MUNICIPALITY_ID" NUMBER(8,0), 
   "POSTAL_CO"       VARCHAR2(10 BYTE), 
   "TELEPHONE_CO"    VARCHAR2(3 BYTE), 
   "SLUG"            VARCHAR2(60 BYTE), 
   "UUID"            VARCHAR2(60 BYTE), 
   "NU_GPS_LAT"      NUMBER(8,4), 
   "NU_GPS_LON"      NUMBER(8,4),
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

COMMENT ON TABLE "IGTP"."CITIES"  IS 'Ciudades';
COMMENT ON COLUMN "IGTP"."CITIES"."ID" IS 'Identificador correlativo unico';
COMMENT ON COLUMN "IGTP"."CITIES"."CITY_CO" IS 'Codigo de la ciudad';
COMMENT ON COLUMN "IGTP"."CITIES"."DESCRIPTION" IS 'Descripcion o nombre de la ciudad';
COMMENT ON COLUMN "IGTP"."CITIES"."MUNICIPALITY_ID" IS 'Codigo de la Municipalidad';
COMMENT ON COLUMN "IGTP"."CITIES"."POSTAL_CO" IS 'Codigo Postal';
COMMENT ON COLUMN "IGTP"."CITIES"."TELEPHONE_CO" IS 'Codigo discal telefonico';
COMMENT ON COLUMN "IGTP"."CITIES"."SLUG" IS 'Forma especifica un lugar determinado de una pagina Web';
COMMENT ON COLUMN "IGTP"."CITIES"."UUID" IS 'Identificador unico de la base de datos';
COMMENT ON COLUMN "IGTP"."CITIES"."USER_ID" IS 'Usuario que ha creado el registro';
COMMENT ON COLUMN "IGTP"."CITIES"."CREATED_AT" IS 'Fecha de Creacion del registro';
COMMENT ON COLUMN "IGTP"."CITIES"."UPDATED_AT" IS 'Fecha de Actualizacion del registro';

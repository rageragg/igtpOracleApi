--------------------------------------------------------
--  DDL for Table LANGUAGES
--------------------------------------------------------

CREATE TABLE "IGTP"."LANGUAGES" 
(	
    "ID"			NUMBER(8,0) DEFAULT IGTP.LANGUAGES_SEQ.NEXTVAL,
	"LANGUAGE_CO" 	VARCHAR2(3 BYTE), 
	"DESCRIPTION" 	VARCHAR2(80 BYTE), 
	"DICCIONARY"	CLOB,
	"CREATED_AT" 	DATE DEFAULT sysdate, 
	"UPDATED_AT" 	DATE DEFAULT sysdate
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
--
COMMENT ON TABLE "IGTP"."LANGUAGES"  IS 'Tabla de lenguajes de mensajeria del sistema de eventos';
--
COMMENT ON COLUMN "IGTP"."LANGUAGES"."ID" IS 'Indetificador del lenguaje';
COMMENT ON COLUMN "IGTP"."LANGUAGES"."DESCRIPTION" IS 'Descripcion del lenguaje';
COMMENT ON COLUMN "IGTP"."LANGUAGES"."DICCIONARY" IS 'Contenido JSON del diccionario';
COMMENT ON COLUMN "IGTP"."LANGUAGES"."CREATED_AT" IS 'Fecha de creacion';
COMMENT ON COLUMN "IGTP"."LANGUAGES"."UPDATED_AT" IS 'Fecha de actualizacion';

/

/*
	-- SAMPLES DATA JSON
	[
		{ "module": "modulo", "code": "20000", "description": "descripcion del error", "action": "accion a tomar" },
		{ "module": "modulo", "code": "20001", "description": "descripcion del error", "action": "accion a tomar" }
	]
	--
*/
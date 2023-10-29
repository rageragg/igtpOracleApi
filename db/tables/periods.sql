--------------------------------------------------------
--  DDL for Table PERIODS
--------------------------------------------------------

CREATE TABLE "IGTP"."PERIODS" 
(	
	"ID" 							NUMBER(8,0), 
	"PERIOD_CO" 			        VARCHAR2(6 BYTE), 
	"PERIOD_DESCRIPTION" 			VARCHAR2(80 BYTE), 
    "FROM_DATE"                     DATE,
    "TO_DATE"                       DATE,
	"CREATED_AT" 					DATE DEFAULT sysdate, 
	"UPDATED_AT" 					DATE DEFAULT sysdate
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

COMMENT ON TABLE "IGTP"."PERIODS"  IS 'Tabla de configuracion periodos de trabajos';

COMMENT ON COLUMN "IGTP"."PERIODS"."PERIOD_CO" IS 'Codigo de periodo';
COMMENT ON COLUMN "IGTP"."PERIODS"."PERIOD_DESCRIPTION" IS 'Descripcion de periodo';
COMMENT ON COLUMN "IGTP"."PERIODS"."FROM_DATE" IS 'Fecha que cubre el periodo desde';
COMMENT ON COLUMN "IGTP"."PERIODS"."TO_DATE" IS 'Fecha que cubre el periodo hasta';
COMMENT ON COLUMN "IGTP"."PERIODS"."CREATED_AT" IS 'Fecha de creacion';
COMMENT ON COLUMN "IGTP"."PERIODS"."UPDATED_AT" IS 'Fecha de actualizacion';
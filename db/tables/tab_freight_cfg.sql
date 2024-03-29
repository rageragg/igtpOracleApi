
--------------------------------------------------------
--  DDL for Table FREIGHT_CFG
--------------------------------------------------------
-- ! crear un codigo de configuracion o contrato, incluir indice y restriccion unica
CREATE TABLE "IGTP"."FREIGHT_CFG"(	
	"ID"                NUMBER(20,0) GENERATED BY DEFAULT AS IDENTITY 
                                     MINVALUE 1 
                                     MAXVALUE 9999999999999999999999999999 
                                     INCREMENT BY 1 
                                     START WITH 1 
                                     CACHE 20 
                                     NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"CUSTOMER_ID"       NUMBER(20,0), 
	"ROUTE_ID"          NUMBER(20,0), 
	"TYPE_CARGO_ID"     NUMBER(20,0), 
	"TYPE_VEHICLE_ID"   NUMBER(20,0), 
	"K_REGIMEN"         VARCHAR2(20 BYTE) DEFAULT 'FREIGHT', 
	"PRE-PROCCESS"      VARCHAR2(256 BYTE), 
	"POST-PROCCESS"     VARCHAR2(256 BYTE), 
	"USER_ID"           NUMBER(20,0), 
	"CREATED_AT"        DATE DEFAULT sysdate, 
	"UPDATED_AT"        DATE DEFAULT sysdate
) 
    SEGMENT CREATION DEFERRED 
    PCTFREE 10 
    PCTUSED 0 
    INITRANS 1 
    MAXTRANS 255 
    NOCOMPRESS LOGGING
    STORAGE( 
        INITIAL 65536 
        MINEXTENTS 1 
        MAXEXTENTS 2147483645
        PCTINCREASE 0
        BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
    )
    TABLESPACE "TS_IGTP_DAT" ;

--
-- se altera la tabla 
ALTER TABLE "IGTP"."FREIGHT_CFG"
    ADD "CONTRACT_CO"       VARCHAR2(08) NOT NULL;

ALTER TABLE "IGTP"."FREIGHT_CFG"
    ADD "TYPE_FREIGHT_ID" 	NUMBER(20,0) NOT NULL;

COMMENT ON TABLE "IGTP"."FREIGHT_CFG"  IS 'Configuracion de Fletes segun cada Cliente';

COMMENT ON COLUMN "IGTP"."FREIGHT_CFG"."ROUTE_ID" IS 'Codigo de Ruta';
COMMENT ON COLUMN "IGTP"."FREIGHT_CFG"."TYPE_CARGO_ID" IS 'Codigo de Tipo de Cargo';
COMMENT ON COLUMN "IGTP"."FREIGHT_CFG"."TYPE_VEHICLE_ID" IS 'Codigo de Tipo de Vehiculo';
COMMENT ON COLUMN "IGTP"."FREIGHT_CFG"."K_REGIMEN" IS 'Regimen de Viaje (FREIGHT,WEIGHT,DISTANCE,AMOUNT-MANIFEST)';
COMMENT ON COLUMN "IGTP"."FREIGHT_CFG"."PRE-PROCCESS" IS 'Nombre de Programa que se aplica luego de aplicar la configuracion';
COMMENT ON COLUMN "IGTP"."FREIGHT_CFG"."POST-PROCCESS" IS 'Nombre de Programa que se aplica luego de aplicar la configuracion';
--------------------------------------------------------
--  DDL for Table FREIGHTS
--------------------------------------------------------

CREATE TABLE "IGTP"."FREIGHTS" 
(	
	"ID" 				NUMBER(20,0) DEFAULT IGTP.FREIGHTS_SEQ.NEXTVAL, 
	"FREIGHT_CO" 		VARCHAR2(20 BYTE), 
	"CUSTOMER_ID" 		NUMBER(20,0), 
	"ROUTE_ID" 			NUMBER(20,0), 
	"TYPE_CARGO_ID" 	NUMBER(20,0), 
	"TYPE_VEHICLE_ID" 	NUMBER(20,0), 
	"TYPE_FREIGHT_ID" 	NUMBER(20,0),
	"K_REGIMEN" 		VARCHAR2(20 BYTE), 
	"UPLOAD_AT" 		DATE, 
	"START_AT" 			DATE, 
	"FINISH_AT" 		DATE, 
	"NOTES" 			VARCHAR2(80 BYTE), 
	"K_STATUS" 			VARCHAR2(20 BYTE), 
	"K_PROCESS" 		VARCHAR2(20 BYTE), 
	"USER_ID" 			NUMBER(20,0), 
	"CREATED_AT" 		DATE DEFAULT sysdate, 
	"UPDATED_AT" 		DATE DEFAULT sysdate
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
--
COMMENT ON TABLE "IGTP"."FREIGHTS"  					IS 'Viajes o Declaracion de Fletes';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."ID" 				IS 'Identificador unico';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."FREIGHT_CO" 		IS 'Codigo externo del flete';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."CUSTOMER_ID" 		IS 'Identificador del cliente que contrata el viaje';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."ROUTE_ID" 			IS 'Identificador de la Ruta';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."TYPE_CARGO_ID" 	IS 'Identificador del tipo de carga';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."TYPE_VEHICLE_ID" 	IS 'Identificador del tipo de vehiculo';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."K_REGIMEN" 		IS 'Regimen del viaje, este valor sirve para procesos';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."UPLOAD_AT" 		IS 'Fecha de carga planeada';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."START_AT" 			IS 'Fecha de inicio planeada';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."FINISH_AT" 		IS 'Fecha de finalizacion planeado';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."NOTES" 			IS 'Notas del flete';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."K_STATUS" 			IS 'Estado del flete';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."K_PROCESS" 		IS 'En que proceso se ubica el flete';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."TYPE_FREIGHT_ID" 	IS 'Tipo de Viaje';
COMMENT ON COLUMN "IGTP"."FREIGHTS"."VALUATION_CURRENCY_CO" IS 'Moneda de valoracion de flete';
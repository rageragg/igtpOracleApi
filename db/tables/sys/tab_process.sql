DROP TABLE "IGTP"."PROCESSES";
--
CREATE TABLE "IGTP"."PROCESSES"(
    "ID" 					NUMBER(8,0) DEFAULT IGTP.PROCESS_SEQ.NEXTVAL, 
    "PROCESS_CO" 			VARCHAR2(30 BYTE), 
	"DESCRIPTION"			VARCHAR2(80 BYTE),
	"K_EVENT_PROCESS" 		VARCHAR2(30 BYTE),
    "OBJECT_OF_PROCESS"     VARCHAR2(128 BYTE),
    "K_MCA_INH"				CHAR(01) DEFAULT 'N',
	"USER_ID" 				NUMBER(8,0), 
	"CREATED_AT" 			DATE DEFAULT sysdate, 
	"UPDATED_AT" 			DATE DEFAULT sysdate    
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
/
COMMENT ON TABLE "IGTP"."PROCESSES"  IS 'Procesos';
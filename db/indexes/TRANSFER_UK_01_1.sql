--------------------------------------------------------
--  DDL for Index TRANSFER_UK_01
--------------------------------------------------------

  CREATE UNIQUE INDEX "IGTP"."TRANSFER_UK_01" ON "IGTP"."TRANSFERS" ("FREIGHT_ID", "SECUENCE_NUMBER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "TS_IGTP_DAT" ;

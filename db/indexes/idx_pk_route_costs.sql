--------------------------------------------------------
--  DDL for Index ROUTE_COSTS
--------------------------------------------------------

CREATE UNIQUE INDEX "IGTP"."ROUTE_COSTS" 
  ON "IGTP"."ROUTE_COSTS" ("ID") 
  PCTFREE 10 
  INITRANS 2 
  MAXTRANS 255 
  COMPUTE STATISTICS 
  STORAGE( 
    INITIAL 65536 
    MINEXTENTS 1 
    MAXEXTENTS 2147483645
    PCTINCREASE 0
    BUFFER_POOL DEFAULT 
    FLASH_CACHE DEFAULT 
    CELL_FLASH_CACHE DEFAULT
  )
  TABLESPACE "TS_IGTP_IDX" ;

--------------------------------------------------------
--  DDL for Index ROUTE_COSTS_UK_00
--------------------------------------------------------

  CREATE UNIQUE INDEX "IGTP"."ROUTE_COSTS_UK_00" 
    ON "IGTP"."ROUTE_COSTS" ( "ROUTE_ID", "CUSTOMER_ID", "TYPE_CARGO_ID" ) 
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

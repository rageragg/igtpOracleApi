--------------------------------------------------------
--  DDL for Index index_cashier_movements_pk
--------------------------------------------------------

CREATE UNIQUE INDEX "IGTP"."CASHIER_MOVEMENTS_PK" 
    ON "IGTP"."CASHIER_MOVEMENTS" ("ID") 
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
) TABLESPACE "TS_IGTP_IDX" ;

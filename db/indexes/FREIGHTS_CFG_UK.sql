--------------------------------------------------------
--  DDL for Index FREIGHTS_UK
--------------------------------------------------------

CREATE UNIQUE INDEX "IGTP"."FREIGHT_CFG_UK_01" 
    ON "IGTP"."FREIGHT_CFG" (
        "CUSTOMER_ID", 
        "ROUTE_ID", 
        "TYPE_CARGO_ID", 
        "TYPE_VEHICLE_ID", "K_REGIMEN"
    ) 
    PCTFREE 10 
    INITRANS 2 
    MAXTRANS 255 
    COMPUTE STATISTICS 
    TABLESPACE "TS_IGTP_DAT" ;

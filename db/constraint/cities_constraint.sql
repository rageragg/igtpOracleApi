--------------------------------------------------------
--  Constraints for Table CITIES
--------------------------------------------------------

ALTER TABLE "IGTP"."CITIES" 
    MODIFY ("ID" NOT NULL ENABLE);
ALTER TABLE "IGTP"."CITIES" 
    ADD CONSTRAINT "CITIES_PK" 
    PRIMARY KEY ("ID")
    USING INDEX "IGTP"."CITIES_PK"  ENABLE;

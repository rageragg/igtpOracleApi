--------------------------------------------------------
--  Constraints for Table COUNTRIES
--------------------------------------------------------

ALTER TABLE "IGTP"."COUNTRIES" 
  ADD CONSTRAINT "COUNTRIES_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."COUNTRIES_PK"  ENABLE;

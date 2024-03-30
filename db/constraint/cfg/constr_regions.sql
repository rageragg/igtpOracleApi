--------------------------------------------------------
--  Constraints for Table REGIONS
--------------------------------------------------------

ALTER TABLE "IGTP"."REGIONS" 
  ADD CONSTRAINT "REGIONS_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."REGIONS_PK"  ENABLE;

ALTER TABLE "IGTP"."REGIONS" 
  ADD CONSTRAINT "REGIONS_UK_00" UNIQUE ("REGION_CO")
  USING INDEX "IGTP"."REGIONS_UK_00" ENABLE;

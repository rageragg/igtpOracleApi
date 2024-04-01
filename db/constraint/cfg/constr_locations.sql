--------------------------------------------------------
--  Constraints for Table LOCATIONS
--------------------------------------------------------

ALTER TABLE "IGTP"."LOCATIONS" 
  ADD CONSTRAINT "LOCATIONS_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."LOCATIONS_PK"  ENABLE;
--
ALTER TABLE "IGTP"."LOCATIONS" 
  ADD CONSTRAINT "LOCATIONS_UK_00" UNIQUE ("LOCATION_CO")
  USING INDEX "IGTP"."LOCATIONS_UK_00" ENABLE;
--
/
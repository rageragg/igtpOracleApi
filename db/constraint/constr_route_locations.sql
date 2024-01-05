--------------------------------------------------------
--  Constraints for Table ROUTE_LOCATIONS
--------------------------------------------------------

ALTER TABLE "IGTP"."ROUTE_LOCATIONS" 
  ADD CONSTRAINT "ROUTE_LOCATIONS_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."ROUTE_LOCATIONS_PK"  ENABLE;

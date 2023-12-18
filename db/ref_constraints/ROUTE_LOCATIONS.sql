--------------------------------------------------------
--  Ref Constraints for Table ROUTE_LOCATIONS
--------------------------------------------------------

  ALTER TABLE "IGTP"."ROUTE_LOCATIONS" 
    ADD CONSTRAINT "ROUTE_LOCATION_ROTE_FK" 
    FOREIGN KEY ("ROUTE_ID")
	  REFERENCES "IGTP"."ROUTES" ("ID") ENABLE;

  ALTER TABLE "IGTP"."ROUTE_LOCATIONS" 
    ADD CONSTRAINT "LOCATION_LOCATION_ROUTE__FK" 
    FOREIGN KEY ("LOCATION_ID")
	  REFERENCES "IGTP"."LOCATIONS" ("ID") ENABLE;

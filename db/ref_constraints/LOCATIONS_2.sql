--------------------------------------------------------
--  Ref Constraints for Table LOCATIONS
--------------------------------------------------------

  ALTER TABLE "IGTP"."LOCATIONS" ADD CONSTRAINT "CITIES_LOCATION_FK" FOREIGN KEY ("CITY_ID")
	  REFERENCES "IGTP"."CITIES" ("ID") ENABLE;

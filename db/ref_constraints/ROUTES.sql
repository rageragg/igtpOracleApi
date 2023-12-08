--------------------------------------------------------
--  Ref Constraints for Table ROUTES
--------------------------------------------------------

  ALTER TABLE "IGTP"."ROUTES" 
    ADD CONSTRAINT "CITY_FROM_ROUTE_FK" 
    FOREIGN KEY ("FROM_CITY_ID")
	  REFERENCES "IGTP"."CITIES" ("ID") ENABLE;

  ALTER TABLE "IGTP"."ROUTES" 
    ADD CONSTRAINT "CITY_TO_ROUTE_FK" 
    FOREIGN KEY ("TO_CITY_ID")
	  REFERENCES "IGTP"."CITIES" ("ID") ENABLE;

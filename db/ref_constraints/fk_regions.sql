--------------------------------------------------------
--  Ref Constraints for Table CITIES
--------------------------------------------------------

  ALTER TABLE "IGTP"."REGIONS" 
    ADD CONSTRAINT "COUNTRY_REGION_FK" 
    FOREIGN KEY ("COUNTRY_ID")
	  REFERENCES "IGTP"."COUNTRIES" ("ID") ENABLE;

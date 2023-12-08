--------------------------------------------------------
--  Ref Constraints for Table CUSTOMERS
--------------------------------------------------------

  ALTER TABLE "IGTP"."CUSTOMERS" 
    ADD CONSTRAINT "LOCATION_CUSTOMER_FK" 
    FOREIGN KEY ("LOCATION_ID")
	  REFERENCES "IGTP"."LOCATIONS" ("ID") ENABLE;

--------------------------------------------------------
--  Ref Constraints for Table SHOPS
--------------------------------------------------------

  ALTER TABLE "IGTP"."SHOPS" 
    ADD CONSTRAINT "LOCATION_SHOP_FK" 
    FOREIGN KEY ("LOCATION_ID")
	  REFERENCES "IGTP"."LOCATIONS" ("ID") ENABLE;

--------------------------------------------------------
--  Ref Constraints for Table SUBSIDIARIES
--------------------------------------------------------

  ALTER TABLE "IGTP"."SUBSIDIARIES" 
    ADD CONSTRAINT "SHOP_SUBSIDIARY_FK" 
    FOREIGN KEY ("SHOP_ID")
	  REFERENCES "IGTP"."SHOPS" ("ID") ENABLE;
  
  ALTER TABLE "IGTP"."SUBSIDIARIES" 
    ADD CONSTRAINT "CUSTOMER_SUBSIDIARY_FK" 
    FOREIGN KEY ("CUSTOMER_ID")
	  REFERENCES "IGTP"."CUSTOMERS" ("ID") ENABLE;

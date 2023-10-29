--------------------------------------------------------
--  Constraints for Table CUSTOMERS
--------------------------------------------------------

ALTER TABLE "IGTP"."CUSTOMERS" 
  ADD CONSTRAINT "CUSTOMERS_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."CUSTOMERS_PK"  ENABLE;
  
ALTER TABLE "IGTP"."CUSTOMERS" 
  ADD CONSTRAINT "TYPE_CUSTOMER_CHK" 
  CHECK ( k_type_customer IN ('F','D','M') ) ENABLE;
  
ALTER TABLE "IGTP"."CUSTOMERS" 
  ADD CONSTRAINT "CATEGORY_CO_CHK" 
  CHECK ( k_category_co IN ('A','B','C') ) ENABLE;

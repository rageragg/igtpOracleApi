--------------------------------------------------------
--  Constraints for Table SHOPS
--------------------------------------------------------

ALTER TABLE "IGTP"."SHOPS" 
  ADD CONSTRAINT "SHOPS_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."SHOPS_PK"  ENABLE;

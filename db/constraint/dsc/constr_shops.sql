--------------------------------------------------------
--  Constraints for Table SHOPS
--------------------------------------------------------

ALTER TABLE "IGTP"."SHOPS" 
  ADD CONSTRAINT "SHOPS_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."SHOPS_PK"  ENABLE;

ALTER TABLE "IGTP"."SHOPS" 
  ADD CONSTRAINT "SHOPS_UK_00" UNIQUE ("SHOP_CO")
  USING INDEX "IGTP"."SHOPS_UK_00" ENABLE;  


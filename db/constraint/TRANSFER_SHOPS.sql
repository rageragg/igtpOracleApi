--------------------------------------------------------
--  Constraints for Table TRANSFER_SHOPS
--------------------------------------------------------

  ALTER TABLE "IGTP"."TRANSFER_SHOPS" ADD CONSTRAINT "FREIGHT_SHOPS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."FREIGHT_SHOPS_PK"  ENABLE;

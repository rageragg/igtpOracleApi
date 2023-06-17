--------------------------------------------------------
--  Constraints for Table CASHIER_MOVEMENTS
--------------------------------------------------------

  ALTER TABLE "IGTP"."CASHIER_MOVEMENTS" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "IGTP"."CASHIER_MOVEMENTS" ADD CONSTRAINT "CASHIER_MOVEMENTS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."CASHIER_MOVEMENTS_PK"  ENABLE;

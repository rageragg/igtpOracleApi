--------------------------------------------------------
--  Constraints for Table TYPE_VEHICLES
--------------------------------------------------------

  ALTER TABLE "IGTP"."TYPE_VEHICLES" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "IGTP"."TYPE_VEHICLES" ADD CONSTRAINT "CHK_CLASS_TYPE_VEHICLES" CHECK (K_CLASS IN ('TRAILER','TRUCK')) ENABLE;
  ALTER TABLE "IGTP"."TYPE_VEHICLES" ADD CONSTRAINT "TYPE_VEHICLES_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."TYPE_VEHICLES_PK"  ENABLE;

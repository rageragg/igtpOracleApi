--------------------------------------------------------
--  Constraints for Table TYPE_FREIGHTS
--------------------------------------------------------

ALTER TABLE "IGTP"."TYPE_FREIGHTS" MODIFY ("ID" NOT NULL ENABLE);

ALTER TABLE "IGTP"."TYPE_FREIGHTS" 
  ADD CONSTRAINT "TYPE_FREIGHTS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."TYPE_FREIGHTS_PK" ENABLE;

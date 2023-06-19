--------------------------------------------------------
--  Constraints for Table PARTNERS
--------------------------------------------------------

  ALTER TABLE "IGTP"."PARTNERS" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "IGTP"."PARTNERS" ADD CONSTRAINT "PARTNERS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."PARTNERS_PK"  ENABLE;

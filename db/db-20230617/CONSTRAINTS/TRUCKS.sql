--------------------------------------------------------
--  Constraints for Table TRUCKS
--------------------------------------------------------

  ALTER TABLE "IGTP"."TRUCKS" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "IGTP"."TRUCKS" ADD CONSTRAINT "TRUCKS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."TRUCKS_PK"  ENABLE;

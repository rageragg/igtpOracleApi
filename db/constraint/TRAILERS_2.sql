--------------------------------------------------------
--  Constraints for Table TRAILERS
--------------------------------------------------------

  ALTER TABLE "IGTP"."TRAILERS" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "IGTP"."TRAILERS" ADD CONSTRAINT "TRAILERS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."TRAILERS_PK"  ENABLE;

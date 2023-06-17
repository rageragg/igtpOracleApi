--------------------------------------------------------
--  Constraints for Table ROUTES
--------------------------------------------------------

  ALTER TABLE "IGTP"."ROUTES" ADD CONSTRAINT "ROUTES_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."ROUTES_PK"  ENABLE;
  ALTER TABLE "IGTP"."ROUTES" ADD CONSTRAINT "LEVEL_CO_CHK" CHECK ( k_level_co IN ('A','B','C') ) ENABLE;

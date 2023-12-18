--------------------------------------------------------
--  Constraints for Table MUNICIPALITIES
--------------------------------------------------------

ALTER TABLE "IGTP"."MUNICIPALITIES" 
  ADD CONSTRAINT "MUNICIPALITIES_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."MUNICIPALITIES_PK"  ENABLE;

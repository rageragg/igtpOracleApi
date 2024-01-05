--------------------------------------------------------
--  Constraints for Table PROVINCES
--------------------------------------------------------

ALTER TABLE "IGTP"."PROVINCES" 
  ADD CONSTRAINT "PROVINCES_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."PROVINCES_PK"  ENABLE;

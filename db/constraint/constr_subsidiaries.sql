--------------------------------------------------------
--  Constraints for Table SUBSIDIARIES
--------------------------------------------------------

ALTER TABLE "IGTP"."SUBSIDIARIES" 
  ADD CONSTRAINT "SUBSIDIARIES_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."SUBSIDIARIES_PK"  ENABLE;

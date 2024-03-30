--------------------------------------------------------
--  Constraints for Table PROVINCES
--------------------------------------------------------

ALTER TABLE "IGTP"."PROVINCES" 
  ADD CONSTRAINT "PROVINCES_PK" 
  PRIMARY KEY ("ID")
  USING INDEX "IGTP"."PROVINCES_PK"  ENABLE;


ALTER TABLE "IGTP"."PROVINCES" 
  ADD CONSTRAINT "PROVINCES_UK_00" UNIQUE ("PROVINCE_CO")
  USING INDEX "IGTP"."PROVINCES_UK_00" ENABLE;

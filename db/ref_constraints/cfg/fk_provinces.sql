--------------------------------------------------------
--  Ref Constraints for Table PROVINCES
--------------------------------------------------------

ALTER TABLE "IGTP"."PROVINCES" 
  ADD CONSTRAINT "REGION_PROVINCE_FK" 
  FOREIGN KEY ("REGION_ID")
  REFERENCES "IGTP"."REGIONS" ("ID") ENABLE;

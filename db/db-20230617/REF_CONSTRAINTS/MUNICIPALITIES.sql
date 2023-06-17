--------------------------------------------------------
--  Ref Constraints for Table MUNICIPALITIES
--------------------------------------------------------

  ALTER TABLE "IGTP"."MUNICIPALITIES" ADD CONSTRAINT "PROVINCE_MUNICIPALITY_FK" FOREIGN KEY ("PROVINCE_ID")
	  REFERENCES "IGTP"."PROVINCES" ("ID") ENABLE;

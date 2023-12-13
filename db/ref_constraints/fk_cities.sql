--------------------------------------------------------
--  Ref Constraints for Table CITIES
--------------------------------------------------------

ALTER TABLE "IGTP"."CITIES" 
  ADD CONSTRAINT "MUNICIPALITY_CITIES_FK" 
  FOREIGN KEY ("MUNICIPALITY_ID")
  REFERENCES "IGTP"."MUNICIPALITIES" ("ID") ENABLE;

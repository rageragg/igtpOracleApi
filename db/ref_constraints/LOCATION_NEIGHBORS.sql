--------------------------------------------------------
--  Ref Constraints for Table LOCATION_NEIGHBORS
--------------------------------------------------------

  ALTER TABLE "IGTP"."LOCATION_NEIGHBORS" 
    ADD CONSTRAINT "LOCATION_NEIGHBORS_1_FK" 
    FOREIGN KEY ("LOCATION_ID")
	  REFERENCES "IGTP"."LOCATIONS" ("ID") ENABLE;

  ALTER TABLE "IGTP"."LOCATION_NEIGHBORS" 
    ADD CONSTRAINT "LOCATION_NEIGHBORS_2_FK" 
    FOREIGN KEY ("NEIGHBORS_ID")
	  REFERENCES "IGTP"."LOCATIONS" ("ID") ENABLE;

--------------------------------------------------------
--  Constraints for Table REGIONS
--------------------------------------------------------

ALTER TABLE "IGTP"."REGIONS" 
	ADD CONSTRAINT "REGIONS_PK" 
	PRIMARY KEY ("ID")
	USING INDEX "IGTP"."REGIONS_PK"  ENABLE;

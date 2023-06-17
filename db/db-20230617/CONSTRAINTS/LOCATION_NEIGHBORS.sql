--------------------------------------------------------
--  Constraints for Table LOCATION_NEIGHBORS
--------------------------------------------------------

  ALTER TABLE "IGTP"."LOCATION_NEIGHBORS" ADD CONSTRAINT "LOCATION_NEIGHBORS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."LOCATION_NEIGHBORS_PK"  ENABLE;
  ALTER TABLE "IGTP"."LOCATION_NEIGHBORS" ADD CONSTRAINT "COORD_CARD_CO_CHK" CHECK ( k_coord_card_co IN ( 1, 2, 3, 4, 5, 6, 7, 8) ) ENABLE;

--------------------------------------------------------
--  DDL for View V_LOCATION_NEIGHBORS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_LOCATION_NEIGHBORS" ("LOCATION_NEIGHBOR_ID", "LOCATION_ID", "LOCATION_CO", "LOCATION_DESC", "NU_GPS_LAT_CENTER", "NU_GPS_LON_CENTER", "NEIGHBORS_ID", "K_COORD_CARD_DESC", "NEIGHBORS_CO", "NEIGHBORS_DESC", "NU_GPS_LAT_COORD", "NU_GPS_LON_COORD") AS 
  SELECT a.id location_neighbor_id, 
       a.location_id,
       b.location_co,
       b.description location_desc,
       b.nu_gps_lat nu_gps_lat_center, 
       b.nu_gps_lon nu_gps_lon_center,
       a.neighbors_id,
       CASE a.k_coord_card_co 
            WHEN 1 THEN 'NORTE'
            WHEN 2 THEN 'NORESTE'
            WHEN 3 THEN 'ESTE'
            WHEN 4 THEN 'SURESTE'
            WHEN 5 THEN 'SUR'
            WHEN 6 THEN 'SUROESTE'
            WHEN 7 THEN 'OESTE'
            WHEN 8 THEN 'NOROESTE'
       END k_coord_card_desc,
       c.location_co neighbors_co,
       c.description neighbors_desc,
       c.nu_gps_lat nu_gps_lat_coord, 
       c.nu_gps_lon nu_gps_lon_coord
  FROM location_neighbors a
  JOIN locations b ON a.location_id = b.id
  JOIN locations c ON a.neighbors_id = c.id
;

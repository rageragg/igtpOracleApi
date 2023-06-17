--------------------------------------------------------
--  DDL for View V_LOCATION_ROUTE_POSITIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_LOCATION_ROUTE_POSITIONS" ("ID", "LOCATION_CO", "LOCATION_DESC", "NU_GPS_LAT", "NU_GPS_LON", "CITY_ID", "CITY_DESC", "K_POSITION", "ROUTE_ID", "ESTIMATED_TIME_HRS") AS 
  SELECT "ID","LOCATION_CO","LOCATION_DESC","NU_GPS_LAT","NU_GPS_LON","CITY_ID","CITY_DESC","K_POSITION","ROUTE_ID","ESTIMATED_TIME_HRS"
  FROM ( 
        SELECT a.id, a.location_co, a.description location_desc, 
               a.nu_gps_lat, a.nu_gps_lon,
               a.city_id, b.description city_desc,
               'I' k_position,
               c.id route_id,
               c.estimated_time_hrs
          From locations a
          JOIN cities b ON a.city_id = b.id
          JOIN routes c ON a.city_id = c.from_city_id
        UNION ALL
        SELECT a.id, a.location_co, a.description location_desc, 
               a.nu_gps_lat, a.nu_gps_lon,
               a.city_id, b.description city_desc,
               'F' k_position,
               c.id route_id,
               c.estimated_time_hrs
          FROM locations a
          JOIN cities b ON a.city_id = b.id
          Join routes c ON a.city_id = c.to_city_id
  )
;

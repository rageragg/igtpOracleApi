--------------------------------------------------------
--  DDL for View V_ROUTE_LOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_ROUTE_LOCATIONS" ("ID", "ROUTE_ID", "ROUTE_CO", "ROUTE_DESC", "LOCATION_ID", "LOCATION_CO", "LOCATION_DESC", "FROM_CITY_ID", "TO_CITY_ID", "K_POSITION", "NU_GPS_LAT", "NU_GPS_LON") AS 
  SELECT a.id, a.route_id, b.route_co, b.description route_desc,
       a.location_id, c.location_co, c.description location_desc,
       b.from_city_id, b.to_city_id,
       CASE WHEN b.from_city_id = c.city_id 
            THEN 'I'
            ELSE CASE WHEN b.to_city_id = c.city_id 
                      THEN 'F'
                      ELSE 'M'
                 END 
       END k_position,   
       c.nu_gps_lat,
       c.nu_gps_lon      
  FROM route_locations a
  JOIN routes b ON a.route_id = b.id
  JOIN locations c ON a.location_id = c.id
;

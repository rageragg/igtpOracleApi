--------------------------------------------------------
--  DDL for View V_LOCATION_CITIES
--------------------------------------------------------

CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_LOCATION_CITIES" (
  "LOCATION_ID", "LOCATION_CO", "LOCATION_DESC", 
  "POSTAL_CO", "SLUG", "UUID", 
  "CITY_DESC", "CITY_ID", "CITY_CO"
  ) AS 
  SELECT a.id location_id, a.location_co, a.description location_desc, a.postal_co, a.slug, a.uuid,
       b.description city_desc, b.id city_id, b.city_co
  FROM locations a
  JOIN cities b ON a.city_id = b.id
;

--------------------------------------------------------
--  DDL for View V_PROVINCES_REGIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_PROVINCES_REGIONS" ("PROVINCE_ID", "PROVINCE_DESC", "PROVINCE_CO", "SLUG", "REGION_ID", "REGION_CO", "REGION_DESC", "COUNTRY_ID", "COUNTRY_CO", "COUNTRY_DESC") AS 
  SELECT a.id province_id, a.description province_desc, a.province_co, 
       a.slug, a.region_id,
       b.region_co, b.description region_desc,
       b.country_id, c.country_co, c.description country_desc
  FROM igtp.provinces a
  JOIN igtp.regions b ON a.region_id = b.id
  JOIN igtp.countries c ON b.country_id = c.id
  ORDER BY b.description
;

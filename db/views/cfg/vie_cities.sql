--------------------------------------------------------
--  DDL for View V_CITIES
--------------------------------------------------------

CREATE OR REPLACE VIEW v_cities AS
SELECT a.id, a.city_co, a.description, a.postal_co,
       b.municipality_co,
       c.province_co
  FROM cities a
  INNER JOIN municipalities b ON a.municipality_id = b.id
  INNER JOIN provinces c ON b.province_id = c.id
  ORDER BY a.description;
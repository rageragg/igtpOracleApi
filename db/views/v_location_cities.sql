CREATE OR REPLACE VIEW v_location_cities AS
SELECT a.id location_id, a.location_co, a.description location_desc, a.postal_co, a.slug, a.uuid,
       b.description city_desc, b.id city_id, b.city_co
  FROM locations a
  JOIN cities b ON a.city_id = b.id;
CREATE OR REPLACE VIEW v_freights AS
SELECT a.id AS freight_id,
       a.freights_co,
       a.k_regimen,
       b.customer_co,
       b.description AS customer_desc,
       c.route_co,
       c.description AS roue_desc,
       c.distance_km,
       c.estimated_time_hrs,
       d.type_cargo_co,
       d.description AS type_cargo_desc,
       j.type_freight_co,
       a.upload_at,
       a.start_at,
       a.finish_at,
       a.k_status     
  FROM freights  a
  JOIN customers b ON a.customer_id = b.id
  JOIN routes   c ON a.route_id = c.id
  JOIN type_cargos d ON a.type_cargo_id = d.id
  JOIN type_freights j ON a.type_freight_id = j.id;
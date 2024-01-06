--------------------------------------------------------
--  DDL for View V_FREIGHTS
--------------------------------------------------------

CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_FREIGHTS" (
  "FREIGHT_ID", "FREIGHTS_CO", "K_REGIMEN", 
  "TYPE_FREIGHT_DESC", "CUSTOMER_CO", "CUSTOMER_DESC", 
  "ROUTE_CO", "ROUE_DESC", "DISTANCE_KM", 
  "ESTIMATED_TIME_HRS", "TYPE_CARGO_CO", "TYPE_CARGO_DESC", 
  "TYPE_FREIGHT_CO", "UPLOAD_AT", "START_AT", 
  "FINISH_AT", "K_STATUS"
) AS 
  SELECT a.id AS freight_id,
       a.freight_co,
       a.k_regimen,
       j.description AS type_freight_desc,
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
  JOIN type_freights j ON a.type_freight_id = j.id
;

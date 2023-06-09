--------------------------------------------------------
--  DDL for View V_TRANSFERS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_TRANSFERS" ("FREIGHT_ID", "FREIGHT_CO", "SECUENCE_NUMBER", "K_REGIMEN", "K_TYPE_TRANSFER", "CUSTOMER_CO", "CUSTOMER_DESC", "ROUTE_CO", "ROUE_DESC", "DISTANCE_KM", "ESTIMATED_TIME_HRS", "TYPE_CARGO_CO", "TYPE_CARGO_DESC", "TYPE_FREIGHT_CO", "PLANED_AT", "START_AT", "END_AT", "EMPLOYEE_CO", "EMPLOYEE_DESC", "TRAILER_CO", "TRUCK_CO", "K_STATUS") AS 
  SELECT a.id AS freight_id,
       a.freight_co,
       e.sequence_number secuence_number,
       a.k_regimen,
       e.k_type_transfer,
       b.customer_co,
       b.description AS customer_desc,
       c.route_co,
       c.description AS roue_desc,
       c.distance_km,
       c.estimated_time_hrs,
       d.type_cargo_co,
       d.description AS type_cargo_desc,
       j.type_freight_co,
       e.planed_at,
       e.start_at,
       e.end_at,
       i.employee_co,
       i.fullname employee_desc,
       g.trailer_co,
       h.truck_co,
       e.k_status     
  FROM freights  a
  JOIN customers b ON a.customer_id = b.id
  JOIN type_cargos d ON a.type_cargo_id = d.id
  JOIN transfers e ON a.id = e.freight_id
  JOIN routes   c ON e.route_id = c.id
  JOIN trailers g ON e.trailer_id = g.id
  JOIN trucks h ON e.truck_id = h.id
  JOIN employees i ON e.main_employee_id = i.id
  JOIN type_freights j ON a.type_freight_id = j.id
WHERE e.sequence_number = ( SELECT MAX(f.sequence_number) 
                              FROM transfers f
									  WHERE f.freight_id = a.id 	 
								  )
;

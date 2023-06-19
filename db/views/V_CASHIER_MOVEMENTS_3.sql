--------------------------------------------------------
--  DDL for View V_CASHIER_MOVEMENTS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_CASHIER_MOVEMENTS" ("ID", "CASHIER_ID", "MOVEMENT_AT", "MOVEMENT_CO", "MOVEMENT_REFERENCE", "TYPE_CASHIER_MOVEMENT_ID", "CASHIER_MOVEMENT_DE", "DEBIT", "CREDIT", "TRANSFER_ID", "TRANSFER_ORDER", "EMPLOYEE_ID", "EMPLOYEE_DE") AS 
  SELECT   a.id, a.cashier_id, movement_at, movement_co, a.movement_reference,
         a.type_cashier_movement_id,
         a.description cashier_movement_de,
         decode(b.k_sign, '+', ABS(a.amount), 0 ) debit,
         decode(b.k_sign, '-', ABS(a.amount), 0 ) credit,
         a.transfer_id,
         ( SELECT c.k_order 
             FROM igtp.transfers c 
             WHERE c.id = a.transfer_id 
         ) transfer_order,
         a.employee_id, 
         ( SELECT d.fullname 
             FROM igtp.employees  d 
             WHERE d.id = a.employee_id 
         ) employee_de
  FROM igtp.cashier_movements a
  JOIN igtp.type_cashier_movements b ON a.type_cashier_movement_id = b.id
;

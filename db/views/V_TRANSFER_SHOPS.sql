--------------------------------------------------------
--  DDL for View V_TRANSFER_SHOPS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_TRANSFER_SHOPS" ("FREIGHT_CO", "TRANSFER_ID", "SHOP_CO", "SHOP_DESC", "K_STATUS", "START_AT", "END_AT", "K_REPARTO", "DOCUMENT_REF", "TYPE_DOCUMENT_CO", "TYPE_DOCUMENT_DESC", "IMP_VALUE", "CURRENCY_CO", "RESPONSIBLE") AS 
  SELECT f.freight_co,
       a.transfer_id, b.shop_co, b.description shop_desc,
       c.k_status, c.start_at, c.end_at,
       a.k_reparto, a.document_ref, d.type_document_co, d.description type_document_desc,
       a.imp_value, a.currency_co,
       e.fullname responsible
  FROM transfer_shops a 
  JOIN shops b ON a.shop_id = b.id
  JOIN transfers c ON a.transfer_id = c.id
  JOIN type_documents d ON a.type_document_id = d.id
  JOIN employees e ON c.main_employee_id = e.id
  JOIN freights f ON c.freight_id = f.id
;

--------------------------------------------------------
--  DDL for View V_CUSTOMER_SHOPS
--------------------------------------------------------

  CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_CUSTOMER_SHOPS" ("CUSTOMER_ID", "CUSTOMER_CO", "DESC_CUSTOMER", "K_TYPE_CUSTOMER", "SUBSIDIARY_ID", "SHOP_ID", "SUBSIDIARY_CO", "SHOP_CO", "DESC_SHOP", "ADDRESS", "TELEPHONE_CO", "LOCATION_ID") AS 
  SELECT a.id customer_id, a.customer_co, a.description desc_customer, 
       a.k_type_customer,
       b.id subsidiary_id, b.shop_id, b.subsidiary_co,
       c.shop_co, c.description desc_shop, c.address, c.telephone_co, c.location_id
  FROM customers a
  JOIN subsidiaries b ON a.id = b.customer_id
  JOIN shops c ON b.shop_id = c.id
;

--------------------------------------------------------
--  DDL for View V_LOCATION_SHOPS
--------------------------------------------------------
CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_LOCATION_SHOPS" (
  "SHOP_CO", "SHOP_DESC", "NAME_CONTACT", 
  "EMAIL_CONTACT", "TELEPHONE_CONTACT", "LOCATION_CO", 
  "LOCATION_DESC", "CITY_CO", "CITY_DESC", 
  "POSTAL_CO"
  ) AS 
  SELECT a.shop_co, a.description shop_desc, a.name_contact, a.email_contact, a.telephone_contact,
       b.location_co, b.description location_desc,
       c.city_co, c.description city_desc, c.postal_co
  FROM shops a
  JOIN locations b ON a.location_id = b.id
  JOIN cities c ON b.city_id = c.id
;

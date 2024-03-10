create or replace package dsc_api_k_subsidiaries IS
    ---------------------------------------------------------------------------
    --  DDL for Package SUBSIDIARIES_API (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de
    --                                  subsidiaries
    ---------------------------------------------------------------------------

type dsc_api_k_subsidiaries_rec is record (
SUBSIDIARY_CO  SUBSIDIARIES.SUBSIDIARY_CO%type
,CREATED_AT  SUBSIDIARIES.CREATED_AT%type
,SHOP_ID  SUBSIDIARIES.SHOP_ID%type
,CUSTOMER_ID  SUBSIDIARIES.CUSTOMER_ID%type
,USER_ID  SUBSIDIARIES.USER_ID%type
,UPDATED_AT  SUBSIDIARIES.UPDATED_AT%type
,ID  SUBSIDIARIES.ID%type
,UUID  SUBSIDIARIES.UUID%type
,SLUG  SUBSIDIARIES.SLUG%type
);
type dsc_api_k_subsidiaries_tab is table of dsc_api_k_subsidiaries_rec;

-- insert
procedure ins (
p_SUBSIDIARY_CO in SUBSIDIARIES.SUBSIDIARY_CO%type default null 
,p_CREATED_AT in SUBSIDIARIES.CREATED_AT%type default null 
,p_SHOP_ID in SUBSIDIARIES.SHOP_ID%type default null 
,p_CUSTOMER_ID in SUBSIDIARIES.CUSTOMER_ID%type default null 
,p_USER_ID in SUBSIDIARIES.USER_ID%type default null 
,p_UPDATED_AT in SUBSIDIARIES.UPDATED_AT%type default null 
,p_ID in SUBSIDIARIES.ID%type
,p_UUID in SUBSIDIARIES.UUID%type default null 
,p_SLUG in SUBSIDIARIES.SLUG%type default null 
);
-- update
procedure upd (
p_SUBSIDIARY_CO in SUBSIDIARIES.SUBSIDIARY_CO%type default null 
,p_CREATED_AT in SUBSIDIARIES.CREATED_AT%type default null 
,p_SHOP_ID in SUBSIDIARIES.SHOP_ID%type default null 
,p_CUSTOMER_ID in SUBSIDIARIES.CUSTOMER_ID%type default null 
,p_USER_ID in SUBSIDIARIES.USER_ID%type default null 
,p_UPDATED_AT in SUBSIDIARIES.UPDATED_AT%type default null 
,p_ID in SUBSIDIARIES.ID%type
,p_UUID in SUBSIDIARIES.UUID%type default null 
,p_SLUG in SUBSIDIARIES.SLUG%type default null 
);
-- delete
procedure del (
p_ID in SUBSIDIARIES.ID%type
);
end dsc_api_k_subsidiaries;

/
create or replace package body dsc_api_k_subsidiaries
is
-- insert
procedure ins (
p_SUBSIDIARY_CO in SUBSIDIARIES.SUBSIDIARY_CO%type default null 
,p_CREATED_AT in SUBSIDIARIES.CREATED_AT%type default null 
,p_SHOP_ID in SUBSIDIARIES.SHOP_ID%type default null 
,p_CUSTOMER_ID in SUBSIDIARIES.CUSTOMER_ID%type default null 
,p_USER_ID in SUBSIDIARIES.USER_ID%type default null 
,p_UPDATED_AT in SUBSIDIARIES.UPDATED_AT%type default null 
,p_ID in SUBSIDIARIES.ID%type
,p_UUID in SUBSIDIARIES.UUID%type default null 
,p_SLUG in SUBSIDIARIES.SLUG%type default null 
) is
begin
insert into SUBSIDIARIES(
SUBSIDIARY_CO
,CREATED_AT
,SHOP_ID
,CUSTOMER_ID
,USER_ID
,UPDATED_AT
,ID
,UUID
,SLUG
) values (
p_SUBSIDIARY_CO
,p_CREATED_AT
,p_SHOP_ID
,p_CUSTOMER_ID
,p_USER_ID
,p_UPDATED_AT
,p_ID
,p_UUID
,p_SLUG
);end;
-- update
procedure upd (
p_SUBSIDIARY_CO in SUBSIDIARIES.SUBSIDIARY_CO%type default null 
,p_CREATED_AT in SUBSIDIARIES.CREATED_AT%type default null 
,p_SHOP_ID in SUBSIDIARIES.SHOP_ID%type default null 
,p_CUSTOMER_ID in SUBSIDIARIES.CUSTOMER_ID%type default null 
,p_USER_ID in SUBSIDIARIES.USER_ID%type default null 
,p_UPDATED_AT in SUBSIDIARIES.UPDATED_AT%type default null 
,p_ID in SUBSIDIARIES.ID%type
,p_UUID in SUBSIDIARIES.UUID%type default null 
,p_SLUG in SUBSIDIARIES.SLUG%type default null 
) is
begin
update SUBSIDIARIES set
SUBSIDIARY_CO = p_SUBSIDIARY_CO
,CREATED_AT = p_CREATED_AT
,SHOP_ID = p_SHOP_ID
,CUSTOMER_ID = p_CUSTOMER_ID
,USER_ID = p_USER_ID
,UPDATED_AT = p_UPDATED_AT
,UUID = p_UUID
,SLUG = p_SLUG
where ID = p_ID;
end;
-- del
procedure del (
p_ID in SUBSIDIARIES.ID%type
) is
begin
delete from SUBSIDIARIES
where ID = p_ID;
end;
end dsc_api_k_subsidiaries;

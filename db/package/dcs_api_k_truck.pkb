create or replace package body dcs_k_api_truck
is
-- insert
procedure ins (
p_EMPLOYEE_ID in TRUCKS.EMPLOYEE_ID%type default null 
,p_CREATED_AT in TRUCKS.CREATED_AT%type default null 
,p_USER_ID in TRUCKS.USER_ID%type default null 
,p_MODEL in TRUCKS.MODEL%type default null 
,p_TRUCK_CO in TRUCKS.TRUCK_CO%type default null 
,p_SERIAL_CHASSIS in TRUCKS.SERIAL_CHASSIS%type default null 
,p_SERIAL_ENGINE in TRUCKS.SERIAL_ENGINE%type default null 
,p_K_STATUS in TRUCKS.K_STATUS%type default null 
,p_YEAR in TRUCKS.YEAR%type default null 
,p_COLOR in TRUCKS.COLOR%type default null 
,p_TRANSFER_ID in TRUCKS.TRANSFER_ID%type default null 
,p_EXTERNAL_CO in TRUCKS.EXTERNAL_CO%type default null 
,p_TYPE_VEHICLE_ID in TRUCKS.TYPE_VEHICLE_ID%type default null 
,p_K_TYPE_GAS in TRUCKS.K_TYPE_GAS%type default null 
,p_LOCATION_ID in TRUCKS.LOCATION_ID%type default null 
,p_UPDATED_AT in TRUCKS.UPDATED_AT%type default null 
,p_ID in TRUCKS.ID%type
,p_PARTNER_ID in TRUCKS.PARTNER_ID%type default null 
) is
begin
insert into TRUCKS(
EMPLOYEE_ID
,CREATED_AT
,USER_ID
,MODEL
,TRUCK_CO
,SERIAL_CHASSIS
,SERIAL_ENGINE
,K_STATUS
,YEAR
,COLOR
,TRANSFER_ID
,EXTERNAL_CO
,TYPE_VEHICLE_ID
,K_TYPE_GAS
,LOCATION_ID
,UPDATED_AT
,ID
,PARTNER_ID
) values (
p_EMPLOYEE_ID
,p_CREATED_AT
,p_USER_ID
,p_MODEL
,p_TRUCK_CO
,p_SERIAL_CHASSIS
,p_SERIAL_ENGINE
,p_K_STATUS
,p_YEAR
,p_COLOR
,p_TRANSFER_ID
,p_EXTERNAL_CO
,p_TYPE_VEHICLE_ID
,p_K_TYPE_GAS
,p_LOCATION_ID
,p_UPDATED_AT
,p_ID
,p_PARTNER_ID
);end;
-- update
procedure upd (
p_EMPLOYEE_ID in TRUCKS.EMPLOYEE_ID%type default null 
,p_CREATED_AT in TRUCKS.CREATED_AT%type default null 
,p_USER_ID in TRUCKS.USER_ID%type default null 
,p_MODEL in TRUCKS.MODEL%type default null 
,p_TRUCK_CO in TRUCKS.TRUCK_CO%type default null 
,p_SERIAL_CHASSIS in TRUCKS.SERIAL_CHASSIS%type default null 
,p_SERIAL_ENGINE in TRUCKS.SERIAL_ENGINE%type default null 
,p_K_STATUS in TRUCKS.K_STATUS%type default null 
,p_YEAR in TRUCKS.YEAR%type default null 
,p_COLOR in TRUCKS.COLOR%type default null 
,p_TRANSFER_ID in TRUCKS.TRANSFER_ID%type default null 
,p_EXTERNAL_CO in TRUCKS.EXTERNAL_CO%type default null 
,p_TYPE_VEHICLE_ID in TRUCKS.TYPE_VEHICLE_ID%type default null 
,p_K_TYPE_GAS in TRUCKS.K_TYPE_GAS%type default null 
,p_LOCATION_ID in TRUCKS.LOCATION_ID%type default null 
,p_UPDATED_AT in TRUCKS.UPDATED_AT%type default null 
,p_ID in TRUCKS.ID%type
,p_PARTNER_ID in TRUCKS.PARTNER_ID%type default null 
) is
begin
update TRUCKS set
EMPLOYEE_ID = p_EMPLOYEE_ID
,CREATED_AT = p_CREATED_AT
,USER_ID = p_USER_ID
,MODEL = p_MODEL
,TRUCK_CO = p_TRUCK_CO
,SERIAL_CHASSIS = p_SERIAL_CHASSIS
,SERIAL_ENGINE = p_SERIAL_ENGINE
,K_STATUS = p_K_STATUS
,YEAR = p_YEAR
,COLOR = p_COLOR
,TRANSFER_ID = p_TRANSFER_ID
,EXTERNAL_CO = p_EXTERNAL_CO
,TYPE_VEHICLE_ID = p_TYPE_VEHICLE_ID
,K_TYPE_GAS = p_K_TYPE_GAS
,LOCATION_ID = p_LOCATION_ID
,UPDATED_AT = p_UPDATED_AT
,PARTNER_ID = p_PARTNER_ID
where ID = p_ID;
end;
-- del
procedure del (
p_ID in TRUCKS.ID%type
) is
begin
delete from TRUCKS
where ID = p_ID;
end;
end dcs_k_api_truck;

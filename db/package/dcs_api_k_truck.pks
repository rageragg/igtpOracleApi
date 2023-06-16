create or replace package dcs_k_api_truck
is

type TRUCKS_tapi_rec is record (
EMPLOYEE_ID  TRUCKS.EMPLOYEE_ID%type
,CREATED_AT  TRUCKS.CREATED_AT%type
,USER_ID  TRUCKS.USER_ID%type
,MODEL  TRUCKS.MODEL%type
,TRUCK_CO  TRUCKS.TRUCK_CO%type
,SERIAL_CHASSIS  TRUCKS.SERIAL_CHASSIS%type
,SERIAL_ENGINE  TRUCKS.SERIAL_ENGINE%type
,K_STATUS  TRUCKS.K_STATUS%type
,YEAR  TRUCKS.YEAR%type
,COLOR  TRUCKS.COLOR%type
,TRANSFER_ID  TRUCKS.TRANSFER_ID%type
,EXTERNAL_CO  TRUCKS.EXTERNAL_CO%type
,TYPE_VEHICLE_ID  TRUCKS.TYPE_VEHICLE_ID%type
,K_TYPE_GAS  TRUCKS.K_TYPE_GAS%type
,LOCATION_ID  TRUCKS.LOCATION_ID%type
,UPDATED_AT  TRUCKS.UPDATED_AT%type
,ID  TRUCKS.ID%type
,PARTNER_ID  TRUCKS.PARTNER_ID%type
);
type TRUCKS_tapi_tab is table of TRUCKS_tapi_rec;

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
);
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
);
-- delete
procedure del (
p_ID in TRUCKS.ID%type
);
end dcs_k_api_truck;
/
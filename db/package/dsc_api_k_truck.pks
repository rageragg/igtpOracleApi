--------------------------------------------------------
--  DDL for Package Body TRUCK_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE dsc_api_k_truck IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'TRUCKS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE trucks_api_tab IS TABLE OF trucks%ROWTYPE;
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN trucks.id%TYPE ) RETURN trucks%ROWTYPE;    
    --
    -- get DATA Array
    FUNCTION get_list RETURN trucks_api_tab;  
    --
    -- insert
    procedure ins (
        p_id                IN trucks.id%TYPE,
        p_truck_co          IN trucks.truck_co%TYPE DEFAULT NULL,
        p_external_co       IN trucks.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN trucks.type_vehicle_id%TYPE DEFAULT NULL, 
        p_k_type_gas        IN trucks.k_type_gas%TYPE DEFAULT 'DIESEL',
        p_year              IN trucks.year%TYPE DEFAULT NULL, 
        p_model             IN trucks.model%TYPE DEFAULT NULL,
        p_color             IN trucks.color%TYPE DEFAULT NULL, 
        p_serial_engine     IN trucks.serial_engine%TYPE DEFAULT NULL, 
        p_serial_chassis    IN trucks.serial_chassis%TYPE DEFAULT NULL, 
        p_k_status          IN trucks.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id        IN trucks.partner_id%TYPE DEFAULT NULL, 
        p_transfer_id       IN trucks.transfer_id%TYPE DEFAULT NULL, 
        p_employee_id       IN trucks.employee_id%TYPE DEFAULT NULL,
        p_location_id       IN trucks.location_id%TYPE DEFAULT NULL, 
        p_user_id           IN trucks.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN trucks.created_at%TYPE DEFAULT sysdate, 
        p_updated_at        IN trucks.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT trucks%ROWTYPE );
    --
    -- update
    procedure upd (
        p_id                IN trucks.id%TYPE,
        p_truck_co          IN trucks.truck_co%TYPE DEFAULT NULL,
        p_external_co       IN trucks.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN trucks.type_vehicle_id%TYPE DEFAULT NULL, 
        p_k_type_gas        IN trucks.k_type_gas%TYPE DEFAULT 'DIESEL',
        p_year              IN trucks.year%TYPE DEFAULT NULL, 
        p_model             IN trucks.model%TYPE DEFAULT NULL,
        p_color             IN trucks.color%TYPE DEFAULT NULL, 
        p_serial_engine     IN trucks.serial_engine%TYPE DEFAULT NULL, 
        p_serial_chassis    IN trucks.serial_chassis%TYPE DEFAULT NULL, 
        p_k_status          IN trucks.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id        IN trucks.partner_id%TYPE DEFAULT NULL, 
        p_transfer_id       IN trucks.transfer_id%TYPE DEFAULT NULL, 
        p_employee_id       IN trucks.employee_id%TYPE DEFAULT NULL,
        p_location_id       IN trucks.location_id%TYPE DEFAULT NULL, 
        p_user_id           IN trucks.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN trucks.created_at%TYPE DEFAULT NULL, 
        p_updated_at        IN trucks.updated_at%TYPE DEFAULT sysdate 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT trucks%ROWTYPE );
    --
    -- delete
    procedure del ( p_ID IN TRUCKS.ID%type  );
    --
end dsc_api_k_truck;
/
--------------------------------------------------------
--  DDL for Package DSC_API_K_TYP_VEHICLE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."DSC_API_K_TYP_VEHICLE" IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'TYPE_VEHICLES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE type_vehicles_api_tab IS TABLE OF type_vehicles%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN type_vehicles.id%TYPE ) RETURN type_vehicles%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_type_vehicle_co IN type_vehicles.type_vehicle_co%TYPE ) RETURN type_vehicles%ROWTYPE;       
    --
    -- get DATA Array
    FUNCTION get_list RETURN type_vehicles_api_tab;  
    --
    -- insert
    PROCEDURE ins (
        p_id                IN type_vehicles.id%TYPE,
        p_type_vehicle_co   IN type_vehicles.type_vehicle_co%TYPE DEFAULT NULL,
        p_description       IN type_vehicles.description%TYPE DEFAULT NULL,
        p_k_class           IN type_vehicles.k_class%TYPE DEFAULT NULL,
        p_k_active          IN type_vehicles.k_active%TYPE DEFAULT NULL,
        p_user_id           IN type_vehicles.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_vehicles.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_vehicles.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT type_vehicles%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN type_vehicles.id%TYPE,
        p_type_vehicle_co   IN type_vehicles.type_vehicle_co%TYPE DEFAULT NULL,
        p_description       IN type_vehicles.description%TYPE DEFAULT NULL,
        p_k_class           IN type_vehicles.k_class%TYPE DEFAULT NULL,
        p_k_active          IN type_vehicles.k_active%TYPE DEFAULT NULL,
        p_user_id           IN type_vehicles.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_vehicles.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_vehicles.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT type_vehicles%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_ID IN type_vehicles.ID%TYPE );
    --
END dsc_api_k_typ_vehicle;

/

--------------------------------------------------------
--  DDL for Package LOCATIONS_API
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE igtp.cfg_api_k_location IS 
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'LOCATIONS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE locations_api_tab IS  TABLE OF locations%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id in locations.id%TYPE ) RETURN locations%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_location_co in locations.location_co%TYPE ) RETURN locations%ROWTYPE;        
    --
    -- get DATA Array
    FUNCTION get_list RETURN locations_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id                IN locations.id%type,
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL, 
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_id           IN locations.city_id%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN locations.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN locations.nu_gps_lon%TYPE DEFAULT NULL, 
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL, 
        p_user_id           IN locations.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN locations.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN locations.updated_at%TYPE DEFAULT NULL
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT locations%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN locations.id%type,
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL, 
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_id           IN locations.city_id%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN locations.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN locations.nu_gps_lon%TYPE DEFAULT NULL, 
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL, 
        p_user_id           IN locations.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN locations.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN locations.updated_at%TYPE DEFAULT NULL
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT locations%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id  IN locations.id%TYPE );
    --
END cfg_api_k_location;

/

--------------------------------------------------------
--  DDL for Package CITIES_API
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE igtp.cfg_api_k_city IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'CITIES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE cities_api_tab IS TABLE OF cities%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN cities.id%TYPE ) RETURN cities%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_city_co IN cities.city_co%TYPE ) RETURN cities%ROWTYPE;
    --
    -- get DATA RETURN Array
    FUNCTION get_list RETURN cities_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id                IN cities.ID%TYPE,
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_id   IN cities.municipality_id%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_id           IN cities.user_id%TYPE DEFAULT NULL,
        p_created_at        IN cities.created_at%TYPE DEFAULT NULL, 
        p_updated_at        IN cities.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT cities%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN cities.id%TYPE,
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_id   IN cities.municipality_id%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_id           IN cities.user_id%TYPE DEFAULT NULL,
        p_created_at        IN cities.created_at%TYPE DEFAULT NULL, 
        p_updated_at        IN cities.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT cities%ROWTYPE );    
    --
    -- delete
    PROCEDURE del ( p_id in cities.id%TYPE );
    --
END cfg_api_k_city;
/

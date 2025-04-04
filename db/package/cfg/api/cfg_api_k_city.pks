CREATE OR REPLACE NONEDITIONABLE PACKAGE igtp.cfg_api_k_city IS
    ---------------------------------------------------------------------------
    --  DDL for Package CITIES_API
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    ---------------------------------------------------------------------------
    --
    K_PROCESS    CONSTANT VARCHAR2(20)  := 'CFG_API_K_CITY';
    K_OWNER      CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'CITIES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE cities_api_tab IS TABLE OF cities%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN cities%ROWTYPE;
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
        p_id                IN OUT cities.id%TYPE,
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_id   IN cities.municipality_id%TYPE DEFAULT NULL,
        p_population        IN cities.population%TYPE DEFAULT NULL,   
        p_uuid              IN OUT cities.uuid%TYPE,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_id           IN cities.user_id%TYPE DEFAULT NULL,
        p_created_at        IN OUT cities.created_at%TYPE, 
        p_updated_at        IN OUT cities.updated_at%TYPE 
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
        p_population        IN cities.population%TYPE DEFAULT NULL,
        p_uuid              IN OUT cities.uuid%TYPE,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_id           IN cities.user_id%TYPE DEFAULT NULL,
        p_created_at        IN OUT cities.created_at%TYPE, 
        p_updated_at        IN OUT cities.updated_at%TYPE 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT cities%ROWTYPE );    
    --
    -- delete
    PROCEDURE del ( p_id in cities.id%TYPE );
    --
    -- exist
    FUNCTION exist( p_id IN cities.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( p_city_co IN cities.city_co%TYPE ) RETURN BOOLEAN;
    --
END cfg_api_k_city;
/

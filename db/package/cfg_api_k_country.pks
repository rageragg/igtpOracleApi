---------------------------------------------------------------------------
--  DDL for Package COUNTRY API
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
---------------------------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE cfg_api_k_country
IS
    --
    K_PROCESS    CONSTANT VARCHAR2(20)  := 'CFG_API_K_COUNTRY';
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'COUNTRIES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE countries_api_tab IS TABLE OF countries%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN countries%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN countries.id%TYPE ) RETURN countries%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_country_co IN countries.country_co%TYPE ) RETURN countries%ROWTYPE;
    --
    -- get DATA RETURN Array
    FUNCTION get_list RETURN countries_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id            IN countries.id%TYPE,
        p_country_co    IN countries.country_co%TYPE DEFAULT NULL, 
        p_description   IN countries.description%TYPE DEFAULT NULL, 
        p_path_image    IN countries.path_image%TYPE DEFAULT NULL, 
        p_telephone_co  IN countries.telephone_co%TYPE DEFAULT NULL, 
        p_user_id       IN countries.user_id%TYPE DEFAULT NULL, 
        p_slug          IN countries.slug%TYPE DEFAULT NULL, 
        p_uuid          IN countries.uuid%TYPE DEFAULT NULL, 
        p_created_at    IN countries.created_at%TYPE DEFAULT NULL, 
        p_updated_at    IN countries.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT countries%ROWTYPE );
    --
    -- update
    procedure upd (
        p_id            IN countries.id%TYPE,
        p_country_co    IN countries.country_co%TYPE DEFAULT NULL, 
        p_description   IN countries.description%TYPE DEFAULT NULL, 
        p_path_image    IN countries.path_image%TYPE DEFAULT NULL, 
        p_telephone_co  IN countries.telephone_co%TYPE DEFAULT NULL, 
        p_user_id       IN countries.user_id%TYPE DEFAULT NULL, 
        p_slug          IN countries.slug%TYPE DEFAULT NULL, 
        p_uuid          IN countries.uuid%TYPE DEFAULT NULL, 
        p_created_at    IN countries.created_at%TYPE DEFAULT NULL, 
        p_updated_at    IN countries.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT countries%ROWTYPE );    
    --
    -- delete
    procedure del (
        p_id IN countries.id%TYPE
    );
    --
    -- exist
    FUNCTION exist( p_id IN countries.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( p_country_co IN countries.country_co%TYPE ) RETURN BOOLEAN;
    --
END cfg_api_k_country;
/

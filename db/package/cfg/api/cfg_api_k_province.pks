---------------------------------------------------------------------------
--  DDL for Package PRONVINCES API
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
---------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE cfg_api_k_province IS
    --
    K_PROCESS    CONSTANT VARCHAR2(20)  := sys_k_constant.K_PROVIDENCE_PROCESS;
    K_OWNER      CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'PROVINCES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE provinces_api_tab IS TABLE OF provinces%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN provinces%ROWTYPE;    
    --
    -- get record
    FUNCTION get_record( p_id IN provinces.id%TYPE ) RETURN provinces%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_province_co IN provinces.province_co%TYPE ) RETURN provinces%ROWTYPE;
    --
    -- get DATA RETURN Array
    FUNCTION get_list RETURN provinces_api_tab;    
    --
    -- insert
    PROCEDURE ins (
        p_id              provinces.id%TYPE,
        p_province_co     provinces.province_co%TYPE,
        p_description     provinces.description%TYPE,
        p_region_id       provinces.region_id%TYPE,
        p_uuid            provinces.uuid%TYPE,
        p_slug            provinces.slug%TYPE,
        p_user_id         provinces.user_id%TYPE,
        p_created_at      provinces.created_at%TYPE,
        p_updated_at      provinces.updated_at%TYPE
    );
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT provinces%ROWTYPE ); 
    --
    -- update
    PROCEDURE upd (
        p_id              provinces.id%TYPE,
        p_province_co     provinces.province_co%TYPE,
        p_description     provinces.description%TYPE,
        p_region_id       provinces.region_id%TYPE,
        p_uuid            provinces.uuid%TYPE,
        p_slug            provinces.slug%TYPE,
        p_user_id         provinces.user_id%TYPE,
        p_created_at      provinces.created_at%TYPE,
        p_updated_at      provinces.updated_at%TYPE
    );
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT provinces%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id provinces.id%TYPE );
    --
    -- exist
    FUNCTION exist( p_id IN provinces.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( p_province_co IN provinces.province_co%TYPE ) RETURN BOOLEAN;
    --    
END cfg_api_k_province;
/
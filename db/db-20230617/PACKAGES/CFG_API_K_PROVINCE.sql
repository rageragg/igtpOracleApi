--------------------------------------------------------
--  DDL for Package CFG_API_K_PROVINCE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."CFG_API_K_PROVINCE" IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'PROVINCES';
    --
    -- get record
    FUNCTION get_record( p_id IN provinces.id%TYPE ) RETURN provinces%ROWTYPE;
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
END cfg_api_k_province;

/

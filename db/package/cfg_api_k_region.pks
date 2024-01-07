--------------------------------------------------------
--  DDL for Package Body regions_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE cfg_api_k_region IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'REGIONS'; 
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;    
    --
    TYPE regions_api_tab IS TABLE OF regions%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN regions%ROWTYPE;    
    --
    -- get record
    FUNCTION get_record( p_id IN regions.id%TYPE ) RETURN regions%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_region_co IN regions.region_co%TYPE ) RETURN regions%ROWTYPE;    
    --
    -- insert
    PROCEDURE ins (
        p_id              regions.id%TYPE, 
        p_region_co       regions.region_co%TYPE,
        p_description     regions.description%TYPE,
        p_country_id      regions.country_id%TYPE,
        p_uuid            regions.uuid%TYPE,
        p_slug            regions.slug%TYPE,
        p_user_id         regions.user_id%TYPE,
        p_created_at      regions.created_at%TYPE,
        p_updated_at      regions.updated_at%TYPE
    );
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT regions%ROWTYPE ); 
    --
    -- update
    PROCEDURE upd (
        p_id              regions.id%TYPE, 
        p_region_co       regions.region_co%TYPE,
        p_description     regions.description%TYPE,
        p_country_id      regions.country_id%TYPE,
        p_uuid            regions.uuid%TYPE,
        p_slug            regions.slug%TYPE,
        p_user_id         regions.user_id%TYPE,
        p_created_at      regions.created_at%TYPE,
        p_updated_at      regions.updated_at%TYPE
    );
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT regions%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id  regions.id%TYPE );
    --
    -- exist
    FUNCTION exist( p_id IN regions.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( p_region_co IN regions.region_co%TYPE ) RETURN BOOLEAN;
    --    
END cfg_api_k_region;
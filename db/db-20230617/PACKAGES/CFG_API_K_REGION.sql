--------------------------------------------------------
--  DDL for Package CFG_API_K_REGION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."CFG_API_K_REGION" IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'REGIONS'; 
    --
    -- get record
    FUNCTION get_record( p_id IN regions.id%TYPE ) RETURN regions%ROWTYPE;
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
END cfg_api_k_region;

/

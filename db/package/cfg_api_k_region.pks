--------------------------------------------------------
--  DDL for Package Body regions_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE cfg_api_k_region IS
    --
    TYPE regions_tapi_rec IS RECORD (
        id              regions.id%TYPE, 
        region_co       regions.region_co%TYPE,
        description     regions.description%TYPE,
        country_id      regions.country_id%TYPE,
        uuid            regions.uuid%TYPE,
        slug            regions.slug%TYPE,
        user_id         regions.user_id%TYPE,
        created_at      regions.created_at%TYPE,
        updated_at      regions.updated_at%TYPE
    );
    --
    TYPE regions_tapi_tab IS TABLE OF regions_tapi_rec;
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
    -- delete
    PROCEDURE del (
        p_id    regions.id%TYPE
    );
    --
END cfg_api_k_region;
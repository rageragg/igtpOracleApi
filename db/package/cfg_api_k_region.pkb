--------------------------------------------------------
--  DDL for Package Body regions_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_region IS
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
    ) IS
    BEGIN
        --
        INSERT INTO regions(
            id,
            region_co,
            description,
            country_id,
            uuid,
            slug,
            user_id,
            created_at,
            updated_at
        ) 
        VALUES (
            p_id,
            p_region_co,
            p_description,
            p_country_id,
            p_uuid,
            p_slug,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
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
    ) IS
    BEGIN
        --
        UPDATE regions SET
            user_id     = p_user_id,
            region_co   = p_region_co,
            description = p_description,
            country_id  = p_country_id,
            uuid        = p_uuid,
            slug        = p_slug,
            created_at  = p_created_at,
            updated_at  = p_updated_at
        WHERE id = p_id;
        --
    END;
    --
    -- del
    PROCEDURE del (
        p_id regions.ID%type
    ) IS
    BEGIN
        --
        DELETE FROM regions
            WHERE ID = p_ID;
        --
    END del;
    --
END cfg_api_k_region;

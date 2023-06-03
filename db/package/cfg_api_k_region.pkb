--------------------------------------------------------
--  DDL for Package Body regions_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_region IS
    --
    -- get record
    FUNCTION get_record( p_id IN regions.id%TYPE ) RETURN regions%ROWTYPE IS 
        --
        l_rec regions%ROWTYPE;
        --
    BEGIN 
        --
        SELECT *
          INTO l_rec
          FROM regions 
         WHERE id = p_id;
        --
        RETURN l_rec;
        --
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                RETURN NULL;  
        --
    END get_record;
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
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT regions%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        INSERT INTO regions 
             VALUES p_rec
             RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
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
    END upd;
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT regions%ROWTYPE ) IS 
    BEGIN  
        --
        p_rec.updated_at := sysdate;
        --
        UPDATE regions 
           SET ROW = p_rec
         WHERE id = p_rec.id
         RETURNING updated_at INTO p_rec.updated_at;
        --
    END upd;     
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

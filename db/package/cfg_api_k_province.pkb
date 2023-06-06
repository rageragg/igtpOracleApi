--------------------------------------------------------
--  DDL for Package Body provinces_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_province IS
    --
    -- get record
    FUNCTION get_record( p_id IN provinces.id%TYPE ) RETURN provinces%ROWTYPE IS 
        --
        l_rec provinces%ROWTYPE;
        --
    BEGIN 
        --
        SELECT *
          INTO l_rec
          FROM provinces 
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
        p_id              provinces.id%TYPE,
        p_province_co     provinces.province_co%TYPE,
        p_description     provinces.description%TYPE,
        p_region_id       provinces.region_id%TYPE,
        p_uuid            provinces.uuid%TYPE,
        p_slug            provinces.slug%TYPE,
        p_user_id         provinces.user_id%TYPE,
        p_created_at      provinces.created_at%TYPE,
        p_updated_at      provinces.updated_at%TYPE
    ) IS
    BEGIN 
        --
        INSERT INTO provinces(
            id,
            province_co,
            description,
            region_id,
            uuid,
            slug,
            user_id,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_province_co,
            p_description,
            p_region_id,
            p_uuid,
            p_slug,
            p_user_id,
            p_created_at ,
            p_updated_at 
        );
        --
    END ins;
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT provinces%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        INSERT INTO provinces 
             VALUES p_rec
             RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;    
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
    ) IS
    BEGIN 
        --
        UPDATE provinces 
           SET province_co = p_province_co,
               description = p_description,
               region_id   = p_region_id,
               uuid        = p_uuid,
               slug        = p_slug,
               user_id     = p_user_id,
               created_at  = p_created_at,
               updated_at  = p_updated_at
          WHERE id = p_id;
        --
    END upd;
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT provinces%ROWTYPE ) IS 
    BEGIN  
        --
        p_rec.updated_at := sysdate;
        --
        UPDATE provinces 
           SET ROW = p_rec
         WHERE id = p_rec.id
         RETURNING updated_at INTO p_rec.updated_at;
        --
    END upd; 
    --
    -- del
    PROCEDURE del ( p_id provinces.id%TYPE ) IS
    BEGIN 
        --
        DELETE FROM provinces
              WHERE id = p_id;
    END del;
    --
END cfg_api_k_province;

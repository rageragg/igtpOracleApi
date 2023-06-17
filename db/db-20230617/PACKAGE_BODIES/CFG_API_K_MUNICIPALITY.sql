--------------------------------------------------------
--  DDL for Package Body CFG_API_K_MUNICIPALITY
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "IGTP"."CFG_API_K_MUNICIPALITY" IS
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in municipalities.id%TYPE ) RETURN municipalities%ROWTYPE IS
        --
        l_data municipalities%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.municipalities WHERE id = p_id;
        -- 
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_data;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_record;      
    --
    -- insert
    PROCEDURE ins (
        p_id               IN municipalities.id%TYPE,
        p_municipality_co  IN municipalities.municipality_co%TYPE DEFAULT NULL, 
        p_description      IN municipalities.description%TYPE DEFAULT NULL, 
        p_province_id      IN municipalities.province_id%TYPE DEFAULT NULL, 
        p_uuid             IN municipalities.uuid%TYPE DEFAULT NULL,
        p_slug             IN municipalities.slug%TYPE DEFAULT NULL, 
        p_user_id          IN municipalities.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN municipalities.created_at%TYPE DEFAULT NULL, 
        p_updated_at       IN municipalities.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        INSERT INTO municipalities(
            id,
            municipality_co,
            description,
            province_id,
            user_id,
            uuid,
            slug,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_description,
            p_municipality_co,
            p_province_id,
            p_uuid,
            p_slug,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec  IN OUT municipalities%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        INSERT INTO municipalities 
             VALUES p_rec
          RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id               IN municipalities.id%TYPE,
        p_municipality_co  IN municipalities.municipality_co%TYPE DEFAULT NULL, 
        p_description      IN municipalities.description%TYPE DEFAULT NULL, 
        p_province_id      IN municipalities.province_id%TYPE DEFAULT NULL, 
        p_uuid             IN municipalities.uuid%TYPE DEFAULT NULL,
        p_slug             IN municipalities.slug%TYPE DEFAULT NULL, 
        p_user_id          IN municipalities.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN municipalities.created_at%TYPE DEFAULT NULL, 
        p_updated_at       IN municipalities.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        UPDATE municipalities 
           SET description = p_description,
               municipality_co = p_municipality_co,
               province_id = p_province_id,
               user_id = p_user_id,
               uuid = p_uuid,
               slug = p_slug,
               created_at = p_created_at,
               updated_at = p_updated_at
         WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( p_rec  IN OUT municipalities%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at := sysdate;
        --
        UPDATE municipalities 
           SET ROW = p_rec
         WHERE id = p_rec.id
         RETURNING updated_at INTO p_rec.updated_at;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id IN municipalities.id%TYPE ) IS
    BEGIN
        DELETE FROM municipalities
              WHERE id = p_id;
    END del;
    --   
END cfg_api_k_municipality;


/

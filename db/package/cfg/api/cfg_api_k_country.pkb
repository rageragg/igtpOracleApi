---------------------------------------------------------------------------
--  DDL for Package Body COUNTRIES_API
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
---------------------------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY cfg_api_k_country IS
    --
    g_record        countries%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN countries%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
    --
    -- get DATA RECORD BY ID
    FUNCTION get_record( p_id in countries.id%TYPE )  RETURN countries%ROWTYPE IS 
        --
        l_data countries%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.countries WHERE id = p_id;
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
    -- get DATA RECORD BY CO
    FUNCTION get_record( p_country_co IN countries.country_co%TYPE ) RETURN countries%ROWTYPE IS 
        --
        l_data countries%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.countries WHERE country_co = p_country_co;
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
    -- get DATA RETURN Array
    FUNCTION get_list RETURN countries_api_tab IS 
        --
        l_data countries_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.countries ORDER BY K_ORDER_LIST;
        --    
    BEGIN 
        --
        OPEN c_data;
        LOOP
            FETCH c_data BULK COLLECT INTO l_data LIMIT K_LIMIT_LIST;   
            EXIT WHEN c_data%NOTFOUND;
        END LOOP;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_list;    
    --
    -- create incremental id
    FUNCTION inc_id RETURN NUMBER IS 
        --
        mx  NUMBER(8);
        --
    BEGIN
        --
        SELECT max(id)
          INTO mx
          FROM igtp.countries;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id; 
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
        ) IS
        --
        ui  varchar2(60)    := sys_guid();
        --
    BEGIN
        --
        IF p_uuid IS NOT NULL THEN 
            ui := p_uuid;
        END IF;   
        --
        INSERT INTO COUNTRIES(
            id,
            country_co,
            description,
            path_image,
            telephone_co,
            user_id,
            slug,
            uuid,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_country_co,
            p_description,
            p_path_image,
            p_telephone_co,
            p_user_id,
            p_slug,
            ui,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT countries%ROWTYPE ) IS
    BEGIN
        --
        p_rec.created_at := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF;
        --    
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_guid();
        END IF;    
        --
        INSERT INTO igtp.countries 
            VALUES p_rec
            RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;       
    --
    -- update
    PROCEDURE upd (
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
        ) IS
    BEGIN
        --
        UPDATE countries 
        SET country_co = p_country_co,
            description = p_description,
            path_image = p_path_image,
            telephone_co = p_telephone_co,
            user_id = p_user_id,
            slug = p_slug,
            uuid = p_uuid,
            created_at = p_created_at,
            updated_at = p_updated_at
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT countries%ROWTYPE ) IS
    BEGIN 
        --
        p_rec.updated_at        := sysdate;
        --
        UPDATE igtp.countries 
           SET ROW = p_rec
         WHERE id = p_rec.id
         RETURNING updated_at INTO p_rec.updated_at;
        --
    END upd;    
    --
    -- del
    PROCEDURE del ( p_id in countries.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM igtp.countries WHERE id = p_id;
        --
    END del;
    --
    -- exist
    FUNCTION exist( p_id IN countries.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( p_country_co IN countries.country_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_country_co => p_country_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
end cfg_api_k_country;

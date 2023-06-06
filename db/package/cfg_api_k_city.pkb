--------------------------------------------------------
--  DDL for Package Body CITIES_API
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.cfg_api_k_city IS
    --
    -- get DATA RECORD
    FUNCTION get_record( p_id in cities.id%TYPE )  RETURN cities%ROWTYPE IS 
        --
        l_data cities%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.cities WHERE id = p_id;
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
    FUNCTION get_list RETURN cities_api_tab IS 
        --
        l_data cities_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.cities ORDER BY K_ORDER_LIST;
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
    -- insert
    PROCEDURE ins (
            p_id                IN cities.ID%TYPE,
            p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
            p_description       IN cities.description%TYPE DEFAULT NULL,
            p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
            p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
            p_municipality_id   IN cities.municipality_id%TYPE DEFAULT NULL,
            p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
            p_slug              IN cities.slug%TYPE DEFAULT NULL,
            p_user_id           IN cities.user_id%TYPE DEFAULT NULL,
            p_created_at        IN cities.created_at%TYPE DEFAULT NULL, 
            p_updated_at        IN cities.updated_at%TYPE DEFAULT NULL 
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
        INSERT INTO igtp.cities(
            id,
            city_co,
            description,
            telephone_co,
            postal_co,
            municipality_id,
            uuid,
            slug,
            user_id,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_city_co,
            p_description,
            p_telephone_co,
            p_postal_co,
            p_municipality_id,
            ui,
            p_slug,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT cities%ROWTYPE ) IS
    BEGIN
        --
        p_rec.created_at := sysdate;
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_guid();
        END IF;    
        --
        INSERT INTO igtp.cities 
             VALUES p_rec
           RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;         
    --
    -- update
    PROCEDURE upd (
            p_id                IN cities.ID%TYPE,
            p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
            p_description       IN cities.description%TYPE DEFAULT NULL,
            p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
            p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
            p_municipality_id   IN cities.municipality_id%TYPE DEFAULT NULL,
            p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
            p_slug              IN cities.slug%TYPE DEFAULT NULL,
            p_user_id           IN cities.user_id%TYPE DEFAULT NULL,
            p_created_at        IN cities.created_at%TYPE DEFAULT NULL, 
            p_updated_at        IN cities.updated_at%TYPE DEFAULT NULL 
        ) IS
    BEGIN
        --
        UPDATE igtp.cities 
        SET city_co         = p_city_co,
            description     = p_description,
            telephone_co    = p_telephone_co,
            postal_co       = p_postal_co,
            municipality_id = p_municipality_id,
            uuid            = p_uuid,
            slug            = p_slug,
            user_id         = p_user_id,
            created_at      = p_created_at,
            updated_at      = sysdate
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT cities%ROWTYPE ) IS
    BEGIN 
        --
        p_rec.updated_at        := sysdate;
        --
        UPDATE igtp.cities 
           SET ROW = p_rec
         WHERE id = p_rec.id
         RETURNING updated_at INTO p_rec.updated_at;
        --
    END upd;       
    --
    -- del
    PROCEDURE del ( p_id in cities.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM igtp.cities WHERE id = p_id;
        --
    END del;
    --
END cfg_api_k_city;

/

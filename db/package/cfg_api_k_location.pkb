--------------------------------------------------------
--  DDL for Package Body LOCATIONS_API
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.cfg_api_k_location IS 
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in locations.id%TYPE ) RETURN locations%ROWTYPE IS
        --
        l_data locations%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.locations WHERE id = p_id;
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
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_location_co in locations.location_co%TYPE ) RETURN locations%ROWTYPE IS
        --
        l_data locations%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.locations WHERE location_co = p_location_co;
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
    -- get DATA Array
    FUNCTION get_list RETURN locations_api_tab IS
        --
        l_data locations_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.locations ORDER BY K_ORDER_LIST;
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
          FROM igtp.locations;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;
    --
    -- insert
    PROCEDURE ins (
        p_id                IN locations.id%type,
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL, 
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_id           IN locations.city_id%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN locations.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN locations.nu_gps_lon%TYPE DEFAULT NULL, 
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL, 
        p_user_id           IN locations.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN locations.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN locations.updated_at%TYPE DEFAULT NULL
        ) IS 
    BEGIN
        --
        INSERT INTO locations(
            id,
            location_co,
            description,
            postal_co ,
            city_id   ,
            nu_gps_lat,
            nu_gps_lon,
            uuid,
            slug,
            user_id,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_location_co,
            p_description,
            p_postal_co ,
            p_city_id   ,
            p_nu_gps_lat,
            p_nu_gps_lon,
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
    PROCEDURE ins( p_rec IN OUT locations%ROWTYPE ) IS  
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_guid();
        END IF;  
        --
        INSERT INTO igtp.locations VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                IN locations.id%type,
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL, 
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_id           IN locations.city_id%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN locations.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN locations.nu_gps_lon%TYPE DEFAULT NULL, 
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL, 
        p_user_id           IN locations.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN locations.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN locations.updated_at%TYPE DEFAULT NULL
        ) IS 
    BEGIN
        --
        UPDATE locations 
        SET postal_co   = p_postal_co,
            city_id     = p_city_id,
            created_at  = p_created_at,
            description = p_description,
            nu_gps_lat  = p_nu_gps_lat,
            location_co = p_location_co,
            user_id     = p_user_id,
            updated_at  = p_updated_at,
            nu_gps_lon  = p_nu_gps_lon,
            uuid        = p_uuid,
            slug        = p_slug
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT locations%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.locations 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id IN locations.id%type ) IS 
    BEGIN
        --
        DELETE FROM locations
              WHERE id = p_id;
        --
    END del;
    --  
END cfg_api_k_location;

/

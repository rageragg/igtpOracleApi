--------------------------------------------------------
--  DDL for Package Body provinces_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_province IS
    --
    g_record        provinces%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN provinces%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
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
    -- get DATA RECORD BY CO
    FUNCTION get_record( p_province_co IN provinces.province_co%TYPE ) RETURN provinces%ROWTYPE IS 
        --
        l_data provinces%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.provinces WHERE province_co = p_province_co;
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
    FUNCTION get_list RETURN provinces_api_tab IS 
        --
        l_data provinces_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.provinces ORDER BY K_ORDER_LIST;
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
          FROM igtp.provinces;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;        
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
        --
        ui  varchar2(60)    := sys_k_utils.f_uuid();
        --
    BEGIN 
        --
        IF p_uuid IS NOT NULL THEN 
            ui := p_uuid;
        END IF;   
        --    
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
            ui,
            p_slug,
            p_user_id,
            p_created_at ,
            p_updated_at 
        );
        --
    END ins;
    --
    -- insert by records
    PROCEDURE ins ( 
            p_rec IN OUT provinces%ROWTYPE 
        ) IS 
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
    -- exist
    FUNCTION exist( p_id IN provinces.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( p_province_co IN provinces.province_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_province_co => p_province_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
END cfg_api_k_province;

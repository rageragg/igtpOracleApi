CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.cfg_api_k_municipality IS
    ---------------------------------------------------------------------------
    --  DDL for Package MUNICIPALITY API
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    ---------------------------------------------------------------------------
    --
    g_record        municipalities%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN municipalities%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN municipalities.id%TYPE ) RETURN municipalities%ROWTYPE IS
        --
        l_data municipalities%ROWTYPE;
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
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_municipality_co IN municipalities.municipality_co%TYPE ) RETURN municipalities%ROWTYPE IS
        --
        l_data municipalities%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.municipalities WHERE municipality_co = p_municipality_co;
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
    FUNCTION get_list RETURN municipalities_api_tab IS 
        --
        l_data municipalities_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.municipalities ORDER BY K_ORDER_LIST;
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
          FROM igtp.municipalities;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;          
    --       
    -- insert
    PROCEDURE ins (
            p_id               IN OUT municipalities.id%TYPE,
            p_municipality_co  IN municipalities.municipality_co%TYPE DEFAULT NULL, 
            p_description      IN municipalities.description%TYPE DEFAULT NULL, 
            p_province_id      IN municipalities.province_id%TYPE DEFAULT NULL, 
            p_uuid             IN OUT municipalities.uuid%TYPE,
            p_slug             IN municipalities.slug%TYPE DEFAULT NULL, 
            p_user_id          IN municipalities.user_id%TYPE DEFAULT NULL, 
            p_created_at       IN OUT municipalities.created_at%TYPE, 
            p_updated_at       IN OUT municipalities.updated_at%TYPE
        ) IS
        --     
    BEGIN
        --
        IF p_id IS NULL THEN 
            p_id := inc_id;
        END IF;
        --
        IF p_uuid IS NULL THEN 
            p_uuid :=  sys_k_utils.f_uuid();
        END IF;    
        --
        IF p_created_at IS NULL THEN 
            p_created_at := sysdate;
        END IF;
        --
        IF p_updated_at IS NULL THEN 
            p_updated_at := sysdate;
        END IF;
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
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF;
        --    
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_k_utils.f_uuid();
        END IF;    
        --
        IF p_rec.created_at IS NULL THEN 
            p_rec.created_at := sysdate;
        END IF;
        --
        IF p_rec.updated_at IS NULL THEN 
            p_rec.updated_at := sysdate;
        END IF;
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
            p_uuid             IN OUT municipalities.uuid%TYPE,
            p_slug             IN municipalities.slug%TYPE DEFAULT NULL, 
            p_user_id          IN municipalities.user_id%TYPE DEFAULT NULL, 
            p_created_at       IN OUT municipalities.created_at%TYPE, 
            p_updated_at       IN OUT municipalities.updated_at%TYPE
        ) IS
    BEGIN
        --
        IF p_uuid IS NULL THEN 
            p_uuid := sys_k_utils.f_uuid();
        END IF;   
        --
        IF p_created_at IS NULL THEN 
            p_created_at := sysdate;
        END IF;
        --
        IF p_updated_at IS NULL THEN 
            p_updated_at := sysdate;
        END IF;
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
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_k_utils.f_uuid();
        END IF;   
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
        --
        DELETE FROM municipalities
            WHERE id = p_id;
        --
    END del;
    --
    -- exist
    FUNCTION exist( p_id IN municipalities.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( p_municipality_co IN municipalities.municipality_co%TYPE  ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_municipality_co => p_municipality_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN FALSE;
    END exist;
    --   
END cfg_api_k_municipality;
/
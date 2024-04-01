--------------------------------------------------------
--  DDL for Package Body regions_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_region IS
    --
    g_record        regions%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN regions%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
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
    -- get DATA RECORD BY CO
    FUNCTION get_record( p_region_co IN regions.region_co%TYPE ) RETURN regions%ROWTYPE IS 
        --
        l_data regions%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.regions WHERE region_co = p_region_co;
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
    FUNCTION get_list RETURN regions_api_tab IS 
        --
        l_data regions_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.regions ORDER BY K_ORDER_LIST;
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
          FROM igtp.regions;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;     
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
        --
        ui  varchar2(60)    := sys_guid();
        --
    BEGIN
        --
        IF p_uuid IS NOT NULL THEN 
            ui := p_uuid;
        END IF;   
        --
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
            ui,
            p_slug,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert by records
    PROCEDURE ins ( 
            p_rec IN OUT regions%ROWTYPE 
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
    PROCEDURE upd ( 
            p_rec IN OUT regions%ROWTYPE 
        ) IS 
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
    -- exist
    FUNCTION exist( p_id IN regions.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( p_region_co IN regions.region_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_region_co => p_region_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
END cfg_api_k_region;
/
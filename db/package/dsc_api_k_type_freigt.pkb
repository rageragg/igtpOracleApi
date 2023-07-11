CREATE OR REPLACE PACKAGE BODY dsc_api_k_type_freight
IS
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN type_freights.id%TYPE ) RETURN type_freights%ROWTYPE IS
        --
        l_data type_freights%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_freights WHERE id = p_id;
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
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_type_freight_co IN type_freights.type_freight_co%TYPE ) RETURN type_freights%ROWTYPE IS 
        --
        l_data type_freights%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_freights WHERE type_freight_co = p_type_freight_co;
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
    FUNCTION get_list RETURN type_freigts_api_tab IS
        --
        l_data type_freigts_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_freights ORDER BY K_ORDER_LIST;
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
          FROM igtp.type_freights;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;  
    --
    -- insert
    PROCEDURE ins (
        p_id                IN type_freights.id%TYPE,
        p_type_freight_co   IN type_freights.type_freight_co%TYPE DEFAULT NULL,
        p_description       IN type_freights.description%TYPE DEFAULT NULL,
        p_k_multi_delivery  IN type_freights.k_multi_delivery%TYPE DEFAULT NULL,
        p_k_multi_load      IN type_freights.k_multi_load%TYPE DEFAULT NULL,
        p_user_id           IN type_freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_freights.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO type_freights(
            created_at
            ,description
            ,k_multi_delivery
            ,type_freight_co
            ,user_id
            ,updated_at
            ,id
            ,k_multi_load
        ) VALUES (
            p_created_at
            ,p_description
            ,p_k_multi_delivery
            ,p_type_freight_co
            ,p_user_id
            ,p_updated_at
            ,p_id
            ,p_k_multi_load
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT type_freights%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.type_freights VALUES p_rec;
        --
    END ins;    
    --
    -- update
    PROCEDURE upd (
            p_id                IN type_freights.id%TYPE,
            p_type_freight_co   IN type_freights.type_freight_co%TYPE DEFAULT NULL,
            p_description       IN type_freights.description%TYPE DEFAULT NULL,
            p_k_multi_delivery  IN type_freights.k_multi_delivery%TYPE DEFAULT NULL,
            p_k_multi_load      IN type_freights.k_multi_load%TYPE DEFAULT NULL,
            p_user_id           IN type_freights.user_id%TYPE DEFAULT NULL,
            p_created_at        IN type_freights.created_at%TYPE DEFAULT NULL,
            p_updated_at        IN type_freights.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        UPDATE type_freights 
           SET created_at = p_created_at
               ,description = p_description
               ,k_multi_delivery = p_k_multi_delivery
               ,type_freight_co = p_type_freight_co
               ,user_id = p_user_id
               ,updated_at = p_updated_at
               ,k_multi_load = p_k_multi_load
         WHERE id = p_id;
         --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT type_freights%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.type_freights 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;    
    --
    -- del
    PROCEDURE del ( p_id IN type_freights.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM type_freights
         WHERE id = p_id;
        -- 
    END del;
    --
END dsc_api_k_type_freight;

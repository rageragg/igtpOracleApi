CREATE OR REPLACE PACKAGE BODY dsc_api_k_subsidiary IS
    ---------------------------------------------------------------------------
    --  DDL for Package subsidiaries_API (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de
    --                                  subsidiaries
    ---------------------------------------------------------------------------
    --
    g_record        subsidiaries%ROWTYPE;    
    --
    -- get DATA 
    FUNCTION get_record RETURN subsidiaries%ROWTYPE IS
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;    
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN subsidiaries.id%TYPE ) RETURN subsidiaries%ROWTYPE IS
        --
        l_data subsidiaries%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.subsidiaries WHERE id = p_id;
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
    FUNCTION get_record( p_subsidiary_co IN subsidiaries.subsidiary_co%TYPE ) RETURN subsidiaries%ROWTYPE IS
        --
        l_data subsidiaries%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.subsidiaries WHERE subsidiary_co = p_subsidiary_co;
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
    FUNCTION get_list RETURN subsidiaries_api_tab IS
        --
        l_data subsidiaries_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.subsidiaries ORDER BY K_ORDER_LIST;
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
          FROM igtp.subsidiaries;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;   
    --
    -- insert
    PROCEDURE ins (
            p_id                IN subsidiaries.ID%type,
            p_subsidiary_co     IN subsidiaries.subsidiary_co%type default null, 
            p_customer_id       IN subsidiaries.customer_id%type default null, 
            p_shop_id           IN subsidiaries.shop_id%type default null, 
            p_slug              IN subsidiaries.slug%type default null, 
            p_uuid              IN subsidiaries.uuid%type default null,
            p_created_at        IN subsidiaries.created_at%type default null,
            p_updated_at        IN subsidiaries.updated_at%type default null,
            p_user_id           IN subsidiaries.user_id%type default null 
        ) IS
    BEGIN
        --
        INSERT INTO subsidiaries(
            id,
            subsidiary_co,
            customer_id,
            shop_id,
            slug,
            uuid,
            created_at,
            updated_at,
            user_id
        ) VALUES (
            p_id,
            p_subsidiary_co,
            p_customer_id,
            p_shop_id,
            p_slug,
            p_uuid,
            p_created_at,
            p_updated_at,
            p_user_id
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT subsidiaries%ROWTYPE ) IS  
    BEGIN 
        --
        p_rec.created_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_k_utils.f_uuid();
        END IF;  
        --
        INSERT INTO igtp.subsidiaries VALUES p_rec;
        --
    END ins;  
    --
    -- update
    PROCEDURE upd (
            p_id            IN subsidiaries.ID%type,
            p_subsidiary_co IN subsidiaries.subsidiary_co%type default null, 
            p_customer_id   IN subsidiaries.CUSTOMER_ID%type default null,
            p_shop_id       IN subsidiaries.shop_id%type default null,
            p_slug          IN subsidiaries.slug%type default null,
            p_uuid          IN subsidiaries.uuid%type default null,
            p_created_at    IN subsidiaries.created_at%type default null,
            p_updated_at    IN subsidiaries.updated_at%type default null,
            p_user_id       IN subsidiaries.user_id%type default null
        ) IS
    BEGIN
        --
        UPDATE subsidiaries 
           SET  subsidiary_co = p_subsidiary_co,
                shop_id       = p_shop_id,
                customer_id   = p_customer_id,
                slug          = p_slug,
                uuid          = p_uuid,
                created_at    = p_created_at,
                updated_at    = p_updated_at,
                user_id       = p_user_id
         WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT subsidiaries%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.subsidiaries 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;     
    --
    -- del
    PROCEDURE del ( 
            p_id IN subsidiaries.id%TYPE
        ) IS
    BEGIN
        --
        DELETE FROM subsidiaries
         WHERE id = p_id;
        -- 
    END del;
    --
    -- exist subsidiare by id
    FUNCTION exist( p_id IN subsidiaries.id%TYPE ) RETURN BOOLEAN IS
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist subsidiare by code
    FUNCTION exist( p_subsidiary_co IN subsidiaries.subsidiary_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_subsidiary_co => p_subsidiary_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;    
    --
end dsc_api_k_subsidiary;
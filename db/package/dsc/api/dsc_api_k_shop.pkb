

CREATE OR REPLACE package body dsc_api_k_shop IS 
    --------------------------------------------------------
    --  DDL for Package SHOPS_API
    --------------------------------------------------------
    --
    g_record        shops%ROWTYPE;    
    --
    -- get DATA 
    FUNCTION get_record RETURN shops%ROWTYPE IS
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;  
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in shops.id%TYPE ) RETURN shops%ROWTYPE IS
        --
        l_data shops%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.shops WHERE id = p_id;
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
    FUNCTION get_record( p_shop_co in shops.shop_co%TYPE ) RETURN shops%ROWTYPE IS
        --
        l_data shops%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.shops WHERE shop_co = p_shop_co;
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
    FUNCTION get_list RETURN shops_api_tab IS
        --
        l_data shops_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.shops ORDER BY K_ORDER_LIST;
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
          FROM igtp.shops;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;       
    --
    -- insert
    PROCEDURE ins (
        p_id                IN shops.id%TYPE,
        p_shop_co           IN shops.shop_co%TYPE DEFAULT NULL,
        p_description       IN shops.description%TYPE DEFAULT NULL, 
        p_location_id       IN shops.location_id%TYPE DEFAULT NULL,
        p_address           IN shops.address%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN shops.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN shops.nu_gps_lon%TYPE DEFAULT NULL, 
        p_telephone_co      IN shops.telephone_co%TYPE DEFAULT NULL, 
        p_fax_co            IN shops.fax_co%TYPE DEFAULT NULL,
        p_email             IN shops.email%TYPE DEFAULT NULL, 
        p_name_contact      IN shops.name_contact%TYPE DEFAULT NULL,
        p_email_contact     IN shops.email_contact%TYPE DEFAULT NULL,
        p_telephone_contact IN shops.telephone_contact%TYPE DEFAULT NULL, 
        p_uuid              IN shops.uuid%TYPE DEFAULT NULL,
        p_slug              IN shops.slug%TYPE DEFAULT NULL,
        p_user_id           IN shops.user_id%TYPE DEFAULT NULL,
        p_created_at        IN shops.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN shops.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        INSERT INTO shops(
            telephone_co
            ,name_contact
            ,created_at
            ,user_id
            ,email
            ,slug
            ,shop_co
            ,description
            ,address
            ,nu_gps_lat
            ,email_contact
            ,location_id
            ,updated_at
            ,id
            ,nu_gps_lon
            ,uuid
            ,telephone_contact
            ,fax_co
        ) VALUES (
            p_telephone_co
            ,p_name_contact
            ,p_created_at
            ,p_user_id
            ,p_email
            ,p_slug
            ,p_shop_co
            ,p_description
            ,p_address
            ,p_nu_gps_lat
            ,p_email_contact
            ,p_location_id
            ,p_updated_at
            ,p_id
            ,p_nu_gps_lon
            ,p_uuid
            ,p_telephone_contact
            ,p_fax_co
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT shops%ROWTYPE ) IS  
    BEGIN 
        --
        p_rec.created_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_guid();
        END IF;  
        --
        INSERT INTO igtp.shops VALUES p_rec;
        --
    END ins;    
    --
    -- update
    PROCEDURE upd (
        p_id                IN shops.id%TYPE,
        p_shop_co           IN shops.shop_co%TYPE DEFAULT NULL,
        p_description       IN shops.description%TYPE DEFAULT NULL, 
        p_location_id       IN shops.location_id%TYPE DEFAULT NULL,
        p_address           IN shops.address%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN shops.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN shops.nu_gps_lon%TYPE DEFAULT NULL, 
        p_telephone_co      IN shops.telephone_co%TYPE DEFAULT NULL, 
        p_fax_co            IN shops.fax_co%TYPE DEFAULT NULL,
        p_email             IN shops.email%TYPE DEFAULT NULL, 
        p_name_contact      IN shops.name_contact%TYPE DEFAULT NULL,
        p_email_contact     IN shops.email_contact%TYPE DEFAULT NULL,
        p_telephone_contact IN shops.telephone_contact%TYPE DEFAULT NULL, 
        p_uuid              IN shops.uuid%TYPE DEFAULT NULL,
        p_slug              IN shops.slug%TYPE DEFAULT NULL,
        p_user_id           IN shops.user_id%TYPE DEFAULT NULL,
        p_created_at        IN shops.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN shops.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        UPDATE shops SET
            telephone_co = p_telephone_co
            ,name_contact = p_name_contact
            ,created_at = p_created_at
            ,user_id = p_user_id
            ,email = p_email
            ,slug = p_slug
            ,shop_co = p_shop_co
            ,description = p_description
            ,address = p_address
            ,nu_gps_lat = p_nu_gps_lat
            ,email_contact = p_email_contact
            ,location_id = p_location_id
            ,updated_at = p_updated_at
            ,nu_gps_lon = p_nu_gps_lon
            ,uuid = p_uuid
            ,telephone_contact = p_telephone_contact
            ,fax_co = p_fax_co
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT shops%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.shops 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;    
    --
    -- del
    PROCEDURE del ( p_id IN shops.id%TYPE
    ) IS
    BEGIN
        --
        DELETE FROM shops
         WHERE id = p_id;
        -- 
    END del;
    --
    -- exist shop by id
    FUNCTION exist( p_id IN shops.id%TYPE ) RETURN BOOLEAN IS
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist customer by code
    FUNCTION exist( p_shop_co IN shops.shop_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_shop_co => p_shop_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --       
end dsc_api_k_shop;

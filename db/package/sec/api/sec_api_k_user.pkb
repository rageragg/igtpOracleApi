--------------------------------------------------------
--  DDL for Package sec_api_k_user
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY sec_api_k_user IS
    --
    g_record        users%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN users%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;    
    --
    -- get DATA RECORD by ID
    FUNCTION get_record( p_id in users.id%TYPE )  RETURN users%ROWTYPE IS 
        --
        l_data users%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.users WHERE id = p_id;
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
    -- get DATA RECORD by CO
    FUNCTION get_record( p_user_co in users.user_co%TYPE )  RETURN users%ROWTYPE IS 
        --
        l_data users%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.users WHERE user_co = p_user_co;
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
    FUNCTION get_list RETURN users_api_tab IS 
        --
        l_data users_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.users ORDER BY K_ORDER_LIST;
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
        mx  number(8);
        --
    BEGIN
        --
        SELECT max(id)
          INTO mx
          FROM igtp.users;
        --
        mx := mx + 1;
        --
        RETURN mx;  
        --
    END inc_id;       
    --
    -- insert
    PROCEDURE ins (
        p_id                IN users.id%TYPE,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_name              IN users.name%TYPE DEFAULT NULL,
        p_email             IN users.email%TYPE DEFAULT NULL,
        p_email_verified_at IN users.email_verified_at%TYPE DEFAULT NULL,
        p_password          IN users.password%TYPE DEFAULT NULL,
        p_api_token         IN users.api_token%TYPE DEFAULT NULL,
        p_token_at          IN users.token_at%TYPE DEFAULT NULL,
        p_uuid              IN users.uuid%TYPE DEFAULT NULL,
        p_rol               IN users.rol%TYPE DEFAULT NULL,
        p_device_id         IN users.device_id%TYPE DEFAULT NULL,
        p_remember_token    IN users.remember_token%TYPE DEFAULT NULL,
        p_k_valid           IN users.k_valid%TYPE DEFAULT NULL,
        p_address_ip        IN users.address_ip%TYPE DEFAULT NULL,
        p_created_at        IN users.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN users.updated_at%TYPE DEFAULT NULL 
    ) IS
        --
        mx  number(8)       := inc_id;
        ui  varchar2(60)    := sys_guid();
        --
    BEGIN
        --
        IF p_id IS NOT NULL THEN 
            mx := p_id;
        END IF;    
        --
        IF p_uuid IS NOT NULL THEN 
            ui := p_uuid;
        END IF;  
        --
        INSERT INTO users(
            token_at
            ,k_valid
            ,created_at
            ,email_verified_at
            ,user_co
            ,address_ip
            ,email
            ,rol
            ,name
            ,api_token
            ,password
            ,updated_at
            ,id
            ,uuid
            ,remember_token
            ,device_id
        ) VALUES (
            p_token_at
            ,p_k_valid
            ,p_created_at
            ,p_email_verified_at
            ,p_user_co
            ,p_address_ip
            ,p_email
            ,p_rol
            ,p_name
            ,p_api_token
            ,p_password
            ,p_updated_at
            ,mx
            ,ui
            ,p_remember_token
            ,p_device_id
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT users%ROWTYPE ) IS
    BEGIN 
        --
        p_rec.created_at  := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_guid();
        END IF;    
        --
        INSERT INTO igtp.users VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                IN users.id%TYPE,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_name              IN users.name%TYPE DEFAULT NULL,
        p_email             IN users.email%TYPE DEFAULT NULL,
        p_email_verified_at IN users.email_verified_at%TYPE DEFAULT NULL,
        p_password          IN users.password%TYPE DEFAULT NULL,
        p_api_token         IN users.api_token%TYPE DEFAULT NULL,
        p_token_at          IN users.token_at%TYPE DEFAULT NULL,
        p_uuid              IN users.uuid%TYPE DEFAULT NULL,
        p_rol               IN users.rol%TYPE DEFAULT NULL,
        p_device_id         IN users.device_id%TYPE DEFAULT NULL,
        p_remember_token    IN users.remember_token%TYPE DEFAULT NULL,
        p_k_valid           IN users.k_valid%TYPE DEFAULT NULL,
        p_address_ip        IN users.address_ip%TYPE DEFAULT NULL,
        p_created_at        IN users.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN users.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        UPDATE users 
           SET token_at = p_token_at
            ,k_valid    = p_k_valid
            ,created_at = p_created_at
            ,user_co    = p_user_co
            ,address_ip = p_address_ip
            ,email      = p_email
            ,rol        = p_rol
            ,name       = p_name
            ,api_token  = p_api_token
            ,password   = p_password
            ,updated_at = p_updated_at
            ,uuid       = p_uuid
            ,email_verified_at  = p_email_verified_at
            ,remember_token     = p_remember_token
            ,device_id          = p_device_id
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT users%ROWTYPE ) IS
    BEGIN 
        --
        p_rec.updated_at  := sysdate;
        --
        UPDATE igtp.users 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;     
    --
    -- del
    PROCEDURE del ( p_id IN users.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM users
         WHERE id = p_id;
    END del;
    --
    -- exist
    FUNCTION exist( p_id IN users.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( p_user_co IN users.user_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_user_co => p_user_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    -- 
END sec_api_k_user;

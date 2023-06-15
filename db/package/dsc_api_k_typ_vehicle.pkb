--------------------------------------------------------
--  DDL for Package Body TYPE_VEHICLES_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY dsc_api_k_typ_vehicle is
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in type_vehicles.id%TYPE ) RETURN type_vehicles%ROWTYPE IS
        --
        l_data type_vehicles%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_vehicles WHERE id = p_id;
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
    FUNCTION get_list RETURN type_vehicles_api_tab IS
        --
        l_data type_vehicles_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_vehicles ORDER BY K_ORDER_LIST;
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
          FROM igtp.type_vehicles;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;   
    --
    -- insert
    PROCEDURE ins (
        p_id                IN type_vehicles.id%TYPE,
        p_type_vehicle_co   IN type_vehicles.type_vehicle_co%TYPE DEFAULT NULL,
        p_description       IN type_vehicles.description%TYPE DEFAULT NULL,
        p_k_class           IN type_vehicles.k_class%TYPE DEFAULT NULL,
        p_k_active          IN type_vehicles.k_active%TYPE DEFAULT NULL,
        p_user_id           IN type_vehicles.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_vehicles.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_vehicles.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO type_vehicles(
            id,
            type_vehicle_co,
            description,
            k_class,
            k_active,
            user_id,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_type_vehicle_co,
            p_description,
            p_k_class,
            p_k_active,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT type_vehicles%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.type_vehicles VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                IN type_vehicles.id%TYPE,
        p_type_vehicle_co   IN type_vehicles.type_vehicle_co%TYPE DEFAULT NULL,
        p_description       IN type_vehicles.description%TYPE DEFAULT NULL,
        p_k_class           IN type_vehicles.k_class%TYPE DEFAULT NULL,
        p_k_active          IN type_vehicles.k_active%TYPE DEFAULT NULL,
        p_user_id           IN type_vehicles.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_vehicles.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_vehicles.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        UPDATE type_vehicles 
           SET type_vehicle_co = p_type_vehicle_co,
               description = p_description,
               k_class = p_k_class,
               k_active = p_k_active,
               user_id = p_user_id,
               created_at = p_created_at,
               updated_at = p_updated_at
         WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT type_vehicles%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.type_vehicles 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_ID IN type_vehicles.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM type_vehicles
         WHERE id = p_id;
        -- 
    END del;
    --
end dsc_api_k_typ_vehicle;

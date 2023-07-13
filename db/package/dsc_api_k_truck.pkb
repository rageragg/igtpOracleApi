--------------------------------------------------------
--  DDL for Package Body TRUCK_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY dsc_api_k_truck IS
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in trucks.id%TYPE ) RETURN trucks%ROWTYPE IS
        --
        l_data trucks%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.trucks WHERE id = p_id;
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
    FUNCTION get_record( p_truck_co IN trucks.truck_co%TYPE ) RETURN trucks%ROWTYPE IS
        --
        l_data trucks%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.trucks WHERE truck_co = p_truck_co;
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
    FUNCTION get_list RETURN trucks_api_tab IS
        --
        l_data trucks_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.trucks ORDER BY K_ORDER_LIST;
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
          FROM igtp.trucks;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id; 
    --
    -- insert
    PROCEDURE ins (
        p_id                IN trucks.id%TYPE,
        p_truck_co          IN trucks.truck_co%TYPE DEFAULT NULL,
        p_external_co       IN trucks.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN trucks.type_vehicle_id%TYPE DEFAULT NULL, 
        p_k_type_gas        IN trucks.k_type_gas%TYPE DEFAULT 'DIESEL',
        p_year              IN trucks.year%TYPE DEFAULT NULL, 
        p_model             IN trucks.model%TYPE DEFAULT NULL,
        p_color             IN trucks.color%TYPE DEFAULT NULL, 
        p_serial_engine     IN trucks.serial_engine%TYPE DEFAULT NULL, 
        p_serial_chassis    IN trucks.serial_chassis%TYPE DEFAULT NULL, 
        p_k_status          IN trucks.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id        IN trucks.partner_id%TYPE DEFAULT NULL, 
        p_transfer_id       IN trucks.transfer_id%TYPE DEFAULT NULL, 
        p_employee_id       IN trucks.employee_id%TYPE DEFAULT NULL,
        p_location_id       IN trucks.location_id%TYPE DEFAULT NULL, 
        p_user_id           IN trucks.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN trucks.created_at%TYPE DEFAULT sysdate, 
        p_updated_at        IN trucks.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO trucks(
            employee_id
            ,created_at
            ,user_id
            ,model
            ,truck_co
            ,serial_chassis
            ,serial_engine
            ,k_status
            ,year
            ,color
            ,transfer_id
            ,external_co
            ,type_vehicle_id
            ,k_type_gas
            ,location_id
            ,updated_at
            ,id
            ,partner_id
        ) VALUES (
            p_employee_id
            ,p_created_at
            ,p_user_id
            ,p_model
            ,p_truck_co
            ,p_serial_chassis
            ,p_serial_engine
            ,p_k_status
            ,p_year
            ,p_color
            ,p_transfer_id
            ,p_external_co
            ,p_type_vehicle_id
            ,p_k_type_gas
            ,p_location_id
            ,p_updated_at
            ,p_id
            ,p_partner_id
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT trucks%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.trucks VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                IN trucks.id%TYPE,
        p_truck_co          IN trucks.truck_co%TYPE DEFAULT NULL,
        p_external_co       IN trucks.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN trucks.type_vehicle_id%TYPE DEFAULT NULL, 
        p_k_type_gas        IN trucks.k_type_gas%TYPE DEFAULT 'DIESEL',
        p_year              IN trucks.year%TYPE DEFAULT NULL, 
        p_model             IN trucks.model%TYPE DEFAULT NULL,
        p_color             IN trucks.color%TYPE DEFAULT NULL, 
        p_serial_engine     IN trucks.serial_engine%TYPE DEFAULT NULL, 
        p_serial_chassis    IN trucks.serial_chassis%TYPE DEFAULT NULL, 
        p_k_status          IN trucks.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id        IN trucks.partner_id%TYPE DEFAULT NULL, 
        p_transfer_id       IN trucks.transfer_id%TYPE DEFAULT NULL, 
        p_employee_id       IN trucks.employee_id%TYPE DEFAULT NULL,
        p_location_id       IN trucks.location_id%TYPE DEFAULT NULL, 
        p_user_id           IN trucks.user_id%TYPE DEFAULT NULL, 
        p_created_at        IN trucks.created_at%TYPE DEFAULT NULL, 
        p_updated_at        IN trucks.updated_at%TYPE DEFAULT sysdate 
    ) IS
    BEGIN
        --
        UPDATE trucks 
           SET employee_id = p_employee_id,
               created_at = p_created_at,
               user_id = p_user_id,
               model = p_model,
               truck_co = p_truck_co,
               serial_chassis = p_serial_chassis,
               serial_engine = p_serial_engine,
               k_status = p_k_status,
               year = p_year,
               color = p_color,
               transfer_id = p_transfer_id,
               external_co = p_external_co,
               type_vehicle_id = p_type_vehicle_id,
               k_type_gas = p_k_type_gas,
               location_id = p_location_id,
               updated_at = p_updated_at,
               partner_id = p_partner_id
         WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT trucks%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.trucks 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;    
    --
    -- del
    PROCEDURE del ( p_id in trucks.id%TYPE  ) is
    BEGIN
        --
        DELETE FROM trucks
         WHERE id = p_id;
        -- 
    END del;
    --
END dsc_api_k_truck;
/
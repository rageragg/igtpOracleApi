--------------------------------------------------------
--  DDL for Package Body EMPLOYEES_api
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY dsc_api_k_employee IS
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN employees.id%TYPE ) RETURN employees%ROWTYPE IS
        --
        l_data employees%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.employees WHERE id = p_id;
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
    FUNCTION get_record( p_employee_co IN employees.employee_co%TYPE ) RETURN employees%ROWTYPE IS
        --
        l_data employees%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.employees 
             WHERE employee_co = p_employee_co;
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
    FUNCTION get_list RETURN employees_api_tab IS
        --
        l_data employees_api_tab;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.employees 
             ORDER BY K_ORDER_LIST;
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
          FROM igtp.employees;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;
    --   
    -- insert
    PROCEDURE ins (
            p_id            IN employees.id%TYPE,
            p_employee_co   IN employees.employee_co%TYPE DEFAULT NULL,
            p_fullname      IN employees.fullname%TYPE DEFAULT NULL,
            p_k_level       IN employees.k_level%TYPE DEFAULT NULL,
            p_k_status      IN employees.k_status%TYPE DEFAULT 'AVAILABLE',
            p_partner_id    IN employees.partner_id%TYPE DEFAULT NULL,
            p_transfer_id   IN employees.transfer_id%TYPE DEFAULT NULL,
            p_truck_id      IN employees.truck_id%TYPE DEFAULT NULL,
            p_trailer_id    IN employees.trailer_id%TYPE DEFAULT NULL,
            p_location_id   IN employees.location_id%TYPE DEFAULT NULL,
            p_user_id       IN employees.user_id%TYPE DEFAULT NULL,
            p_created_at    IN employees.created_at%TYPE DEFAULT sysdate,
            p_updated_at    IN employees.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO EMPLOYEES(
            created_at
            ,user_id
            ,k_status
            ,k_level
            ,employee_co
            ,transfer_id
            ,truck_id
            ,location_id
            ,updated_at
            ,id
            ,trailer_id
            ,fullname
            ,partner_id
        ) VALUES (
            p_created_at
            ,p_user_id
            ,p_k_status
            ,p_k_level
            ,p_employee_co
            ,p_transfer_id
            ,p_truck_id
            ,p_location_id
            ,p_updated_at
            ,p_id
            ,p_trailer_id
            ,p_fullname
            ,p_partner_id
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT employees%ROWTYPE ) IS 
        --
        l_rec employees%ROWTYPE;
        --
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.k_status IS NULL THEN 
            p_rec.k_status := K_STATUS_AVAILABLE;
        END IF;
        --
        INSERT INTO igtp.employees VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id            IN employees.id%TYPE,
        p_employee_co   IN employees.employee_co%TYPE DEFAULT NULL,
        p_fullname      IN employees.fullname%TYPE DEFAULT NULL,
        p_k_level       IN employees.k_level%TYPE DEFAULT NULL,
        p_k_status      IN employees.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id    IN employees.partner_id%TYPE DEFAULT NULL,
        p_transfer_id   IN employees.transfer_id%TYPE DEFAULT NULL,
        p_truck_id      IN employees.truck_id%TYPE DEFAULT NULL,
        p_trailer_id    IN employees.trailer_id%TYPE DEFAULT NULL,
        p_location_id   IN employees.location_id%TYPE DEFAULT NULL,
        p_user_id       IN employees.user_id%TYPE DEFAULT NULL,
        p_created_at    IN employees.created_at%TYPE DEFAULT NULL,
        p_updated_at    IN employees.updated_at%TYPE DEFAULT sysdate 
    ) IS
    BEGIN
        --
        UPDATE EMPLOYEES 
        SET created_at = p_created_at
            ,user_id = p_user_id
            ,k_status = p_k_status
            ,k_level = p_k_level
            ,employee_co = p_employee_co
            ,transfer_id = p_transfer_id
            ,truck_id = p_truck_id
            ,location_id = p_location_id
            ,updated_at = p_updated_at
            ,trailer_id = p_trailer_id
            ,fullname = p_fullname
            ,partner_id = p_partner_id
        WHERE id = p_id;
        -- 
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT employees%ROWTYPE ) IS
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.employees 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;     
    --
    -- del
    PROCEDURE del ( p_id in employees.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM employees
        WHERE id = p_id;
        -- 
    END del;
    --
END dsc_api_k_employee;

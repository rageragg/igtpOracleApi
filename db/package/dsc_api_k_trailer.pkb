--------------------------------------------------------
--  DDL for Package Body RAILERS_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY dsc_api_k_trailer IS
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in trailers.id%TYPE ) RETURN trailers%ROWTYPE IS
        --
        l_data trailers%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.trailers WHERE id = p_id;
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
    FUNCTION get_list RETURN trailers_api_tab IS
        --
        l_data trailers_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.trailers ORDER BY K_ORDER_LIST;
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
          FROM igtp.trailers;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id; 
    --
    -- insert
    PROCEDURE ins (
        p_id               IN trailers.id%TYPE,
        p_trailer_co       IN trailers.trailer_co%TYPE DEFAULT NULL,
        p_external_co      IN trailers.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id  IN trailers.type_vehicle_id%TYPE DEFAULT NULL,
        p_model            IN trailers.model%TYPE DEFAULT NULL,
        p_serial_chassis   IN trailers.serial_chassis%TYPE DEFAULT NULL,
        p_year             IN trailers.year%TYPE DEFAULT NULL,
        p_color            IN trailers.color%TYPE DEFAULT NULL, 
        p_partner_id       IN trailers.partner_id%TYPE DEFAULT NULL,
        p_k_status         IN trailers.k_status%TYPE DEFAULT 'AVAILABLE',
        p_employee_id      IN trailers.employee_id%TYPE DEFAULT NULL, 
        p_location_id      IN trailers.location_id%TYPE DEFAULT NULL,
        p_transfer_id      IN trailers.transfer_id%TYPE DEFAULT NULL, 
        p_user_id          IN trailers.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN trailers.created_at%TYPE DEFAULT sysdate,
        p_updated_at       IN trailers.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        INSERT INTO trailers(
            id,
            trailer_co,
            external_co,
            type_vehicle_id,
            model,
            serial_chassis,
            year,
            color, 
            partner_id,
            k_status,
            employee_id, 
            location_id,
            transfer_id, 
            user_id, 
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_trailer_co,
            p_external_co,
            p_type_vehicle_id,
            p_model,
            p_serial_chassis,
            p_year,
            p_color, 
            p_partner_id,
            p_k_status,
            p_employee_id, 
            p_location_id,
            p_transfer_id, 
            p_user_id, 
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT trailers%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.trailers VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id               IN trailers.id%TYPE,
        p_trailer_co       IN trailers.trailer_co%TYPE DEFAULT NULL,
        p_external_co      IN trailers.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id  IN trailers.type_vehicle_id%TYPE DEFAULT NULL,
        p_model            IN trailers.model%TYPE DEFAULT NULL,
        p_serial_chassis   IN trailers.serial_chassis%TYPE DEFAULT NULL,
        p_year             IN trailers.year%TYPE DEFAULT NULL,
        p_color            IN trailers.color%TYPE DEFAULT NULL, 
        p_partner_id       IN trailers.partner_id%TYPE DEFAULT NULL,
        p_k_status         IN trailers.k_status%TYPE DEFAULT 'AVAILABLE',
        p_employee_id      IN trailers.employee_id%TYPE DEFAULT NULL, 
        p_location_id      IN trailers.location_id%TYPE DEFAULT NULL,
        p_transfer_id      IN trailers.transfer_id%TYPE DEFAULT NULL, 
        p_user_id          IN trailers.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN trailers.created_at%TYPE DEFAULT NULL,
        p_updated_at       IN trailers.updated_at%TYPE DEFAULT sysdate
    ) IS
    BEGIN
        --
        UPDATE trailers 
           SET trailer_co = p_trailer_co,
               employee_id = p_employee_id,
               created_at = p_created_at,
               user_id = p_user_id,
               model = p_model,
               serial_chassis = p_serial_chassis,
               k_status = p_k_status,
               year = p_year,
               color = p_color,
               transfer_id = p_transfer_id,
               external_co = p_external_co,
               type_vehicle_id = p_type_vehicle_id,
               location_id = p_location_id,
               updated_at = p_updated_at,
               partner_id = p_partner_id
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT trailers%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.trailers 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id IN trailers.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM trailers
         WHERE id = p_id;
        -- 
    END del;
    --
end dsc_api_k_trailer;

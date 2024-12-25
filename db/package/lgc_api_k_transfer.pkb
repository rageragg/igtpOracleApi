
CREATE OR REPLACE PACKAGE BODY lgc_api_k_transfer IS
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN transfers.id%TYPE ) RETURN transfers%ROWTYPE IS
        --
        l_data transfers%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.transfers WHERE id = p_id;
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
    -- get DATA RETURN RECORD by FREIGHT ID
    FUNCTION get_record( p_freight_id       IN transfers.freight_id%TYPE,
                         p_sequence_number  IN transfers.sequence_number%TYPE DEFAULT NULL
                       ) RETURN transfers%ROWTYPE IS
        --
        l_data transfers%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.transfers 
             WHERE freight_id      = p_freight_id
               AND sequence_number = p_sequence_number;
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
    -- get DATA RETURN RECORD by current sequence
    FUNCTION get_current_sequence( p_freight_id IN transfers.freight_id%TYPE ) RETURN transfers%ROWTYPE IS
        --
        l_data transfers%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.transfers 
             WHERE freight_id      = p_freight_id
               AND sequence_number = ( SELECT max(sequence_number) 
                                         FROM igtp.transfers 
                                        WHERE freight_id = p_freight_id 
                                     );
        -- 
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_data;
        CLOSE c_data;
        --
        RETURN l_data;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN NULL;
        --
    END get_current_sequence; 
    --
    -- get DATA Array
    FUNCTION get_list(p_freight_id IN transfers.freight_id%TYPE) RETURN transfers_api_tab IS
        --
        l_data transfers_api_tab;
        l_idx  NUMBER   := 0;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.transfers 
             WHERE freight_id = p_freight_id
             ORDER BY K_ORDER_LIST;
        -- 
    BEGIN 
        --
        l_data.DELETE;
        --
        FOR r_reg IN c_data LOOP
            --
            l_idx := l_idx + 1;
            l_data(l_idx) := r_reg;
            --
        END LOOP;
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
          FROM igtp.transfers;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;     
    --
    -- insert
    PROCEDURE ins (
        p_id                IN transfers.id%TYPE,
        p_freight_id        IN transfers.freight_id%TYPE DEFAULT NULL,
        p_sequence_number   IN transfers.sequence_number%TYPE DEFAULT NULL,
        p_k_order           IN transfers.k_order%TYPE DEFAULT NULL,
        p_route_id          IN transfers.route_id%TYPE DEFAULT NULL,
        p_k_regimen         IN transfers.k_regimen%TYPE DEFAULT 'FREIGHT',
        p_k_status          IN transfers.k_status%TYPE DEFAULT 'PLANNED',
        p_k_process         IN transfers.k_process%TYPE DEFAULT 'LOGISTIC',
        p_k_type_transfer   IN transfers.k_type_transfer%TYPE DEFAULT 'TRANSFERENCE',
        p_planed_at         IN transfers.planed_at%TYPE DEFAULT NULL,
        p_start_date        IN transfers.start_at%TYPE DEFAULT NULL,
        p_end_date          IN transfers.end_at%TYPE DEFAULT NULL,
        p_main_employee_id  IN transfers.main_employee_id%TYPE DEFAULT NULL,
        p_aux_employee_id   IN transfers.aux_employee_id%TYPE DEFAULT NULL,
        p_truck_id          IN transfers.truck_id%TYPE DEFAULT NULL,
        p_trailer_id        IN transfers.trailer_id%TYPE DEFAULT NULL,
        p_user_id           IN transfers.user_id%TYPE DEFAULT NULL,
        p_created_at        IN transfers.created_at%TYPE DEFAULT sysdate,
        p_updated_at        IN transfers.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO transfers(
            created_at
            ,route_id
            ,freight_id
            ,k_regimen
            ,end_at
            ,user_id
            ,start_at
            ,k_status
            ,k_process
            ,aux_employee_id
            ,sequence_number
            ,k_order
            ,planed_at
            ,truck_id
            ,main_employee_id
            ,updated_at
            ,id
            ,trailer_id
            ,k_type_transfer
        ) VALUES (
            p_created_at
            ,p_route_id
            ,p_freight_id
            ,p_k_regimen
            ,p_end_date
            ,p_user_id
            ,p_start_date
            ,p_k_status
            ,p_k_process
            ,p_aux_employee_id
            ,p_sequence_number
            ,p_k_order
            ,p_planed_at
            ,p_truck_id
            ,p_main_employee_id
            ,p_updated_at
            ,p_id
            ,p_trailer_id
            ,p_k_type_transfer
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT transfers%ROWTYPE ) IS 
        --
        l_rec transfers%ROWTYPE;
        --
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.k_regimen IS NULL THEN 
            p_rec.k_regimen := K_REGIMEN_FREIGHT;
        END IF;
        --
        IF p_rec.k_status IS NULL THEN 
            p_rec.k_status := K_STATUS_PLANNED;
        END IF;
        --
        IF p_rec.k_process IS NULL THEN 
            p_rec.k_process := K_PROCESS_LOGISTIC;
        END IF;
        --
        IF p_rec.sequence_number IS NULL THEN 
            --
            l_rec  := get_current_sequence( p_freight_id => p_rec.freight_id );
            --
            IF l_rec.sequence_number IS NOT NULL THEN 
                p_rec.sequence_number  := nvl(l_rec.sequence_number, 0 ) + 1;
            ELSE 
                p_rec.sequence_number  := 1;
            END IF;    
            --
        END IF;
        --
        INSERT INTO igtp.transfers VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                IN transfers.id%TYPE,
        p_freight_id        IN transfers.freight_id%TYPE DEFAULT NULL,
        p_sequence_number   IN transfers.sequence_number%TYPE DEFAULT NULL,
        p_k_order           IN transfers.k_order%TYPE DEFAULT NULL,
        p_route_id          IN transfers.route_id%TYPE DEFAULT NULL,
        p_k_regimen         IN transfers.k_regimen%TYPE DEFAULT 'FREIGHT',
        p_k_status          IN transfers.k_status%TYPE DEFAULT 'PLANNED',
        p_k_process         IN transfers.k_process%TYPE DEFAULT 'LOGISTIC',
        p_k_type_transfer   IN transfers.k_type_transfer%TYPE DEFAULT NULL,
        p_planed_at       IN transfers.planed_at%TYPE DEFAULT NULL,
        p_start_date        IN transfers.start_at%TYPE DEFAULT NULL,
        p_end_date          IN transfers.end_at%TYPE DEFAULT NULL,
        p_main_employee_id  IN transfers.main_employee_id%TYPE DEFAULT NULL,
        p_aux_employee_id   IN transfers.aux_employee_id%TYPE DEFAULT NULL,
        p_truck_id          IN transfers.truck_id%TYPE DEFAULT NULL,
        p_trailer_id        IN transfers.trailer_id%TYPE DEFAULT NULL,
        p_user_id           IN transfers.user_id%TYPE DEFAULT NULL,
        p_created_at        IN transfers.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN transfers.updated_at%TYPE DEFAULT sysdate 
    ) IS
    BEGIN
        --
        UPDATE transfers 
           SET created_at = p_created_at
            ,route_id = p_route_id
            ,freight_id = p_freight_id
            ,k_regimen = p_k_regimen
            ,end_at = p_end_date
            ,user_id = p_user_id
            ,start_at = p_start_date
            ,k_status = p_k_status
            ,k_process = p_k_process
            ,aux_employee_id = p_aux_employee_id
            ,sequence_number = p_sequence_number
            ,k_order = p_k_order
            ,planed_at = p_planed_at
            ,truck_id = p_truck_id
            ,main_employee_id = p_main_employee_id
            ,updated_at = p_updated_at
            ,trailer_id = p_trailer_id
            ,k_type_transfer = p_k_type_transfer
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT transfers%ROWTYPE ) IS
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.transfers 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd; 
    --
    -- del
    PROCEDURE del ( p_id in transfers.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM transfers
         WHERE id = p_id;
        --
    END del;
    --
    -- max secuence
    FUNCTION get_max_secuence( p_id IN transfers.id%TYPE ) RETURN NUMBER IS 
        --
        l_max_secuence NUMBER;
        --
    BEGIN 
        --
        SELECT max(sequence_number) 
          INTO l_max_secuence
          FROM igtp.transfers 
         WHERE freight_id = p_id;
        --
        RETURN l_max_secuence;
        --
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                RETURN 0;
        --        
    END get_max_secuence;
    --
END lgc_api_k_transfer;

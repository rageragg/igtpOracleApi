
--------------------------------------------------------
--  DDL for Package Body FREIGHT_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY lgc_api_k_freight IS
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in freights.id%TYPE ) RETURN freights%ROWTYPE IS
        --
        l_data freights%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.freights WHERE id = p_id;
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
    FUNCTION get_list RETURN freights_api_tab IS
        --
        l_data freights_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.freights ORDER BY K_ORDER_LIST;
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
          FROM igtp.freights;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id; 
    --
    -- insert
    PROCEDURE ins (
        p_id                IN freights.id%TYPE,
        p_freights_co       IN freights.freights_co%TYPE DEFAULT NULL,
        p_customer_id       IN freights.customer_id%TYPE DEFAULT NULL,
        p_route_id          IN freights.route_id%TYPE DEFAULT NULL,
        p_type_cargo_id     IN freights.type_cargo_id%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN freights.type_vehicle_id%TYPE DEFAULT NULL,
        p_k_regimen         IN freights.k_regimen%TYPE DEFAULT 'FREIGHT',
        p_upload_at         IN freights.upload_at%TYPE DEFAULT NULL,
        p_start_at          IN freights.start_at%TYPE DEFAULT NULL,
        p_finish_at         IN freights.finish_at%TYPE DEFAULT NULL,
        p_notes             IN freights.notes%TYPE DEFAULT NULL,
        p_k_status          IN freights.k_status%TYPE DEFAULT 'PLANNED',
        p_k_process         IN freights.k_process%TYPE DEFAULT 'LOGISTY',
        p_user_id           IN freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN freights.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO freights(
            upload_at
            ,created_at
            ,customer_id
            ,route_id
            ,finish_at
            ,k_regimen
            ,user_id
            ,type_cargo_id
            ,freights_co
            ,k_status
            ,k_process
            ,notes
            ,start_at
            ,type_vehicle_id
            ,updated_at
            ,id
        ) values (
            p_upload_at
            ,p_created_at
            ,p_customer_id
            ,p_route_id
            ,p_finish_at
            ,p_k_regimen
            ,p_user_id
            ,p_type_cargo_id
            ,p_freights_co
            ,p_k_status
            ,p_k_process
            ,p_notes
            ,p_start_at
            ,p_type_vehicle_id
            ,p_updated_at
            ,p_id
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT freights%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
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
            p_rec.k_process := K_PROCESS_LOGISTY;
        END IF;
        --
        INSERT INTO igtp.freights VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                IN freights.id%TYPE,
        p_freights_co       IN freights.freights_co%TYPE DEFAULT NULL,
        p_customer_id       IN freights.customer_id%TYPE DEFAULT NULL,
        p_route_id          IN freights.route_id%TYPE DEFAULT NULL,
        p_type_cargo_id     IN freights.type_cargo_id%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN freights.type_vehicle_id%TYPE DEFAULT NULL,
        p_k_regimen         IN freights.k_regimen%TYPE DEFAULT NULL,
        p_upload_at         IN freights.upload_at%TYPE DEFAULT NULL,
        p_start_at          IN freights.start_at%TYPE DEFAULT NULL,
        p_finish_at         IN freights.finish_at%TYPE DEFAULT NULL,
        p_notes             IN freights.notes%TYPE DEFAULT NULL,
        p_k_status          IN freights.k_status%TYPE DEFAULT NULL,
        p_k_process         IN freights.k_process%TYPE DEFAULT NULL,
        p_user_id           IN freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN freights.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        UPDATE freights 
            SET upload_at = p_upload_at
                ,created_at = p_created_at
                ,customer_id = p_customer_id
                ,route_id = p_route_id
                ,finish_at = p_finish_at
                ,k_regimen = p_k_regimen
                ,user_id = p_user_id
                ,type_cargo_id = p_type_cargo_id
                ,freights_co = p_freights_co
                ,k_status = p_k_status
                ,k_process = p_k_process
                ,notes = p_notes
                ,start_at = p_start_at
                ,type_vehicle_id = p_type_vehicle_id
                ,updated_at = p_updated_at
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT freights%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.freights 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd; 
    --
    -- del
    PROCEDURE del ( p_id in freights.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM freights
         WHERE id = p_id;
        -- 
    END del;
    --
end lgc_api_k_freight;

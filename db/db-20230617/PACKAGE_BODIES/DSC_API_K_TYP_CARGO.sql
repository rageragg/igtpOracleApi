--------------------------------------------------------
--  DDL for Package Body DSC_API_K_TYP_CARGO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "IGTP"."DSC_API_K_TYP_CARGO" IS
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id in type_cargos.id%TYPE ) RETURN type_cargos%ROWTYPE IS
        --
        l_data type_cargos%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_cargos WHERE id = p_id;
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
    FUNCTION get_record( p_type_cargo_co in type_cargos.type_cargo_co%TYPE ) RETURN type_cargos%ROWTYPE IS
        --
        l_data type_cargos%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_cargos WHERE type_cargo_co =p_type_cargo_co;
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
    FUNCTION get_list RETURN type_cargos_api_tab IS
        --
        l_data type_cargos_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.type_cargos ORDER BY K_ORDER_LIST;
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
          FROM igtp.type_cargos;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;    
    --
    -- insert
    PROCEDURE ins (
        p_id            IN type_cargos.id%TYPE,
        p_type_cargo_co IN type_cargos.type_cargo_co%TYPE DEFAULT NULL, 
        p_description   IN type_cargos.description%TYPE DEFAULT NULL, 
        p_k_active      IN type_cargos.k_active%TYPE DEFAULT NULL, 
        p_user_id       IN type_cargos.user_id%TYPE DEFAULT NULL, 
        p_created_at    IN type_cargos.created_at%TYPE DEFAULT NULL, 
        p_updated_at    IN type_cargos.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO type_cargos(
            id,
            type_cargo_co,
            description,
            k_active,
            user_id,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_type_cargo_co,
            p_description,
            p_k_active,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT type_cargos%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.type_cargos VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id            IN type_cargos.id%TYPE,
        p_type_cargo_co IN type_cargos.type_cargo_co%TYPE DEFAULT NULL, 
        p_description   IN type_cargos.description%TYPE DEFAULT NULL, 
        p_k_active      IN type_cargos.k_active%TYPE DEFAULT NULL, 
        p_user_id       IN type_cargos.user_id%TYPE DEFAULT NULL, 
        p_created_at    IN type_cargos.created_at%TYPE DEFAULT NULL, 
        p_updated_at    IN type_cargos.updated_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        UPDATE type_cargos 
           SET user_id = p_user_id,
               type_cargo_co = p_type_cargo_co,
               description = p_description,
               k_active = p_k_active,
               created_at = p_created_at,
               updated_at = p_updated_at
         WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT type_cargos%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.type_cargos 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id in type_cargos.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM type_cargos
         WHERE id = p_id;
        -- 
    END del;
    --
end dsc_api_k_typ_cargo;

/

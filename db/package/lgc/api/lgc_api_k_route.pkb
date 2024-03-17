CREATE OR REPLACE PACKAGE BODY igtp.lgc_api_k_route IS
    ---------------------------------------------------------------------------
    --  DDL for Package routes_API (Process)
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
    --                                  rutas
    ---------------------------------------------------------------------------
    --
    g_record        routes%ROWTYPE;   
    --
    -- get DATA 
    FUNCTION get_record RETURN routes%ROWTYPE IS
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;  
    --
    -- get DATA RECORD by ID
    FUNCTION get_record( p_id in routes.id%TYPE )  RETURN routes%ROWTYPE IS 
        --
        l_data routes%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.routes WHERE id = p_id;
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
    FUNCTION get_record( p_route_co in routes.route_co%TYPE )  RETURN routes%ROWTYPE IS 
        --
        l_data routes%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.routes WHERE route_co = p_route_co;
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
    FUNCTION get_list RETURN routes_api_tab IS 
        --
        l_data routes_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.routes ORDER BY K_ORDER_LIST;
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
          FROM igtp.routes;
        --
        mx := mx + 1;
        --
        RETURN mx;  
        --
    END inc_id;
    --
    -- insert
    PROCEDURE ins (
        p_id                  routes.id%TYPE,
        p_route_co            routes.route_co%TYPE,
        p_description         routes.description%TYPE,
        p_from_city_id        routes.from_city_id%TYPE,
        p_to_city_id          routes.to_city_id%TYPE,
        p_k_level_co          routes.k_level_co%TYPE,
        p_distance_km         routes.distance_km%TYPE,
        p_estimated_time_hrs  routes.estimated_time_hrs%TYPE,
        p_slug                routes.slug%TYPE,
        p_uuid                routes.uuid%TYPE,
        p_user_id             routes.user_id%TYPE,
        p_created_at          routes.created_at%TYPE,
        p_updated_at          routes.updated_at%TYPE
    ) IS
        --
        mx  number(8)       := inc_id;
        ui  varchar2(60)    := sys_guid();
        --
    BEGIN
        --
        --
        IF p_id IS NOT NULL THEN 
            mx := p_id;
        END IF;    
        --
        IF p_uuid IS NOT NULL THEN 
            ui := p_uuid;
        END IF;  
        --
        INSERT INTO routes(
            id,
            route_co,
            description,
            from_city_id,
            to_city_id,
            k_level_co,
            distance_km,
            estimated_time_hrs,
            slug,
            uuid,
            user_id,
            created_at,
            updated_aT
        ) VALUES (
            mx,
            p_route_co,
            p_description,
            p_from_city_id,
            p_to_city_id,
            p_k_level_co,
            p_distance_km,
            p_estimated_time_hrs,
            p_slug,
            ui,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT routes%ROWTYPE ) IS
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
        INSERT INTO igtp.routes VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                  routes.id%TYPE,
        p_route_co            routes.route_co%TYPE,
        p_description         routes.description%TYPE,
        p_from_city_id        routes.from_city_id%TYPE,
        p_to_city_id          routes.to_city_id%TYPE,
        p_k_level_co          routes.k_level_co%TYPE,
        p_distance_km         routes.distance_km%TYPE,
        p_estimated_time_hrs  routes.estimated_time_hrs%TYPE,
        p_slug                routes.slug%TYPE,
        p_uuid                routes.uuid%TYPE,
        p_user_id             routes.user_id%TYPE,
        p_created_at          routes.created_at%TYPE,
        p_updated_at          routes.updated_at%TYPE
    ) IS
    BEGIN
        --
        UPDATE routes 
           SET route_co = p_route_co,
               description = p_description,
               from_city_id = p_from_city_id,
               to_city_id = p_to_city_id,
               k_level_co = p_k_level_co,
               distance_km = p_distance_km,
               estimated_time_hrs = p_estimated_time_hrs,
               slug = p_slug,
               uuid = p_uuid,
               user_id = p_user_id,
               updated_at = p_updated_at,
               created_at = p_created_at
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT routes%ROWTYPE ) IS
    BEGIN 
        --
        p_rec.updated_at  := sysdate;
        --
        UPDATE igtp.routes 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd; 
    --
    -- del
    PROCEDURE del ( p_id routes.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM routes
            WHERE id = p_id;
        --
    END del;
    --  
    -- exist route by id
    FUNCTION exist( p_id IN routes.id%TYPE ) RETURN BOOLEAN IS
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist route by code
    FUNCTION exist( p_route_co IN routes.route_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_route_co => p_route_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;    
    --
END lgc_api_k_route;
/

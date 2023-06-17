--------------------------------------------------------
--  DDL for Package Body CFG_API_K_ROUTE_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "IGTP"."CFG_API_K_ROUTE_LOCATION" IS
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
          FROM igtp.route_locations;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;
    --
    -- insert
    PROCEDURE ins (
            p_created_at    IN igtp.route_locations.created_at%TYPE DEFAULT NULL,
            p_description   IN igtp.route_locations.description%TYPE DEFAULT NULL,
            p_route_id      IN igtp.route_locations.route_id%TYPE DEFAULT NULL,
            p_user_id       IN igtp.route_locations.user_id%TYPE DEFAULT NULL,
            p_location_id   IN igtp.route_locations.location_id%TYPE DEFAULT NULL, 
            p_updated_at    IN igtp.route_locations.updated_at%TYPE DEFAULT NULL, 
            p_id            IN igtp.route_locations.id%type
        ) IS
        --
        mx  number(8)       := inc_id;
        --
    BEGIN
        --
        IF p_id IS NOT NULL THEN 
            mx := p_id;
        END IF;   
        --
        INSERT INTO igtp.route_locations(
            created_at,
            description,
            route_id,
            user_id,
            location_id,
            updated_at,
            id
        ) VALUES (
            p_created_at,
            p_description,
            p_route_id,
            p_user_id,
            p_location_id,
            p_updated_at,
            mx
        );
        --
    END ins;
    --
        --
    -- insert RECORD
    PROCEDURE ins ( 
            p_record IN OUT cfg_api_k_route_location.route_locations_api_rec
        ) IS
        --
        r_rec   igtp.route_locations%ROWTYPE;
        --
    BEGIN
        --
        IF p_record.id IS NULL THEN 
            p_record.id := inc_id;
        END IF; 
        --
        r_rec.id            := p_record.id;
        r_rec.route_id      := p_record.route_id;
        r_rec.location_id   := p_record.location_id;
        r_rec.description   := p_record.description;
        r_rec.user_id       := p_record.user_id; 
        r_rec.updated_at    := sysdate;
        r_rec.created_at    := sysdate;
        --
        INSERT INTO igtp.route_locations VALUES r_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
            p_created_at    IN igtp.route_locations.created_at%TYPE DEFAULT NULL,
            p_description   IN igtp.route_locations.description%TYPE DEFAULT NULL,
            p_route_id      IN igtp.route_locations.route_id%TYPE DEFAULT NULL,
            p_user_id       IN igtp.route_locations.user_id%TYPE DEFAULT NULL,
            p_location_id   IN igtp.route_locations.location_id%TYPE DEFAULT NULL, 
            p_updated_at    IN igtp.route_locations.updated_at%TYPE DEFAULT NULL, 
            p_id            IN igtp.route_locations.id%TYPE
        ) IS
    BEGIN
        --
        UPDATE igtp.route_locations 
           SET created_at  = p_created_at,
               description = p_description,
               route_id    = p_route_id,
               user_id     = p_user_id,
               location_id = p_location_id,
               updated_at  = p_updated_at
         WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( 
            p_record IN OUT cfg_api_k_route_location.route_locations_api_rec
        ) IS
        --
        r_rec   route_locations%ROWTYPE;
        --
    BEGIN 
        --
        r_rec.route_id      := p_record.route_id;
        r_rec.location_id   := p_record.location_id;
        r_rec.description   := p_record.description;
        r_rec.user_id       := p_record.user_id; 
        r_rec.updated_at    := sysdate;
        r_rec.created_at    := sysdate;
        --
        UPDATE igtp.route_locations 
           SET ROW = r_rec
         WHERE id = p_record.id;
        --         
    END upd;        
    --
    -- del
    PROCEDURE del (
            p_id IN igtp.route_locations.id%TYPE
        ) IS
    BEGIN
        --
        DELETE FROM igtp.route_locations
        WHERE id = p_id;
        --
    END del;
     --
    -- exist record
    FUNCTION existe_record ( 
            p_route_id      IN igtp.route_locations.route_id%TYPE DEFAULT NULL,
            p_location_id   IN igtp.route_locations.location_id%TYPE DEFAULT NULL
        ) RETURN BOOLEAN IS
        -- 
        l_count NUMBER  := 0;
        --
        CURSOR c_data IS  
            SELECT count(1)
              FROM igtp.route_locations
             WHERE route_id    = p_route_id 
               AND location_id = p_location_id;
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_count;
        CLOSE c_data;
        --
        RETURN (l_count > 0);
        --
    END existe_record;
    --
    -- build from route
    PROCEDURE build_from_route( 
            p_route_id IN igtp.route_locations.route_id%TYPE DEFAULT NULL 
        ) IS 
        --
        rf_locations_from   SYS_REFCURSOR;
        rf_locations_to     SYS_REFCURSOR;
        l_route_id          NUMBER(08);
        l_route_co          VARCHAR2(10);
        l_location_id       NUMBER(08);
        l_location_co       VARCHAR2(10);
        --
        CURSOR c_routes IS
            SELECT a.id route_id, a.route_co,
                   CURSOR(
                        SELECT c.id, c.location_co 
                          FROM igtp.locations c
                         WHERE c.city_id IN ( SELECT b.id FROM igtp.cities b WHERE b.id = a.from_city_id )
                   ) AS locations_from,
                   CURSOR(
                        SELECT c.id, c.location_co  
                          FROM igtp.locations c
                         WHERE c.city_id IN ( SELECT b.id FROM igtp.cities b WHERE b.id = a.to_city_id )
                   ) AS locations_to
              FROM igtp.routes a
             WHERE a.id = p_route_id;
        --
    BEGIN 
        --
        -- routes
        OPEN c_routes;
        --
        LOOP
            -- 
            FETCH c_routes INTO l_route_id,l_route_co, rf_locations_from, rf_locations_to;
            EXIT WHEN c_routes%NOTFOUND;                    
            --
            -- locations from
            IF rf_locations_from%ISOPEN THEN 
                --
                LOOP
                    FETCH rf_locations_from INTO l_location_id, l_location_co;
                    EXIT WHEN rf_locations_from%NOTFOUND;
                    --
                    IF NOT igtp.cfg_api_k_route_location.existe_record(l_route_id, l_location_id) THEN 
                        --
                        igtp.cfg_api_k_route_location.ins( 
                            p_created_at    => sysdate,
                            p_description   => l_route_co ||'/'||l_location_co,
                            p_route_id      => l_route_id,
                            p_user_id       => 1,
                            p_location_id   => l_location_id, 
                            p_updated_at    => sysdate, 
                            p_id            => NULL
                        );    
                        --
                    END IF;
                    --
                END LOOP;
                --    
            END IF;
            --
            -- locations to
            IF rf_locations_to%ISOPEN THEN 
                --
                LOOP
                    FETCH rf_locations_to INTO l_location_id, l_location_co;
                    EXIT WHEN rf_locations_to%NOTFOUND;
                    --
                    IF NOT igtp.cfg_api_k_route_location.existe_record(l_route_id, l_location_id) THEN 
                        --
                        igtp.cfg_api_k_route_location.ins( 
                            p_created_at    => sysdate,
                            p_description   => l_route_co ||'/'||l_location_co,
                            p_route_id      => l_route_id,
                            p_user_id       => 1,
                            p_location_id   => l_location_id, 
                            p_updated_at    => sysdate, 
                            p_id            => NULL
                        );    
                        --
                    END IF;
                    --
                END LOOP;
                -- 
            END IF;
            --
        END LOOP;
        --
        CLOSE c_routes;
        --
        COMMIT;
        --
    END build_from_route;    
    --
    -- bulding all
    PROCEDURE build_all IS 
    BEGIN 
        --
        FOR r IN (SELECT * FROM igtp.routes) LOOP  
            igtp.cfg_api_k_route_location.build_from_route( p_route_id => r.id );
        END LOOP;
        --
        COMMIT;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                ROLLBACK;
        --
    END build_all;
    --
END cfg_api_k_route_location;


/

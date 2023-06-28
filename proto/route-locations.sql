DECLARE 
    --
    -- routes/locations
    CURSOR c_routes IS 
        SELECT a.id, a.route_co, a.from_city_id, a.to_city_id,
               CURSOR( SELECT b.id, b.location_co FROM locations b WHERE b.city_id = a.from_city_id ) from_locations,
               CURSOR( SELECT c.id, c.location_co FROM locations c WHERE c.city_id = a.to_city_id ) to_locations
          FROM routes a;
    --
    l_route_id        routes.id%TYPE;
    l_route_co        routes.route_co%TYPE;
    l_from_city_id    routes.from_city_id%TYPE;
    l_to_city_id      routes.to_city_id%TYPE;
    --
    l_ref_fr_location SYS_REFCURSOR;      
    l_ref_to_location SYS_REFCURSOR;
    --
    l_location_id     locations.id%TYPE;   
    l_location_co     locations.location_co%TYPE; 
    --
    l_mx              NUMBER;
    --
BEGIN 
    --
    -- eliminamos toda la informacion
    DELETE FROM route_locations;
    --
    OPEN c_routes;
    --
    LOOP 
        --
        FETCH c_routes INTO l_route_id, l_route_co, l_from_city_id, l_to_city_id,
                            l_ref_fr_location, l_ref_to_location;
        --
        EXIT WHEN c_routes%NOTFOUND;
        --
        -- from
        LOOP 
            --
            FETCH l_ref_fr_location INTO l_location_id, l_location_co;
            EXIT WHEN l_ref_fr_location%NOTFOUND;
            --
            SELECT max(id)
              INTO l_mx
              FROM igtp.route_locations;
            --
            BEGIN 
                --
                l_mx := nvl(l_mx,0) + 1;
                --
                INSERT INTO route_locations( 
                    id, 
                    route_id, 
                    location_id, 
                    description, 
                    user_id, 
                    created_at, 
                    updated_at 
                ) VALUES( 
                    l_mx,
                    l_route_id,
                    l_location_id,
                    l_route_co||'/'||l_location_co,
                    1,
                    sysdate,
                    NULL
                );
                --
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                --
            END;              
            --
        END LOOP;    
        --
        -- to
        LOOP 
            --
            FETCH l_ref_to_location INTO l_location_id, l_location_co;
            EXIT WHEN l_ref_to_location%NOTFOUND;
            --
            SELECT max(id)
              INTO l_mx
              FROM igtp.route_locations;
            --
            BEGIN 
                --
                l_mx := nvl(l_mx,0) + 1;
                --
                INSERT INTO route_locations( 
                    id, 
                    route_id, 
                    location_id, 
                    description, 
                    user_id, 
                    created_at, 
                    updated_at 
                ) VALUES( 
                    l_mx,
                    l_route_id,
                    l_location_id,
                    l_route_co||'/'||l_location_co,
                    1,
                    sysdate,
                    NULL
                );
                --
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                --
            END;
            --
        END LOOP;
        --
    END LOOP;
    --
    CLOSE c_routes;
    --
    COMMIT;
    --
END;
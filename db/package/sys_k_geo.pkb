--------------------------------------------------------
--  DDL for Package sys_k_geo
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.sys_k_geo AS
    --
    -- VERSION: 1.00.00
    /* -------------------- DESCRIPCION -------------------- 
    || - Permite :
    ||   Funciones y procesos de calculo geoespacial
    */ ----------------------------------------------------- 
    --
    -- Para convertir grados a radianes, puede utilizar la siguiente fórmula:
    -- radianes = grados * pi / 180
    FUNCTION f_grade_to_radians( p_grade NUMBER ) RETURN NUMBER IS 
    BEGIN 
        --
        RETURN p_grade * sys_k_geo.K_PI / sys_k_geo.K_RADIAN_180;
        --
    END f_grade_to_radians;
    --
    -- La fórmula del Haversine es una ecuación astronómica que permite calcular la 
    -- distancia de círculo máximo entre dos puntos del globo terráqueo sabiendo 
    -- su longitud y su latitud. 
    -- La fórmula es la siguiente:
    --  d = 2 * r * arcsin( sqrt( sin²((lat2 - lat1)/2) + cos(lat1)cos(lat2)sin²((lon2 - lon1)/2)))
    -- Donde:
    --   •	d es la distancia entre los dos puntos en metros.
    --   •	r es el radio de la Tierra en metros (6,371,000 m).
    --   •	lat1 y lat2 son las latitudes de los dos puntos en radianes.
    --   •	lon1 y lon2 son las longitudes de los dos puntos en radianes.
    -- devuelve KM
    FUNCTION f_distance_points( p_lat_init NUMBER, 
                                p_lng_init NUMBER, 
                                p_lat_end  NUMBER, 
                                p_lng_end  NUMBER
                              ) RETURN NUMBER IS 
        --
        -- calculamos la diferencia en radianes radianes
        l_dif_lat   NUMBER := (f_grade_to_radians( p_lat_end )-f_grade_to_radians( p_lat_init ));
        l_dif_lng   NUMBER := (f_grade_to_radians( p_lng_end )-f_grade_to_radians( p_lng_init ));   
        l_lat_init  NUMBER := f_grade_to_radians( p_lat_init );
        l_lat_end   NUMBER := f_grade_to_radians( p_lat_end );
        --
        l_result    NUMBER;
        --                
    BEGIN 
        --
        SELECT  2 * sys_k_geo.K_RATIO_EARTH_MTS *
                asin(
                    sqrt(
                        power(sin(l_dif_lat/2),2) + 
                        cos(l_lat_init)*cos(l_lat_end)*power(sin(l_dif_lng/2),2) 
                    )
                )/1000
          INTO l_result
          FROM DUAL;
        --  
        RETURN l_result;
        --
    END f_distance_points;        
    --
    FUNCTION get_ecliptic_degree( p_degree    IN NUMBER,
                                  p_direction IN VARCHAR2
                                ) RETURN NUMBER IS
        --
        l_returnvalue number;
        --
    BEGIN
        --   
        IF p_direction in (K_LONGITUDE_DIRECTION_WEST, K_LATITUDE_DIRECTION_SOUTH) then
            l_returnvalue := 360 - p_degree;
        ELSE
            l_returnvalue := p_degree;
        END IF;
        --
        RETURN l_returnvalue;
        --
    END get_ecliptic_degree;  
    --
    FUNCTION get_ecliptic_distance( p_from_latitude     IN NUMBER,
                                    p_from_longitude    IN NUMBER,
                                    p_to_latitude       IN NUMBER,
                                    p_to_longitude      IN NUMBER,
                                    p_radius            IN NUMBER := K_RADIUS_EARTH_MILES
                                  ) RETURN NUMBER
    AS
        --
        l_returnvalue NUMBER;
    BEGIN
        --
        BEGIN
            l_returnvalue := (p_radius * acos((sin(p_from_latitude / K_DEGREES_TO_RADIANS_FACTOR) * sin(p_to_latitude / K_DEGREES_TO_RADIANS_FACTOR)) +
                (cos(p_from_latitude / K_DEGREES_TO_RADIANS_FACTOR) * cos(p_to_latitude /K_DEGREES_TO_RADIANS_FACTOR) *
                cos(p_to_longitude / K_DEGREES_TO_RADIANS_FACTOR - p_from_longitude/ K_DEGREES_TO_RADIANS_FACTOR))));
        EXCEPTION
            WHEN OTHERS THEN
            l_returnvalue := NULL;
        END;
        --            
        RETURN l_returnvalue;
        --
    END get_ecliptic_distance;                
    --
END sys_k_geo;
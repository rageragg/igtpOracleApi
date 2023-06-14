--------------------------------------------------------
--  DDL for Package sys_k_geo
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE igtp.sys_k_geo AS
    --
    -- VERSION: 1.00.00
    /* -------------------- DESCRIPCION -------------------- 
    || - Permite :
    ||   Funciones y procesos de calculo geoespacial
    */ ----------------------------------------------------- 
    --
    -- ! CONSTANTES
    K_PI                        CONSTANT NUMBER      := 3.14159;
    K_RATIO_EARTH_MTS           CONSTANT NUMBER      := 6371000.00;
    K_RADIAN_180                CONSTANT NUMBER      := 180; 
    K_RADIUS_EARTH_MILES        CONSTANT NUMBER      := 3443.917;
    K_DEGREES_TO_RADIANS_FACTOR CONSTANT NUMBER      := 57.29577951;
    --
    K_LATITUDE_DIRECTION_NORTH  CONSTANT VARCHAR2(1) := 'N';
    K_LATITUDE_DIRECTION_SOUTH  CONSTANT VARCHAR2(1) := 'S';
    K_LONGITUDE_DIRECTION_EAST  CONSTANT VARCHAR2(1) := 'E';
    K_LONGITUDE_DIRECTION_WEST  CONSTANT VARCHAR2(1) := 'W';
    --
    -- Para convertir grados a radianes, puede utilizar la siguiente fórmula:
    -- radianes = grados * pi / 180
    FUNCTION f_grade_to_radians( p_grade NUMBER )RETURN NUMBER;
    --
    -- La fórmula del Haversine es una ecuación astronómica que permite calcular la 
    -- distancia de círculo máximo entre dos puntos del globo terráqueo sabiendo 
    -- su longitud y su latitud. 
    -- La fórmula es la siguiente:
    --  d = 2r arcsin(sqrt(sin²((lat2 - lat1)/2) + cos(lat1)cos(lat2)sin²((lon2 - lon1)/2)))
    FUNCTION f_distance_points( p_lat_init NUMBER, 
                                p_lng_init NUMBER, 
                                p_lat_end  NUMBER, 
                                p_lng_end  NUMBER
                              ) RETURN NUMBER; 
    --
    -- get ecliptic degree of position
    FUNCTION get_ecliptic_degree( p_degree    IN NUMBER,
                                  p_direction IN VARCHAR2
                                ) RETURN NUMBER;                     
                     
  -- get distance between to geographic position
  FUNCTION get_ecliptic_distance( p_from_latitude   IN NUMBER,
                                  p_from_longitude  IN NUMBER,
                                  p_to_latitude     IN NUMBER,
                                  p_to_longitude    IN NUMBER,
                                  p_radius          IN NUMBER := K_RADIUS_EARTH_MILES
                                ) RETURN NUMBER;
    --
END sys_k_geo;
/

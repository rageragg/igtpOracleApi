
CREATE OR REPLACE PACKAGE igtp.prs_api_k_location IS
    ---------------------------------------------------------------------------
    --  DDL for Package LOCATIONS_API (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CITY                  PAQUETE DE BASE
    --  PRS_API_K_LANGUAGE              PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de locaciones
    ---------------------------------------------------------------------------
    --
    K_PROCESS    CONSTANT VARCHAR2(30)  := sys_k_constant.K_LOCATION_PROCESS;
    K_OWNER      CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_CONTEXT    CONSTANT VARCHAR2(30)  := sys_k_constant.K_LOCATION_CONTEXT;
    --
    TYPE location_api_doc IS RECORD(
        p_location_co       locations.location_co%TYPE DEFAULT NULL, 
        p_description       locations.description%TYPE DEFAULT NULL,
        p_postal_co         locations.postal_co%TYPE DEFAULT NULL, 
        p_city_co           cities.city_co%TYPE DEFAULT NULL,
        p_uuid              locations.uuid%TYPE DEFAULT NULL,
        p_slug              locations.slug%TYPE DEFAULT NULL,
        p_nu_gps_lat 		locations.nu_gps_lat%TYPE DEFAULT NULL, 
	    p_nu_gps_lon 		locations.nu_gps_lon%TYPE DEFAULT NULL,  
        p_user_co           users.user_co%TYPE DEFAULT NULL
    );
    --
    -- obteniendo el registro 
    FUNCTION get_record(
        p_location_co       locations.location_co%TYPE,
        p_result            OUT VARCHAR2 
    ) RETURN location_api_doc;
    --
    -- create locations
    PROCEDURE create_location (
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL,
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL,
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL,
        p_nu_gps_lat 		IN locations.nu_gps_lat%TYPE DEFAULT NULL, 
	    p_nu_gps_lon 		IN locations.nu_gps_lon%TYPE DEFAULT NULL,  
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2 
    );
    --
    -- insert RECORD
    PROCEDURE create_location( 
        p_rec       IN OUT location_api_doc,
        p_result    OUT VARCHAR2  
    );
    --
    -- create city by json
    PROCEDURE create_location( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update
    PROCEDURE update_location(
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL,
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL,
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL,
        p_nu_gps_lat 		IN locations.nu_gps_lat%TYPE DEFAULT NULL, 
	    p_nu_gps_lon 		IN locations.nu_gps_lon%TYPE DEFAULT NULL,  
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2  
    );
    --
    -- update RECORD 
    PROCEDURE update_location( 
        p_rec       IN OUT location_api_doc,
        p_result    OUT VARCHAR2  
    );    
    --
    -- delete
    PROCEDURE delete_location( 
        p_location_co   IN locations.location_co%TYPE,
        p_result        OUT VARCHAR2 
    );
    --
    -- load file masive data
    PROCEDURE load_file(
        p_json      IN VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
END prs_api_k_location;
/

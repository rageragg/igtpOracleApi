
CREATE OR REPLACE PACKAGE igtp.prs_api_k_city IS
    ---------------------------------------------------------------------------
    --  DDL for Package PRS_API_K_CITY (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CITY                  PAQUETE DE BASE
    --  CFG_API_K_MUNICIPALITY          PAQUETE DE BASE
    --  PRS_API_K_LANGUAGE              PAQUETE DE BASE
    --  SYS_K_CONSTANT                  PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de ciudades
    ---------------------------------------------------------------------------
    --
    K_PROCESS    CONSTANT VARCHAR2(30)  := sys_k_constant.K_CITY_PROCESS;
    K_OWNER      CONSTANT VARCHAR2(30)  := sys_k_constant.K_OWNER_APP;
    K_CONTEXT    CONSTANT VARCHAR2(30)  := sys_k_constant.K_CITY_CONTEXT;
    --
    TYPE city_api_doc IS RECORD(
        p_city_co           cities.city_co%TYPE DEFAULT NULL, 
        p_description       cities.description%TYPE DEFAULT NULL,
        p_telephone_co      cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   municipalities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              cities.uuid%TYPE DEFAULT NULL,
        p_slug              cities.slug%TYPE DEFAULT NULL,
        p_nu_gps_lat        cities.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        cities.nu_gps_lon%TYPE DEFAULT NULL,
        p_user_co           users.user_co%TYPE DEFAULT NULL
    );
    --
    -- obteniendo el registro 
    FUNCTION get_record(
        p_city_co           cities.city_co%TYPE,
        p_result            OUT VARCHAR2 
    ) RETURN city_api_doc;
    --
    -- create city by document
    PROCEDURE create_city (
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   IN municipalities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2 
    );
    --
    -- create city by record
    PROCEDURE create_city( 
        p_rec       IN OUT city_api_doc,
        p_result    OUT VARCHAR2  
    );
    --
    -- create city by json
    PROCEDURE create_city( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- create city by global data
    PROCEDURE create_city( 
        p_result    OUT VARCHAR2  
    );
    --
    -- update city by documents
    PROCEDURE update_city(
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   IN municipalities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2  
    );
    --
    -- update city by record
    PROCEDURE update_city( 
        p_rec       IN OUT city_api_doc,
        p_result    OUT VARCHAR2  
    );
    --
    -- update city by json
    PROCEDURE update_city( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2  
    );    
    --
    -- delete city by di
    PROCEDURE delete_city( 
        p_city_co   IN cities.city_co%TYPE,
        p_result    OUT VARCHAR2 
    );
    --
    -- get json based on city_api_doc
    FUNCTION get_json(
        p_city_co   IN cities.city_co%TYPE,
        p_result    OUT VARCHAR2 
    ) RETURN JSON_OBJECT_T;
    --
END prs_api_k_city;
/

---------------------------------------------------------------------------
--  DDL for Package CITIES_API (Process)
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
--  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
--                                  administrativos de creacion de ciudades
---------------------------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE igtp.cfg_api_k_city IS
    --
    K_PROCESS    CONSTANT VARCHAR2(20)  := 'PRC_API_K_CITY';
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    --
    TYPE city_api_doc IS RECORD(
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   IN cities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_co           IN cities.user_co%TYPE DEFAULT NULL
    );
    --
    -- create city
    PROCEDURE create_city (
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   IN cities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_co           IN cities.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2 
    );
    --
    -- insert RECORD
    PROCEDURE create_city( 
        p_rec       IN OUT city_api_doc,
        p_result    OUT VARCHAR2  
    );
    --
    -- update
    PROCEDURE update_city(
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   IN cities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_co           IN cities.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2  
    );
    --
    -- update RECORD
    PROCEDURE update_city( 
        p_rec       IN OUT city_api_doc,
        p_result    OUT VARCHAR2  
    );    
    --
    -- delete
    PROCEDURE delete_city( 
        p_co        IN cities.citie_co%TYPE,
        p_result    OUT VARCHAR2 
    );
    --
END cfg_api_k_city;
/

CREATE OR REPLACE PACKAGE igtp.json_api_k_city IS
    ---------------------------------------------------------------------------
    --  DDL for Package JSON_API_K_CITY (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    ---------------------------------------------------------------------------
    K_PROCESS    CONSTANT VARCHAR2(30)  := sys_k_constant.K_CITY_PROCESS;
    K_OWNER      CONSTANT VARCHAR2(30)  := sys_k_constant.K_OWNER_APP;
    K_CONTEXT    CONSTANT VARCHAR2(30)  := sys_k_constant.K_CITY_CONTEXT;
    --
    -- selecciona una ciudad por su id
    FUNCTION get_json(
        p_id        cities.id%TYPE,
        p_result    OUT VARCHAR2 
    ) RETURN JSON_OBJECT_T;    
    --
    -- selecciona una ciudad por su codigo
    FUNCTION get_json(
        p_city_co   cities.city_co%TYPE,
        p_result    OUT VARCHAR2 
    ) RETURN JSON_OBJECT_T;
    --
END json_api_k_city;
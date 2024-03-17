CREATE OR REPLACE PACKAGE prs_api_k_route IS
    ---------------------------------------------------------------------------
    --  DDL for Package ROUTE_API (Process)
    --  REFERENCES
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CITY                  PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de 
    --                                  rutas
    ---------------------------------------------------------------------------
    --
    -- CONSTANT
    K_OWNER         CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME    CONSTANT VARCHAR2(30)  := sys_k_constant.K_ROUTE_TABLE;
    K_LIMIT_LIST    CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST    CONSTANT PLS_INTEGER   := 2;
    K_PROCESS       CONSTANT VARCHAR2(30)  := sys_k_constant.K_ROUTE_PROCESS;
    K_CONTEXT       CONSTANT VARCHAR2(30)  := sys_k_constant.K_ROUTE_CONTEXT;   
    --
        --
    -- document
    TYPE route_api_doc IS RECORD(
        p_route_co              routes.route_co%TYPE,
        p_description           routes.descripcion%TYPE,
        p_from_city_co          routes.from_city_co%TYPE,
        p_to_city_co            routes.to_city_co%TYPE,
        p_distance_km           routes.distance_km%TYPE,
        p_estimated_time_hrs    routes.estimated_time_hrs%TYPE,
        p_uuid                  routes.uuid%TYPE,
        p_slug                  routes.slug%TYPE,
        p_user_co               users.user_co%TYPE
    );
    --
    -- plsq tables
    TYPE route_api_tab IS  TABLE OF routes%ROWTYPE;
    TYPE route_doc_tab IS  TABLE OF route_api_doc INDEX BY PLS_INTEGER;
    --
    -- create route by record
    PROCEDURE create_route( 
        p_rec       IN OUT route_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- create route by json
    PROCEDURE create_route( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update route by record
    PROCEDURE update_route(
        p_rec       IN OUT route_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- update route by json
    PROCEDURE update_route( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update route by json
    PROCEDURE delete_route( 
        p_route_co  IN routes.route_co%TYPE,
        p_result    OUT VARCHAR2 
    );
    --
    -- load file masive data
    PROCEDURE load_file(
        p_json      IN VARCHAR2,
        p_result    OUT VARCHAR2
    );    
    --
END prs_api_k_route;
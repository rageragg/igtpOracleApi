CREATE OR REPLACE PACKAGE prs_api_k_shop IS
    ---------------------------------------------------------------------------
    --  DDL for Package SHOP_API (Process)
    --  REFERENCES
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_LOCATION              PAQUETE DE BASE
    --  CFG_API_K_USER                  PAQUETE DE BASE
    --  PRS_API_K_LANGUAGE              PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de tiendas
    ---------------------------------------------------------------------------
    --
    K_OWNER         CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME    CONSTANT VARCHAR2(30)  := sys_k_constant.K_SHOP_TABLE;
    K_LIMIT_LIST    CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST    CONSTANT PLS_INTEGER   := 2;
    K_PROCESS       CONSTANT VARCHAR2(30)  := sys_k_constant.K_SHOP_PROCESS;
    K_CONTEXT       CONSTANT VARCHAR2(30)  := sys_k_constant.K_SHOP_CONTEXT;    
    --
    -- CONSTANTES DE NEGOCIO
    --
    -- document
    TYPE shop_api_doc IS RECORD(
        p_shop_co               shops.shop_co%TYPE,
        p_description           shops.description%TYPE,
        p_location_co           locations.location_co%TYPE,
        p_address               shops.address%TYPE,
        p_nu_gps_lat            shops.nu_gps_lat%TYPE,
        p_nu_gps_lon            shops.nu_gps_lon%TYPE,
        p_telephone_co          shops.telephone_co%TYPE,
        p_fax_co                shops.fax_co%TYPE,
        p_email                 shops.email%TYPE,
        p_name_contact          shops.name_contact%TYPE,
        p_email_contact         shops.email_contact%TYPE,
        p_telephone_contact     shops.telephone_contact%TYPE,
        p_user_co               users.user_co%TYPE,
        p_uuid                  shops.uuid%TYPE,
        p_slug                  shops.slug%TYPE
    );
    --
    -- plsq tables
    TYPE shop_api_tab IS  TABLE OF shops%ROWTYPE;
    TYPE shop_doc_tab IS  TABLE OF shop_api_doc INDEX BY PLS_INTEGER;
    --
    -- create shop by record
    PROCEDURE create_shop( 
        p_rec       IN OUT shop_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- create shop by json
    PROCEDURE create_shop( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update shop by record
    PROCEDURE update_shop(
        p_rec       IN OUT shop_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- update shop by json
    PROCEDURE update_shop( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update shop by json
    PROCEDURE delete_shop( 
        p_shop_co       IN shops.shop_co%TYPE,
        p_result        OUT VARCHAR2 
    );
--
    -- load file masive data
    PROCEDURE load_file(
        p_json      IN VARCHAR2,
        p_result    OUT VARCHAR2
    );    
    --
END prs_api_k_shop;
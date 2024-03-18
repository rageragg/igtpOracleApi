CREATE OR REPLACE PACKAGE prs_api_k_subsidiary IS
    ---------------------------------------------------------------------------
    --  DDL for Package SUBSIDIARY_API (Process)
    --  REFERENCES
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CUSTOMER              PAQUETE DE BASE
    --  CFG_API_K_SHOP                  PAQUETE DE BASE
    --  CFG_API_K_USER                  PAQUETE DE BASE
    --  PRS_API_K_LANGUAGE              PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de 
    --                                  subsidiarias
    ---------------------------------------------------------------------------
    --
    -- CONSTANT
    K_OWNER         CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME    CONSTANT VARCHAR2(30)  := sys_k_constant.K_SUBSIDIARY_TABLE;
    K_LIMIT_LIST    CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST    CONSTANT PLS_INTEGER   := 2;
    K_PROCESS       CONSTANT VARCHAR2(30)  := sys_k_constant.K_SUBSIDIARY_PROCESS;
    K_CONTEXT       CONSTANT VARCHAR2(30)  := sys_k_constant.K_SUBSIDIARY_CONTEXT;    
    --
    -- document
    TYPE subsidiary_api_doc IS RECORD(
        p_subsidiary_co         subsidiaries.subsidiary_co%TYPE,
        p_customer_co           customers.customer_co%TYPE,
        p_shop_co               shops.shop_co%TYPE,
        p_uuid                  subsidiaries.uuid%TYPE,
        p_slug                  subsidiaries.slug%TYPE,
        p_user_co               users.user_co%TYPE
    );
    --
    -- plsq tables
    TYPE subsidiary_api_tab IS  TABLE OF subsidiaries%ROWTYPE;
    TYPE subsidiary_doc_tab IS  TABLE OF subsidiary_api_doc INDEX BY PLS_INTEGER;
    --
    -- create subsidiary by record
    PROCEDURE create_subsidiary( 
        p_rec       IN OUT subsidiary_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- create subsidiary by json
    PROCEDURE create_subsidiary( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update subsidiary by record
    PROCEDURE update_subsidiary(
        p_rec       IN OUT subsidiary_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- update subsidiary by json
    PROCEDURE update_subsidiary( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update subsidiary by json
    PROCEDURE delete_subsidiary( 
        p_subsidiary_co IN subsidiaries.subsidiary_co%TYPE,
        p_result        OUT VARCHAR2 
    );
    --
    -- load file masive data
    PROCEDURE load_file(
        p_json      IN VARCHAR2,
        p_result    OUT VARCHAR2
    );    
    --
END prs_api_k_subsidiary;
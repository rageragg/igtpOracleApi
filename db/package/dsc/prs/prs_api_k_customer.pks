CREATE OR REPLACE NONEDITIONABLE PACKAGE prs_api_k_customer IS
    ---------------------------------------------------------------------------
    --  DDL for Package CUSTOMERS_API (Process)
    --  REFERENCIAS
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
    --                                  administrativos de creacion de clientes
    ---------------------------------------------------------------------------
    --
    K_OWNER         CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME    CONSTANT VARCHAR2(30)  := sys_k_constant.K_CUSTOMER_TABLE;
    K_LIMIT_LIST    CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST    CONSTANT PLS_INTEGER   := 2;
    K_PROCESS       CONSTANT VARCHAR2(30)  := sys_k_constant.K_CUSTOMER_PROCESS;
    K_CONTEXT       CONSTANT VARCHAR2(30)  := sys_k_constant.K_CUSTOMER_CONTEXT;
    --
    -- CONSTANTES DE NEGOCIO
    -- tipo de clientes
    K_TYPE_CUSTOMER_FACTORY     CONSTANT CHAR(01) := sys_k_constant.K_TYPE_CUSTOMER_FACTORY; 
    K_TYPE_CUSTOMER_DISTRIBUTOR CONSTANT CHAR(01) := sys_k_constant.K_TYPE_CUSTOMER_DISTRIB;
    K_TYPE_CUSTOMER_MARKET      CONSTANT CHAR(01) := sys_k_constant.K_TYPE_CUSTOMER_MARKET;
    --
    -- categoria de clientes
    K_CATEGORY_A                CONSTANT CHAR(01) := sys_k_constant.K_CUSTOMER_CATEGORY_A;
    K_CATEGORY_B                CONSTANT CHAR(01) := sys_k_constant.K_CUSTOMER_CATEGORY_B;
    K_CATEGORY_C                CONSTANT CHAR(01) := sys_k_constant.K_CUSTOMER_CATEGORY_C;
    --
    -- document
    TYPE customer_api_doc IS RECORD(
        p_customer_co           customers.customer_co%TYPE DEFAULT NULL,
        p_description           customers.description%TYPE DEFAULT NULL,
        p_telephone_co          customers.telephone_co%TYPE DEFAULT NULL,
        p_fax_co                customers.fax_co%TYPE DEFAULT NULL,
        p_email                 customers.email%TYPE DEFAULT NULL,
        p_address               customers.address%TYPE DEFAULT NULL,
        p_k_type_customer       customers.k_type_customer%TYPE DEFAULT NULL,
        p_k_sector              customers.k_sector%TYPE DEFAULT NULL,
        p_k_category_co         customers.k_category_co%TYPE DEFAULT NULL,
        p_fiscal_document_co    customers.fiscal_document_co%TYPE DEFAULT NULL,
        p_location_co           locations.location_co%TYPE DEFAULT NULL,
        p_telephone_contact     customers.telephone_contact%TYPE DEFAULT NULL,
        p_name_contact          customers.name_contact%TYPE DEFAULT NULL,
        p_email_contact         customers.email_contact%TYPE DEFAULT NULL,
        p_uuid                  customers.uuid%TYPE DEFAULT NULL,
        p_slug                  customers.slug%TYPE DEFAULT NULL,
        p_user_co               users.user_co%TYPE DEFAULT NULL,
        p_k_mca_inh             customers.k_mca_inh%TYPE DEFAULT 'N',
        p_created_at            customers.created_at%TYPE DEFAULT sysdate,
        p_updated_at            customers.updated_at%TYPE DEFAULT sysdate
    );
    --
    -- plsq tables
    TYPE customer_api_tab IS  TABLE OF customers%ROWTYPE;
    TYPE customer_doc_tab IS  TABLE OF customer_api_doc INDEX BY PLS_INTEGER;
    --
    -- manejo de log
    PROCEDURE record_log( 
        p_context  IN VARCHAR2,
        p_line     IN VARCHAR2,
        p_raw      IN VARCHAR2,
        p_result   IN VARCHAR,
        p_clob     IN OUT CLOB
    );    
    --
    -- create customer by record
    PROCEDURE create_customer( 
        p_rec       IN OUT customer_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- create customer by json
    PROCEDURE create_customer( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update customer by record
    PROCEDURE update_customer(
        p_rec       IN OUT customer_api_doc,
        p_result    OUT VARCHAR2
    );
    --
    -- update customer by json
    PROCEDURE update_customer( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- update customer by json
    PROCEDURE delete_customer( 
        p_customer_co   IN customers.customer_co%TYPE,
        p_result        OUT VARCHAR2 
    );
    --
    -- load file masive data
    PROCEDURE load_file(
        p_json      IN VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
END prs_api_k_customer;
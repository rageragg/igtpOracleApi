CREATE OR REPLACE PACKAGE prs_api_k_customer IS
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
    K_OWNER         CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME    CONSTANT VARCHAR2(30)  := 'CUSTOMERS';
    K_LIMIT_LIST    CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST    CONSTANT PLS_INTEGER   := 2;
    --
    -- CONSTANTES DE NEGOCIO
    -- tipo de clientes
    K_TYPE_CUSTOMER_FACTORY     CONSTANT CHAR(01) := 'F'; 
    K_TYPE_CUSTOMER_DISTRIBUTOR CONSTANT CHAR(01) := 'D';
    K_TYPE_CUSTOMER_MARKET      CONSTANT CHAR(01) := 'M';
    -- categoria de clientes
    K_CATEGORY_A                CONSTANT CHAR(01) := 'A';
    K_CATEGORY_B                CONSTANT CHAR(01) := 'B';
    K_CATEGORY_C                CONSTANT CHAR(01) := 'C';
    --
    -- document
    TYPE customer_api_doc IS RECORD(
        customer_co           customers.customer_co%TYPE DEFAULT NULL,
        description           customers.description%TYPE DEFAULT NULL,
        telephone_co          customers.telephone_co%TYPE DEFAULT NULL,
        fax_co                customers.fax_co%TYPE DEFAULT NULL,
        email                 customers.email%TYPE DEFAULT NULL,
        address               customers.address%TYPE DEFAULT NULL,
        k_type_customer       customers.k_type_customer%TYPE DEFAULT NULL,
        k_sector              customers.k_sector%TYPE DEFAULT NULL,
        k_category_co         customers.k_category_co%TYPE DEFAULT NULL,
        fiscal_document_co    customers.fiscal_document_co%TYPE DEFAULT NULL,
        location_co           locations.location_co%TYPE DEFAULT NULL,
        telephone_contact     customers.telephone_contact%TYPE DEFAULT NULL,
        name_contact          customers.name_contact%TYPE DEFAULT NULL,
        email_contact         customers.email_contact%TYPE DEFAULT NULL,
        uuid                  customers.uuid%TYPE DEFAULT NULL,
        slug                  customers.slug%TYPE DEFAULT NULL,
        user_co               users.user_co%TYPE DEFAULT NULL,
        k_mca_inh             customer.k_mca_inh%TYPE DEFAULT 'N',
        created_at            customers.created_at%TYPE DEFAULT sysdate,
        updated_at            customers.updated_at%TYPE DEFAULT sysdate
    );
    --
    -- plsq tables
    TYPE customer_api_tab IS  TABLE OF customers%ROWTYPE;
    TYPE customer_doc_tab IS  TABLE OF customer_api_doc INDEX BY PLS_INTEGER;
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
    ) RETURN BOOLEAN;
    --
    -- update customer by json
    PROCEDURE update_customer( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    );
    --
    -- TODO: desarrollar el metodo eliminar y de lista
    --
END prs_api_k_customer;
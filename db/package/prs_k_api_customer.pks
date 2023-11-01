--------------------------------------------------------
--  DDL for Package Body CUSTOMER_API
--  PROCESS
--------------------------------------------------------

CREATE OR REPLACE PACKAGE prs_api_k_customer IS
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
    TYPE customer_api_tab IS  TABLE OF customers%ROWTYPE;
    --
    -- DOCUMENT
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
        p_created_at            customers.created_at%TYPE DEFAULT sysdate,
        p_updated_at            customers.updated_at%TYPE DEFAULT sysdate
    );
    --
    -- CREATE CUSTOMER BY RECORD
    FUNCTION create( p_rec IN OUT customer_api_doc ) RETURN BOOLEAN;
    --
    -- CREATE CUSTOMER BY JSON
    -- TODO: FUNCTION create( p_rec IN OUT CLOB ) RETURN BOOLEAN;
    --
END prs_api_k_customer;

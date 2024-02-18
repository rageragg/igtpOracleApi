--------------------------------------------------------
--  DDL for Package Body CUSTOMER_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE dsc_api_k_customer IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'CUSTOMERS';
    K_CONTEXT    CONSTANT VARCHAR2(30)  := 'CUSTOMERS-ADMINISTRATOR';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE customer_api_tab IS  TABLE OF customers%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record RETURN customers%ROWTYPE;        
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN customers.id%TYPE ) RETURN customers%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_customer_co IN customers.customer_co%TYPE ) RETURN customers%ROWTYPE;   
    --
    -- get DATA Array
    FUNCTION get_list RETURN customer_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id                    IN customers.id%TYPE,
        p_customer_co           IN customers.customer_co%TYPE DEFAULT NULL,
        p_description           IN customers.description%TYPE DEFAULT NULL,
        p_telephone_co          IN customers.telephone_co%TYPE DEFAULT NULL,
        p_fax_co                IN customers.fax_co%TYPE DEFAULT NULL,
        p_email                 IN customers.email%TYPE DEFAULT NULL,
        p_address               IN customers.address%TYPE DEFAULT NULL,
        p_k_type_customer       IN customers.k_type_customer%TYPE DEFAULT NULL,
        p_k_sector              IN customers.k_sector%TYPE DEFAULT NULL,
        p_k_category_co         IN customers.k_category_co%TYPE DEFAULT NULL,
        p_fiscal_document_co    IN customers.fiscal_document_co%TYPE DEFAULT NULL,
        p_location_id           IN customers.location_id%TYPE DEFAULT NULL,
        p_telephone_contact     IN customers.telephone_contact%TYPE DEFAULT NULL,
        p_name_contact          IN customers.name_contact%TYPE DEFAULT NULL,
        p_email_contact         IN customers.email_contact%TYPE DEFAULT NULL,
        p_uuid                  IN customers.uuid%TYPE DEFAULT NULL,
        p_slug                  IN customers.slug%TYPE DEFAULT NULL,
        p_user_id               IN customers.user_id%TYPE DEFAULT NULL,
        p_created_at            IN customers.created_at%TYPE DEFAULT NULL,
        p_updated_at            IN customers.updated_at%TYPE DEFAULT NULL
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT customers%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
            p_id                    IN customers.id%TYPE,
            p_customer_co           IN customers.customer_co%TYPE DEFAULT NULL,
            p_description           IN customers.description%TYPE DEFAULT NULL,
            p_telephone_co          IN customers.telephone_co%TYPE DEFAULT NULL,
            p_fax_co                IN customers.fax_co%TYPE DEFAULT NULL,
            p_email                 IN customers.email%TYPE DEFAULT NULL,
            p_address               IN customers.address%TYPE DEFAULT NULL,
            p_k_type_customer       IN customers.k_type_customer%TYPE DEFAULT NULL,
            p_k_sector              IN customers.k_sector%TYPE DEFAULT NULL,
            p_k_category_co         IN customers.k_category_co%TYPE DEFAULT NULL,
            p_fiscal_document_co    IN customers.fiscal_document_co%TYPE DEFAULT NULL,
            p_location_id           IN customers.location_id%TYPE DEFAULT NULL,
            p_telephone_contact     IN customers.telephone_contact%TYPE DEFAULT NULL,
            p_name_contact          IN customers.name_contact%TYPE DEFAULT NULL,
            p_email_contact         IN customers.email_contact%TYPE DEFAULT NULL,
            p_uuid                  IN customers.uuid%TYPE DEFAULT NULL,
            p_slug                  IN customers.slug%TYPE DEFAULT NULL,
            p_user_id               IN customers.user_id%TYPE DEFAULT NULL,
            p_created_at            IN customers.created_at%TYPE DEFAULT NULL,
            p_updated_at            IN customers.updated_at%TYPE DEFAULT NULL
    );
    --
    -- upd RECORD
    PROCEDURE upd( p_rec IN OUT customers%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN customers.id%TYPE );
    --
    -- TODO: desarrollar las funciones que evaluan la existencia
    -- exist customer by id
    FUNCTION exist( p_id IN customers.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist customer by code
    FUNCTION exist( p_customer_co IN customers.customer_co%TYPE ) RETURN BOOLEAN;
    --
END dsc_api_k_customer;

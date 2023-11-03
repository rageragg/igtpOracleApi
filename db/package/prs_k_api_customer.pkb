--------------------------------------------------------
--  DDL for Package Body CUSTOMER_API
--  PROCESS
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY prs_api_k_customer IS
    --
    -- GLOBALES
    g_rec_customer      customer_api_doc;
    g_rec_locations     igtp.locations%ROWTYPE;
    g_rec_customers     igtp.customers%ROWTYPE;
     --
    -- TODO: crear el manejo de errores para transferirlo al nivel superior
    --
    -- VALIDATE type customer
    FUNCTION validate_type_customer RETURN BOOLEAN IS 
    BEGIN
        --
        -- se verifica que el tipo de cliente este dentro de los siguientes valores
        RETURN g_rec_customer.k_type_customer IN (
            K_TYPE_CUSTOMER_FACTORY,
            K_TYPE_CUSTOMER_DISTRIBUTOR,
            K_TYPE_CUSTOMER_MARKET
        );
        --
    END validate_type_customer;
    --
    -- VALIDATE type customer
    FUNCTION validate_location RETURN BOOLEAN IS 
    BEGIN
        --
        -- Se toma el registro de location por codigo
        g_rec_locations := NULL;
        g_rec_locations := igtp.cfg_api_k_location.get_record(
                                    p_location_co => g_rec_customer.location_co
                                );
        --
        RETURN ( g_rec_locations.id IS NOT NULL );
        --
    END validate_location;
    --
    -- VALIDATE email
    FUNCTION validate_email( p_email VARCHAR2 ) RETURN BOOLEAN IS 
    BEGIN
        --
        -- Se valida el email
        RETURN sys_k_string_util.validate_email( p_email );
        --
    END validate_email;
    --
    -- EXIST customer code
    FUNCTION exist_customer_code RETURN BOOLEAN IS
    BEGIN 
        --
        -- Se toma el registro de cliente por codigo
        g_rec_customers := NULL;
        g_rec_customers := igtp.dsc_api_k_customer.get_record(
                                    p_customer_co => g_rec_customer.customer_co
                                );
        --
        RETURN g_rec_customers.id IS NOT NULL;
        --
    END exist_customer_code;
    --
    -- VALIDATE category customer
    FUNCTION validate_category_customer RETURN BOOLEAN IS 
    BEGIN
        --
        -- se verifica que el tipo de cliente este dentro de los siguientes valores
        RETURN g_rec_customer.k_category_co IN (
            K_CATEGORY_A,
            K_CATEGORY_B,
            K_CATEGORY_C
        );
        --
    END validate_category_customer;
    --
    -- CREATE CUSTOMER BY DOCUMENT
    FUNCTION ins( 
            p_rec       IN OUT customer_api_doc,
            p_result    OUT VARCHAR2 
        ) RETURN BOOLEAN IS
        --
        -- excepciones
        e_validate_type_customer        EXCEPTION;
        e_validate_location             EXCEPTION;
        e_exist_customer_code           EXCEPTION;
        e_validate_category_customer    EXCEPTION; 
        e_validate_email                EXCEPTION;
        --
        PRAGMA exception_init( e_validate_type_customer, -20001 );
        PRAGMA exception_init( e_validate_location, -20002 );
        PRAGMA exception_init( e_exist_customer_code, -20003 );
        PRAGMA exception_init( e_validate_category_customer, -20004 );
        PRAGMA exception_init( e_validate_email, -20005 );
        --
        -- 
    BEGIN 
        --
        -- se establece el valor a la global 
        g_rec_customer := p_rec;
        --
        -- valida tipo de cliente 
        IF NOT validate_type_customer THEN 
            -- 
            p_result := 'INVALID TYPE CUSTOMER';
            raise_application_error(-20001, p_result );
            --
        END IF;
        --
        -- validamos el codigo de la localidad del cliente
        IF NOT validate_location THEN 
            -- 
            p_result := 'INVALID LOCATION CODE';
            raise_application_error(-20002, p_result );
            --
        END IF;
        --
        -- validamos que el codigo del cliente no este registrado
        IF exist_customer_code THEN 
            -- 
            p_result := 'INVALID CUSTOMER CODE';
            raise_application_error(-20003, p_result );
            --
        END IF;
        --
        -- validamos la categoria del cliente 
        IF NOT validate_category_customer THEN 
            -- 
            p_result := 'INVALID CATEGORY CODE';
            raise_application_error(-20004, p_result );
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_rec_customer.email ) THEN 
            -- 
            p_result := 'INVALID CUSTOMER EMAIL';
            raise_application_error(-20004, p_result );
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_rec_customer.email_contact ) THEN 
            -- 
            p_result := 'INVALID CONTACT EMAIL';
            raise_application_error(-20004, p_result );
            --
        END IF;
        --
        -- completamos los datos del cliente
        g_rec_customers.id                  := NULL;
        g_rec_customers.customer_co         := g_rec_customer.customer_co;
        g_rec_customers.description         := g_rec_customer.description;
        g_rec_customers.telephone_co        := g_rec_customer.telephone_co;
        g_rec_customers.fax_co              := g_rec_customer.fax_co;
        g_rec_customers.email               := g_rec_customer.email;
        g_rec_customers.address             := g_rec_customer.address;
        g_rec_customers.k_type_customer     := g_rec_customer.k_type_customer;
        g_rec_customers.k_sector            := g_rec_customer.k_sector;
        g_rec_customers.k_category_co       := g_rec_customer.k_category_co;
        g_rec_customers.fiscal_document_co  := g_rec_customer.fiscal_document_co;
        g_rec_customers.location_id         := g_rec_locations.id;
        g_rec_customers.telephone_contact   := g_rec_customer.telephone_contact;
        g_rec_customers.name_contact        := g_rec_customer.name_contact;
        g_rec_customers.email_contact       := g_rec_customer.email_contact;
        g_rec_customers.slug                := NULL;
        g_rec_customers.uuid                := NULL;
        g_rec_customers.k_mca_inh           := 'N';
        g_rec_customers.user_id             := NULL;
        g_rec_customers.created_at          := sysdate;
        --
        -- creamos el registro
        dsc_api_k_customer.ins( 
            p_rec => g_rec_customers
        );
        --
        p_result := 'ID: ' || g_rec_customers.id;
        --
        RETURN TRUE;
        --
        EXCEPTION 
            WHEN e_validate_type_customer       OR
                 e_validate_location            OR
                 e_exist_customer_code          OR
                 e_validate_category_customer   OR
                 e_validate_email               THEN 
                --
                RETURN FALSE;
                -- 
            WHEN OTHERS THEN 
                --
                IF p_result IS NULL THEN 
                    p_result := SQLERRM;
                END IF;
                --
                ROLLBACK;
                --
                RETURN FALSE;
        --
    END ins;
    --
END prs_api_k_customer;

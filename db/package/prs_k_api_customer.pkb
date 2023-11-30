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
    g_modo              VARCHAR2(20);
    --
    -- TODO: crear el manejo de errores para transferirlo al nivel superior
    --
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
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

    -- TODO: crear un sistema de regionalizacion de mensajes
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
    -- validacion total
    FUNCTION f_validation_all RETURN BOOLEAN IS 
    BEGIN  
        --
        g_hay_error := FALSE;
        --
        -- valida tipo de cliente 
        IF NOT validate_type_customer THEN 
            -- 
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID TYPE CUSTOMER';
            g_cod_error := -20001;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error;
            --
        END IF;
                
        --
        -- validamos el codigo de la localidad del cliente
        IF NOT validate_location THEN 
            -- 
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID LOCATION CODE';
            g_cod_error := -20002;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error;
            --
        END IF;
        --
        -- validamos que el codigo del cliente no este registrado
        IF exist_customer_code AND g_modo = 'INSERT' THEN
            --
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID CUSTOMER CODE';
            g_cod_error := -20003;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error; 
            -- 
        END IF;
        --
        -- validamos la categoria del cliente 
        IF NOT validate_category_customer THEN
            --
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID CATEGORY CODE';
            g_cod_error := -20003;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error; 
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_rec_customer.email ) THEN 
            --
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID CUSTOMER EMAIL';
            g_cod_error := -20004;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error; 
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_rec_customer.email_contact ) THEN 
            --
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID CONTACT EMAIL';
            g_cod_error := -20004;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error; 
            --
        END IF;
        --
    END p_validation_all;
    --
    -- CREATE CUSTOMER BY DOCUMENT
    FUNCTION ins( 
            p_rec       IN OUT customer_api_doc,
            p_result    OUT VARCHAR2 
        ) RETURN BOOLEAN IS
        --
        l_reg_user      igtp.users%ROWTYPE;
        --
    BEGIN 
        --
        -- se establece el valor a la global 
        g_rec_customer  := p_rec;
        g_modo          := 'INSERT';
        --
        -- validacion total
        IF NOT p_validation_all THEN
            --
            p_result := g_msg_error;
            raise_application_error(g_cod_error, g_msg_error );
            -- 
        ELSE
            --
            p_result := NULL;
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
        g_rec_customers.slug                := g_rec_customer.slug;
        g_rec_customers.uuid                := NULL;
        g_rec_customers.k_mca_inh           := 'N';
        g_rec_customers.created_at          := sysdate;
        --
        --
        -- TODO: buscar el id del usuario
        l_rec_user := sec_api_k_user.get_record(
            p_user_co => g_rec_customer.user_co
        );
        g_rec_customers.user_id             := l_rec_user.id;
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
    -- CREATE CUSTOMER BY JSON
    FUNCTION ins( 
            p_josn      IN OUT VARCHAR2,
            p_result    OUT VARCHAR2
        ) RETURN BOOLEAN IS 
        --
        l_obj       json_object_t;
        --
    BEGIN 
        --
        g_modo  := 'INSERT';
        -- analizamos los datos JSON
        l_obj   := json_object_t.parse(p_josn);
        --
        -- completamos los datos del registro customer
        r_customer.customer_co        := l_obj.get_string('customer_co');
        r_customer.description        := l_obj.get_string('description');
        r_customer.telephone_co       := l_obj.get_string('telephone_co');
        r_customer.fax_co             := l_obj.get_string('fax_co');
        r_customer.email              := l_obj.get_string('email');
        r_customer.address            := l_obj.get_string('address');
        r_customer.k_type_customer    := l_obj.get_string('k_type_customer');
        r_customer.k_sector           := l_obj.get_string('k_sector');
        r_customer.k_category_co      := l_obj.get_string('k_category_co');
        r_customer.fiscal_document_co := l_obj.get_string('fiscal_document_co');
        r_customer.location_co        := l_obj.get_string('location_co');
        r_customer.telephone_contact  := l_obj.get_string('telephone_contact');
        r_customer.name_contact       := l_obj.get_string('name_contact');
        r_customer.email_contact      := l_obj.get_string('email_contact');
        r_customer.slug               := l_obj.get_string('slug');
        r_customer.user_co            := l_obj.get_string('user_co');
        --
        l_ok := ins( 
                p_rec       => r_customer,
                p_result    => p_result
        );
        --
        RETURN l_ok;
        --
        EXCEPTIONS
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
    -- UPDATE CUSTOMER BY RECORD
    PROCEDURE upd(
            p_rec       IN OUT customer_api_doc,
            p_result    OUT VARCHAR2
        ) RETURN BOOLEAN IS
        --
        l_reg_customer  igtp.customers%ROWTYPE;
        l_reg_user      igtp.users%ROWTYPE;
        --
    BEGIN 
        --
        -- se establece el valor a la global 
        g_rec_customer  := p_rec;
        g_modo          := 'UPDATE';
        --
        -- validacion total
        IF NOT p_validation_all THEN
            --
            p_result := g_msg_error;
            raise_application_error(g_cod_error, g_msg_error );
            -- 
        ELSE
            --
            p_result := NULL;
            --
        END IF;
        --
        -- verificamos que exista
        l_reg_customer := dsc_api_k_customer.get_record( 
            p_customer_co => l_reg.customer_co
        );
        --
        -- completamos los datos del cliente
        g_rec_customers.id                  := l_reg_customer.id;
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
        g_rec_customers.slug                := g_rec_customer.slug;
        g_rec_customers.uuid                := g_rec_customer.uuid;
        g_rec_customers.k_mca_inh           := g_rec_customer.k_mca_inh;
        --
        -- TODO: buscar el id del usuario
        l_rec_user := sec_api_k_user.get_record(
            p_user_co => l_reg_customer.user_co
        );
        --
        g_rec_customers.user_id             := l_rec_user.id;
        g_rec_customers.created_at          := sysdate;
        --
        -- creamos el registro
        dsc_api_k_customer.upd( 
            p_rec => g_rec_customers
        );
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
    END upd;
    --
END prs_api_k_customer;

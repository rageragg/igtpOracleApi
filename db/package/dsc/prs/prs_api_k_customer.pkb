CREATE OR REPLACE PACKAGE BODY prs_api_k_customer IS
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
    -- GLOBALES
    g_doc_customer      customer_api_doc;
    g_rec_locations     igtp.locations%ROWTYPE;
    g_rec_customer      igtp.customers%ROWTYPE;
    g_rec_user          igtp.users%ROWTYPE;
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
    e_validate_user                 EXCEPTION;
    --
    PRAGMA exception_init( e_validate_type_customer, -20001 );
    PRAGMA exception_init( e_validate_location, -20002 );
    PRAGMA exception_init( e_exist_customer_code, -20003 );
    PRAGMA exception_init( e_validate_category_customer, -20004 );
    PRAGMA exception_init( e_validate_email, -20005 );
    PRAGMA exception_init( e_validate_user, -20006 );
    --
    -- raise_error 
    PROCEDURE raise_error( 
        p_cod_error NUMBER,
        p_msg_error VARCHAR2
    ) IS 
    BEGIN 
        --
        -- TODO: regionalizacion de mensajes
        g_cod_error := p_cod_error;
        g_hay_error := TRUE;
        --
        g_msg_error := prs_k_api_language.f_message( 
            p_language_co => sys_k_global.geter('LANGUAGE_CO'),
            p_context     => K_PROCESS,
            p_error_co    => g_cod_error 
        );
        --
        g_msg_error := nvl(g_msg_error, p_msg_error );
        --
        raise_application_error(g_cod_error, g_msg_error );
        -- 
    END raise_error;    
    --
    -- TODO: crear un sistema de regionalizacion de mensajes
    --
    -- VALIDATE type customer
    FUNCTION validate_type_customer RETURN BOOLEAN IS 
    BEGIN
        --
        -- se verifica que el tipo de cliente este dentro de los siguientes valores
        RETURN g_doc_customer.k_type_customer IN (
            K_TYPE_CUSTOMER_FACTORY,
            K_TYPE_CUSTOMER_DISTRIBUTOR,
            K_TYPE_CUSTOMER_MARKET
        );
        --
    END validate_type_customer;
    --
    -- VALIDATE category customer
    FUNCTION validate_category_customer RETURN BOOLEAN IS 
    BEGIN
        --
        -- se verifica que el tipo de cliente este dentro de los siguientes valores
        RETURN g_doc_customer.k_category_co IN (
            K_CATEGORY_A,
            K_CATEGORY_B,
            K_CATEGORY_C
        );
        --
    END validate_category_customer;
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
    -- validacion total
    PROCEDURE validate_all IS 
    BEGIN  
        --
        -- valida tipo de cliente 
        IF NOT validate_type_customer THEN 
            --
            raise_error( 
                p_cod_error => -20001,
                p_msg_error => 'INVALID TYPE CUSTOMER'
            );
            --
        END IF;                
        --
        -- validamos la categoria del cliente 
        IF NOT validate_category_customer THEN
            --
            raise_error( 
                p_cod_error => -20004,
                p_msg_error => 'INVALID CATEGORY CODE'
            );
            --
        END IF;        
        --
        -- validamos el codigo de la localidad del cliente
        IF NOT cfg_api_k_location.exist( p_location_co =>  g_doc_customer.location_co ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20002,
                p_msg_error => 'INVALID LOCATION CODE'
            );
            --
        ELSE 
            --
            g_rec_locations := igtp.cfg_api_k_location.get_record;
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_doc_customer.email ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20005,
                p_msg_error => 'INVALID CUSTOMER EMAIL'
            );
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_doc_customer.email_contact ) THEN 
            --
            -- TODO: regionalizacion de mensajes
            g_msg_error := 'INVALID CONTACT EMAIL';
            g_cod_error := -20005;
            g_hay_error := TRUE;
            --
            RETURN g_hay_error; 
            --
        END IF;
        --
        -- validamos el codigo del usuario
        IF NOT sec_api_k_user.exist( p_user_co =>  g_doc_customer.user_co ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20006,
                p_msg_error => 'INVALID USER CODE'
            );
            --
        ELSE 
            --
            g_rec_user := sec_api_k_user.get_record;
            --
        END IF;
        --
    END validate_all;
    --
    -- CREATE CUSTOMER BY DOCUMENT
    PROCEDURE create_customer( 
            p_rec       IN OUT customer_api_doc,
            p_result    OUT VARCHAR2 
        ) IS
    BEGIN 
        --
        -- se establece el valor a la global 
        g_doc_customer  := p_rec;
        --
        -- verificamos que el codigo de cliente no exista
        IF dsc_api_k_customer.exist( p_customer_co => p_rec.p_customer_co )
            --
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID CUSTOMER CODE'
            );
            --
        END IF; 
        --
        -- validacion total
        validate_all;
        --
        -- completamos los datos del cliente
        g_rec_customer.id                  := NULL;
        g_rec_customer.customer_co         := g_doc_customer.customer_co;
        g_rec_customer.description         := g_doc_customer.description;
        g_rec_customer.telephone_co        := g_doc_customer.telephone_co;
        g_rec_customer.fax_co              := g_doc_customer.fax_co;
        g_rec_customer.email               := g_doc_customer.email;
        g_rec_customer.address             := g_doc_customer.address;
        g_rec_customer.k_type_customer     := g_doc_customer.k_type_customer;
        g_rec_customer.k_sector            := g_doc_customer.k_sector;
        g_rec_customer.k_category_co       := g_doc_customer.k_category_co;
        g_rec_customer.fiscal_document_co  := g_doc_customer.fiscal_document_co;
        g_rec_customer.location_id         := g_rec_locations.id;
        g_rec_customer.telephone_contact   := g_doc_customer.telephone_contact;
        g_rec_customer.name_contact        := g_doc_customer.name_contact;
        g_rec_customer.email_contact       := g_doc_customer.email_contact;
        g_rec_customer.uuid                := NULL;
        g_rec_customer.k_mca_inh           := 'N';
        g_rec_customer.created_at          := sysdate;
        g_rec_customer.user_id             := g_rec_user.id;
        --
        g_rec_customer.slug                := g_doc_customer.slug;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_rec_customer.slug :=  lower( substr(g_rec_municipality.slug||'-'||g_rec_customer.customer_co,1,60) );
            --
        ELSE
            --
            g_rec_customer.slug :=  g_doc_customer.p_slug;
            --
        END IF;
        --
        -- creamos el registro
        dsc_api_k_customer.ins( 
            p_rec => g_rec_customer
        );
        --
        p_rec := g_rec_customer;
        p_result := 'ID: ' || g_rec_customer.id;
        --
        COMMIT;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        EXCEPTION 
            WHEN e_validate_type_customer       OR
                 e_validate_location            OR
                 e_exist_customer_code          OR
                 e_validate_category_customer   OR
                 e_validate_email               
                 e_validate_user THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| g_msg_error ||'" }';
                -- 
            WHEN OTHERS THEN 
                --
                IF p_result IS NULL THEN 
                    --
                    p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                    --
                END IF;
                --
                ROLLBACK;
                --
        --
    END create_customer;
    --
    -- CREATE CUSTOMER BY JSON
    PROCEDURE create_customer( 
            p_josn      IN OUT VARCHAR2,
            p_result    OUT VARCHAR2
        ) IS 
        --
        l_obj       json_object_t;
        --
    BEGIN 
        --
        NULL;
        /*
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
        l_ok := create_customer( 
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
        */
    END create_customer;
    --
    -- UPDATE CUSTOMER BY RECORD
    PROCEDURE update_customer(
            p_rec       IN OUT customer_api_doc,
            p_result    OUT VARCHAR2
        ) IS
        --
        l_reg_customer  igtp.customers%ROWTYPE;
        g_rec_user      igtp.users%ROWTYPE;
        --
    BEGIN
        --
        NULL;
        /*
        --
        -- se establece el valor a la global 
        g_doc_customer  := p_rec;
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
        g_rec_customer.id                  := l_reg_customer.id;
        g_rec_customer.customer_co         := g_doc_customer.customer_co;
        g_rec_customer.description         := g_doc_customer.description;
        g_rec_customer.telephone_co        := g_doc_customer.telephone_co;
        g_rec_customer.fax_co              := g_doc_customer.fax_co;
        g_rec_customer.email               := g_doc_customer.email;
        g_rec_customer.address             := g_doc_customer.address;
        g_rec_customer.k_type_customer     := g_doc_customer.k_type_customer;
        g_rec_customer.k_sector            := g_doc_customer.k_sector;
        g_rec_customer.k_category_co       := g_doc_customer.k_category_co;
        g_rec_customer.fiscal_document_co  := g_doc_customer.fiscal_document_co;
        g_rec_customer.location_id         := g_rec_locations.id;
        g_rec_customer.telephone_contact   := g_doc_customer.telephone_contact;
        g_rec_customer.name_contact        := g_doc_customer.name_contact;
        g_rec_customer.email_contact       := g_doc_customer.email_contact;
        g_rec_customer.slug                := g_doc_customer.slug;
        g_rec_customer.uuid                := g_doc_customer.uuid;
        g_rec_customer.k_mca_inh           := g_doc_customer.k_mca_inh;
        --
        -- TODO: buscar el id del usuario
        l_rec_user := sec_api_k_user.get_record(
            p_user_co => l_reg_customer.user_co
        );
        --
        g_rec_customer.user_id             := l_rec_user.id;
        g_rec_customer.created_at          := sysdate;
        --
        -- creamos el registro
        dsc_api_k_customer.upd( 
            p_rec => g_rec_customer
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
        */ 
    END update_customer;
    --
    --
    -- update customer by json
    PROCEDURE update_customer( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    ) IS 
    BEGIN
      NULL; 
    END update_customer;
    --
END prs_api_k_customer;

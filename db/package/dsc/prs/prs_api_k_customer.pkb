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
    K_CFG_CO     CONSTANT NUMBER        := 1;
    --
    -- GLOBALES
    g_doc_customer      customer_api_doc;
    g_rec_locations     igtp.locations%ROWTYPE;
    g_rec_customer      igtp.customers%ROWTYPE;
    g_rec_user          igtp.users%ROWTYPE;
    --
    -- TODO: crear el manejo de errores para transferirlo al nivel superior
    --
    g_cfg_co                        configurations.id%TYPE;
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    g_reg_config                    configurations%ROWTYPE;
    -- excepciones
    e_validate_type_customer        EXCEPTION;
    e_validate_location             EXCEPTION;
    e_exist_customer_code           EXCEPTION;
    e_validate_category_customer    EXCEPTION; 
    e_validate_email                EXCEPTION;
    e_validate_user                 EXCEPTION;
    e_no_exist_customer_code        EXCEPTION;
    --
    PRAGMA exception_init( e_validate_type_customer, -20001 );
    PRAGMA exception_init( e_validate_location, -20002 );
    PRAGMA exception_init( e_exist_customer_code, -20003 );
    PRAGMA exception_init( e_validate_category_customer, -20004 );
    PRAGMA exception_init( e_validate_email, -20005 );
    PRAGMA exception_init( e_validate_user, -20006 );
    PRAGMA exception_init( e_no_exist_customer_code, -20007 );
    --
    -- raise_error 
    PROCEDURE raise_error( 
        p_cod_error NUMBER,
        p_msg_error VARCHAR2
    ) IS 
    BEGIN 
        --
        -- TODO: regionalizacion de mensajes
        g_msg_error := p_msg_error;
        g_cod_error := p_cod_error;
        g_hay_error := TRUE;
        --
        g_msg_error := prs_api_k_language.f_message( 
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
        RETURN g_doc_customer.p_k_type_customer IN (
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
        RETURN g_doc_customer.p_k_category_co IN (
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
        IF NOT cfg_api_k_location.exist( p_location_co =>  g_doc_customer.p_location_co ) THEN 
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
        IF NOT validate_email( g_doc_customer.p_email ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20005,
                p_msg_error => 'INVALID CUSTOMER EMAIL'
            );
            --
        END IF;
        --
        -- validamos el email del cliente 
        IF NOT validate_email( g_doc_customer.p_email_contact ) THEN 
            --
            raise_error( 
                p_cod_error => -20005,
                p_msg_error => 'INVALID CONTACT EMAIL'
            );
            --
            --
        END IF;
        --
        -- validamos el codigo del usuario
        IF NOT sec_api_k_user.exist( p_user_co =>  g_doc_customer.p_user_co ) THEN 
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
        IF dsc_api_k_customer.exist( p_customer_co => p_rec.p_customer_co ) THEN
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
        g_rec_customer.customer_co         := g_doc_customer.p_customer_co;
        g_rec_customer.description         := g_doc_customer.p_description;
        g_rec_customer.telephone_co        := g_doc_customer.p_telephone_co;
        g_rec_customer.fax_co              := g_doc_customer.p_fax_co;
        g_rec_customer.email               := g_doc_customer.p_email;
        g_rec_customer.address             := g_doc_customer.p_address;
        g_rec_customer.k_type_customer     := g_doc_customer.p_k_type_customer;
        g_rec_customer.k_sector            := g_doc_customer.p_k_sector;
        g_rec_customer.k_category_co       := g_doc_customer.p_k_category_co;
        g_rec_customer.fiscal_document_co  := g_doc_customer.p_fiscal_document_co;
        g_rec_customer.location_id         := g_rec_locations.id;
        g_rec_customer.telephone_contact   := g_doc_customer.p_telephone_contact;
        g_rec_customer.name_contact        := g_doc_customer.p_name_contact;
        g_rec_customer.email_contact       := g_doc_customer.p_email_contact;
        g_rec_customer.uuid                := NULL;
        g_rec_customer.k_mca_inh           := 'N';
        g_rec_customer.created_at          := sysdate;
        g_rec_customer.user_id             := g_rec_user.id;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_rec_customer.slug :=  lower( substr(g_rec_locations.slug||'-'||g_rec_customer.customer_co,1,60) );
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
        p_rec.p_uuid    := g_rec_customer.uuid;
        p_rec.p_slug    := g_rec_customer.slug;
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
                 e_validate_email               OR    
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
            p_json      IN OUT VARCHAR2,
            p_result    OUT VARCHAR2
        ) IS 
        --
        l_obj       json_object_t;
        --
    BEGIN 
        --
        -- analizamos los datos JSON
        l_obj   := json_object_t.parse(p_json);
        --
        -- completamos los datos del registro customer
        g_doc_customer.p_customer_co        := l_obj.get_string('customer_co');
        g_doc_customer.p_description        := l_obj.get_string('description');
        g_doc_customer.p_telephone_co       := l_obj.get_string('telephone_co');
        g_doc_customer.p_fax_co             := l_obj.get_string('fax_co');
        g_doc_customer.p_email              := l_obj.get_string('email');
        g_doc_customer.p_address            := l_obj.get_string('address');
        g_doc_customer.p_k_type_customer    := l_obj.get_string('k_type_customer');
        g_doc_customer.p_k_sector           := l_obj.get_string('k_sector');
        g_doc_customer.p_k_category_co      := l_obj.get_string('k_category_co');
        g_doc_customer.p_fiscal_document_co := l_obj.get_string('fiscal_document_co');
        g_doc_customer.p_location_co        := l_obj.get_string('location_co');
        g_doc_customer.p_telephone_contact  := l_obj.get_string('telephone_contact');
        g_doc_customer.p_name_contact       := l_obj.get_string('name_contact');
        g_doc_customer.p_email_contact      := l_obj.get_string('email_contact');
        g_doc_customer.p_slug               := l_obj.get_string('slug');
        g_doc_customer.p_user_co            := l_obj.get_string('user_co');
        --
        create_customer( 
                p_rec       => g_doc_customer,
                p_result    => p_result
        );
        --
        l_obj.put('slug', g_doc_customer.p_slug);
        l_obj.put('uuid', g_doc_customer.p_uuid);
        p_json := l_obj.stringify; 
        --
        EXCEPTION
            WHEN OTHERS THEN 
                --
                IF p_result IS NULL THEN 
                    p_result :=  '{ "status":"ERROR", "message":"'||SQLERRM||'" }';
                END IF;
                --
                ROLLBACK;
                --
        --
    END create_customer;
    --
    -- UPDATE CUSTOMER BY RECORD
    PROCEDURE update_customer(
            p_rec       IN OUT customer_api_doc,
            p_result    OUT VARCHAR2
        ) IS
    BEGIN
        --
        -- se establece el valor a la global 
        g_doc_customer  := p_rec;
        --
        -- verificamos que el codigo de cliente no exista
        IF dsc_api_k_customer.exist( p_customer_co => p_rec.p_customer_co ) THEN
            --
            g_rec_customer := dsc_api_k_customer.get_record;
            --
            -- validacion total
            validate_all;
            --
            -- completamos los datos del cliente
            g_rec_customer.customer_co         := g_doc_customer.p_customer_co;
            g_rec_customer.description         := g_doc_customer.p_description;
            g_rec_customer.telephone_co        := g_doc_customer.p_telephone_co;
            g_rec_customer.fax_co              := g_doc_customer.p_fax_co;
            g_rec_customer.email               := g_doc_customer.p_email;
            g_rec_customer.address             := g_doc_customer.p_address;
            g_rec_customer.k_type_customer     := g_doc_customer.p_k_type_customer;
            g_rec_customer.k_sector            := g_doc_customer.p_k_sector;
            g_rec_customer.k_category_co       := g_doc_customer.p_k_category_co;
            g_rec_customer.fiscal_document_co  := g_doc_customer.p_fiscal_document_co;
            g_rec_customer.location_id         := g_rec_locations.id;
            g_rec_customer.telephone_contact   := g_doc_customer.p_telephone_contact;
            g_rec_customer.name_contact        := g_doc_customer.p_name_contact;
            g_rec_customer.email_contact       := g_doc_customer.p_email_contact;
            g_rec_customer.k_mca_inh           := g_doc_customer.p_k_mca_inh;
            --
            IF g_doc_customer.p_slug IS NOT NULL THEN 
                g_rec_customer.uuid             :=  g_doc_customer.p_slug;
            END IF;
            --
            IF g_doc_customer.p_uuid IS NOT NULL THEN 
                g_rec_customer.slug             :=  g_doc_customer.p_uuid;
            END IF;            
            --
            g_rec_customer.update_at := sysdate;
            --
            -- creamos el registro
            dsc_api_k_customer.upd( 
                p_rec => g_rec_customer
            );
            --
            COMMIT;
            --
            p_rec.p_uuid    := g_rec_customer.uuid;
            p_rec.p_slug    := g_rec_customer.slug;
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --            
        ELSE 
            --
            raise_error( 
                p_cod_error => -20007,
                p_msg_error => 'INVALID CUSTOMER CODE'
            );
            --
        END IF;         
        --
        EXCEPTION 
            WHEN e_validate_type_customer       OR
                 e_validate_location            OR
                 e_no_exist_customer_code       OR
                 e_validate_category_customer   OR
                 e_validate_email               OR    
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
    END update_customer;
    --
    -- update customer by json
    PROCEDURE update_customer( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    ) IS 
        --
        l_obj       json_object_t;
        --
    BEGIN 
        --
        -- analizamos los datos JSON
        l_obj   := json_object_t.parse(p_json);
        --
        -- completamos los datos del registro customer
        g_doc_customer.p_customer_co        := l_obj.get_string('customer_co');
        g_doc_customer.p_description        := l_obj.get_string('description');
        g_doc_customer.p_telephone_co       := l_obj.get_string('telephone_co');
        g_doc_customer.p_fax_co             := l_obj.get_string('fax_co');
        g_doc_customer.p_email              := l_obj.get_string('email');
        g_doc_customer.p_address            := l_obj.get_string('address');
        g_doc_customer.p_k_type_customer    := l_obj.get_string('k_type_customer');
        g_doc_customer.p_k_sector           := l_obj.get_string('k_sector');
        g_doc_customer.p_k_category_co      := l_obj.get_string('k_category_co');
        g_doc_customer.p_fiscal_document_co := l_obj.get_string('fiscal_document_co');
        g_doc_customer.p_location_co        := l_obj.get_string('location_co');
        g_doc_customer.p_telephone_contact  := l_obj.get_string('telephone_contact');
        g_doc_customer.p_name_contact       := l_obj.get_string('name_contact');
        g_doc_customer.p_email_contact      := l_obj.get_string('email_contact');
        g_doc_customer.p_slug               := l_obj.get_string('slug');
        g_doc_customer.p_user_co            := l_obj.get_string('user_co');
        --
        update_customer( 
                p_rec       => g_doc_customer,
                p_result    => p_result
        );
        --
        EXCEPTION
            WHEN OTHERS THEN 
                --
                IF p_result IS NULL THEN 
                    p_result :=  '{ "status":"ERROR", "message":"'||SQLERRM||'" }';
                END IF;
                --
                ROLLBACK;
                --
        --
    END update_customer;
    --
    -- update customer by json
    PROCEDURE delete_customer( 
        p_customer_co   IN customers.customer_co%TYPE,
        p_result        OUT VARCHAR2 
    ) IS 
        --
        g_reg_customer  customers%ROWTYPE;
        --
    BEGIN 
        --
        -- verificamos que el codigo de cliente no exista
        IF dsc_api_k_customer.exist( p_customer_co => p_customer_co ) THEN
            --
            -- tomamos el registro encontrado
            g_reg_customer := dsc_api_k_customer.get_record;
            --
            dsc_api_k_customer.del( p_id => g_reg_customer.id );
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --
        ELSE 
            --
            raise_error( 
                p_cod_error => -20007,
                p_msg_error => 'INVALID CUSTOMER CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_no_exist_customer_code THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
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
    END delete_customer;
    --   
BEGIN    
    --
    -- verificamos la configuracion Actual 
    g_cfg_co := nvl(sys_k_global.ref_f_global(
        p_variable => 'CONFIGURATION_ID'
    ), K_CFG_CO );
    --
    -- tomamos la configuracion local
    g_reg_config := cfg_api_k_configuration.get_record( 
        p_id => g_cfg_co
    );
    --
    -- establecemos el lenguaje de trabajo
    sys_k_global.p_seter(
        p_variable  => 'LANGUAGE_CO', 
        p_value     => g_reg_config.language_co
    );
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line('Init Package: '||sqlerrm);
    --     
END prs_api_k_customer;

CREATE OR REPLACE PACKAGE BODY prs_api_k_shop IS
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
    -- GLOBALES
    g_doc_shop          shop_api_doc;
    g_rec_locations     igtp.locations%ROWTYPE;
    g_rec_shop          igtp.shops%ROWTYPE;
    g_rec_user          igtp.users%ROWTYPE;
    --
    -- TODO: crear el manejo de errores para transferirlo al nivel superior
    --
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    -- excepciones
    e_validate_location             EXCEPTION;
    e_exist_shop_code               EXCEPTION;
    e_validate_user                 EXCEPTION;
    e_validate_email                EXCEPTION;
    e_no_exist_shop_code            EXCEPTION;
    --
    PRAGMA exception_init( e_validate_location, -20002 );
    PRAGMA exception_init( e_exist_shop_code, -20003 );
    PRAGMA exception_init( e_validate_email, -20005 );
    PRAGMA exception_init( e_validate_user,  -20006 );
    PRAGMA exception_init( e_no_exist_shop_code, -20007 );
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
        -- validamos el codigo de la localidad del cliente
        IF NOT cfg_api_k_location.exist( p_location_co =>  g_doc_shop.p_location_co ) THEN 
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
        -- validamos el email del tienda 
        IF NOT validate_email( g_doc_shop.p_email ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20005,
                p_msg_error => 'INVALID SHOP EMAIL'
            );
            --
        --
        -- validamos el email del contacto 
        IF NOT validate_email( g_doc_shop.p_email_contact ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20005,
                p_msg_error => 'INVALID SHOP EMAIL'
            );
            --
        END IF;        
        --
        -- validamos el codigo del usuario
        IF NOT sec_api_k_user.exist( p_user_co =>  g_doc_shop.p_user_co ) THEN 
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
    -- create customer by record
    PROCEDURE create_shop( 
        p_rec       IN OUT shop_api_doc,
        p_result    OUT VARCHAR2
    ) IS
    BEGIN
        --
        -- se establece el valor a la global 
        g_doc_shop  := p_rec;
        --
        -- verificamos que el codigo de la tienda no exista
        IF dsc_api_k_shop.exist( p_shop_co => p_rec.p_shop_co ) THEN
            --
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID SHOP CODE'
            );
            --
        END IF; 
        --
        -- validacion total
        validate_all;
        --
        -- completamos los datos del cliente
        g_rec_shop.id                   := NULL;
        g_rec_shop.shop_co              := g_doc_shop.p_shop_co;
        g_rec_shop.description          := g_doc_shop.p_description;
        g_rec_shop.location_id          := g_rec_locations.id;
        g_rec_shop.address              := g_doc_shop.p_address;
        g_rec_shop.nu_gps_lat           := g_doc_shop.p_nu_gps_lat;
        g_rec_shop.nu_gps_lon           := g_doc_shop.p_nu_gps_lon;
        g_rec_shop.telephone_co         := g_doc_shop.p_telephone_co;
        g_rec_shop.fax_co               := g_doc_shop.p_fax_co;
        g_rec_shop.email                := g_doc_shop.p_email;
        g_rec_shop.name_contact         := g_doc_shop.p_name_contact;
        g_rec_shop.email_contact        := g_doc_shop.p_email_contact;
        g_rec_shop.telephone_contact    := g_doc_shop.p_telephone_contact;
        g_rec_shop.user_id              := g_rec_user.id;
        g_rec_shop.created_at           := sysdate;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_rec_shop.slug :=  lower( substr(g_rec_locations.slug||'-'||g_rec_shop.shop_co,1,60) );
            --
        ELSE
            --
            g_rec_shop.slug :=  g_doc_shop.p_slug;
            --
        END IF;
        --
        -- creamos el registro
        dsc_api_k_shop.ins( 
            p_rec => g_rec_shop
        );
        --
        p_rec.p_uuid    := g_rec_shop.uuid;
        p_rec.p_slug    := g_rec_shop.slug;
        --
        COMMIT;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        EXCEPTION 
            WHEN e_validate_location  OR
                 e_exist_shop_code    OR
                 e_no_exist_shop_code OR
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
    END create_shop;    
    --
    -- create customer by json
    PROCEDURE create_shop( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    ) IS 
    BEGIN
        --
        NULL;
        --
    END create_shop;         
    --
    -- update customer by record
    PROCEDURE update_shop(
        p_rec       IN OUT shop_api_doc,
        p_result    OUT VARCHAR2
    ) IS 
    BEGIN
        --
        NULL;
        --
    END update_shop;  
    --
    -- update customer by json
    PROCEDURE update_shop( 
        p_json      IN OUT VARCHAR2,
        p_result    OUT VARCHAR2
    ) IS 
    BEGIN
        --
        NULL;
        --
    END update_shop;  
    --
    -- update customer by json
    PROCEDURE delete_shop( 
        p_shop_co       IN shops.shop_co%TYPE,
        p_result        OUT VARCHAR2 
    ) IS 
    BEGIN
        --
        NULL;
        --
    END delete_shop;  
    --
END prs_api_k_shop;
---------------------------------------------------------------------------
--  DDL for Package body CITIES_API (Process)
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
--  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
--                                  administrativos de creacion de ciudades
---------------------------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.prs_k_api_city IS
    --
    K_PROCESS    CONSTANT VARCHAR2(20)  := 'PRC_API_K_CITY';
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_CFG_CO     CONSTANT NUMBER        := '1';
    --
    -- globales
    g_cfg_co                        cfg_configurations.id%TYPE;
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    g_reg_config                    cfg_configurations%ROWTYPE;
    -- excepciones
    e_validate_municipality         EXCEPTION;
    e_validate_user                 EXCEPTION;
    e_exist_city_code               EXCEPTION;
    --
    PRAGMA exception_init( e_validate_municipality, -20001 );
    PRAGMA exception_init( e_validate_user, -20002 );
    PRAGMA exception_init( e_exist_city_code, -20003 );
    --
    -- create city
    PROCEDURE create_city (
            p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
            p_description       IN cities.description%TYPE DEFAULT NULL,
            p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
            p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
            p_municipality_co   IN cities.municipality_co%TYPE DEFAULT NULL,
            p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
            p_slug              IN cities.slug%TYPE DEFAULT NULL,
            p_user_co           IN cities.user_co%TYPE DEFAULT NULL,
            p_result            OUT VARCHAR2 
        ) IS 
        --
        l_reg_municipality      municipalities%ROWTYPE;
        l_reg_user              users%ROWTYPE;
        l_reg_city              cities%ROWTYPE;
        --
    BEGIN
        --
        -- TODO: 1.- validar que el codigo de ciudad no exista
        IF prs_k_api_city.exist( p_city_co => p_city_co ) THEN
            --
            -- TODO: regionalizacion de mensajes
            g_cod_error := -20003;
            g_hay_error := TRUE;
            --
            g_msg_error := prs_api_k_language.p_message( 
                p_language_co => ref_f_global.f_geter('LANGUAGE_CO'),
                p_context     => K_PROCESS,
                p_error_co    => g_cod_error 
            );
            --
            g_msg_error := nvl(g_msg_error, 'INVALID CITY CODE');
            p_result    := g_msg_error;
            --
            raise_application_error(g_cod_error, g_msg_error );
            --  
        END IF;
        --
        -- TODO: 2.- validar que el codigo de municipalidad exista
        l_reg_municipality := cfg_api_k_municipality.get_record( 
            p_municipality_co => p_municipality_co
        );
        --
        IF l_reg_municipality.id IS NULL THEN
            --
            -- TODO: regionalizacion de mensajes
            g_cod_error := -20001;
            g_hay_error := TRUE;
            --
            g_msg_error := prs_api_k_language.p_message( 
                p_language_co => ref_f_global.f_geter('LANGUAGE_CO'),
                p_context     => K_PROCESS,
                p_error_co    => g_cod_error 
            );
            --
            g_msg_error := nvl(g_msg_error, 'INVALID MUNICIPALITY CODE');
            p_result    := g_msg_error;
            --
            raise_application_error(g_cod_error, g_msg_error );
            -- 
        END IF;
        --
        -- TODO: 3.- validar que el codigo de usuario exista
        l_reg_user := cfg_api_k_municipality.get_record( 
            p_user_co => p_user_co
        );
        --
        IF l_reg_user.id IS NULL THEN
            --
            -- TODO: regionalizacion de mensajes
            g_cod_error := -20002;
            g_hay_error := TRUE;
            --
            g_msg_error := prs_api_k_language.p_message( 
                p_language_co => ref_f_global.f_geter('LANGUAGE_CO'),
                p_context     => K_PROCESS,
                p_error_co    => g_cod_error 
            );
            --
            g_msg_error := nvl(g_msg_error, 'INVALID USER CODE');
            p_result    := g_msg_error;
            --            
            raise_application_error(g_cod_error, g_msg_error );
            -- 
        END IF;
        --
        l_reg_city.city_co          :=  p_city_co; 
        l_reg_city.description      :=  p_description;
        l_reg_city.telephone_co     :=  p_telephone_co; 
        l_reg_city.postal_co        :=  p_postal_co; 
        l_reg_city.municipality_id  :=  l_reg_municipality.id;
        l_reg_city.uuid             :=  p_uuid;
        l_reg_city.slug             :=  p_slug;
        l_reg_city.user_id          :=  l_reg_user.id;
        --
        prs_k_api_city.ins( p_rec => l_reg_city );
        --
        COMMIT;
        --
        p_result := '{ "status":"OK", "message":"" }';
        --
        EXCEPTION
            WHEN e_exist_city_code OR e_validate_municipality OR e_validate_user THEN 
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
    END create_city;
    --
    -- insert RECORD
    PROCEDURE create_city( 
        p_rec               IN OUT city_api_doc,
        p_result            OUT VARCHAR2 
    );
    --
    -- update
    PROCEDURE update_city(
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
        p_description       IN cities.description%TYPE DEFAULT NULL,
        p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
        p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
        p_municipality_co   IN cities.municipality_co%TYPE DEFAULT NULL,
        p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
        p_slug              IN cities.slug%TYPE DEFAULT NULL,
        p_user_co           IN cities.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2  
    );
    --
    -- update RECORD
    PROCEDURE update_city( 
        p_rec               IN OUT city_api_doc,
        p_result            OUT VARCHAR2 
    );    
    --
    -- delete
    PROCEDURE delete_city( 
        p_co                IN cities.citie_co%TYPE,
        p_result            OUT VARCHAR2 
    );
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
        p_id => g_cfg_co;
    );
    --
    -- establecemos el lenguaje de trabajo
    sys_k_global.p_seter(
        p_variable  => 'LANGUAGE_CO', 
        p_value     => g_reg_config.language_co
    );
    --
END prs_k_api_city;
/
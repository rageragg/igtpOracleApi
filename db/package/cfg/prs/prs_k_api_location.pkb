
    ---------------------------------------------------------------------------
    --  DDL for Package body LOCATIONS_API (Process)
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de locaiones
    --
    -- TODO: Compactar codigo repetitivo en funciones de utilerias
    ---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY igtp.prs_k_api_location IS
    --
    K_CFG_CO     CONSTANT NUMBER        := 1;
    --
    -- globales
    g_cfg_co                        configurations.id%TYPE;
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    g_reg_config                    configurations%ROWTYPE;
    --
    -- excepciones
    e_validate_city                 EXCEPTION;
    e_validate_user                 EXCEPTION;
    e_exist_location_code           EXCEPTION;
    e_no_exist_location_code        EXCEPTION;
    --
    PRAGMA exception_init( e_validate_city, -20001 );
    PRAGMA exception_init( e_validate_user, -20002 );
    PRAGMA exception_init( e_exist_location_code, -20003 );
    PRAGMA exception_init( e_no_exist_location_code, -20004 );
    --    
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
    -- create locations
    PROCEDURE create_location (
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL,
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL,
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL,
        p_nu_gps_lat 		IN locations.nu_gps_lat%TYPE DEFAULT NULL, 
	    p_nu_gps_lon 		IN locations.nu_gps_lon%TYPE DEFAULT NULL,  
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2 
    ) IS 
        --        
        l_reg_location      locations%ROWTYPE;
        l_reg_user          users%ROWTYPE;
        l_reg_city          cities%ROWTYPE;
        --
    BEGIN 
        --
        -- TODO: 1.- validar que el codigo de locacion no exista
        IF cfg_api_k_location.exist( p_location_co => p_location_co ) THEN
            --
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID LOCATIONS CODE'
            );
            --  
        END IF;
        --
        IF NOT cfg_api_k_city.exist( p_city_co => p_city_co ) THEN
            --
            raise_error( 
                p_cod_error => -20001,
                p_msg_error => 'INVALID CITY CODE'
            );
            -- 
        ELSE 
            --
            l_reg_city := cfg_api_k_city.get_record;
            --            
        END IF;
        --
        IF NOT sec_api_k_user.exist( p_user_co =>  p_user_co ) THEN
            --
            raise_error( 
                p_cod_error => -20002,
                p_msg_error => 'INVALID USER CODE'
            );
            -- 
        ELSE 
            --
            l_reg_user := sec_api_k_user.get_record;
            --            
        END IF;
        --
        l_reg_location.location_co      := p_location_co;
        l_reg_location.description      := p_description; 
        l_reg_location.postal_co        := p_postal_co; 
        l_reg_location.city_id          := l_reg_city.id;
        l_reg_location.nu_gps_lat       := p_nu_gps_lat;
        l_reg_location.nu_gps_lon       := p_nu_gps_lon;
        l_reg_location.uuid             := p_uuid; 
        --
        -- creamos el slug
        IF p_slug IS NULL THEN 
            --
            l_reg_location.slug :=  lower( substr(l_reg_city.slug||'-'||l_reg_location.location_co,1,60) );
            --
        ELSE
            --
            l_reg_location.slug :=  p_slug;
            --
        END IF;
        --
        l_reg_location.user_id          := l_reg_user.id;
        --
        cfg_api_k_location.ins( p_rec => l_reg_location );
        --
        COMMIT;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        EXCEPTION
            WHEN e_exist_location_code OR e_validate_city OR e_validate_user THEN 
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
    END create_location;
    --  
    -- insert RECORD
    PROCEDURE create_location( 
        p_rec       IN OUT location_api_doc,
        p_result    OUT VARCHAR2  
    ) IS 
        --        
        l_reg_location      locations%ROWTYPE;
        l_reg_user          users%ROWTYPE;
        l_reg_city          cities%ROWTYPE;
        --    
    BEGIN 
        --
        -- TODO: 1.- validar que el codigo de locacion no exista
        IF cfg_api_k_location.exist( p_location_co => p_rec.p_location_co ) THEN
            --
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID LOCATIONS CODE'
            );
            --  
        END IF;
        --
        IF NOT cfg_api_k_city.exist( p_city_co => p_rec.p_city_co ) THEN
            --
            raise_error( 
                p_cod_error => -20001,
                p_msg_error => 'INVALID CITY CODE'
            );
            -- 
        ELSE 
            --
            l_reg_city := cfg_api_k_city.get_record;
            --            
        END IF;
        --
        IF NOT sec_api_k_user.exist( p_user_co => p_rec.p_user_co ) THEN
            --
            raise_error( 
                p_cod_error => -20002,
                p_msg_error => 'INVALID USER CODE'
            );
            -- 
        ELSE 
            --
            l_reg_user := sec_api_k_user.get_record;
            --            
        END IF;
        --
        l_reg_location.location_co      := p_rec.p_location_co;
        l_reg_location.description      := p_rec.p_description; 
        l_reg_location.postal_co        := p_rec.p_postal_co; 
        l_reg_location.city_id          := l_reg_city.id;
        l_reg_location.nu_gps_lat       := p_rec.p_nu_gps_lat;
        l_reg_location.nu_gps_lon       := p_rec.p_nu_gps_lon;
        l_reg_location.uuid             := p_rec.p_uuid; 
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            l_reg_location.slug :=  lower( substr(l_reg_city.slug||'-'||l_reg_location.location_co,1,60) );
            --
        ELSE
            --
            l_reg_location.slug :=  p_rec.p_slug;
            --
        END IF;
        --
        l_reg_location.user_id          := l_reg_user.id;
        --
        cfg_api_k_location.ins( p_rec => l_reg_location );
        --
        p_rec.p_uuid    := l_reg_location.uuid;
        p_rec.p_slug    := l_reg_location.slug;                
        --
        COMMIT;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        EXCEPTION
            WHEN e_exist_location_code OR e_validate_city OR e_validate_user THEN 
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
    END create_location;
    --  
    --
    -- update
    PROCEDURE update_location(
        p_location_co       IN locations.location_co%TYPE DEFAULT NULL, 
        p_description       IN locations.description%TYPE DEFAULT NULL,
        p_postal_co         IN locations.postal_co%TYPE DEFAULT NULL, 
        p_city_co           IN cities.city_co%TYPE DEFAULT NULL,
        p_uuid              IN locations.uuid%TYPE DEFAULT NULL,
        p_slug              IN locations.slug%TYPE DEFAULT NULL,
        p_nu_gps_lat 		IN locations.nu_gps_lat%TYPE DEFAULT NULL, 
	    p_nu_gps_lon 		IN locations.nu_gps_lon%TYPE DEFAULT NULL,  
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_result            OUT VARCHAR2  
    ) IS 
        --
        l_reg_location          locations%ROWTYPE;
        l_reg_user              users%ROWTYPE;
        l_reg_city              cities%ROWTYPE;
        --
    BEGIN
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_location.exist( p_location_co => p_location_co ) THEN
            --
            -- tomamos el registro encontrado
            l_reg_location := cfg_api_k_location.get_record;
            --
            IF NOT cfg_api_k_city.exist( p_city_co => p_city_co )  THEN
                --
                -- TODO: regionalizacion de mensajes
                g_cod_error := -20001;
                g_hay_error := TRUE;
                --
                raise_error( 
                    p_cod_error => -20001,
                    p_msg_error => 'INVALID CITY CODE'
                );
                -- 
            ELSE 
                --
                l_reg_city := cfg_api_k_city.get_record;
                --
            END IF;
            --
            IF NOT sec_api_k_user.exist(p_user_co => p_user_co) THEN
                --
                -- TODO: regionalizacion de mensajes
                raise_error( 
                    p_cod_error => -20002,
                    p_msg_error => 'INVALID USER CODE'
                );
                --
            ELSE 
                --
                l_reg_user := sec_api_k_user.get_record;
                --
            END IF;
            --
            l_reg_location.location_co      := p_location_co;
            l_reg_location.description      := p_description; 
            l_reg_location.postal_co        := p_postal_co; 
            l_reg_location.city_id          := l_reg_city.id;
            l_reg_location.nu_gps_lat       := p_nu_gps_lat;
            l_reg_location.nu_gps_lon       := p_nu_gps_lon;
            --
            -- creamos el slug
            IF p_uuid IS NOT NULL THEN 
                l_reg_location.uuid             :=  p_uuid;
            END IF;
            --
            IF p_slug IS NOT NULL THEN 
                --
                l_reg_location.slug             :=  p_slug;
                --
            ELSE
                --
                IF l_reg_location.slug IS NULL THEN 
                    l_reg_location.slug :=  lower( substr(l_reg_city.slug||'-'||l_reg_location.location_co,1,60) );
                END IF;
                --
            END IF;
            --
            l_reg_location.user_id          := l_reg_user.id;
            --
            cfg_api_k_location.upd( p_rec => l_reg_location );
            --
            COMMIT;
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --
        ELSE
            --
            -- TODO: Manejar el error cuando no exista el codigo de ciudad
            --
            -- TODO: regionalizacion de mensajes
            raise_error( 
                p_cod_error => -20004,
                p_msg_error => 'INVALID CITY CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_validate_city OR e_validate_user THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                -- 
            WHEN e_no_exist_location_code THEN 
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
    END update_location;
    --
    -- update RECORD 
    PROCEDURE update_location( 
        p_rec       IN OUT location_api_doc,
        p_result    OUT VARCHAR2  
    ) IS
        --
        l_reg_location          locations%ROWTYPE;
        l_reg_user              users%ROWTYPE;
        l_reg_city              cities%ROWTYPE;
        --
    BEGIN
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_location.exist( p_location_co => p_rec.p_location_co ) THEN
            --
            -- tomamos el registro encontrado
            l_reg_location := cfg_api_k_location.get_record;
            --
            IF NOT cfg_api_k_city.exist( p_city_co => p_rec.p_city_co )  THEN
                --
                -- TODO: regionalizacion de mensajes
                g_cod_error := -20001;
                g_hay_error := TRUE;
                --
                raise_error( 
                    p_cod_error => -20001,
                    p_msg_error => 'INVALID CITY CODE'
                );
                -- 
            ELSE 
                --
                l_reg_city := cfg_api_k_city.get_record;
                --
            END IF;
            --
            IF NOT sec_api_k_user.exist(p_user_co => p_rec.p_user_co) THEN
                --
                -- TODO: regionalizacion de mensajes
                raise_error( 
                    p_cod_error => -20002,
                    p_msg_error => 'INVALID USER CODE'
                );
                --
            ELSE 
                --
                l_reg_user := sec_api_k_user.get_record;
                --
            END IF;
            --
            l_reg_location.location_co      := p_rec.p_location_co;
            l_reg_location.description      := p_rec.p_description; 
            l_reg_location.postal_co        := p_rec.p_postal_co; 
            l_reg_location.city_id          := l_reg_city.id;
            l_reg_location.nu_gps_lat       := p_rec.p_nu_gps_lat;
            l_reg_location.nu_gps_lon       := p_rec.p_nu_gps_lon;
            --
            -- creamos el slug
            IF p_rec.p_uuid IS NOT NULL THEN 
                l_reg_location.uuid             :=  p_rec.p_uuid;
            END IF;
            --
            IF p_rec.p_slug IS NOT NULL THEN 
                --
                l_reg_location.slug             :=  p_rec.p_slug;
                --
            ELSE
                --
                IF l_reg_location.slug IS NULL THEN 
                    l_reg_location.slug :=  lower( substr(l_reg_city.slug||'-'||l_reg_location.location_co,1,60) );
                END IF;
                --
            END IF;
            --
            l_reg_location.user_id          := l_reg_user.id;
            --
            cfg_api_k_location.upd( p_rec => l_reg_location );
            --
            p_rec.p_uuid    := l_reg_location.uuid;
            p_rec.p_slug    := l_reg_location.slug;     
            --
            COMMIT;
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --
        ELSE
            --
            -- TODO: Manejar el error cuando no exista el codigo de ciudad
            --
            -- TODO: regionalizacion de mensajes
            raise_error( 
                p_cod_error => -20004,
                p_msg_error => 'INVALID CITY CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_validate_city OR e_validate_user THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                -- 
            WHEN e_no_exist_location_code THEN 
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
    END update_location;   
    --
    -- delete
    PROCEDURE delete_location( 
        p_location_co   IN locations.location_co%TYPE,
        p_result        OUT VARCHAR2 
    ) IS 
        --
        l_reg_locations     locations%ROWTYPE;
        --
    BEGIN 
        --
        IF cfg_api_k_location.exist( p_location_co => p_location_co ) THEN
            --
            -- tomamos el registro encontrado
            l_reg_locations := cfg_api_k_location.get_record;
            --
            cfg_api_k_location.del( p_id => l_reg_locations.id );
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --
        ELSE 
            --
            -- TODO: Manejar el error cuando no exista el codigo de ciudad
            --
            -- TODO: regionalizacion de mensajes
            g_cod_error := -20004;
            g_hay_error := TRUE;
            --
            raise_error( 
                p_cod_error => -20004,
                p_msg_error => 'INVALID LOCATION CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_no_exist_location_code THEN 
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
    END delete_location;
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
END prs_k_api_location;
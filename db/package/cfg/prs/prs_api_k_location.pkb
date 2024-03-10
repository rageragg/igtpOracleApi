CREATE OR REPLACE PACKAGE BODY igtp.prs_api_k_location IS
    --
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
    --
    K_CFG_CO     CONSTANT NUMBER        := 1;
    --
    -- globales
    g_cfg_co                        configurations.id%TYPE;
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    g_rec_config                    configurations%ROWTYPE;
    g_rec_location                  locations%ROWTYPE;
    g_doc_location                  location_api_doc;
    g_rec_user                      igtp.users%ROWTYPE;
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
        g_msg_error := prs_api_k_language.f_message( 
            p_language_co => sys_k_global.geter(sys_k_constant.K_FIELD_LANGUAGE_CO),
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
    -- manejo de log
    PROCEDURE record_log( 
            p_context  IN VARCHAR2,
            p_line     IN VARCHAR2,
            p_raw      IN VARCHAR2,
            p_result   IN VARCHAR,
            p_clob     IN OUT CLOB
        ) IS 
    BEGIN 
        --
        sys_k_utils.record_log( 
            p_context   => sys_k_constant.K_LOCATION_LOAD_CONTEXT,
            p_line      => p_line,
            p_raw       => p_raw,
            p_result    => p_result,
            p_clob      => p_clob
        );
        --
    END record_log; 
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
            g_rec_user := sec_api_k_user.get_record;
            --            
        END IF;
        --
        g_rec_location.location_co      := p_location_co;
        g_rec_location.description      := p_description; 
        g_rec_location.postal_co        := p_postal_co; 
        g_rec_location.city_id          := l_reg_city.id;
        g_rec_location.nu_gps_lat       := p_nu_gps_lat;
        g_rec_location.nu_gps_lon       := p_nu_gps_lon;
        g_rec_location.uuid             := p_uuid; 
        --
        -- creamos el slug
        IF p_slug IS NULL THEN 
            --
            g_rec_location.slug :=  lower( substr(l_reg_city.slug||'-'||g_rec_location.location_co,1,60) );
            --
        ELSE
            --
            g_rec_location.slug :=  p_slug;
            --
        END IF;
        --
        g_rec_location.user_id := g_rec_user.id;
        --
        cfg_api_k_location.ins( p_rec => g_rec_location );
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
        l_reg_city          cities%ROWTYPE;
        --    
    BEGIN 
        --
        -- se establece el valor a la global 
        g_doc_location  := p_rec;
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
            g_rec_user := sec_api_k_user.get_record;
            --            
        END IF;
        --
        g_rec_location.id               := NULL;
        g_rec_location.location_co      := g_doc_location.p_location_co;
        g_rec_location.description      := g_doc_location.p_description; 
        g_rec_location.postal_co        := g_doc_location.p_postal_co; 
        g_rec_location.city_id          := l_reg_city.id;
        g_rec_location.nu_gps_lat       := g_doc_location.p_nu_gps_lat;
        g_rec_location.nu_gps_lon       := g_doc_location.p_nu_gps_lon;
        g_rec_location.uuid             := NULL; 
        g_rec_location.created_at       := sysdate;
        g_rec_location.user_id          := g_rec_user.id;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_rec_location.slug :=  lower( substr(l_reg_city.slug||'-'||g_rec_location.location_co,1,60) );
            --
        ELSE
            --
            g_rec_location.slug :=  p_rec.p_slug;
            --
        END IF;
        --
        -- creamos el registro
        cfg_api_k_location.ins( 
            p_rec => g_rec_location 
        );
        --
        p_rec.p_uuid    := g_rec_location.uuid;
        p_rec.p_slug    := g_rec_location.slug;                
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
        l_reg_city              cities%ROWTYPE;
        --
    BEGIN
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_location.exist( p_location_co => p_location_co ) THEN
            --
            -- tomamos el registro encontrado
            g_rec_location := cfg_api_k_location.get_record;
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
                g_rec_user := sec_api_k_user.get_record;
                --
            END IF;
            --
            g_rec_location.location_co      := p_location_co;
            g_rec_location.description      := p_description; 
            g_rec_location.postal_co        := p_postal_co; 
            g_rec_location.city_id          := l_reg_city.id;
            g_rec_location.nu_gps_lat       := p_nu_gps_lat;
            g_rec_location.nu_gps_lon       := p_nu_gps_lon;
            --
            -- creamos el slug
            IF p_uuid IS NOT NULL THEN 
                g_rec_location.uuid             :=  p_uuid;
            END IF;
            --
            IF p_slug IS NOT NULL THEN 
                --
                g_rec_location.slug             :=  p_slug;
                --
            ELSE
                --
                IF g_rec_location.slug IS NULL THEN 
                    g_rec_location.slug :=  lower( substr(l_reg_city.slug||'-'||g_rec_location.location_co,1,60) );
                END IF;
                --
            END IF;
            --
            g_rec_location.user_id          := g_rec_user.id;
            --
            cfg_api_k_location.upd( p_rec => g_rec_location );
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
        l_reg_city              cities%ROWTYPE;
        --
    BEGIN
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_location.exist( p_location_co => p_rec.p_location_co ) THEN
            --
            -- tomamos el registro encontrado
            g_rec_location := cfg_api_k_location.get_record;
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
                g_rec_user := sec_api_k_user.get_record;
                --
            END IF;
            --
            g_rec_location.location_co      := p_rec.p_location_co;
            g_rec_location.description      := p_rec.p_description; 
            g_rec_location.postal_co        := p_rec.p_postal_co; 
            g_rec_location.city_id          := l_reg_city.id;
            g_rec_location.nu_gps_lat       := p_rec.p_nu_gps_lat;
            g_rec_location.nu_gps_lon       := p_rec.p_nu_gps_lon;
            --
            -- creamos el slug
            IF p_rec.p_uuid IS NOT NULL THEN 
                g_rec_location.uuid             :=  p_rec.p_uuid;
            END IF;
            --
            IF p_rec.p_slug IS NOT NULL THEN 
                --
                g_rec_location.slug             :=  p_rec.p_slug;
                --
            ELSE
                --
                IF g_rec_location.slug IS NULL THEN 
                    g_rec_location.slug :=  lower( substr(l_reg_city.slug||'-'||g_rec_location.location_co,1,60) );
                END IF;
                --
            END IF;
            --
            g_rec_location.user_id          := g_rec_user.id;
            --
            cfg_api_k_location.upd( p_rec => g_rec_location );
            --
            p_rec.p_uuid    := g_rec_location.uuid;
            p_rec.p_slug    := g_rec_location.slug;     
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
    BEGIN 
        --
        IF cfg_api_k_location.exist( p_location_co => p_location_co ) THEN
            --
            -- tomamos el registro encontrado
            g_rec_location := cfg_api_k_location.get_record;
            --
            cfg_api_k_location.del( p_id => g_rec_location.id );
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
    -- load file masive data
    PROCEDURE load_file(
            p_json      IN VARCHAR2,
            p_result    OUT VARCHAR2
        ) IS 
        --
        l_directory_indir   VARCHAR2(30)    := sys_k_constant.K_IN_DIRECTORY;
        l_directory_outdir  VARCHAR2(30)    := sys_k_constant.K_OUT_DIRECTORY;
        l_file_name         VARCHAR2(128);
        l_user_code         VARCHAR2(10);
        l_data              CLOB;
        l_log               CLOB;
        l_obj               json_object_t;
        --
        l_file_exists       BOOLEAN;
        l_is_number         BOOLEAN;
        l_is_valid_record   BOOLEAN;
        --
        -- lectura de datos desde un CLOB
        CURSOR c_csv IS
            SELECT line_number, line_raw, 
                   c001 location_co, 
                   c002 description, 
                   c003 postal_co, 
                   c004 city_co, 
                   c005 nu_gps_lat,
                   c006 nu_gps_lon
              FROM sys_k_csv_util.clob_to_csv (
                        p_csv_clob  => l_data,
                        p_separator => ';',
                        p_skip_rows => 1
                   );
        --
    BEGIN 
        --
        -- analizamos los datos JSON
        l_obj   := json_object_t.parse(p_json);
        --
        -- completamos los datos del registro customer
        l_file_name := l_obj.get_string('file_name');
        l_user_code := l_obj.get_string('user_name');
        --
        IF l_file_name IS NOT NULL THEN 
            --
            l_file_exists := sys_k_file_util.file_exists(
                p_directory_name    => l_directory_indir,
                p_file_name         => l_file_name
            );
            --
            IF l_file_exists THEN 
                --
                -- creamos el log temporal
                dbms_lob.createtemporary(
                    lob_loc => l_log,
                    cache   => FALSE
                );
                --
                -- leemos el archivo y lo transformamos en CLOB
                l_data := sys_k_file_util.get_clob_from_file (
                    p_directory_name    => l_directory_indir,
                    p_file_name         => l_file_name
                );
                --
                -- seleccion de datos
                FOR r_reg in c_csv LOOP 
                    --
                    -- completamos los datos del registro customer
                    g_doc_location.p_location_co    := r_reg.location_co;
                    g_doc_location.p_description    := r_reg.description;
                    g_doc_location.p_postal_co      := r_reg.postal_co;
                    g_doc_location.p_city_co        := r_reg.city_co;
                    g_doc_location.p_slug           := NULL;
                    g_doc_location.p_user_co        := l_user_code;
                    --
                    r_reg.nu_gps_lat                := nvl( r_reg.nu_gps_lat, '0.00'); 
                    r_reg.nu_gps_lon                := nvl( r_reg.nu_gps_lon, '0.00'); 
                    --
                    -- verificamos el valor sea convertible a numerico
                    l_is_number := sys_k_string_util.is_str_number(
                        p_str                => r_reg.nu_gps_lat,
                        p_decimal_separator  => sys_k_string_util.get_nls_decimal_separator,
                        p_thousand_separator => sys_k_string_util.get_nls_thousand_separator
                    );
                    --
                    IF l_is_number THEN 
                        --
                        g_doc_location.p_nu_gps_lat := sys_k_string_util.str_to_num (
                            p_str                        => r_reg.nu_gps_lat,
                            p_decimal_separator          => sys_k_string_util.get_nls_decimal_separator,
                            p_thousand_separator         => sys_k_string_util.get_nls_thousand_separator,
                            p_raise_error_if_parse_error => FALSE,
                            p_value_name                 => NULL
                        );
                        --
                    END IF;
                    --
                    -- verificamos el valor sea convertible a numerico
                    l_is_number := sys_k_string_util.is_str_number(
                        p_str                => r_reg.nu_gps_lon,
                        p_decimal_separator  => sys_k_string_util.get_nls_decimal_separator,
                        p_thousand_separator => sys_k_string_util.get_nls_thousand_separator
                    );
                    --
                    IF l_is_number THEN 
                        --
                        g_doc_location.p_nu_gps_lon := sys_k_string_util.str_to_num (
                            p_str                        => r_reg.nu_gps_lon,
                            p_decimal_separator          => sys_k_string_util.get_nls_decimal_separator,
                            p_thousand_separator         => sys_k_string_util.get_nls_thousand_separator,
                            p_raise_error_if_parse_error => FALSE,
                            p_value_name                 => NULL
                        );
                        --
                    END IF;                    
                    --
                    create_location( 
                            p_rec       => g_doc_location,
                            p_result    => p_result
                    );
                    --
                    -- manejo de log
                    record_log( 
                        p_context   => sys_k_constant.K_LOCATION_LOAD_CONTEXT,
                        p_line      => r_reg.line_number,
                        p_raw       => r_reg.line_raw,
                        p_result    => p_result,
                        p_clob      => l_log
                    );
                    --
                END LOOP;
                --
                COMMIT;
                --
                -- registramos el archivo log
                sys_k_file_util.save_clob_to_file (
                    p_directory_name  => l_directory_outdir,
                    p_file_name       => sys_k_constant.K_LOCATION_FILE_DATA_LOAD,
                    p_clob            => l_log
                );
                --
                -- liberamos el temporal
                dbms_lob.freetemporary (
                    lob_loc => l_log
                ); 
                --
            ELSE 
                --
                p_result := '{ "status":"ERROR", "message":"FILE NOT FOUND" }';
                --
            END IF;
            --
        END IF;
        --
    END load_file;
    --      
BEGIN
    --
    -- verificamos la configuracion Actual 
    g_cfg_co := nvl(sys_k_global.ref_f_global(
        p_variable => 'CONFIGURATION_ID'
    ), K_CFG_CO );
    --
    -- tomamos la configuracion local
    g_rec_config := cfg_api_k_configuration.get_record( 
        p_id => g_cfg_co
    );
    --
    -- establecemos el lenguaje de trabajo
    sys_k_global.p_seter(
        p_variable  => sys_k_constant.K_FIELD_LANGUAGE_CO, 
        p_value     => g_rec_config.language_co
    );
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line('Init Package: '||sqlerrm);
    --    
END prs_api_k_location;
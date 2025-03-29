
CREATE OR REPLACE PACKAGE BODY igtp.prs_api_k_city IS
    --
    ---------------------------------------------------------------------------
    --  DDL for Package body CITIES_API (Process)
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de ciudades
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
    g_reg_config                    configurations%ROWTYPE;
    g_doc_city                      prs_api_k_city.city_api_doc;
    --
    g_reg_municipality              municipalities%ROWTYPE;
    g_reg_user                      users%ROWTYPE;
    g_reg_city                      cities%ROWTYPE;
    --
    -- excepciones
    e_validate_municipality         EXCEPTION;
    e_validate_user                 EXCEPTION;
    e_exist_city_code               EXCEPTION;
    e_no_exist_city_code            EXCEPTION;
    --
    PRAGMA exception_init( e_validate_municipality, -20001 );
    PRAGMA exception_init( e_validate_user, -20002 );
    PRAGMA exception_init( e_exist_city_code, -20003 );
    PRAGMA exception_init( e_no_exist_city_code, -20004 );
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
    -- validate all
    PROCEDURE validate_all IS 
    BEGIN 
        -- 
        IF NOT cfg_api_k_municipality.exist( p_municipality_co => g_doc_city.p_municipality_co ) THEN
            --
            raise_error( 
                p_cod_error => -20001,
                p_msg_error => 'INVALID MUNICIPALITY CODE'
            );
            -- 
        ELSE 
            --
            g_reg_municipality := cfg_api_k_municipality.get_record;
            --            
        END IF;
        --
        IF NOT sec_api_k_user.exist( p_user_co =>  g_doc_city.p_user_co ) THEN
            --
            raise_error( 
                p_cod_error => -20002,
                p_msg_error => 'INVALID USER CODE'
            );
            -- 
        ELSE 
            --
            g_reg_user := sec_api_k_user.get_record;
            --            
        END IF;
        --
    END validate_all;
    --
    -- se establece los valores json
    FUNCTION get_json RETURN VARCHAR2 IS 
        --
        l_obj       json_object_t;
        --
    BEGIN 
        --
        l_obj   := json_object_t();
        l_obj.put( 'id', g_reg_city.id );
        l_obj.put( 'city_co', g_reg_city.city_co );
        l_obj.put( 'description', g_reg_city.description );
        l_obj.put( 'telephone_co', g_reg_city.telephone_co );
        l_obj.put( 'postal_co', g_reg_city.postal_co );
        l_obj.put( 'municipality_id', g_reg_city.municipality_id );
        l_obj.put( 'municipality_co', g_doc_city.p_municipality_co );
        l_obj.put( 'uuid', g_reg_city.uuid );
        l_obj.put( 'slug', g_reg_city.slug );
        l_obj.put( 'user_id', g_reg_city.user_id );
        l_obj.put( 'user_co', g_doc_city.p_user_co );
        l_obj.put( 'created_at', g_reg_city.created_at );
        --
        RETURN l_obj.stringify;
        --
    END get_json;
    --
    -- establece los valores globales json
    PROCEDURE set_global IS
    BEGIN 
        --
        -- global format JSON
        sys_k_global.p_seter(
            p_variable  => sys_k_constant.K_CITY_JSON, 
            p_value     => get_json
        );
          --
    END set_global;
    --
    -- process events
    PROCEDURE process_event( p_event VARCHAR2 ) IS 
        --
        l_pay_load VARCHAR2(32000);
        --
    BEGIN 
        --
        l_pay_load := get_json;
        --
        -- TODO: establecer las variables globales
        sys_k_global.p_seter(
            p_variable  => 'PARAMETERS', 
            p_value     => l_pay_load
        );
        --
        -- TODO: procesos de eventos
        prs_k_proccess.p_execute_event(
            p_proccess_co       => K_PROCESS,
            p_context           => K_CONTEXT,
            p_k_event_process   => p_event
        );
        --
    END process_event;
    --
    -- obteniendo el registro 
    FUNCTION get_record(
            p_city_co   cities.city_co%TYPE,
            p_result            OUT VARCHAR2 
        ) RETURN city_api_doc IS 
    BEGIN 
        --
        -- validamos que el codigo de ciudad exista
        IF NOT igtp.cfg_api_k_city.exist( p_city_co => p_city_co ) THEN
            --
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID CITY CODE'
            );
            --  
        END IF;
        --
        -- obtenemos el registro de la ciudad
        g_reg_city := igtp.cfg_api_k_city.get_record;
        --
        g_doc_city.p_city_co        := g_reg_city.city_co;
        g_doc_city.p_description    := g_reg_city.description;
        g_doc_city.p_telephone_co   := g_reg_city.telephone_co;
        g_doc_city.p_postal_co      := g_reg_city.postal_co;
        g_doc_city.p_slug           := g_reg_city.slug;
        g_doc_city.p_uuid           := g_reg_city.uuid;
        g_doc_city.p_nu_gps_lat     := g_reg_city.nu_gps_lat;
        g_doc_city.p_nu_gps_lon     := g_reg_city.nu_gps_lon;
        --
        -- obtenemos el registro de la municipalidad
        g_reg_municipality := igtp.cfg_api_k_municipality.get_record( 
            p_id => g_reg_city.municipality_id
        );
        --
        g_doc_city.p_municipality_co := g_reg_municipality.municipality_co;
        --
        -- obtenemos el registro del usuario
        g_reg_user := igtp.sec_api_k_user.get_record( 
            p_id => g_reg_city.user_id
        );
        --
        g_doc_city.p_user_co := g_reg_user.user_co;
        --
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        RETURN g_doc_city;
        --
        EXCEPTION
            WHEN e_exist_city_code THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                --
                RETURN NULL;
                -- 
            WHEN OTHERS THEN 
                --
                IF p_result IS NULL THEN 
                    --
                    p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                    --
                END IF;
                --
                RETURN NULL;
                --
        --
    END get_record;
    --
    -- create city by document
    PROCEDURE create_city (
            p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
            p_description       IN cities.description%TYPE DEFAULT NULL,
            p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
            p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
            p_municipality_co   IN municipalities.municipality_co%TYPE DEFAULT NULL,
            p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
            p_slug              IN cities.slug%TYPE DEFAULT NULL,
            p_user_co           IN users.user_co%TYPE DEFAULT NULL,
            p_result            OUT VARCHAR2 
        ) IS 
    BEGIN
        --
        g_doc_city.p_city_co            := p_city_co;
        g_doc_city.p_municipality_co    := p_municipality_co;
        g_doc_city.p_user_co            := p_user_co;
        --
        -- TODO: 1.- validar que el codigo de ciudad no exista
        IF cfg_api_k_city.exist( p_city_co => p_city_co ) THEN
            --
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID CITY CODE'
            );
            --  
        END IF;
        --
        -- valida los codigo asociados 
        validate_all;
        --
        g_reg_city.city_co          :=  p_city_co; 
        g_reg_city.description      :=  p_description;
        g_reg_city.telephone_co     :=  p_telephone_co; 
        g_reg_city.postal_co        :=  p_postal_co; 
        g_reg_city.municipality_id  :=  g_reg_municipality.id;
        g_reg_city.uuid             :=  p_uuid;
        --
        -- creamos el slug
        IF p_slug IS NULL THEN 
            --
            g_reg_city.slug :=  lower( substr(g_reg_municipality.slug||'-'||g_reg_city.city_co,1,60) );
            --
        ELSE
            --
            g_reg_city.slug :=  p_slug;
            --
        END IF;
        --
        g_reg_city.user_id          :=  g_reg_user.id;
        --
        -- ejecucion de procesos previos a insertar
        process_event( 
            p_event =>  sys_k_constant.K_DB_EP_BF_INSERT
        );
        --
        cfg_api_k_city.ins( p_rec => g_reg_city );
        --
        -- ejecucion de procesos posteriores a insertar
        process_event( 
            p_event =>  sys_k_constant.K_DB_EP_AF_INSERT
        );
        --
        COMMIT;
        --
        -- se establece los valores globales json
        set_global;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
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
    -- insert city by record
    PROCEDURE create_city( 
            p_rec               IN OUT city_api_doc,
            p_result            OUT VARCHAR2 
        ) IS 
    BEGIN
        --
        g_doc_city.p_city_co            := p_rec.p_city_co;
        g_doc_city.p_municipality_co    := p_rec.p_municipality_co;
        g_doc_city.p_user_co            := p_rec.p_user_co;
        --
        IF cfg_api_k_city.exist( p_city_co => p_rec.p_city_co ) THEN
            --
            raise_error( 
                p_cod_error => -20002,
                p_msg_error => 'INVALID CITY CODE'
            );
            --
        END IF;
        --
        -- valida los codigo asociados 
        validate_all;
        --
        g_reg_city.city_co          :=  p_rec.p_city_co; 
        g_reg_city.description      :=  p_rec.p_description;
        g_reg_city.telephone_co     :=  p_rec.p_telephone_co; 
        g_reg_city.postal_co        :=  p_rec.p_postal_co; 
        g_reg_city.municipality_id  :=  g_reg_municipality.id;
        g_reg_city.uuid             :=  p_rec.p_uuid;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_reg_city.slug :=  lower( substr(g_reg_municipality.slug||'-'||g_reg_city.city_co,1,60) );
            --
        ELSE
            --
            g_reg_city.slug :=  p_rec.p_slug;
            --
        END IF;
        --
        g_reg_city.user_id          :=  g_reg_user.id;
        --
        cfg_api_k_city.ins( 
            p_rec => g_reg_city 
        );
        --
        p_rec.p_uuid    := g_reg_city.uuid;
        p_rec.p_slug    := g_reg_city.slug;
        --
        COMMIT;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        EXCEPTION
            WHEN e_exist_city_code OR e_validate_municipality OR e_validate_user THEN 
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
    END create_city;
    --
    -- create city by json
    PROCEDURE create_city( 
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
        -- completamos los datos del registro ciudad
        g_doc_city.p_city_co            := l_obj.get_string('city_co');
        g_doc_city.p_description        := l_obj.get_string('description');
        g_doc_city.p_telephone_co       := l_obj.get_string('telephone_co');
        g_doc_city.p_postal_co          := l_obj.get_string('p_postal_co');
        g_doc_city.p_municipality_co    := l_obj.get_string('p_municipality_co');
        g_doc_city.p_slug               := l_obj.get_string('slug');
        g_doc_city.p_user_co            := l_obj.get_string('user_co');
        --
        create_city( 
            p_rec       => g_doc_city,
            p_result    => p_result
        );
        --
        l_obj.put('slug', g_doc_city.p_slug);
        l_obj.put('uuid', g_doc_city.p_uuid);
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
    END create_city;
    --
    -- create city by global data
    PROCEDURE create_city( 
            p_result    OUT VARCHAR2  
        ) IS
        --
        l_rec   city_api_doc;
        --
    BEGIN
        --
        -- global format JSON
        l_rec.p_city_co           := sys_k_global.ref_f_global(p_variable => 'city_co');
        l_rec.p_description       := sys_k_global.ref_f_global(p_variable => 'description');
        l_rec.p_telephone_co      := sys_k_global.ref_f_global(p_variable => 'telephone_co');
        l_rec.p_postal_co         := sys_k_global.ref_f_global(p_variable => 'postal_co');
        l_rec.p_municipality_co   := sys_k_global.ref_f_global(p_variable => 'municipality_co');
        l_rec.p_uuid              := sys_k_global.ref_f_global(p_variable => 'uuid');
        l_rec.p_slug              := sys_k_global.ref_f_global(p_variable => 'slug');
        l_rec.p_user_co           := sys_k_global.ref_f_global(p_variable => 'user_co');
        --
        create_city( 
            p_rec       => l_rec,
            p_result    => p_result
        );
        --
        set_global;
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
    END create_city;
    --
    -- update city by document
    PROCEDURE update_city(
            p_city_co           IN cities.city_co%TYPE DEFAULT NULL, 
            p_description       IN cities.description%TYPE DEFAULT NULL,
            p_telephone_co      IN cities.telephone_co%TYPE DEFAULT NULL, 
            p_postal_co         IN cities.postal_co%TYPE DEFAULT NULL, 
            p_municipality_co   IN municipalities.municipality_co%TYPE DEFAULT NULL,
            p_uuid              IN cities.uuid%TYPE DEFAULT NULL,
            p_slug              IN cities.slug%TYPE DEFAULT NULL,
            p_user_co           IN users.user_co%TYPE DEFAULT NULL,
            p_result            OUT VARCHAR2 
        ) IS
    BEGIN
        --
        g_doc_city.p_city_co            := p_city_co;
        g_doc_city.p_municipality_co    := p_municipality_co;
        g_doc_city.p_user_co            := p_user_co;
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_city.exist( p_city_co => p_city_co ) THEN
            --
            -- tomamos el registro encontrado
            g_reg_city := cfg_api_k_city.get_record;
            --
            -- valida los codigo asociados 
            validate_all;
            --
            g_reg_city.city_co          :=  p_city_co; 
            g_reg_city.description      :=  p_description;
            g_reg_city.telephone_co     :=  p_telephone_co; 
            g_reg_city.postal_co        :=  p_postal_co; 
            g_reg_city.municipality_id  :=  g_reg_municipality.id;
            --
            IF p_uuid IS NOT NULL THEN 
                g_reg_city.uuid             :=  p_uuid;
            END IF;
            --
            IF p_slug IS NOT NULL THEN 
                g_reg_city.slug             :=  p_slug;
            END IF;
            --
            g_reg_city.user_id          :=  g_reg_user.id;
            --
            cfg_api_k_city.upd( p_rec => g_reg_city );
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
            WHEN e_exist_city_code OR e_validate_municipality OR e_validate_user THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                -- 
            WHEN e_no_exist_city_code THEN 
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
    END update_city;
    --
    -- update city by record
    PROCEDURE update_city( 
            p_rec               IN OUT city_api_doc,
            p_result            OUT VARCHAR2 
        ) IS
    BEGIN
        --
        g_doc_city.p_city_co            := p_rec.p_city_co;
        g_doc_city.p_municipality_co    := p_rec.p_municipality_co;
        g_doc_city.p_user_co            := p_rec.p_user_co;
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_city.exist( p_city_co => p_rec.p_city_co ) THEN
            --
            -- tomamos el registro encontrado
            g_reg_city := cfg_api_k_city.get_record;
            --
            -- valida los codigo asociados 
            validate_all;
            --
            g_reg_city.city_co          :=  p_rec.p_city_co; 
            g_reg_city.description      :=  p_rec.p_description;
            g_reg_city.telephone_co     :=  p_rec.p_telephone_co; 
            g_reg_city.postal_co        :=  p_rec.p_postal_co; 
            g_reg_city.municipality_id  :=  g_reg_municipality.id;
            --
            IF p_rec.p_uuid IS NOT NULL THEN 
                g_reg_city.uuid             :=  p_rec.p_uuid;
            END IF;
            --
            IF p_rec.p_slug IS NOT NULL THEN 
                g_reg_city.slug             :=  p_rec.p_slug;
            END IF;
            --
            g_reg_city.user_id          :=  g_reg_user.id;
            --
            cfg_api_k_city.upd( p_rec => g_reg_city );
            --
            COMMIT;
            --
            p_rec.p_uuid    := g_reg_city.uuid;
            p_rec.p_slug    := g_reg_city.slug;
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --
        ELSE
            --
            -- TODO: Manejar el error cuando no exista el codigo de ciudad
            --
            -- TODO: regionalizacion de mensajes
            --
            raise_error( 
                p_cod_error => -20004,
                p_msg_error => 'INVALID CITY CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_exist_city_code OR e_validate_municipality OR e_validate_user THEN 
                --
                p_result := '{ "status":"ERROR", "message":"'|| SQLERRM ||'" }';
                -- 
            WHEN e_no_exist_city_code THEN 
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
    END update_city; 
    --
    -- update city by json
    PROCEDURE update_city( 
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
        -- completamos los datos del registro ciudad
        g_doc_city.p_city_co            := l_obj.get_string('city_co');
        g_doc_city.p_description        := l_obj.get_string('description');
        g_doc_city.p_telephone_co       := l_obj.get_string('telephone_co');
        g_doc_city.p_postal_co          := l_obj.get_string('p_postal_co');
        g_doc_city.p_municipality_co    := l_obj.get_string('p_municipality_co');
        g_doc_city.p_slug               := l_obj.get_string('slug');
        g_doc_city.p_user_co            := l_obj.get_string('user_co');
        --
        update_city( 
                p_rec       => g_doc_city,
                p_result    => p_result
        );
        --
        l_obj.put('slug', g_doc_city.p_slug);
        l_obj.put('uuid', g_doc_city.p_uuid);
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
    END update_city;  
    --
    -- delete
    PROCEDURE delete_city( 
            p_city_co   IN cities.city_co%TYPE,
            p_result    OUT VARCHAR2 
        ) IS 
        --
        g_reg_city              cities%ROWTYPE;
        --
    BEGIN 
        --
        -- TODO: 1.- validar que el codigo de ciudad exista
        IF cfg_api_k_city.exist( p_city_co => p_city_co ) THEN
            --
            -- tomamos el registro encontrado
            g_reg_city := cfg_api_k_city.get_record;
            --
            cfg_api_k_city.del( p_id => g_reg_city.id );
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
                p_msg_error => 'INVALID CITY CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_no_exist_city_code THEN 
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
    END delete_city;
    --
BEGIN
    --
    -- verificamos la configuracion Actual 
    g_cfg_co := nvl(sys_k_global.ref_f_global(
        p_variable => sys_k_constant.K_CONFIGURATION_ID
    ), K_CFG_CO );
    --
    -- tomamos la configuracion local
    g_reg_config := cfg_api_k_configuration.get_record( 
        p_id => g_cfg_co
    );
    --
    -- establecemos el lenguaje de trabajo
    sys_k_global.p_seter(
        p_variable  => sys_k_constant.K_FIELD_LANGUAGE_CO, 
        p_value     => g_reg_config.language_co
    );
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line('Init Package: '||sqlerrm);
    --
END prs_api_k_city;


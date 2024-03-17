CREATE OR REPLACE PACKAGE BODY prs_api_k_route IS
    ---------------------------------------------------------------------------
    --  DDL for Package ROUTE_API (Process)
    --  REFERENCES
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CITY                  PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de 
    --                                  rutas
    ---------------------------------------------------------------------------
    --
    K_CFG_CO     CONSTANT NUMBER        := 1;
    --
    -- GLOBALES
    g_cfg_co                        igtp.configurations.id%TYPE;
    g_doc_route                     route_api_doc;
    g_rec_from_city                 igtp.cities%ROWTYPE;
    g_rec_to_city                   igtp.cities%ROWTYPE;
    g_rec_user                      igtp.users%ROWTYPE;
    g_reg_config                    igtp.configurations%ROWTYPE;
    --
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    --
    e_validate_from_city            EXCEPTION;
    e_validate_to_city              EXCEPTION;
    e_exist_route_code              EXCEPTION;
    e_no_exist_route_code           EXCEPTION;
    e_distance_km_invalid           EXCEPTION;
    e_estimated_time_hrs            EXCEPTION;
    --
    PRAGMA exception_init( e_validate_from_city, -20002 );
    PRAGMA exception_init( e_validate_to_city, -20003 );
    PRAGMA exception_init( e_exist_route_code, -20004 );
    PRAGMA exception_init( e_no_exist_route_code, -20005 );
    PRAGMA exception_init( e_distance_km_invalid, -20006 );
    PRAGMA exception_init( e_estimated_thrs_invalid, -20007 );
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
    --
    -- validacion total
    PROCEDURE validate_all IS 
    BEGIN                   
        --
        -- validamos el codigo de la ciudad "desde" exista
        IF NOT cfg_api_k_city.exist( p_city_co =>  g_doc_route.p_from_city_co ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20002,
                p_msg_error => 'INVALID FROM CITY CODE'
            );
            --
        ELSE 
            --
            g_rec_from_city := igtp.cfg_api_k_city.get_record;
            --
        END IF;     
        --
        -- validamos el codigo de la ciudad "hasta" exista
        IF NOT cfg_api_k_city.exist( p_city_co =>  g_doc_route.p_to_city_co ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20003,
                p_msg_error => 'INVALID TO CITY CODE'
            );
            --
        ELSE 
            --
            g_rec_to_city := igtp.cfg_api_k_city.get_record;
            --
        END IF;             
        --
        -- validamos la distancia KM
        IF g_doc_route.p_distance_km <= 0 THEN 
            -- 
            raise_error( 
                p_cod_error => -20006,
                p_msg_error => 'INVALID KM DISTANCE'
            );
            --
        END IF;   
        --
        -- validamos el tiempo estimado en horas
        IF g_doc_route.p_estimated_time_hrs <= 0 THEN 
            -- 
            raise_error( 
                p_cod_error => -20007,
                p_msg_error => 'INVALID ESTIMATED TIME'
            );
            --
        END IF;        
        --
    END validate_all; 
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
            p_context   => sys_k_constant.K_ROUTE_LOAD_CONTEXT,
            p_line      => p_line,
            p_raw       => p_raw,
            p_result    => p_result,
            p_clob      => p_clob
        );
        --
    END record_log;  
    --
    -- create subsidiary by record
    PROCEDURE create_route( 
            p_rec       IN OUT route_api_doc,
            p_result    OUT VARCHAR2
        ) IS
    BEGIN
        --
        -- se establece el valor a la global 
        g_doc_route  := p_rec;
        --
        -- verificamos que el codigo de la ruta no exista
        IF lgs_api_k_route.exist( p_route_co => p_rec.p_route_co ) THEN
            --
            raise_error( 
                p_cod_error => -20004,
                p_msg_error => 'INVALID ROUTE CODE'
            );
            --
        END IF; 
        --
        -- validacion total
        validate_all;
        --
        -- completamos los datos del cliente
        g_rec_route.id                  := NULL;
        g_rec_route.route_co            := g_doc_route.p_route_co;
        g_rec_route.from_city_id        := g_rec_from_city.id;
        g_rec_route.to_city_id          := g_rec_to_city.id;
        g_rec_route.distance_km         := g_doc_route.p_distance_km;
        g_rec_route.estimated_time_hrs  := g_doc_route.p_estimated_time_hrs;
        g_rec_route.uuid                := NULL;
        g_rec_route.user_id             := g_rec_user.id;
        g_rec_route.created_at          := sysdate;
        --
        IF g_doc_route.p_description IS NOT NULL THEN 
            --
            g_rec_route.description  := g_doc_route.p_description;
            --
        ELSE
            --
            g_rec_route.description  := upper( substr(g_rec_from_city.city_co||'-'||g_rec_to_city.city_co,1,60) );
            --
        END IF;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_rec_route.slug :=  lower( substr(g_rec_from_city.city_co||'-'||g_rec_to_city.city_co,1,60) );
            --
        ELSE
            --
            g_rec_route.slug :=  g_doc_route.p_slug;
            --
        END IF;
        --
        -- creamos el registro
        lgs_api_k_route.ins( 
            p_rec => g_rec_route
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
            WHEN e_validate_customer  OR
                 e_exist_shop_code    OR
                 e_no_exist_shop_code OR
                 e_no_exist_route_code OR
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
    END create_route;      
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
END prs_api_k_route;
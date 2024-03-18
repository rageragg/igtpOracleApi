CREATE OR REPLACE PACKAGE BODY prs_api_k_subsidiary IS
    ---------------------------------------------------------------------------
    --  DDL for Package SUBSIDIARY_API (Process)
    --  REFERENCES
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CUSTOMER              PAQUETE DE BASE
    --  CFG_API_K_SHOP                  PAQUETE DE BASE
    --  CFG_API_K_USER                  PAQUETE DE BASE
    --  PRS_API_K_LANGUAGE              PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de 
    --                                  subsidiarias
    ---------------------------------------------------------------------------
    --
    K_CFG_CO     CONSTANT NUMBER        := 1;
    --
    -- GLOBALES
    g_cfg_co            igtp.configurations.id%TYPE;
    g_doc_subsidiary    subsidiary_api_doc;
    g_rec_subsidiary    igtp.subsidiaries%ROWTYPE;
    g_rec_customer      igtp.customers%ROWTYPE;
    g_rec_shop          igtp.shops%ROWTYPE;
    g_rec_user          igtp.users%ROWTYPE;
    g_reg_config        igtp.configurations%ROWTYPE;
    --
    -- TODO: crear el manejo de errores para transferirlo al nivel superior
    --
    g_hay_error                     BOOLEAN;
    g_msg_error                     VARCHAR2(512);
    g_cod_error                     NUMBER;
    -- excepciones
    e_validate_customer             EXCEPTION;
    e_exist_shop_code               EXCEPTION;
    e_exist_customer_code           EXCEPTION;
    e_exist_subsidiary_code         EXCEPTION;
    e_validate_user                 EXCEPTION;
    e_validate_email                EXCEPTION;
    e_no_exist_shop_code            EXCEPTION;
    e_no_exist_subsidiary_code      EXCEPTION;
    e_no_exist_customer_code        EXCEPTION;
    --
    PRAGMA exception_init( e_validate_customer, -20002 );
    PRAGMA exception_init( e_exist_shop_code, -20003 );
    PRAGMA exception_init( e_validate_email, -20005 );
    PRAGMA exception_init( e_validate_user,  -20006 );
    PRAGMA exception_init( e_no_exist_shop_code, -20007 );
    --
    PRAGMA exception_init( e_exist_subsidiary_code, -20008 );
    PRAGMA exception_init( e_no_exist_subsidiary_code, -20009 );

    PRAGMA exception_init( e_exist_customer_code, -20010 );
    PRAGMA exception_init( e_no_exist_customer_code, -20011 );
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
        RAISE_APPLICATION_ERROR(g_cod_error, g_msg_error );
        -- 
    END raise_error;      
    --
    -- validacion total
    PROCEDURE validate_all IS 
    BEGIN                   
        --
        -- validamos el codigo de la localidad del cliente
        IF NOT dsc_api_k_shop.exist( p_shop_co =>  g_doc_subsidiary.p_shop_co ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20007,
                p_msg_error => 'INVALID SHOP CODE'
            );
            --
        ELSE 
            --
            g_rec_shop := igtp.dsc_api_k_shop.get_record;
            --
        END IF;     
        --
        -- validamos el codigo del cliente exista
        IF NOT dsc_api_k_customer.exist( p_customer_co =>  g_doc_subsidiary.p_customer_co ) THEN 
            -- 
            raise_error( 
                p_cod_error => -20011,
                p_msg_error => 'INVALID CUSTOMER CODE'
            );
            --
        ELSE 
            --
            g_rec_customer := igtp.dsc_api_k_customer.get_record;
            --
        END IF;          
        --
        -- validamos el codigo del usuario
        IF NOT sec_api_k_user.exist( p_user_co =>  g_doc_subsidiary.p_user_co ) THEN 
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
            p_context   => sys_k_constant.K_SUBSIDIARY_LOAD_CONTEXT,
            p_line      => p_line,
            p_raw       => p_raw,
            p_result    => p_result,
            p_clob      => p_clob
        );
        --
    END record_log;       
    --
    -- create subsidiary by record
    PROCEDURE create_subsidiary( 
            p_rec       IN OUT subsidiary_api_doc,
            p_result    OUT VARCHAR2
        ) IS
    BEGIN
        --
        -- se establece el valor a la global 
        g_doc_subsidiary  := p_rec;
        --
        -- verificamos que el codigo de la subsidiaria no exista
        IF dsc_api_k_subsidiary.exist( p_subsidiary_co => p_rec.p_subsidiary_co ) THEN
            --
            raise_error( 
                p_cod_error => -20011,
                p_msg_error => 'INVALID SUBSIDIARY CODE'
            );
            --
        END IF; 
        --
        -- validacion total
        validate_all;
        --
        -- completamos los datos del cliente
        g_rec_subsidiary.id             := NULL;
        g_rec_subsidiary.subsidiary_co  := g_doc_subsidiary.p_subsidiary_co;
        g_rec_subsidiary.customer_id    := g_rec_customer.id; 
        g_rec_subsidiary.shop_id        := g_rec_shop.id;
        g_rec_subsidiary.uuid           := NULL;
        g_rec_subsidiary.user_id        := g_rec_user.id;
        g_rec_subsidiary.created_at     := sysdate;
        --
        -- creamos el slug
        IF p_rec.p_slug IS NULL THEN 
            --
            g_rec_subsidiary.slug :=  lower( substr(g_rec_customer.slug||'-'||g_rec_subsidiary.subsidiary_co,1,60) );
            --
        ELSE
            --
            g_rec_subsidiary.slug :=  g_doc_subsidiary.p_slug;
            --
        END IF;
        --
        -- creamos el registro
        dsc_api_k_subsidiary.ins( 
            p_rec => g_rec_subsidiary
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
                 e_no_exist_subsidiary_code OR
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
    END create_subsidiary;    
    --
    -- create subsidiary by json
    PROCEDURE create_subsidiary( 
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
        g_doc_subsidiary.p_subsidiary_co      := l_obj.get_string('subsidiary_co');
        g_doc_subsidiary.p_shop_co            := l_obj.get_string('shop_co');
        g_doc_subsidiary.p_customer_co        := l_obj.get_string('customer_co');
        g_doc_subsidiary.p_slug               := l_obj.get_string('slug');
        g_doc_subsidiary.p_user_co            := l_obj.get_string('user_co');
        --
        create_subsidiary( 
            p_rec      => g_doc_subsidiary,
            p_result   => p_result
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
    END create_subsidiary;         
    --
    -- update subsidiary by record
    PROCEDURE update_subsidiary(
            p_rec       IN OUT subsidiary_api_doc,
            p_result    OUT VARCHAR2
        ) IS 
    BEGIN
        --
        -- se establece el valor a la global 
        g_doc_subsidiary  := p_rec;
        --
        -- verificamos que el codigo de cliente no exista
        IF dsc_api_k_subsidiary.exist( p_subsidiary_co => p_rec.p_subsidiary_co ) THEN
            --
            g_rec_subsidiary := dsc_api_k_subsidiary.get_record;
            --
            -- validacion total
            validate_all;
            --
            -- completamos los datos del cliente
            g_rec_subsidiary.customer_id          := g_rec_customer.id;
            g_rec_subsidiary.shop_id              := g_rec_shop.id;
            g_rec_subsidiary.updated_at           := sysdate;
            --
            -- creamos el slug
            IF p_rec.p_slug IS NULL THEN 
                --
                g_rec_subsidiary.slug :=  lower( substr(g_rec_customer.slug||'-'||g_rec_subsidiary.subsidiary_co,1,60) );
                --
            ELSE
                --
                g_rec_subsidiary.slug :=  g_doc_subsidiary.p_slug;
                --
            END IF;
            --
            -- creamos el registro
            dsc_api_k_subsidiary.upd( 
                p_rec => g_rec_subsidiary
            );
            --
            p_rec.p_uuid    := g_rec_shop.uuid;
            p_rec.p_slug    := g_rec_shop.slug;
            --
            COMMIT;
            --
        ELSE 
            --
            raise_error( 
                p_cod_error => -20007,
                p_msg_error => 'INVALID SUBSIDIARY CODE'
            );
            --
        END IF;
        --
        p_result := '{ "status":"OK", "message":"SUCCESS" }';
        --
        EXCEPTION 
            WHEN e_validate_customer  OR
                 e_no_exist_subsidiary_code OR
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
    END update_subsidiary;  
    --
    -- update subsidiary by json
    PROCEDURE update_subsidiary( 
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
        g_doc_subsidiary.p_subsidiary_co      := l_obj.get_string('subsidiary_co');
        g_doc_subsidiary.p_customer_co        := l_obj.get_string('customer_co');
        g_doc_subsidiary.p_shop_co            := l_obj.get_string('shop_co');
        g_doc_subsidiary.p_slug               := l_obj.get_string('slug');
        g_doc_subsidiary.p_user_co            := l_obj.get_string('user_co');        
        --
        update_subsidiary( 
            p_rec       => g_doc_subsidiary,
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
    END update_subsidiary;  
    --
    -- update subsidiary by json
    PROCEDURE delete_subsidiary( 
            p_subsidiary_co       IN subsidiaries.subsidiary_co%TYPE,
            p_result        OUT VARCHAR2 
        ) IS 
    BEGIN 
        --
        -- verificamos que el codigo de cliente no exista
        IF dsc_api_k_subsidiary.exist( p_subsidiary_co => p_subsidiary_co ) THEN
            --
            -- tomamos el registro encontrado
            g_rec_subsidiary := dsc_api_k_subsidiary.get_record;
            --
            dsc_api_k_subsidiary.del( p_id => g_rec_subsidiary.id );
            --
            p_result := '{ "status":"OK", "message":"SUCCESS" }';
            --
        ELSE 
            --
            raise_error( 
                p_cod_error => -20009,
                p_msg_error => 'INVALID SHOP CODE'
            );
            --
        END IF;
        --
        EXCEPTION
            WHEN e_no_exist_subsidiary_code THEN 
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
    END delete_subsidiary;  
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
                   c001 subsidiary_co, 
                   c002 customer_co, 
                   c003 shop_co, 
                   c004 slug, 
                   c005 user_co
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
                    -- completamos los datos del registro subsidiaria
                    g_doc_subsidiary.p_subsidiary_co      := r_reg.subsidiary_co;
                    g_doc_subsidiary.p_customer_co        := r_reg.customer_co;
                    g_doc_subsidiary.p_shop_co            := r_reg.shop_co;
                    g_doc_subsidiary.p_slug               := NULL;
                    g_doc_subsidiary.p_user_co            := l_user_code;
                    --
                    -- crear tienda
                    create_subsidiary( 
                        p_rec       => g_doc_subsidiary,
                        p_result    => p_result
                    );
                    --
                    -- manejo de log
                    record_log( 
                        p_context   => sys_k_constant.K_SUBSIDIARY_LOAD_CONTEXT,
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
                    p_file_name       => sys_k_constant.K_SUBSIDIARY_FILE_DATA_LOAD,
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
END prs_api_k_subsidiary;
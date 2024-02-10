CREATE OR REPLACE PACKAGE BODY prs_k_api_language IS
    --
    -- tabla de propiedades a recibir
    TYPE t_properties IS TABLE OF VARCHAR2(60) INDEX BY PLS_INTEGER;
    --
    -- GLOBALES
    g_tab_properties    t_properties;
    g_error_message     VARCHAR2(512);
    g_error_code        NUMBER;
    g_rec_diccionary    t_diccionary;
    g_rec_configuration configurations%ROWTYPE;
    --
    -- EXCEPTIONS
    e_validate_properties EXCEPTION;
    --
    -- PRAGMAS
    PRAGMA exception_init( e_validate_properties, -20001 );
    --
    -- inicializa la tabla de propiesdades
    PROCEDURE p_init_tab_properties IS  
    BEGIN 
        --
        g_tab_properties(1) := 'language_co';
        g_tab_properties(2) := 'description';
        g_tab_properties(3) := 'context';
        g_tab_properties(4) := 'code_error'; 
        g_tab_properties(5) := 'description_error';
        g_tab_properties(6) := 'cause_error';
        --
    END p_init_tab_properties;
    --
    -- inicializa las globales
    PROCEDURE p_init_globals IS 
    BEGIN  
        --
        g_rec_configuration := cfg_api_k_configuration.get_record( 
                                    p_id => sys_k_global.ref_f_global('LANGUAGE_CO') 
                               );
        --
    END p_init_globals;
    --
    -- verifica que existan las propiedades esperadas
    FUNCTION f_chk_properties( 
            p_key_list_param    IN json_key_list
        ) RETURN BOOLEAN IS 
        --
        l_count     PLS_INTEGER := 0;
        --
    BEGIN 
        --
        -- chequeamos que la cantidad de elementos sean los esperados
        IF g_tab_properties.COUNT < p_key_list_param.COUNT THEN
            --
            RETURN FALSE;
            -- 
        END IF;
        --
        -- chequeamos que las propiedades existan en su totalidad
        FOR counter IN 1 .. p_key_list_param.COUNT LOOP 
            --
            IF g_tab_properties.EXISTS(counter) THEN
                --
                IF p_key_list_param(counter) = g_tab_properties(counter) THEN 
                    --
                    l_count := l_count + 1;
                    --
                END IF;
                -- 
            END IF;
            --
        END LOOP; 
        --
        RETURN (l_count >= g_tab_properties.COUNT); 
        --
    END f_chk_properties;
    --
    -- devuelve el mensaje del diccionario
    FUNCTION f_message( 
            p_language_co IN VARCHAR2,
            p_context     IN VARCHAR2,
            p_error_co    IN VARCHAR2 
        ) RETURN VARCHAR2 IS 
        --
        l_message   VARCHAR2(1024);
        --
        -- cursor de busqueda de mensaje de error 
        CURSOR c_message IS 
            SELECT a.description_error description
                FROM languages b,
                     json_table(
                            b.diccionary, 
                            '$[*]' COLUMNS (
                                    code_error   VARCHAR PATH '$.code_error',
                                    context      VARCHAR PATH '$.context',
                                    description_error  VARCHAR PATH '$.description_error'
                            )
                        ) a
               WHERE b.language_co = p_language_co
                 AND a.context     = p_context
                 AND a.code_error  = p_error_co;
        --
    BEGIN  
        --
        OPEN c_message;
        FETCH c_message INTO l_message;
        CLOSE c_message;
        --
        RETURN l_message;
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                --
                RETURN NULL; 
                --
            WHEN OTHERS THEN 
                --
                -- TODO: manejar el error propio
                RETURN NULL;
        --
    END f_message;
    --
    -- incluir o actualizar diccionario
    FUNCTION f_ins_upd_diccionary( 
            p_json          IN VARCHAR2,
            p_result        OUT VARCHAR2 
        ) RETURN BOOLEAN IS
        --
        l_json              VARCHAR2(32000) := p_json;
        l_obj_param         json_object_t;
        l_obj_actual        json_object_t; 
        l_obj_diccionary    json_object_t;
        l_obj_new           json_object_t;
        l_key_list_param    json_key_list;
        l_key_list_actual   json_key_list; 
        l_array_actual      json_array_t;
        --
        -- registro de lenguaje
        l_reg_actual        languages%ROWTYPE;
        l_insert            BOOLEAN := TRUE;
        l_ok                BOOLEAN;
        -- 
    BEGIN
        --
        -- realizamos la conversion 
        l_obj_param         := json_object_t.parse(l_json);
        l_key_list_param    := l_obj_param.get_keys;
        --
        -- chequeamos las propiedades
        IF NOT f_chk_properties( p_key_list_param => l_key_list_param ) THEN  
            --
            -- TODO: se lanza la excepcion
            g_rec_diccionary.context            := prs_k_api_language.K_CONTEXT;
            g_rec_diccionary.error_co           := -20001;
            g_rec_diccionary.error_description  := f_message( 
                                                    p_language_co => g_rec_configuration.language_co,
                                                    p_context     => g_rec_diccionary.context ,
                                                    p_error_co    => g_rec_diccionary.error_co
                                                );
            --
            p_result := g_rec_diccionary.error_description;
            --
            raise_application_error(g_rec_diccionary.error_co, p_result );
            --
        ELSE
            --
            -- PROCESAMOS LAS PROPIEDADES
            --
            -- verificamos que exista
            l_reg_actual := cfg_api_k_language.get_record( 
                p_language_co => l_obj_param.get_string('language_co')
            );
            -- 
            -- el lenguaje existe, hacemos la conversion
            l_obj_actual        := json_object_t.parse( '{ "diccionary":' ||nvl(l_reg_actual.diccionary,'[]') ||'}' );
            l_array_actual      := l_obj_actual.get_array('diccionary');
            --
            IF l_reg_actual.language_co IS NOT NULL THEN 
                --
                -- ! existe el registro
                -- verificamos si los valores que vienen de los parametros estan ya registrados 
                -- se actualizan
                FOR counter IN 0 .. l_array_actual.get_size - 1 LOOP
                    --
                    -- seleccionamos el elemento actual
                    l_obj_diccionary := json_object_t(l_array_actual.get(counter));
                    l_key_list_actual   := l_obj_diccionary.get_keys;
                    --
                    IF l_obj_diccionary.has('code_error') THEN 
                        --
                        IF l_obj_diccionary.get_string('code_error') = l_obj_param.get_string('code_error') THEN 
                            --
                            l_insert := FALSE;
                            --
                        END IF;
                        --
                    END IF;
                    --
                    -- verificamos el resultado del analisis
                    IF NOT l_insert THEN 
                        --
                        l_obj_diccionary.put('context', l_obj_param.get_string('context') );
                        l_obj_diccionary.put('description_error', l_obj_param.get_string('description_error') );
                        l_obj_diccionary.put('cause_error', l_obj_param.get_string('cause_error') );
                        --
                        EXIT;
                        --
                    END IF;
                    --
                END LOOP;
                --
                -- insertar en el documento JSON y actualiza la base de datos
                IF l_insert THEN 
                    --
                    l_obj_new := json_object_t.parse( 
                        '{   "context": "' || l_obj_param.get_string('context') || '",' ||
                        '    "code_error":"' || l_obj_param.get_string('code_error') || '",' ||
                        '    "description_error":"' || l_obj_param.get_string('description_error') || '",' ||
                        '    "cause_error": "' || l_obj_param.get_string('cause_error') || '"' ||
                        '}'
                    );
                    --
                    l_array_actual.append(l_obj_new);           
                    --
                END IF; 
                --
                l_reg_actual.diccionary := l_array_actual.stringify;
                cfg_api_k_language.upd( p_rec => l_reg_actual );
                --   
            ELSE 
                --
                -- ! NO existe el registro
                -- no existe, hay que incluirlo
                l_reg_actual.language_co    := l_obj_param.get_string('language_co');
                l_reg_actual.description    := l_obj_param.get_string('description');
                l_reg_actual.diccionary     := '';
                --
                l_obj_actual        := json_object_t.parse( 
                    '{ "diccionary": [ {' ||
                    '    "context": "' || l_obj_param.get_string('context') || '",' ||
                    '    "code_error":"' || l_obj_param.get_string('code_error') || '",' ||
                    '    "description_error":"' || l_obj_param.get_string('description_error') || '",' ||
                    '    "cause_error": "' || l_obj_param.get_string('cause_error') || '"' ||
                    '}]}'
                );
                --
                -- covertimos el objeto json valido ARRAY
                l_array_actual          := l_obj_actual.get_array('diccionary');
                l_reg_actual.diccionary := l_array_actual.stringify; 
                --
                -- Lo insertamos en la base de datos 
                cfg_api_k_language.ins ( p_rec => l_reg_actual ); 
                l_ok := TRUE;
                --
            END IF;
            --                    
        END IF;
        --
        -- verificacion de resultado
        IF NOT l_ok THEN 
            --
            p_result := 'ERROR';
            ROLLBACK;
            --
        ELSE
            --
            p_result := 'SUCCESS';
            --
            COMMIT;
            --
        END IF;
        --
        RETURN l_ok;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                --
                ROLLBACK;
                p_result := SQLERRM;
                RETURN l_ok;

        -- 
    END f_ins_upd_diccionary;
    --
    -- incluir o actualizar diccionario
    FUNCTION p_ins_upd_diccionary(
            p_language_co       IN VARCHAR2, 
            p_description       IN VARCHAR2,
            p_context           IN VARCHAR2,
            error_code          IN VARCHAR2,
            error_descripcion   IN VARCHAR2,
            error_cause         IN VARCHAR2 
        ) RETURN BOOLEAN IS 
        --
        l_json      VARCHAR2(2048);
        l_result    VARCHAR2(2048);
        l_ok        BOOLEAN;
        --
    BEGIN 
        --
        l_json  := '{
            "language_co":"'||p_language_co||'",
            "description": "'||p_description||'",
            "context": "'||p_context||'",
            "code_error":"'||error_code||'", 
            "description_error":"'||error_descripcion||'",
            "cause_error": "'||error_cause||'"
        }'; 
        --
        l_ok := prs_k_api_language.f_ins_upd_diccionary(
                                                        p_json          => l_json,
                                                        p_result        => l_result 
                                                    );
        --
        RETURN l_ok;
        --
    END p_ins_upd_diccionary;
    --
    -- devuelve el mensaje del diccionario
    FUNCTION f_message_list( 
            p_language_co IN VARCHAR2,
            p_context     IN VARCHAR2 
        ) RETURN t_diccionary_tab IS 
        --
        l_diccionary_tab    t_diccionary_tab;
        l_diccionary_rec    t_diccionary;
        --
        -- datos
        CURSOR c_message IS
        SELECT a.context, a.code_error error_co, a.description_error description, rownum idx
            FROM languages b,
                json_table(
                        b.diccionary, 
                        '$[*]' COLUMNS (
                                code_error   VARCHAR PATH '$.code_error',
                                context      VARCHAR PATH '$.context',
                                description_error  VARCHAR PATH '$.description_error'
                        )
                    ) a
            WHERE b.language_co = p_language_co
              AND a.context     = nvl(p_context, a.context );
        --
    BEGIN 
        --
        FOR r_rec IN c_message LOOP 
            --
            l_diccionary_rec.context            := r_rec.context;
            l_diccionary_rec.error_co           := r_rec.error_co;
            l_diccionary_rec.error_description  := r_rec.description;
            l_diccionary_rec.error_cause        := null;
            l_diccionary_tab(r_rec.idx) := l_diccionary_rec;
            --
        END LOOP;
        --
        RETURN l_diccionary_tab;
        --
    END f_message_list; 
    --
BEGIN
    --
    -- inicializacion de propiedades
    p_init_tab_properties;
    --
    p_init_globals;
    --
END prs_k_api_language;
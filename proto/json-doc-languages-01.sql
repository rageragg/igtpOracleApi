declare 
    --
    l_json              VARCHAR2(32000);
    l_obj_param         json_object_t;
    l_key_list_param    json_key_list; 
    l_array_param       json_array_t;
    l_obj_actual        json_object_t;
    l_key_list_actual   json_key_list; 
    l_array_actual      json_array_t;
    l_obj_diccionary    json_object_t;
    l_obj_new           json_object_t;
    --
    r_customer  prs_api_k_customer.customer_api_doc;
    l_result    VARCHAR2(512);
    l_ok        BOOLEAN;
    l_insert    BOOLEAN := TRUE;
    --
    -- registro de lenguaje
    l_reg_actual languages%ROWTYPE;
    /*
    SELECT a.context, a.code_error error_co, a.description_error description
      FROM languages b,
           json_table(
                b.diccionary, 
                '$[*]' COLUMNS (
                        code_error   VARCHAR PATH '$.code_error',
                        context      VARCHAR PATH '$.context',
                        description_error  VARCHAR PATH '$.description_error'
                )
            ) a
     WHERE b.language_co = 'ES'
    */
    --
    -- metodo que verifica las propiedades del objeto
begin 
    --
    -- parametro recibido
    l_json  := '{
        "language_co":"ES",
        "description": "ESPANOL",
        "context": "GENERAL",
        "code_error":"00002", 
        "description_error":"INSERTANDO",
        "cause_error": "Esta intentando agregar un valor de clave unica que ya existe!"
    }'; 
    --
    -- realizamos la conversion 
    l_obj_param         := json_object_t.parse(l_json);
    l_key_list_param    := l_obj_param.get_keys; 
    --
    -- verificamos que exista
    l_reg_actual := cfg_api_k_language.get_record( 
        p_language_co => l_obj_param.get_string('language_co')
    );
    --
    IF l_reg_actual.language_co IS NOT NULL THEN 
        -- 
        -- el lenguaje existe, hacemos la conversion
        l_obj_actual        := json_object_t.parse( '{ "diccionary":' ||nvl(l_reg_actual.diccionary,'[]') ||'}' );
        l_array_actual      := l_obj_actual.get_array('diccionary');
        --
        -- verificamos si los valores que vienen de los parametros estan ya registrados 
        -- se actualizan
        FOR counter IN 0 .. l_array_actual.get_size - 1
        LOOP
            --
            -- seleccionamos el elemento actual
            l_obj_diccionary := json_object_t(l_array_actual.get(counter));
            l_key_list_actual   := l_obj_diccionary.get_keys;
            --
            dbms_output.put_line( l_obj_actual.stringify );
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
                dbms_output.put_line( l_obj_diccionary.stringify );
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
            dbms_output.put_line( 'INSERTANDO' );
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
        dbms_output.put_line( 'ACTUALIZANDO' );
        l_reg_actual.diccionary := l_array_actual.stringify;
        cfg_api_k_language.upd( p_rec => l_reg_actual );
        --
    ELSE
        --
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
    -- verificacion de resultado
    IF NOT l_ok THEN 
        --
        dbms_output.put_line(l_result);
        ROLLBACK;
        --
    ELSE
        --
        COMMIT;
        --
    END IF;
    --
end;
CREATE OR REPLACE PACKAGE BODY prs_api_k_language IS
    --
    -- tabla de propiedades a recibir
    TYPE t_properties IS TABLE OF VARCHAR2(60);
    --
    -- GLOBALES
    g_tab_properties    t_properties;
    g_error_message     VARCHAR2(512);
    g_error_code        NUMBER;
    g_rec_diccionary    t_diccionary;
    g_rec_configuration configuratiosn%ROWTYPE;
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
        FOR counter IN 1 .. p_key_list_param.COUNT 
        LOOP 
            --
            IF g_tab_properties.EXISTS(p_key_list_param(counter)) THEN
                --
                l_count := l_count + 1;
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
    FUNCTION p_message( 
        p_language_co IN VARCHAR2,
        p_context     IN VARCHAR2,
        p_error_co    IN VARCHAR2 
    ) RETURN VARCHAR2 IS 
        --
        l_message   VARCHAR2(1024);
        --
        -- cursor de busqueda de mensaje de error
        CURSOR c_message IS 
           SELECT a.error_descripcion
             FROM languages b,
                  json_table(
                        b.diccionary, 
                        '$[*]' COLUMNS (
                                error_code   VARCHAR PATH '$.error_code',
                                context      VARCHAR PATH '$.context',
                                error_descripcion  VARCHAR PATH '$.error_descripcion'
                        )
                  ) a
            WHERE b.language_co = p_language_co
              AND a.context     = p_context
              AND a.error_code  = p_error_co;
        --
    BEGIN  
        --
        OPEN c_message;
        FETCH c_message INTO l_message;
        CLOSE c_message;
        --
        RETURN l_message;
        --
        EXCEPTIONS
            WHEN NO_DATA_FOUND THEN 
                --
                RETURN NULL;
                -- 
            WHEN OTHERS THEN 
                --
                -- TODO: manejar el error propio
                RETURN NULL;
        --
    END p_message;
    --
    -- incluir o actualizar diccionario
    FUNCTION p_ins_upd_diccionary( 
            p_json          IN VARCHAR2,
            p_result        OUT VARCHAR2 
        ) RETURN BOOLEAN IS
        --
        l_json              VARCHAR2(32000) := p_json;
        l_obj_param         json_object_t;
        l_key_list_param    json_key_list;
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
            g_rec_diccionary.context  := prs_api_k_language.K_CONTEXT;
            g_rec_diccionary.error_co := -20001;
            error_description         := p_message( 
                                            p_language_co => g_rec_configuration.language_co,
                                            p_context     => g_rec_diccionary.context ,
                                            p_error_co    => g_rec_diccionary.error_co
                                        );
            --
            p_result := error_description;
            --
            raise_application_error(g_rec_diccionary.error_co, p_result );
            --
        END IF;
        -- 
    END p_ins_upd_diccionary;
    --
BEGIN
    --
    -- inicializacion de propiedades
    p_init_tab_properties;
    --
    p_init_globals;
    --
END prs_api_k_language;
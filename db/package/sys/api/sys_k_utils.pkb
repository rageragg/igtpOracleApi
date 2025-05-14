--------------------------------------------------------
--  DDL for Package Body sys_k_utils
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.sys_k_utils AS
    --
    -- VERSION: 1.00.00
    /* --------------------------------
    || Tratamiento de Globales (PL/SQL)
    */---------------------------------
    --
    -- ! GLOBALES
    g_source_parameters CHAR(1)         DEFAULT 'D'; -- D es DEFAULT, I es INSTALACION igtp
    g_nls_date_format   VARCHAR2(128);
    g_nls_time_format   VARCHAR2(128);
    --
    -- ! PRIVADAS
    -- 
    -- devuelve el valor del parametro de configuracion
    FUNCTION pf_parameters_db( p_parameter IN VARCHAR2 ) RETURN VARCHAR2 IS 
        --
        l_value VARCHAR2(128);
        --
    BEGIN  
        --
        IF g_source_parameters = sys_k_utils.K_SDBP_DEFAULT THEN 
            --
            SELECT value  
              INTO l_value
              FROM nls_database_parameters
             WHERE parameter = p_parameter;
            --
        ELSE 
            --
            SELECT value  
              INTO l_value
              FROM igtp.database_parameters
             WHERE parameter = p_parameter;
            --
        END IF;     
        --
        RETURN l_value;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN NULL;
        --         
    END pf_parameters_db;
    --
    -- ! PUBLICAS
    -- 
    -- Funcion que devuelve un identificador unico
    FUNCTION f_uuid RETURN VARCHAR2 IS 
        --
        l_uuid      VARCHAR2(60) := sys_guid();
        l_result    VARCHAR2(60) := NULL;
        l_init      NUMBER(03)   := 1;
        --
        -- cursor para defragmentar el codigo
        CURSOR c_k_defragment IS
            SELECT rownum, regexp_substr(igtp.sys_k_utils.K_FRAGMENT_UUID, '[^,]+', 1, LEVEL) fragment,
                   cast('' AS VARCHAR2(60)) result
              FROM DUAL
             CONNECT BY regexp_substr(igtp.sys_k_utils.K_FRAGMENT_UUID, '[^,]+', 1, LEVEL) IS NOT NULL;
        --     
    BEGIN
        --
        FOR r_frag IN c_k_defragment LOOP 
            --
            r_frag.result := substr(l_uuid,l_init,r_frag.fragment);  
            --
            IF l_init = 1 THEN 
                l_result := r_frag.result;
            ELSE 
                l_result := l_result ||'-'|| r_frag.result;    
            END IF;
            --    
            l_init := l_init + to_number( r_frag.fragment );
            --
        END LOOP;
        --
        RETURN lower(l_result);
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN NULL;
        --        
    END f_uuid;
    --
    -- ! LISTAS
    -- 
    -- funcion que devuelve un cursor a partir de una lista separada por ','
    -- salida del cursor es { id, data }
    FUNCTION f_list_to_cursor( 
            p_list      IN VARCHAR2, 
            p_separator IN VARCHAR2 DEFAULT ',' 
        ) RETURN sys_refcursor IS 
        --
        l_cursor sys_refcursor;
        -- 
    BEGIN       
        --
        OPEN l_cursor FOR 
            SELECT rownum id, regexp_substr(p_list, '[^'||p_separator||']+', 1, LEVEL) data
              FROM DUAL
             CONNECT BY regexp_substr(p_list, '[^'||p_separator||']+', 1, LEVEL) IS NOT NULL;
        --
        RETURN l_cursor;
        --
    END f_list_to_cursor;    
    --    
    -- procedimiento que establece el los parametros de la instalacion
    PROCEDURE p_set_install_parameters IS 
    BEGIN 
        --
        g_source_parameters := sys_k_utils.K_SDBP_INSTALL;
        --
    END p_set_install_parameters;    
    --
    -- procedimiento que establece el los parametros de la base de datos
    PROCEDURE p_set_database_parameters IS 
    BEGIN 
        --
        g_source_parameters := sys_k_utils.K_SDBP_DEFAULT;
        --
    END p_set_database_parameters;       
    --
    -- function que devuelve el formato de fecha K_NLS_DATE_FORMAT
    FUNCTION f_k_nls_date_format RETURN VARCHAR2 IS 
        --
        l_test_date DATE;
        --
    BEGIN 
        --
        IF g_nls_date_format IS NULL THEN 
            g_nls_date_format := pf_parameters_db( p_parameter => 'NLS_DATE_FORMAT' );
        ELSE 
            l_test_date := to_char(sysdate, g_nls_date_format );
        END IF;
        --    
        RETURN g_nls_date_format;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN NULL;
        --        
    END f_k_nls_date_format;
    --
    -- function que devuelve el formato de fecha NLS_TIME_FORMAT
    FUNCTION f_k_nls_time_format RETURN VARCHAR2  IS 
        --
        l_test_date DATE;
        --
    BEGIN 
        --
        IF g_nls_time_format IS NULL THEN 
            g_nls_time_format := pf_parameters_db( p_parameter => 'NLS_TIME_FORMAT' );
        ELSE 
            l_test_date := to_char(sysdate, g_nls_time_format );
        END IF; 
        --    
        RETURN g_nls_time_format;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN NULL;
        --        
    END f_k_nls_time_format;
    --
    -- function que devuelve modo de calendario NLS_CALENDAR
    FUNCTION f_k_nls_calendar RETURN VARCHAR2 IS 
    BEGIN 
        --
        RETURN pf_parameters_db( p_parameter => 'NLS_CALENDAR' );
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN NULL;
        --        
    END f_k_nls_calendar;
    --
    -- dia de la semana
    FUNCTION f_day_of_week( p_date DATE ) RETURN NUMBER IS  
        --
        l_nls_data_config VARCHAR2(64);
        l_nls_language    VARCHAR2(16)  := pf_parameters_db( p_parameter => 'NLS_DATE_LANGUAGE' );
        l_ref             sys_refcursor;
        --
        l_id  NUMBER;
        l_day NVARCHAR2(20);
        --
    BEGIN 
        --
        l_nls_data_config := 'NLS_DATE_LANGUAGE=' ||l_nls_language;
        IF K_NLS_LANG_DEFAULT = l_nls_language THEN 
            l_ref := igtp.sys_k_utils.f_list_to_cursor(sys_k_utils.K_LIST_DW_AMERICAN);
        ELSIF K_NLS_LANG_INSTALL = l_nls_language  THEN 
            l_ref := igtp.sys_k_utils.f_list_to_cursor(sys_k_utils.K_LIST_DW_SPANISH);
        END IF;
        --
        IF l_ref%ISOPEN THEN 
            --
            LOOP  
                --
                FETCH l_ref INTO l_id, l_day;
                EXIT WHEN l_ref%NOTFOUND; 
                --
                IF l_day = trim(to_char(p_date, 'DAY', l_nls_data_config)) THEN 
                    EXIT;
                END IF;
                --    
            END LOOP;
            --
            CLOSE l_ref;
            --
        END IF;
        --
        RETURN l_id;
        --
    END f_day_of_week; 
    --
    -- lista de los dias de la semana
    FUNCTION f_list_day_of_week( p_date DATE ) RETURN sys_refcursor IS 
        --
        l_nls_language    VARCHAR2(16)  := pf_parameters_db( p_parameter => 'NLS_DATE_LANGUAGE' );
        l_ref             sys_refcursor;
        --
    BEGIN 
        --
        IF K_NLS_LANG_DEFAULT = l_nls_language THEN 
            l_ref := igtp.sys_k_utils.f_list_to_cursor(sys_k_utils.K_LIST_DW_AMERICAN);
        ELSIF K_NLS_LANG_INSTALL = l_nls_language  THEN 
            l_ref := igtp.sys_k_utils.f_list_to_cursor(sys_k_utils.K_LIST_DW_SPANISH);
        END IF;
        --
        RETURN l_ref;
        --
    END f_list_day_of_week;   
    --
    -- devuelve los segundos desde una fecha especifica
    FUNCTION f_get_seconds (p_fecha DATE) RETURN NUMBER IS
        --
        dFechaBase DATE := to_date('01011970','ddmmyyyy');
        nSegundo   NUMBER;
        --
    BEGIN
        --
        IF p_fecha > dFechaBase THEN
            nSegundo := trunc((p_fecha-dFechaBase)*24*60*60);
        ELSE
            nSegundo := NULL;
        END IF;  
        --
        RETURN nSegundo;
        --
    END f_get_seconds;
    --
    -- devuelve una tabla con las columnas de una determinada tabla
    FUNCTION get_map_data( p_owner      VARCHAR2,
                           p_table_name VARCHAR2
                         ) RETURN data_map_tab IS 
        --
        l_mdata         igtp.sys_k_utils.data_map_tab;
        --
        CURSOR c_data IS 
            SELECT a.column_name, a.data_type, a.data_length, b.comments, a.column_id 
              FROM all_tab_columns a
              INNER JOIN all_col_comments b ON a.owner       = b.owner
                                           AND a.table_name  = b.table_name
                                           AND a.column_name = b.column_name
             WHERE a.owner      = UPPER(p_owner) 
               AND a.table_name = UPPER(p_table_name)
             ORDER BY a.column_id;
        --  
    BEGIN 
        --
        l_mdata.DELETE;
        --
        FOR r_data IN c_data LOOP
            --
            l_mdata(trim(r_data.column_name)).column_name := r_data.column_name;
            l_mdata(trim(r_data.column_name)).data_type   := r_data.data_type;
            l_mdata(trim(r_data.column_name)).data_length := r_data.data_length;
            l_mdata(trim(r_data.column_name)).comments    := r_data.comments;
            l_mdata(trim(r_data.column_name)).column_id   := r_data.column_id;
            --  
        END LOOP;
        --
        RETURN l_mdata;
        -- 
    END get_map_data;  
    --
    -- devuelve el valor del campo enviado 
    FUNCTION get_map_data_value( p_field VARCHAR2,
                                 p_mdata igtp.sys_k_utils.data_map_tab 
                               ) RETURN SYS.ANYDATA IS    
        --
        l_data  SYS.ANYDATA;
        l_field VARCHAR2(30) := upper(trim(p_field));
        --
    BEGIN 
        --
        IF p_mdata.exists( l_field ) THEN 
            --
            l_data := p_mdata( l_field ).data_value;
            --    
        END IF;
        --
        RETURN l_data;
        --
    END get_map_data_value;    
    --
    -- devuelve el typo del campo enviado 
    FUNCTION get_map_data_type( p_field VARCHAR2,
                                p_mdata igtp.sys_k_utils.data_map_tab 
                              ) RETURN VARCHAR2 IS    
        --
        l_type  VARCHAR2(30);
        l_field VARCHAR2(30) := upper(trim(p_field));
        --
    BEGIN 
        --
        IF p_mdata.exists( l_field ) THEN 
            --
            l_type := p_mdata( l_field ).data_type;
            --    
        END IF;
        --
        RETURN l_type;
        --
    END get_map_data_type;   
    --
    -- verifica si una tabla existe
    FUNCTION f_table_exist( p_owner VARCHAR2, 
                            p_table VARCHAR2
                          ) RETURN BOOLEAN IS 
        --
        l_dummy CHAR(1);
        l_ok    BOOLEAN := FALSE;
        --
        CURSOR c_tables IS 
            SELECT 'X' 
              FROM all_tables 
             WHERE owner      = p_owner
               AND table_name = upper(p_table);
        --     
    BEGIN 
        --
        OPEN c_tables;
        FETCH c_tables INTO l_dummy;
        l_ok := c_tables%FOUND;
        CLOSE c_tables;
        --
        RETURN l_ok;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(SQLERRM);
                RETURN FALSE;
        --
    END f_table_exist;             
    --  
    -- devuelve un cursor de una determinada tabla 
    FUNCTION f_get_refcursor( p_owner VARCHAR2, 
                              p_table VARCHAR2,
                              p_where VARCHAR2,
                              p_order VARCHAR2
                            ) RETURN SYS_REFCURSOR IS 
        --
        l_ref_cursor SYS_REFCURSOR;
        l_stm        VARCHAR2(4048);
        --
    BEGIN 
        --
        -- TODO: VALIDAR QUE LA TABLA EXISTA
        IF f_table_exist( p_owner => p_owner, p_table => p_table ) THEN  
            --
            l_stm := 'SELECT * FROM '||p_owner||'.'||p_table;
            --
            IF p_where IS NOT NULL THEN  
                l_stm := l_stm ||' '||p_where;
            END IF;
            --
            IF p_order IS NOT NULL THEN  
                l_stm := l_stm ||' '||p_order;
            END IF;
            --      
            OPEN l_ref_cursor FOR l_stm; 
            --
        END IF;
        --
        RETURN l_ref_cursor;
        --
        EXCEPTION 
            --
            WHEN OTHERS THEN 
                RETURN NULL;
        --
    END f_get_refcursor;
    -- 
    -- manejo de log, agrega una linea al archivo de memoria
    PROCEDURE record_log( 
            p_context  IN VARCHAR2,
            p_line     IN VARCHAR2,
            p_raw      IN VARCHAR2,
            p_result   IN VARCHAR,
            p_clob     IN OUT CLOB
        ) IS 
        --
        l_str   VARCHAR2(8000);
        --
    BEGIN 
        --
        l_str := p_context||';'||p_line || ';' ||p_raw||';RESULT:'||p_result||chr(13);
        --
        dbms_lob.append( p_clob, l_str );
        --
        EXCEPTION 
            --
            WHEN OTHERS THEN 
                RAISE;
        --
    END record_log;
    -- 
    -- devuelve el conjunto de caracteres
    FUNCTION f_character_set RETURN NVARCHAR2 IS
    BEGIN
        -- 
        RETURN nls_charset_name( nls_charset_id( 'NCHAR_CS' ) );
        --
    END f_character_set;
    --
    -- devuelve el lenguaje territorial
    FUNCTION f_language_ter RETURN VARCHAR2 IS
    BEGIN 
        --
        RETURN substr( sys_context( 'userenv', 'LANGUAGE' ), 1, instr( sys_context( 'userenv', 'LANGUAGE' ), '.' ) );              
        --
    END f_language_ter;
    --
END sys_k_utils;

/

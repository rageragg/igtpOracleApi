--------------------------------------------------------
--  DDL for Package sys_k_utils
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE PACKAGE igtp.sys_k_utils AS
    --
    -- VERSION: 1.00.00
    /* -------------------- DESCRIPCION -------------------- 
    || - Permite :
    ||   Funciones y procesos de utileria general del sistema
    */ ----------------------------------------------------- 
    --
    -- ! CONSTANTES
    K_SDBP_DEFAULT     CONSTANT CHAR(1)         := 'D';
    K_SDBP_INSTALL     CONSTANT CHAR(1)         := 'I';
    K_NLS_LANG_DEFAULT CONSTANT VARCHAR2(16)    := 'AMERICAN';
    K_NLS_LANG_INSTALL CONSTANT VARCHAR2(16)    := 'SPANISH';
    K_FRAGMENT_UUID    CONSTANT VARCHAR2(20)    := '8,4,4,4,12'; -- fragmentacion del codigo uuid    
    K_LIST_DW_AMERICAN CONSTANT NVARCHAR2(64)   := 'SUNDAY,MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY';
    K_LIST_DW_SPANISH  CONSTANT NVARCHAR2(64)   := 'LUNES,MARTES,MI'||CHR(50057)||'RCOLES,JUEVES,VIERNES,S'||CHR(50049)||'BADO,DOMINGO';
    K_TZNAME           CONSTANT VARCHAR2(32)    := 'America/Caracas';
    --
    -- tipos  
    TYPE data_map_rec IS RECORD(
        column_id       NUMBER, 
        column_name     VARCHAR2(30),
        data_type       VARCHAR2(30),
        data_length     NUMBER,
        comments        VARCHAR2(4000),
        data_value      SYS.ANYDATA
    );
    --
    -- tabla de columnas de una determinada tabla
    TYPE data_map_tab IS TABLE OF data_map_rec INDEX BY VARCHAR2(30);
    --
    -- Funcion que devuelve un identificador unico
    FUNCTION f_uuid RETURN VARCHAR2;
    --
    -- ! LISTAS
    -- 
    -- funcion que devuelve un cursor a partir de una lista separada por ','
    -- salida del cursor es { id, data }
    FUNCTION f_list_to_cursor( 
        p_list      IN VARCHAR2, 
        p_separator IN VARCHAR2 DEFAULT ',' 
    ) RETURN sys_refcursor;
    --    
    --
    -- procedimiento que establece el los parametros de la instalacion
    PROCEDURE p_set_install_parameters; 
    --
    -- procedimiento que establece el los parametros de la base de datos
    PROCEDURE p_set_database_parameters; 
    -- 
    -- ! FECHAS
    -- function que devuelve el formato de fecha NLS_DATE_FORMAT
    FUNCTION f_k_nls_date_format RETURN VARCHAR2;
    --
    -- function que devuelve el formato de fecha NLS_TIME_FORMAT
    FUNCTION f_k_nls_time_format RETURN VARCHAR2;
    --
    -- function que devuelve modo de calendario NLS_CALENDAR
    FUNCTION f_k_nls_calendar RETURN VARCHAR2;
    --
    -- dia de la semana
    FUNCTION f_day_of_week( 
      p_date DATE 
    ) RETURN NUMBER;
    --
    -- lista de los dias de la semana
    FUNCTION f_list_day_of_week( p_date DATE ) RETURN sys_refcursor;
    --
    -- devuelve los segundos desde una fecha especifica
    FUNCTION f_get_seconds (
      p_fecha DATE
    ) RETURN NUMBER;
    --
    -- devuelve una tabla con las columnas de una determinada tabla
    FUNCTION get_map_data( 
      p_owner      VARCHAR2,
      p_table_name VARCHAR2
    ) RETURN data_map_tab;
    --
    -- devuelve una tabla con las columnas de una determinada tabla json
    FUNCTION get_map_data_json( 
      p_owner      VARCHAR2,
      p_table_name VARCHAR2
    ) RETURN CLOB;
    --
    -- devuelve el valor del campo enviado 
    FUNCTION get_map_data_value( 
      p_field VARCHAR2,
      p_mdata igtp.sys_k_utils.data_map_tab 
    ) RETURN SYS.ANYDATA;
    --
    -- devuelve el tipo del campo enviado 
    FUNCTION get_map_data_type( 
      p_field VARCHAR2,
      p_mdata igtp.sys_k_utils.data_map_tab 
    ) RETURN VARCHAR2;
    --
    -- TODO: NLS_NUMERIC_CHARACTERS
    -- 
    -- verifica si una tabla existe
    FUNCTION f_table_exist( 
      p_owner VARCHAR2, 
      p_table VARCHAR2
    ) RETURN BOOLEAN;
    --
    -- devuelve un cursor de una determinada tabla 
    FUNCTION f_get_refcursor( 
      p_owner VARCHAR2, 
      p_table VARCHAR2,
      p_where VARCHAR2,
      p_order VARCHAR2
    ) RETURN SYS_REFCURSOR;
    --
    -- manejo de log
    PROCEDURE record_log( 
        p_context  IN VARCHAR2,
        p_line     IN VARCHAR2,
        p_raw      IN VARCHAR2,
        p_result   IN VARCHAR,
        p_clob     IN OUT CLOB
    );
    --
    -- devuelve el conjunto de caracteres
    FUNCTION f_character_set RETURN NVARCHAR2;
    --
    -- devuelve el lenguaje territorial
    FUNCTION f_language_ter RETURN VARCHAR2;
    --
END sys_k_utils;

/

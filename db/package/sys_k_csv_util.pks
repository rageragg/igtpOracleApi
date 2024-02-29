CREATE OR REPLACE PACKAGE sys_k_csv_util IS
  
    g_default_separator            constant varchar2(1) := ';';
    --
    -- convert CSV line to array of values
    FUNCTION csv_to_array (
        p_csv_line  IN VARCHAR2,
        p_separator IN VARCHAR2 := g_default_separator
    ) RETURN t_str_array;
    --
    -- convert array of values to CSV
    FUNCTION array_to_csv (
        p_values    IN t_str_array,
        p_separator IN VARCHAR2 := g_default_separator
    ) RETURN varchar2;
    --
    -- get value from array by position
    FUNCTION get_array_value (
        p_values        IN t_str_array,
        p_position      IN NUMBER,
        p_column_name   IN VARCHAR2 := null
    ) RETURN VARCHAR2;
    --
    -- convert clob to CSV
    FUNCTION clob_to_csv (
        p_csv_clob  IN CLOB,
        p_separator IN VARCHAR2 := g_default_separator,
        p_skip_rows IN NUMBER   := 0
    ) RETURN t_csv_tab pipelined;
    --
END sys_k_csv_util;

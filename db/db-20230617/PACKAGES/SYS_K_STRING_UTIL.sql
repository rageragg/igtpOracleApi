--------------------------------------------------------
--  DDL for Package SYS_K_STRING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."SYS_K_STRING_UTIL" AS
    /*
        Purpose:    The package handles general string-related functionality
        Remarks:  
        Who     Date        Description
        ------  ----------  -------------------------------------
        MBR     21.09.2006  Created   
    */
    --
    g_max_pl_varchar2_def          VARCHAR2(32767);
    g_max_db_varchar2_def          VARCHAR2(4000);
    --
    SUBTYPE t_max_pl_varchar2      IS g_max_pl_varchar2_def%type;
    SUBTYPE t_max_db_varchar2      IS g_max_db_varchar2_def%type;
    --
    g_default_separator            CONSTANT VARCHAR2(1) := ';';
    g_param_and_value_separator    CONSTANT VARCHAR2(1) := '=';
    g_param_and_value_param        CONSTANT VARCHAR2(1) := 'P';
    g_param_and_value_value        CONSTANT VARCHAR2(1) := 'V';
    --
    g_yes                          CONSTANT VARCHAR2(1) := 'Y';
    g_no                           CONSTANT VARCHAR2(1) := 'N';
    --
    g_line_feed                    CONSTANT VARCHAR2(1) := chr(10);
    g_new_line                     CONSTANT VARCHAR2(1) := chr(13);
    g_carriage_return              CONSTANT VARCHAR2(1) := chr(13);
    g_crlf                         CONSTANT VARCHAR2(2) := g_carriage_return || g_line_feed;
    g_tab                          CONSTANT VARCHAR2(1) := chr(9);
    g_ampersand                    CONSTANT VARCHAR2(1) := chr(38); 
    --
    g_html_entity_carriage_return  CONSTANT VARCHAR2(5) := chr(38) || '#13;';
    g_html_nbsp                    CONSTANT VARCHAR2(6) := chr(38) || 'nbsp;'; 
    --
    -- RETURN string merged with substitution values
    FUNCTION get_str (  p_msg    IN VARCHAR2,
                        p_value1 IN VARCHAR2 := NULL,
                        p_value2 IN VARCHAR2 := NULL,
                        p_value3 IN VARCHAR2 := NULL,
                        p_value4 IN VARCHAR2 := NULL,
                        p_value5 IN VARCHAR2 := NULL,
                        p_value6 IN VARCHAR2 := NULL,
                        p_value7 IN VARCHAR2 := NULL,
                        p_value8 IN VARCHAR2 := NULL
                     ) RETURN VARCHAR2;
    --
    -- add token to string
    PROCEDURE add_token ( p_text      IN OUT VARCHAR2,
                          p_token     IN VARCHAR2,
                          p_separator IN VARCHAR2 := g_default_separator
                        );
    --
    -- get the sub-string at the Nth position 
    FUNCTION get_nth_token( p_text      IN VARCHAR2,
                            p_num       IN NUMBER,
                            p_separator IN VARCHAR2 := g_default_separator
                          ) RETURN VARCHAR2;
    --
    -- get the NUMBER of sub-strings
    FUNCTION get_token_count(p_text      IN VARCHAR2,
                             p_separator IN VARCHAR2 := g_default_separator
                            ) RETURN NUMBER;
    --
    -- convert string to NUMBER
    FUNCTION str_to_num (p_str                        IN VARCHAR2,
                         p_decimal_separator          IN VARCHAR2 := NULL,
                         p_thousand_separator         IN VARCHAR2 := NULL,
                         p_raise_error_if_parse_error IN boolean := FALSE,
                         p_value_name                 IN VARCHAR2 := NULL
                        ) RETURN NUMBER;
    --            
    -- copy part of string
    FUNCTION copy_str (p_string   IN VARCHAR2,
                       p_from_pos IN NUMBER := 1,
                       p_to_pos   IN NUMBER := NULL
                      ) RETURN VARCHAR2;
    --             
    -- remove part of string
    FUNCTION del_str (p_string   IN VARCHAR2,
                      p_from_pos IN NUMBER := 1,
                      p_to_pos   IN NUMBER := NULL
                     ) RETURN VARCHAR2;
    --
    -- get value from parameter list with multiple named parameters
    FUNCTION get_param_value_from_list (p_param_name      IN VARCHAR2,
                                        p_param_string    IN VARCHAR2,
                                        p_param_separator IN VARCHAR2 := g_default_separator,
                                        p_value_separator IN VARCHAR2 := g_param_and_value_separator
                                       ) RETURN VARCHAR2;
    --
    -- remove all whitespace from string
    FUNCTION remove_whitespace (p_str                    IN VARCHAR2,
                                p_preserve_single_blanks IN boolean := FALSE,
                                p_remove_line_feed       IN boolean := FALSE,
                                p_remove_tab             IN boolean := FALSE
                              ) RETURN VARCHAR2;
    --                          
    -- remove all non-numeric characters from string
    FUNCTION remove_non_numeric_chars (p_str IN VARCHAR2) RETURN VARCHAR2;
    --
    -- remove all non-alpha characters (A-Z) from string
    FUNCTION remove_non_alpha_chars (p_str IN VARCHAR2) RETURN VARCHAR2;
    --
    -- returns true if string only contains alpha characters
    FUNCTION is_str_alpha (p_str IN VARCHAR2) RETURN boolean;  
    --
    -- returns true if string IS alphanumeric
    FUNCTION is_str_alphanumeric (p_str IN VARCHAR2) RETURN boolean;
    --
    -- returns true if string IS "empty" (contains only whitespace characters)
    FUNCTION is_str_empty (p_str IN VARCHAR2) RETURN boolean;
    --
    -- returns true if string IS a valid NUMBER
    FUNCTION is_str_number (p_str IN VARCHAR2,
                            p_decimal_separator IN VARCHAR2 := NULL,
                            p_thousand_separator IN VARCHAR2 := NULL
                           ) RETURN boolean;
    --
    -- returns true if string IS an integer
    FUNCTION is_str_integer (p_str IN VARCHAR2) RETURN boolean;
    --
    -- returns substring and indicates if string has been truncated
    FUNCTION short_str (p_str IN VARCHAR2,
                        p_length IN NUMBER,
                        p_truncation_indicator IN VARCHAR2 := '...') RETURN VARCHAR2;
    --
    -- RETURN either name or value from name/value pair
    FUNCTION get_param_or_value (p_param_value_pair IN VARCHAR2,
                                 p_param_or_value IN VARCHAR2 := g_param_and_value_value,
                                 p_delimiter IN VARCHAR2 := g_param_and_value_separator
                                ) RETURN VARCHAR2;
    --
    -- add item to delimited list
    FUNCTION add_item_to_list (p_item IN VARCHAR2,
                               p_list IN VARCHAR2,
                               p_separator IN VARCHAR2 := g_default_separator
                              ) RETURN VARCHAR2;
    --           
    -- convert string to boolean
    FUNCTION str_to_bool (p_str IN VARCHAR2) RETURN boolean;
    --
    -- convert string to boolean string
    FUNCTION str_to_bool_str (p_str IN VARCHAR2) RETURN VARCHAR2;
    --
    -- get pretty string
    FUNCTION get_pretty_str (p_str IN VARCHAR2) RETURN VARCHAR2;
    --
    -- parse string to date, accept various formats
    FUNCTION parse_date (p_str IN VARCHAR2) RETURN date;
    --
    -- split delimited string to rows
    FUNCTION split_str (p_str IN VARCHAR2,
                        p_delim IN VARCHAR2 := g_default_separator
                       ) RETURN t_str_array pipelined;
    --
    -- create delimited string from cursor
    FUNCTION join_str (p_cursor IN sys_refcursor,
                       p_delim IN VARCHAR2 := g_default_separator
                      ) RETURN VARCHAR2;
    --
    -- replace several strings
    FUNCTION multi_replace (p_string IN VARCHAR2,
                            p_search_for IN t_str_array,
                            p_replace_with IN t_str_array
                           ) RETURN VARCHAR2;
    --
    -- replace several strings (clob version)
    FUNCTION multi_replace (p_clob         IN clob,
                            p_search_for   IN t_str_array,
                            p_replace_with IN t_str_array
                           ) RETURN clob;
    --
    -- RETURN true if item IS IN list
    FUNCTION is_item_in_list (p_item IN VARCHAR2,
                              p_list IN VARCHAR2,
                              p_separator IN VARCHAR2 := g_default_separator
                             ) RETURN boolean;
    --
    -- randomize array
    FUNCTION randomize_array (p_array IN t_str_array) RETURN t_str_array;
    --
    -- RETURN true if two values are different
    FUNCTION value_has_changed (p_old IN VARCHAR2,
                                p_new IN VARCHAR2
                               ) RETURN boolean;
    --
    -- concatenate non-NULL strings with specified separator
    FUNCTION concat_array (p_array IN t_str_array,
                           p_separator IN VARCHAR2 := g_default_separator
                          ) RETURN VARCHAR2;
    --                           
END sys_k_string_util;

/

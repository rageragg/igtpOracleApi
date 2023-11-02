--------------------------------------------------------
--  DDL FOR Package sys_k_string_util
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY sys_k_string_util
AS 
    /*
      Purpose:    The package handles general string-related functionality
      Remarks:  
      Who     Date        Description
      ------  ----------  -------------------------------------
      MBR     21.09.2006  Created
    */
    --
    m_nls_decimal_separator        VARCHAR2(1);
    --
    FUNCTION get_nls_decimal_separator RETURN VARCHAR2 AS 
        --
        l_returnvalue VARCHAR2(1);
        --
    BEGIN
        /*
            Purpose:    Get decimal separator FOR session
            Remarks:    The value is cached to avoid looking it up dynamically 
                        each time this FUNCTION is called
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     11.05.2007  Created      
        */
        --
        IF m_nls_decimal_separator IS NULL THEN
            --
            BEGIN
                --
                SELECT substr(value,1,1)
                  INTO l_returnvalue
                  FROM nls_session_parameters
                 WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
                 --
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_returnvalue:='.';
            END;
            --
            m_nls_decimal_separator := l_returnvalue;
            --
        END IF;
        --  
        l_returnvalue := m_nls_decimal_separator;
        --
        RETURN l_returnvalue;
        --
    END get_nls_decimal_separator;
    --
    FUNCTION get_str (p_msg IN VARCHAR2,
                      p_value1 IN VARCHAR2 := NULL,
                      p_value2 IN VARCHAR2 := NULL,
                      p_value3 IN VARCHAR2 := NULL,
                      p_value4 IN VARCHAR2 := NULL,
                      p_value5 IN VARCHAR2 := NULL,
                      p_value6 IN VARCHAR2 := NULL,
                      p_value7 IN VARCHAR2 := NULL,
                      p_value8 IN VARCHAR2 := NULL
                     ) RETURN VARCHAR2 AS 
        --
        l_returnvalue t_max_pl_varchar2;
        --
    BEGIN
        /*
            Purpose:    RETURN string merged with substitution values
            Remarks:  
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     21.09.2006  Created
            MBR     15.02.2009  Altered the debug text to display (blank) instead of %1 
                                when p_value1 is NULL (SA #58851)
        */
        --
        l_returnvalue:=p_msg;
        --
        l_returnvalue:=replace(l_returnvalue, '%1', nvl(p_value1, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%2', nvl(p_value2, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%3', nvl(p_value3, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%4', nvl(p_value4, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%5', nvl(p_value5, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%6', nvl(p_value6, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%7', nvl(p_value7, '(blank)'));
        l_returnvalue:=replace(l_returnvalue, '%8', nvl(p_value8, '(blank)'));
        --
        RETURN l_returnvalue;
        --
    END get_str;
    --
    PROCEDURE add_token(
            p_text IN out VARCHAR2,
            p_token IN VARCHAR2,
            p_separator IN VARCHAR2 := g_default_separator
        ) AS 
    BEGIN
        /*
            Purpose:    add token to string
            Remarks:  
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     30.10.2015  Created      
        */
        --
        IF p_text IS NULL THEN
            p_text := p_token;
        ELSE
            p_text := p_text || p_separator || p_token;
        END IF;
        --
    END add_token;
    --
    FUNCTION get_nth_token(
            p_text IN VARCHAR2,
            p_num IN NUMBER,
            p_separator IN VARCHAR2 := g_default_separator
        ) RETURN VARCHAR2 AS 
        --
        l_pos_begin    PLS_INTEGER;
        l_pos_end      PLS_INTEGER;
        l_returnvalue  t_max_pl_varchar2;
        --
    BEGIN
        /*
            Purpose:    get the sub-string at the Nth position 
            Remarks:  
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     27.11.2006  Created, based on Pandion code        
        */
        --
        -- get start- and end-positions
        IF p_num <= 0 THEN
            RETURN NULL;
        ELSIF p_num = 1 THEN
            l_pos_begin:=1;
        ELSE
            l_pos_begin:=instr(p_text, p_separator, 1, p_num - 1);
        END IF;
        -- separator may be the first character
        l_pos_end:=instr(p_text, p_separator, 1, p_num);
        --
        IF l_pos_end > 1 THEN
            l_pos_end:=l_pos_end - 1;
        END IF;
        --
        IF l_pos_begin > 0 THEN
            -- find the last element even though it may not be terminated by separator
            IF l_pos_end <= 0 THEN
                l_pos_end:=length(p_text);
            END IF;
            --
            -- do not include separator character IN output
            IF p_num = 1 THEN
                l_returnvalue:=substr(p_text, l_pos_begin, l_pos_end - l_pos_begin + 1);
            ELSE
                l_returnvalue:=substr(p_text, l_pos_begin + 1, l_pos_end - l_pos_begin);
            END IF;
            --
        ELSE
            l_returnvalue:=NULL;
        END IF;
        --
        RETURN l_returnvalue;
        --
        EXCEPTION
            WHEN OTHERS THEN
                RETURN NULL;
        --
    END get_nth_token;
    --
    FUNCTION get_token_count(p_text IN VARCHAR2,
                             p_separator IN VARCHAR2 := g_default_separator
                            ) RETURN NUMBER
    AS 
        --
        l_pos          PLS_INTEGER;
        l_counter      PLS_INTEGER := 0;
        l_returnvalue  NUMBER;
        --
    BEGIN
        /*
            Purpose:    get the NUMBER of sub-strings
            Remarks:  
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     27.11.2006  Created, based on Pandion code
        */
        --
        IF p_text IS NULL THEN
            l_returnvalue:=0;
        ELSE
            --
            LOOP
                --
                l_pos:=instr(p_text, p_separator, 1, l_counter + 1);
                --
                IF l_pos > 0 THEN
                    l_counter:=l_counter + 1;
                ELSE
                    EXIT;
                END IF;
                --
            END LOOP;

            l_returnvalue:=l_counter + 1;

        END IF;
        --
        RETURN l_returnvalue;
        --
    END get_token_count;
    --
    FUNCTION str_to_num (
            p_str IN VARCHAR2,
            p_decimal_separator IN VARCHAR2 := NULL,
            p_thousand_separator IN VARCHAR2 := NULL,
            p_raise_error_if_parse_error IN BOOLEAN := false,
            p_value_name IN VARCHAR2 := NULL
        ) RETURN NUMBER AS 
        --
        l_returnvalue           NUMBER;
        --
    BEGIN
        /*
            Purpose:    convert string to NUMBER
            Remarks:  
            Who     Date        Description
            ------  ----------  -------------------------------------
            FDL     03.05.2007  Created       
        */
        BEGIN
            IF (p_decimal_separator is NULL) and (p_thousand_separator is NULL) THEN
                l_returnvalue := to_number(p_str);
            ELSE
                l_returnvalue := to_number(replace(replace(p_str,p_thousand_separator,''), p_decimal_separator, get_nls_decimal_separator));
            END IF;
        EXCEPTION
            WHEN value_error THEN
                IF p_raise_error_if_parse_error THEN
                    raise_application_error (
                        -20000, 
                        sys_k_string_util.get_str('Failed to parse the string "%1" to a valid NUMBER. Using decimal separator = "%2" and thousand separator = "%3". Field name = "%4". ' || sqlerrm, p_str, p_decimal_separator, p_thousand_separator, p_value_name));
                ELSE
                    l_returnvalue := NULL;
                END IF;
        END;
        --
        RETURN l_returnvalue;
        --
    END str_to_num;
    --
    FUNCTION copy_str (
            p_string IN VARCHAR2,
            p_from_pos IN NUMBER := 1,
            p_to_pos IN NUMBER := NULL
        ) RETURN VARCHAR2 AS 
        --
        l_to_pos       PLS_INTEGER;
        l_returnvalue  t_max_pl_varchar2;
        --
    BEGIN
        /*
            Purpose:    copy part of string
            Remarks:  
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     08.05.2007  Created           
        */
        IF (p_string is NULL) or (p_from_pos <= 0) THEN
            l_returnvalue:=NULL;
        ELSE

            IF p_to_pos IS NULL THEN
                l_to_pos:=length(p_string);
            ELSE
                l_to_pos:=p_to_pos;
            END IF;

            IF l_to_pos > length(p_string) THEN
                l_to_pos:=length(p_string);
            END IF;

            l_returnvalue:=substr(p_string, p_from_pos, l_to_pos - p_from_pos + 1);

        END IF;

        RETURN l_returnvalue;

    END copy_str;
    --
    FUNCTION del_str (p_string IN VARCHAR2,
                    p_from_pos IN NUMBER := 1,
                    p_to_pos IN NUMBER := NULL) RETURN VARCHAR2
    AS 
    l_to_pos       PLS_INTEGER;
    l_returnvalue  t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    remove part of string

    Remarks:  

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     08.05.2007  Created
    
    */

    IF (p_string is NULL) or (p_from_pos <= 0) THEN
        l_returnvalue:=NULL;
    ELSE

        IF p_to_pos IS NULL THEN
        l_to_pos:=length(p_string);
        ELSE
        l_to_pos:=p_to_pos;
    END IF;

        IF l_to_pos > length(p_string) THEN
        l_to_pos:=length(p_string);
    END IF;

        l_returnvalue:=substr(p_string, 1, p_from_pos - 1) || substr(p_string, l_to_pos + 1, length(p_string) - l_to_pos);

    END IF;

    RETURN l_returnvalue;

    END del_str;
    --
    FUNCTION get_param_value_from_list (p_param_name IN VARCHAR2,
                                        p_param_string IN VARCHAR2,
                                        p_param_separator IN VARCHAR2 := g_default_separator,
                                        p_value_separator IN VARCHAR2 := g_param_and_value_separator) RETURN VARCHAR2
    AS 
    l_returnvalue  t_max_pl_varchar2;
    l_temp_str     t_max_pl_varchar2;
    l_begin_pos    PLS_INTEGER;
    l_end_pos      PLS_INTEGER;
    BEGIN


    /*

    Purpose:    get value FROM parameter list with multiple named parameters

    Remarks:    given a string of type param1=value1;param2=value2;param3=value3,
                extract the value part of the given param (specified by name)

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     16.05.2007  Created
    MBR     24.09.2015  IF parameter name not specified (NULL), THEN RETURN NULL
    
    */

    IF p_param_name is not NULL THEN

        -- get the starting position of the param name
        l_begin_pos:=instr(p_param_string, p_param_name || p_value_separator);

        IF l_begin_pos = 0 THEN
        l_returnvalue:=NULL;
        ELSE

        -- trim off characters before param value begins, including param name
        l_temp_str:=substr(p_param_string, l_begin_pos, length(p_param_string) - l_begin_pos + 1);
        l_temp_str:=del_str(l_temp_str, 1, length(p_param_name || p_value_separator));

        -- now find the first next occurence of the character delimiting the params
        -- IF delimiter not found, RETURN the rest of the string

        l_end_pos:=instr(l_temp_str, p_param_separator);
        IF l_end_pos = 0 THEN
            l_end_pos:=length(l_temp_str);
        ELSE
            -- strip off delimiter
            l_end_pos:=l_end_pos - 1;
        END IF;

        -- retrieve the value
        l_returnvalue:=copy_str(l_temp_str, 1, l_end_pos);

    END IF;

    END IF;

    RETURN l_returnvalue;

    END get_param_value_from_list;                                   
    --
    FUNCTION remove_whitespace (p_str IN VARCHAR2,
                                p_preserve_single_blanks IN BOOLEAN := false,
                                p_remove_line_feed IN BOOLEAN := false,
                                p_remove_tab IN BOOLEAN := false) RETURN VARCHAR2
    AS 
    l_temp_char                    constant VARCHAR2(1) := chr(0);
    l_returnvalue                  t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    remove all whitespace FROM string

    Remarks:    FOR preserving single blanks, see http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:13912710295209
    
                "I found this solution (...) to be really "elegant" (not to mention terse, fast, and 99.9999% complete -- 
                normally, chr(0) will fill the billAS a "safe character"."

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     08.06.2007  Created
    MBR     13.01.2011  Added option to remove tab characters
    
    */

    IF p_preserve_single_blanks THEN
        l_returnvalue := trim(replace(replace(replace(p_str,' ',' ' || l_temp_char), l_temp_char || ' ',''),' ' || l_temp_char,' '));
    ELSE
        l_returnvalue := replace(p_str, ' ', '');
    END IF;
    
    IF p_remove_line_feed THEN
        l_returnvalue := replace (l_returnvalue, g_line_feed, '');
        l_returnvalue := replace (l_returnvalue, g_carriage_return, '');
    END IF;
    
    IF p_remove_tab THEN
        l_returnvalue := replace (l_returnvalue, g_tab, '');
    END IF;

    RETURN l_returnvalue;

    END remove_whitespace;
    --
    FUNCTION remove_non_numeric_chars (p_str IN VARCHAR2) RETURN VARCHAR2
    AS 
    l_returnvalue                  t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    remove all non-numeric characters FROM string

    Remarks:    leaving thousand and decimal separator values (perhaps the actual values used could have been passedAS parameters)

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     14.06.2007  Created
    
    */
    
    l_returnvalue := regexp_replace(p_str, '[^0-9,.]' , '');
    
    RETURN l_returnvalue;

    END remove_non_numeric_chars;
    --
    FUNCTION remove_non_alpha_chars (p_str IN VARCHAR2) RETURN VARCHAR2
    AS 
    l_returnvalue                  t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    remove all non-alpha characters (A-Z) FROM string

    Remarks:    does not support non-English characters (but the regular expression could be modified to support it)

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     04.07.2007  Created
    
    */
    
    l_returnvalue := regexp_replace(p_str, '[^A-Za-z]' , '');
    
    RETURN l_returnvalue;

    END remove_non_alpha_chars;
    --
    FUNCTION is_str_alpha (p_str IN VARCHAR2) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN;
    BEGIN

    /*
    
    Purpose:    returns true IF string only contains alpha characters
    
    Who     Date        Description
    ------  ----------  -------------------------------------
    MJH     12.05.2015  Created
    
    */

    l_returnvalue := regexp_instr(p_str, '[^a-z|A-Z]') = 0;

    RETURN l_returnvalue;

    END is_str_alpha;
    --    
    FUNCTION is_str_alphanumeric (p_str IN VARCHAR2) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN;
    BEGIN

    /*

    Purpose:    returns true IF string is alphanumeric

    Who     Date        Description
    ------  ----------  -------------------------------------
    MJH     12.05.2015  Created

    */

    l_returnvalue := regexp_instr(p_str, '[^a-z|A-Z|0-9]') = 0;

    RETURN l_returnvalue;

    END is_str_alphanumeric;
    --
    FUNCTION is_str_empty (p_str IN VARCHAR2) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN;
    BEGIN

    /*

    Purpose:    returns true IF string is "empty" (contains only whitespace characters)

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     14.06.2007  Created
    
    */

    IF p_str IS NULL THEN
        l_returnvalue := true;
    ELSIF remove_whitespace (p_str, false, true) = '' THEN
        l_returnvalue := true;
    ELSE
        l_returnvalue := false;
    END IF;
    
    RETURN l_returnvalue;

    END is_str_empty;
    --
    FUNCTION is_str_number (p_str IN VARCHAR2,
                            p_decimal_separator IN VARCHAR2 := NULL,
                            p_thousand_separator IN VARCHAR2 := NULL) RETURN BOOLEAN 
    AS 
    l_number                NUMBER;
    l_returnvalue           BOOLEAN;
    BEGIN

    /*

    Purpose:    returns true IF string is a valid NUMBER

    Remarks:  

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     04.07.2007  Created
    
    */
    
    BEGIN
    
        IF (p_decimal_separator is NULL) and (p_thousand_separator is NULL) THEN
        l_number := to_number(p_str);
        ELSE
        l_number := to_number(replace(replace(p_str,p_thousand_separator,''), p_decimal_separator, get_nls_decimal_separator));
    END IF;
        
        l_returnvalue := true;
        
    EXCEPTION
        WHEN OTHERS THEN
        l_returnvalue := false;
    END;
    
    RETURN l_returnvalue;

    END is_str_number;
    --
    FUNCTION is_str_integer (p_str IN VARCHAR2) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN;
    BEGIN

    /*

    Purpose:    returns true IF string is an integer

    Who     Date        Description
    ------  ----------  -------------------------------------
    MJH     12.05.2015  Created
    
    */

    l_returnvalue := regexp_instr(p_str, '[^0-9]') = 0;

    RETURN l_returnvalue;

    END is_str_integer;
    --
    FUNCTION short_str (p_str IN VARCHAR2,
                        p_length IN NUMBER,
                        p_truncation_indicator IN VARCHAR2 := '...') RETURN VARCHAR2
    AS 
    l_returnvalue t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    returns substring and indicates IF string has been truncated

    Remarks:  

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     04.07.2007  Created
    
    */

    IF length(p_str) > p_length THEN
        l_returnvalue := substr(p_str, 1, p_length - length(p_truncation_indicator)) || p_truncation_indicator;
    ELSE
        l_returnvalue := p_str;
    END IF;
    
    RETURN l_returnvalue;
    
    END short_str;
    --
    FUNCTION get_param_or_value (p_param_value_pair IN VARCHAR2,
                                p_param_or_value IN VARCHAR2 := g_param_and_value_value,
                                p_delimiter IN VARCHAR2 := g_param_and_value_separator) RETURN VARCHAR2
    AS 
    l_delim_pos   PLS_INTEGER;
    l_returnvalue t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    RETURN either name or value FROM name/value pair

    Remarks:  

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     18.08.2009  Created
    
    */

    l_delim_pos := instr(p_param_value_pair, p_delimiter);

    IF l_delim_pos != 0 THEN

        IF upper(p_param_or_value) = g_param_and_value_value THEN
        l_returnvalue:=substr(p_param_value_pair, l_delim_pos + 1, length(p_param_value_pair) - l_delim_pos);
        ELSIF upper(p_param_or_value) = g_param_and_value_param THEN
        l_returnvalue:=substr(p_param_value_pair, 1, l_delim_pos - 1);
    END IF;

    END IF;

    RETURN l_returnvalue;

    END get_param_or_value;
    --
    FUNCTION add_item_to_list (p_item IN VARCHAR2,
                            p_list IN VARCHAR2,
                            p_separator IN VARCHAR2 := g_default_separator) RETURN VARCHAR2
    AS 
    l_returnvalue t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    add item to list

    Remarks:  

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     15.12.2008  Created
    
    */
    
    IF p_list IS NULL THEN
        l_returnvalue := p_item;
    ELSE
        l_returnvalue := p_list || p_separator || p_item; 
    END IF; 
    
    RETURN l_returnvalue;

    END add_item_to_list;     
    --
    FUNCTION str_to_bool (p_str IN VARCHAR2) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN := false;
    BEGIN

    /*

    Purpose:    convert string to BOOLEAN

    Remarks:  

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     06.01.2009  Created
    
    */
    
    IF lower(p_str) IN ('y', 'yes', 'true', '1') THEN
        l_returnvalue := true;
    END IF;
    
    RETURN l_returnvalue;

    END str_to_bool;
    --
    FUNCTION str_to_bool_str (p_str IN VARCHAR2) RETURN VARCHAR2
    AS 
    l_returnvalue VARCHAR2(1) := g_no;
    BEGIN

    /*

    Purpose:    convert string to (application-defined) BOOLEAN string

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     06.01.2009  Created
    MJH     12.05.2015  Leverage sys_k_string_util.str_to_bool IN order to reduce code redundancy
    
    */
    
    IF str_to_bool(p_str) THEN
        l_returnvalue := g_yes;
    END IF;
    
    RETURN l_returnvalue;

    END str_to_bool_str;
    --
    FUNCTION get_pretty_str (p_str IN VARCHAR2) RETURN VARCHAR2
    AS 
    l_returnvalue t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    returns "pretty" string

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     16.11.2009  Created
    
    */
    
    l_returnvalue := replace(initcap(trim(p_str)), '_', ' ');
    
    RETURN l_returnvalue;

    END get_pretty_str;
    --
    FUNCTION parse_date (p_str IN VARCHAR2) RETURN date
    AS 
    l_returnvalue date;
    
    FUNCTION try_parse_date (p_str IN VARCHAR2,
                            p_date_format IN VARCHAR2) RETURN date
    AS 
        l_returnvalue date;
    BEGIN
    
        BEGIN
        l_returnvalue := to_date(p_str, p_date_format);
        EXCEPTION
        WHEN OTHERS THEN
            l_returnvalue:=NULL;
        END;

        RETURN l_returnvalue;
    
    END try_parse_date;
    
    BEGIN

    /*

    Purpose:    parse string to date, accept various formats

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     16.11.2009  Created
    
    */

    -- note: Oracle handles separator characters (comma, dash, slash) interchangeably,
    --       so we don't need to duplicate the various format masks with different separators (slash, hyphen)  

    l_returnvalue := try_parse_date (p_str, 'DD.MM.RRRR HH24:MI:SS');
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'DD.MM HH24:MI:SS'));
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'DDMMYYYY HH24:MI:SS'));
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'DDMMRRRR HH24:MI:SS'));
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'YYYY.MM.DD HH24:MI:SS'));
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'MM.YYYY'));
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'DD.MON.RRRR HH24:MI:SS'));
    l_returnvalue := coalesce(l_returnvalue, try_parse_date (p_str, 'YYYY-MM-DD"T"HH24:MI:SS".000Z"')); -- standard XML date format
    
    RETURN l_returnvalue;

    END parse_date;
    --
    FUNCTION split_str (p_str IN VARCHAR2,
                        p_delim IN VARCHAR2 := g_default_separator) RETURN t_str_array pipelined
    AS 
    l_str   long := p_str || p_delim;
    l_n     NUMBER;
    BEGIN

    /*

    Purpose:    split delimited string to rows

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     23.11.2009  Created
    
    */

    LOOP
        l_n := instr(l_str, p_delim);
        EXIT when (nvl(l_n,0) = 0);
        pipe row (ltrim(rtrim(substr(l_str,1,l_n-1))));
        l_str := substr(l_str, l_n +1);
    END LOOP;

    return;

    END split_str;
    --
    FUNCTION join_str (p_cursor IN sys_refcursor,
                    p_delim IN VARCHAR2 := g_default_separator) RETURN VARCHAR2
    AS 
    l_value        t_max_pl_varchar2;
    l_returnvalue  t_max_pl_varchar2;
    BEGIN

    /*

    Purpose:    create delimited string FROM cursor

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     23.11.2009  Created
    
    */

    LOOP

        fetch p_cursor
        INTO l_value;
        EXIT when p_cursor%notfound;
        
        IF l_returnvalue is not NULL THEN
        l_returnvalue := l_returnvalue || p_delim;
    END IF;
        
        l_returnvalue := l_returnvalue || l_value;
        
    END LOOP;

    RETURN l_returnvalue;
        
    END join_str;
    --
    FUNCTION multi_replace (p_string IN VARCHAR2,
                            p_search_for IN t_str_array,
                            p_replace_with IN t_str_array) RETURN VARCHAR2
    AS 
    l_returnvalue t_max_pl_varchar2; 
    BEGIN

    /*

    Purpose:    replace several strings

    Remarks:    see http://oraclequirks.blogspot.com/2010/01/how-fast-can-we-replace-multiple.html
                this implementation uses t_str_array type instead of index-by table, so it can be used FROM both SQL and PL/SQL

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     21.01.2011  Created
    
    */
    
    l_returnvalue := p_string;

    IF p_search_for.count > 0 THEN
        FOR i IN 1 .. p_search_for.count LOOP
        l_returnvalue := replace (l_returnvalue, p_search_for(i), p_replace_with(i));
        END LOOP;
    END IF;

    RETURN l_returnvalue;

    END multi_replace;
    --
    FUNCTION multi_replace (p_clob IN clob,
                            p_search_for IN t_str_array,
                            p_replace_with IN t_str_array) RETURN clob
    AS 
    l_returnvalue clob; 
    BEGIN

    /*

    Purpose:    replace several strings (clob version)

    Remarks:    

    Who     Date        Description
    ------  ----------  -------------------------------------
    MBR     25.01.2011  Created
    
    */
    
    l_returnvalue := p_clob;

    IF p_search_for.count > 0 THEN
        FOR i IN 1 .. p_search_for.count LOOP
        l_returnvalue := replace (l_returnvalue, p_search_for(i), p_replace_with(i));
        END LOOP;
    END IF;

    RETURN l_returnvalue;

    END multi_replace;
    --
    FUNCTION is_item_in_list (p_item IN VARCHAR2,
                            p_list IN VARCHAR2,
                            p_separator IN VARCHAR2 := g_default_separator) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN;
    BEGIN
        /*
            Purpose:    RETURN true IF item is contained IN list
            Remarks:    
            Who     Date        Description
            ------  ----------  -------------------------------------
            MBR     02.07.2010  Created     
        */
        -- add delimiters before and after list to avoid partial match
        l_returnvalue := (instr(p_separator || p_list || p_separator, p_separator || p_item || p_separator) > 0) AND 
                         (p_item IS NOT NULL);
        --
        RETURN l_returnvalue;
        --
    END is_item_in_list;     
    --
    FUNCTION randomize_array (p_array IN t_str_array) RETURN t_str_array
    AS 
    l_swap_pos    PLS_INTEGER;
    l_value       VARCHAR2(4000);
    l_returnvalue t_str_array := p_array;
    BEGIN

        /*

        Purpose:    randomize array of strings

        Remarks:    

        Who     Date        Description
        ------  ----------  -------------------------------------
        MBR     07.07.2010  Created
        MBR     26.04.2012  Ignore empty array to avoid error
        
        */

        IF l_returnvalue.count > 0 THEN

            FOR i IN l_returnvalue.first .. l_returnvalue.last LOOP
            l_swap_pos := trunc(dbms_random.value(1, l_returnvalue.count));
            l_value := l_returnvalue(i);
            l_returnvalue (i) := l_returnvalue (l_swap_pos);
            l_returnvalue (l_swap_pos) := l_value;
            END LOOP;

        END IF;
        
        RETURN l_returnvalue;
        
    END randomize_array;
    --
    FUNCTION value_has_changed (p_old IN VARCHAR2,
                                p_new IN VARCHAR2) RETURN BOOLEAN
    AS 
    l_returnvalue BOOLEAN;
    BEGIN
    
        /*
        
        Purpose:      RETURN true IF two values are different
        
        Remarks:      
        
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     30.07.2010  Created
        
        */
        
        IF ((p_new is NULL) and (p_old is not NULL)) or
            ((p_new is not NULL) and (p_old is NULL)) or
            (p_new <> p_old)
        THEN
            l_returnvalue := true;
        ELSE
            l_returnvalue := false;
        END IF;

        RETURN l_returnvalue;
        
    END value_has_changed;
    --
    FUNCTION concat_array (
            p_array IN t_str_array,
            p_separator IN VARCHAR2 := g_default_separator
        ) RETURN VARCHAR2 AS 
        --
        l_returnvalue                  t_max_pl_varchar2;
        --
    BEGIN
        /*
            Purpose:      concatenate non-NULL strings with specified separator
            Remarks:      
            Who     Date        Description
            ------  ----------  --------------------------------
            MBR     19.11.2015  Created
        */
        IF p_array.count > 0 THEN
            --
            FOR i IN 1 .. p_array.count LOOP
                --
                IF p_array(i) is not NULL THEN
                    --
                    IF l_returnvalue IS NULL THEN
                        l_returnvalue := p_array(i);
                    ELSE
                        l_returnvalue := l_returnvalue || p_separator || p_array(i);
                    END IF;
                    --
                END IF;
                --
            END LOOP;
            --
        END IF;

        RETURN l_returnvalue;

    END concat_array;
    --
    -- validate email
    FUNCTION validate_email( 
            p_email IN VARCHAR2
        ) RETURN BOOLEAN IS
        --
        l_result VARCHAR2(64);
        --
    BEGIN 
        /*
            Purpose:  validate email
            Remarks:      
            Who         Date        Description
            ----------- ----------  --------------------------------
            RGUERRA     01.11.2023  Created
        */
        --
        SELECT regexp_substr( p_email,igtp.sys_k_string_util.g_email_str_validate)
          INTO l_result
          FROM DUAL;
        --
        RETURN l_result IS NOT NULL;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN FALSE;  
        --
    END validate_email;
    --
END sys_k_string_util;
/


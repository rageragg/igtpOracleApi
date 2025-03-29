CREATE OR REPLACE PACKAGE BODY sys_k_csv_util IS
    --
    /*
        Purpose:      convert CSV line to array of values  
        Remarks:      based on code from http://www.experts-exchange.com/Database/Oracle/PL_SQL/Q_23106446.html
        
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     31.03.2010  Created
        KJS     20.04.2011  Modified to allow double-quote escaping
        MBR     23.07.2012  Fixed issue with multibyte characters, thanks to Vadi..., see http://code.google.com/p/plsql-utils/issues/detail?id=13
    */
    --
    FUNCTION csv_to_array (
            p_csv_line  IN VARCHAR2,
            p_separator IN VARCHAR2 := g_default_separator
        ) RETURN t_str_array IS
        --
        l_returnvalue      t_str_array      := t_str_array();
        l_length           PLS_INTEGER      := length(p_csv_line);
        l_idx              binary_integer   := 1;
        l_quoted           BOOLEAN          := FALSE;  
        l_quote  constant  VARCHAR2(1)      := '"';
        l_start            BOOLEAN          := TRUE;
        l_position         PLS_INTEGER      := 1;
        l_current          VARCHAR2(1 CHAR);
        l_next             VARCHAR2(1 CHAR);
        l_current_column   VARCHAR2(32767);
        --
        -- Set the start flag, save our column value
        PROCEDURE save_column IS
        BEGIN
            --
            l_start                 := TRUE;
            l_returnvalue.extend;        
            l_returnvalue(l_idx)    := l_current_column;
            l_idx                   := l_idx + 1;            
            l_current_column        := null;
            --
        END save_column;
        --
        -- Append the value of l_current to l_current_column
        PROCEDURE append_current IS
        BEGIN
            --
            l_current_column := l_current_column || l_current;
            --
        END append_current;
        --
    BEGIN
        --
        WHILE l_position <= l_length LOOP
            --
            -- Set our variables with the current and next characters
            l_current   := substr(p_csv_line, l_position, 1);
            l_next      := substr(p_csv_line, l_position + 1, 1);    
            --
            IF l_start THEN
                --
                l_start             := FALSE;
                l_current_column    := null;
                --
                -- Check for leading quote and set our flag
                l_quoted := l_current = l_quote;
                --
                -- We skip a leading quote character
                IF l_quoted THEN 
                    --
                    GOTO loop_again; 
                    --
                END IF;
                --
            END IF;
            --
            --Check to see IF we are inside of a quote    
            IF l_quoted THEN
                --
                -- The current character is a quote - is it the end of our quote or does
                -- it represent an escaped quote?
                IF l_current = l_quote THEN
                    --
                    -- IF the next character is a quote, this is an escaped quote.
                    IF l_next = l_quote THEN
                        --
                        -- Append the literal quote to our column
                        append_current;
                        --
                        -- Advance the pointer to ignore the duplicated (escaped) quote
                        l_position := l_position + 1;
                        --
                        -- IF the next character is a separator, current is the end quote
                    ELSIF l_next = p_separator THEN
                        --
                        -- Get out of the quote and loop again - we will hit the separator next loop
                        l_quoted := FALSE;
                        GOTO loop_again;
                        --
                        -- Ending quote, no more columns
                    ELSIF l_next is null THEN
                        --
                        --  Save our current value, and iterate (end loop)
                        save_column;
                        GOTO loop_again;          
                        --
                        -- Next character is not a quote
                    ELSE
                        --
                        append_current;
                        --
                    END IF;
                    --
                ELSE
                    --
                    -- The current character is not a quote - append it to our column value
                    append_current;     
                    --
                END IF;
                ---
                -- Not quoted
            ELSE
                --
                -- Check IF the current value is a separator, save or append as appropriate
                IF l_current = p_separator THEN
                    save_column;
                ELSE
                    append_current;
                END IF;
                --
            END IF;
            --
            -- Check to see IF we've used all our characters
            IF l_next IS NULL THEN
                --
                save_column;
                --
            END IF;
            --
            --The continue statement was not added to PL/SQL until 11g. Use GOTO in 9i.
            <<loop_again>> 
                l_position := l_position + 1;
            --
        END LOOP;
        --
        RETURN l_returnvalue;
        --
    END csv_to_array;
    --
    /*
        Purpose:      convert array of values to CSV
        Remarks:      
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     31.03.2010  Created
        KJS     20.04.2011  Modified to allow quoted data, fixed a bug when 1st col was null
    */
    --
    FUNCTION array_to_csv(
            p_values    IN t_str_array,
            p_separator IN VARCHAR2 := g_default_separator
        ) RETURN VARCHAR2 IS
        --
        l_value       VARCHAR2(32767);
        l_returnvalue VARCHAR2(32767);
        --
    BEGIN
        --
        FOR i IN p_values.first .. p_values.last LOOP
            --
            -- Double quotes must be escaped
            l_value := replace(p_values(i), '"', '""');
            --
            -- Values containing the separator, a double quote, or a new line must be quoted.
            IF instr(l_value, p_separator) > 0 or instr(l_value, '"') > 0 or instr(l_value, chr(10)) > 0 THEN
                --
                l_value := '"' || l_value || '"';
                --
            END IF;
            --
            -- Append our value to our return value
            IF i = p_values.first THEN
                --
                l_returnvalue := l_value;
                --
            ELSE
                --
                l_returnvalue := l_returnvalue || p_separator || l_value;
                --
            END IF;
            --
        END LOOP;
        --
        RETURN l_returnvalue;
        --
    END array_to_csv;
    --
    /*
        Purpose:      get value from array by position
        Remarks:     
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     31.03.2010  Created
    */
    --
    FUNCTION get_array_value (
            p_values        IN t_str_array,
            p_position      IN NUMBER,
            p_column_name   IN VARCHAR2 := null
        ) RETURN VARCHAR2 IS
        --
        l_returnvalue VARCHAR2(4000);
        --
    BEGIN
        --
        IF p_values.count >= p_position THEN
            --
            l_returnvalue := p_values(p_position);
            --
        ELSE
            --
            IF p_column_name IS NOT NULL THEN
                --
                RAISE_APPLICATION_ERROR (-20000, 'Column number ' || p_position || ' does not exist. Expected column: ' || p_column_name);
                --
            ELSE
                --
                l_returnvalue := null;
                --
            END IF;
            --
        END IF;
        --
        RETURN l_returnvalue;
        --
    END get_array_value;
    --
    /*
        Purpose:      convert clob to CSV
        Remarks:      based on code from http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:1352202934074
                                    and  http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:744825627183
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     31.03.2010  Created
        JLL     20.04.2015  Modified made an internal clob because || l_line_separator is very bad for performance
    */
    --
    FUNCTION clob_to_csv (
            p_csv_clob  IN CLOB,
            p_separator IN VARCHAR2 := g_default_separator,
            p_skip_rows IN NUMBER   := 0
        ) RETURN t_csv_tab PIPELINED IS
        --
        l_csv_clob               CLOB;
        l_line_separator         VARCHAR2(2) := chr(13) || chr(10);
        l_last                   PLS_INTEGER;
        l_current                PLS_INTEGER;
        l_line                   VARCHAR2(32000);
        l_line_number            PLS_INTEGER := 0;
        l_from_line              PLS_INTEGER := p_skip_rows + 1;
        l_line_array             t_str_array;
        l_row                    t_csv_line := t_csv_line (
                                                    null, null,  -- line number, line raw
                                                    null, null, null, null, null, null, null, null, null, null,   -- lines 1-10
                                                    null, null, null, null, null, null, null, null, null, null    -- lines 11-20
                                                ); 
    BEGIN
        --
        -- IF the file has a DOS newline (cr+lf), use that
        -- IF the file does not have a DOS newline, use a Unix newline (lf)
        IF (nvl(dbms_lob.instr(p_csv_clob, l_line_separator, 1, 1),0) = 0) THEN
            l_line_separator := chr(10);
        END IF;
        --
        l_last := 1;
        l_csv_clob := p_csv_clob || l_line_separator;
        --
        LOOP
            --
            l_current := dbms_lob.instr (l_csv_clob , l_line_separator, l_last, 1);
            EXIT WHEN (nvl(l_current,0) = 0);
            
            l_line_number := l_line_number + 1;
            
            IF l_from_line <= l_line_number THEN
                --
                l_line := dbms_lob.substr(l_csv_clob, l_current - l_last + 1, l_last);
                -- 
                l_line := replace(l_line, chr(10), '');
                l_line := replace(l_line, chr(13), '');
                --
                l_line_array := csv_to_array (l_line, p_separator);
                --
                l_row.line_number   := l_line_number;
                l_row.line_raw      := substr(l_line,1,4000);
                --
                l_row.c001 := get_array_value (l_line_array, 1);
                l_row.c002 := get_array_value (l_line_array, 2);
                l_row.c003 := get_array_value (l_line_array, 3);
                l_row.c004 := get_array_value (l_line_array, 4);
                l_row.c005 := get_array_value (l_line_array, 5);
                l_row.c006 := get_array_value (l_line_array, 6);
                l_row.c007 := get_array_value (l_line_array, 7);
                l_row.c008 := get_array_value (l_line_array, 8);
                l_row.c009 := get_array_value (l_line_array, 9);
                l_row.c010 := get_array_value (l_line_array, 10);
                l_row.c011 := get_array_value (l_line_array, 11);
                l_row.c012 := get_array_value (l_line_array, 12);
                l_row.c013 := get_array_value (l_line_array, 13);
                l_row.c014 := get_array_value (l_line_array, 14);
                l_row.c015 := get_array_value (l_line_array, 15);
                l_row.c016 := get_array_value (l_line_array, 16);
                l_row.c017 := get_array_value (l_line_array, 17);
                l_row.c018 := get_array_value (l_line_array, 18);
                l_row.c019 := get_array_value (l_line_array, 19);
                l_row.c020 := get_array_value (l_line_array, 20);
                --
                PIPE ROW (l_row);
                --
            END IF;
            --
            l_last := l_current + length (l_line_separator);
            --
        END LOOP;
        --
        RETURN;
        --
    END clob_to_csv;
    --
END sys_k_csv_util;
/
 

DECLARE
    --
    l_str   VARCHAR2(512) := '3400000000001;6340150061617;CED;06400174667;10127075;36264.73;;';
    l_spt   CHAR(01)      := ';';
    l_lgn   NUMBER;
    l_pos   NUMBER;
    l_tmp   VARCHAR2(512);
    l_fld   VARCHAR2(512);
    l_sec   PLS_INTEGER;
    --
    FUNCTION del_str (
            p_string    IN VARCHAR2,
            p_from_pos  IN NUMBER := 1,
            p_to_pos    IN NUMBER := NULL
        ) RETURN VARCHAR2 AS 
        --
        l_to_pos       PLS_INTEGER;
        l_returnvalue  VARCHAR2(32767);
        --
    BEGIN
        --
        IF (p_string is NULL) or (p_from_pos <= 0) THEN
            l_returnvalue := NULL;
        ELSE
            --
            IF p_to_pos IS NULL THEN
                l_to_pos := length(p_string);
            ELSE
                l_to_pos := p_to_pos;
            END IF;
            --
            IF l_to_pos > length(p_string) THEN
                l_to_pos :=  length(p_string);
            END IF;
            --
            l_returnvalue   :=  substr(p_string, 1, p_from_pos - 1) || 
                                substr(p_string, l_to_pos + 1, length(p_string) - l_to_pos);
            --
        END IF;
        --
        RETURN l_returnvalue;
        --
    END del_str;
    --
BEGIN 
    --
    l_lgn := length(l_str);
    l_tmp := l_str;
    l_sec := 0;
    --
    LOOP
        --
        l_pos := nvl(instr(l_tmp,l_spt),0);
        --
        EXIT WHEN l_pos = 0 AND nvl(length(l_tmp),0) = 0;
        --
        l_sec := l_sec + 1;
        --
        IF l_pos = 0 THEN 
          --
          l_pos := length(l_tmp)+1;
          --
        END IF;
        --
        l_fld := substr(
            l_tmp,
            1,
            l_pos-1
        );
        --
        l_tmp := del_str (
            p_string    => l_tmp,
            p_from_pos  => 1,
            p_to_pos    => l_pos
        );
        --
    END LOOP;
    --
END;
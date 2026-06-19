CREATE OR REPLACE FUNCTION validar_email (
        p_email     IN VARCHAR2,
        p_strong    IN BOOLEAN DEFAULT FALSE
    ) RETURN BOOLEAN IS
    --
    l_patron VARCHAR2(200);
    --
BEGIN
    --    
    -- Patrón estándar RFC 5322 simplificado
    IF p_strong THEN 
        --
        l_patron := '^[A-Za-z0-9]+([._%+-][A-Za-z0-9]+)*@[A-Za-z0-9]+([.-][A-Za-z0-9]+)*\.[A-Za-z]{2,}$';
        --
    ELSE
        --
        l_patron := '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
        --
    END IF;
    --
    -- Validación del texto nulo o vacío
    IF p_email IS NULL THEN
        RETURN FALSE;
    END IF;
    --
    -- Comprobación del patrón
    IF REGEXP_LIKE(p_email, l_patron) THEN
        RETURN TRUE;
    END IF;
    --
    RETURN FALSE;
    --
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    --    
END validar_email;
/

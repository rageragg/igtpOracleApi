CREATE OR REPLACE PROCEDURE registrar_error_log (
        p_modulo IN VARCHAR2
    ) IS
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_backtrace VARCHAR2(32767);
    --
BEGIN
    -- Capturamos la traza en una variable antes de insertarla
    v_backtrace := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    
    INSERT INTO log_errores (
            usuario, modulo, error_msg, error_trace
        )
    VALUES(
        USER, p_modulo, SQLERRM, v_backtrace
    );
    --
    COMMIT; -- El commit solo afecta a la inserción en el log
    --
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Evita que errores al loguear afecten al sistema
END;
/

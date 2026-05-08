CREATE OR REPLACE PROCEDURE mi_proceso_negocio AS
BEGIN
    -- Tu lógica de negocio aquí...
    DBMS_OUTPUT.PUT_LINE(10 / 0); -- Forzar error
    --
EXCEPTION
    WHEN OTHERS THEN
        -- Registramos el error de forma centralizada
        registrar_error_log('MI_PROCESO_NEGOCIO');
        
        -- Opcional: Volver a lanzar el error para que la app sepa que falló
        RAISE; 
END;
/

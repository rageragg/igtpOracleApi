DECLARE
    --
    v_message   VARCHAR2(1800);
    --
    /*
        0 significa que se recibió la alerta.
        1 significa que expiró el tiempo de espera
    */
    --    
    v_status    INTEGER; 
    --
BEGIN
    --
    -- 1. Registrar el interés de esta sesión en la alerta específica
    DBMS_ALERT.REGISTER(
        name => 'nuevo_inventario_critico'
    );
    --
    -- 2. Esperar de forma síncrona a que ocurra la alerta (tiempo de espera: 60 segundos)
    DBMS_ALERT.WAITONE(
        name        => 'nuevo_inventario_critico',
        message     => v_message,
        status      => v_status,
        timeout     => 60
    );
    --
    -- 3. Evaluar el resultado
    IF v_status = 0 THEN
        --
        DBMS_OUTPUT.PUT_LINE('¡Alerta recibida! Mensaje: ' || v_message);
        /* 
            TODO: Logica de negocio si se recibe una ALERTA
        */    
    ELSE
        --
        DBMS_OUTPUT.PUT_LINE('Tiempo de espera agotado sin recibir alertas.');
        --
    END IF;
    --
    -- 4. Desregistrar la alerta al terminar para liberar recursos
    DBMS_ALERT.REMOVE(
        name    => 'nuevo_inventario_critico'
    );
    --
END;
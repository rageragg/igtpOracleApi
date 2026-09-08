DECLARE
    v_opciones_desencolar DBMS_AQ.DEQUEUE_OPTIONS_T;
    v_propiedades_msg     DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msg_id              RAW(16);
    v_payload             typ_aq_notification;
BEGIN
    --
    -- Opcional: Configurar para que no se quede esperando indefinidamente si está vacía
    v_opciones_desencolar.wait := DBMS_AQ.NO_WAIT; 
    --
    -- Extraer el primer mensaje disponible de la cola (First-In, First-Out)
    DBMS_AQ.DEQUEUE (
        queue_name         => 'queue_notifications',
        dequeue_options    => v_opciones_desencolar,
        message_properties => v_propiedades_msg,
        payload            => v_payload, -- Aquí se vierte el objeto extraído
        msgid              => v_msg_id
    );
    --
    -- Mostrar los datos extraídos
    DBMS_OUTPUT.PUT_LINE('ID Notificación: ' || v_payload.id);
    DBMS_OUTPUT.PUT_LINE('Destinatario:    ' || v_payload.to_user);
    DBMS_OUTPUT.PUT_LINE('Mensaje:         ' || v_payload.message);
    --
    -- Confirmar la extracción (remueve definitivamente el mensaje de la cola)
    COMMIT;
    --
EXCEPTION
    WHEN OTHERS THEN
        -- Captura el error si la cola está vacía y usamos NO_WAIT
        IF SQLCODE = -25228 THEN
            DBMS_OUTPUT.PUT_LINE('No hay mensajes disponibles en la cola.');
        ELSE
            RAISE;
        END IF;
END;
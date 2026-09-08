DECLARE
    --
    v_opciones_desencolar DBMS_AQ.DEQUEUE_OPTIONS_T;
    v_propiedades_msg     DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msg_id              RAW(16);
    v_payload             typ_aq_notification;
    --
BEGIN
    --
    -- INDICAR QUÉ CLIENTE ESTÁ CONSUMIENDO
    v_opciones_desencolar.consumer_name := 'CLIENTE_A';
    v_opciones_desencolar.wait          := DBMS_AQ.NO_WAIT;
    --
    DBMS_AQ.DEQUEUE (
        queue_name         => 'cola_difusion',
        dequeue_options    => v_opciones_desencolar,
        message_properties => v_propiedades_msg,
        payload            => v_payload,
        msgid              => v_msg_id
    );
    --
    DBMS_OUTPUT.PUT_LINE(
        'CLIENTE_A procesó el mensaje: ' || v_payload.message
    );
    --
    COMMIT;
    --
END;
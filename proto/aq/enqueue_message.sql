DECLARE
    --
    v_opciones_encolar   DBMS_AQ.ENQUEUE_OPTIONS_T;
    v_propiedades_msg    DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msg_id             RAW(16); -- Almacena el identificador único del mensaje generado por Oracle
    v_payload            typ_aq_notification;
    --
BEGIN
    --
    -- Instanciar el objeto con los datos que queremos enviar
    v_payload := typ_aq_notification(
        id          => 101,
        to_user     => 'rguerra@correo.com',
        from_user   => 'admin@correo.com',
        message     => 'Tu código de verificación es 5543',
        create_at   => SYSDATE
    );
    --
    -- Insertar el mensaje en la cola
    DBMS_AQ.ENQUEUE (
        queue_name         => 'queue_notifications',
        enqueue_options    => v_opciones_encolar,
        message_properties => v_propiedades_msg,
        payload            => v_payload,
        msgid              => v_msg_id
    );
    --
    -- Confirmar la transacción (esencial para que el mensaje sea visible)
    COMMIT;
    --  
    DBMS_OUTPUT.PUT_LINE('Mensaje encolado con ID exitosamente.');
    --
END;
/

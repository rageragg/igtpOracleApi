DECLARE
    --
    v_opciones_encolar   DBMS_AQ.ENQUEUE_OPTIONS_T;
    v_propiedades_msg    DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msg_id             RAW(16);
    v_payload            typ_aq_notification;
    --
BEGIN
    --
    v_payload := typ_aq_notification(
        id          => 102,
        to_user     => 'rguerra@correo.com',
        from_user   => 'admin@correo.com',
        message     => 'Tu código de verificación es 5543',
        create_at   => SYSDATE
    );
    --
    DBMS_AQ.ENQUEUE (
        queue_name         => 'queue_difusion',
        enqueue_options    => v_opciones_encolar,
        message_properties => v_propiedades_msg,
        payload            => v_payload,
        msgid              => v_msg_id
    );
    --
    COMMIT;
    --
    DBMS_OUTPUT.PUT_LINE('Mensaje de difusión enviado de forma exitosa.');
    --
END;
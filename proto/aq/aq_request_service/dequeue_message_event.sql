DECLARE
    --
    v_opciones_desencolar DBMS_AQ.DEQUEUE_OPTIONS_T;
    v_propiedades_msg     DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msg_id              RAW(16);
    --
    v_payload             typ_aq_event;
    json_payload          JSON_OBJECT_T;
    json_content          JSON_OBJECT_T;
    --
BEGIN
    --
    -- INDICAR QUÉ CLIENTE ESTÁ CONSUMIENDO
    v_opciones_desencolar.consumer_name := 'LOGISTICS';
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
    -- TODO: Aquí puedes procesar el mensaje recibido
    json_payload := JSON_OBJECT_T(v_payload.data_json);
    --
    -- Ejecutar la función de callback especificada en el mensaje
    IF json_payload.has('call_back') THEN   
        --
        DECLARE
            --
            v_callback_function VARCHAR2(100);
            --
        BEGIN
            --
            v_callback_function := json_payload.get_string('call_back');
            --
            -- Aquí puedes usar EXECUTE IMMEDIATE para llamar a la función de callback
            EXECUTE IMMEDIATE 'BEGIN ' || v_callback_function || '( :1 ); END;' USING json_payload.to_string;
            --
        END;
        --
    END IF;
    --
    COMMIT;
    --
END;
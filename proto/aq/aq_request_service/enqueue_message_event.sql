DECLARE
    --
    v_opciones_encolar   DBMS_AQ.ENQUEUE_OPTIONS_T;
    v_propiedades_msg    DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_msg_id             RAW(16);
    --
    v_payload            typ_aq_event;
    json_payload         JSON_OBJECT_T;
    json_content         JSON_OBJECT_T;
    --
BEGIN
    --
    -- incializamos el objeto JSON para el payload
    json_payload := JSON_OBJECT_T('{}');
    json_content := JSON_OBJECT_T('{}');
    --
    json_content.put('client_id', '2023-0001');
    json_content.put('client_name', 'Transportes del Norte S.A.');
    json_content.put('service_type', 'Logistics');
    json_content.put('service_description', 'Solicitud de servicio de transporte de carga, desde Barquisimeto hacia a Caracas.');
    json_content.put('service_date', '2024-06-15'); 
    json_content.put('type_cargo', 'Refrigerated Goods');
    json_content.put('cargo_weight', '1500 kg');
    json_content.put('origin_address', 'Av. Libertador, Barquisimeto, Lara, Venezuela');
    json_content.put('destination_address', 'Av. Libertador, Caracas, Venezuela');
    --
    json_payload.put('type_json', 'REQUEST_SERVICE');
    json_payload.put('call_back', 'igtp.lgc_api_k_rest_service.process_request_service');
    json_payload.put('content', json_content);
    --
    v_payload := typ_aq_event(
        id          => 102,
        to_user     => 'rguerra@correo.com',
        from_user   => 'admin@correo.com',
        data_json   => json_payload.to_string,
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
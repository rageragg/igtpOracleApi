BEGIN
    --
    -- 1. Crear la tabla especificando múltiple consumidor
    DBMS_AQADM.CREATE_QUEUE_TABLE (
        queue_table        => 'tbl_queue_event',
        queue_payload_type => 'typ_aq_event',
        multiple_consumers => TRUE -- <-- ESTA ES LA CLAVE
    );
    --
    -- 2. Crear la cola
    DBMS_AQADM.CREATE_QUEUE (
        queue_name  => 'queue_event',
        queue_table => 'tbl_queue_event'
    );
    --
    -- 3. Iniciar la cola
    DBMS_AQADM.START_QUEUE (
        queue_name => 'queue_event'
    );
    --
END;
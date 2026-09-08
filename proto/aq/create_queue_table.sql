BEGIN
    --
    -- 1. Crear la tabla que almacenará físicamente los mensajes
    DBMS_AQADM.CREATE_QUEUE_TABLE (
        queue_table        => 'tbl_queue_notifications',
        queue_payload_type => 'typ_aq_notification'
    );
    --
    -- 2. Crear la cola lógica asociada a la tabla anterior
    DBMS_AQADM.CREATE_QUEUE (
        queue_name  => 'queue_notifications',
        queue_table => 'tbl_queue_notifications'
    );
    --
    -- 3. Iniciar la cola para permitir encolar (enqueue) y desencolar (dequeue)
    DBMS_AQADM.START_QUEUE (
        queue_name => 'queue_notifications'
    );
    --
END;
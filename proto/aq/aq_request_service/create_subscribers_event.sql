DECLARE
    --
    v_suscriptor SYS.AQ$_AGENT;
    --
BEGIN
    --
    -- Registrar el Primer Suscriptor
    v_suscriptor := SYS.AQ$_AGENT('LOGISTICS', NULL, NULL);
    --
    DBMS_AQADM.ADD_SUBSCRIBER(
        queue_name => 'queue_event',
        subscriber => v_suscriptor
    );
    --
    -- Registrar el Segundo Suscriptor
    v_suscriptor := SYS.AQ$_AGENT('SALES', NULL, NULL);
    --
    DBMS_AQADM.ADD_SUBSCRIBER(
        queue_name => 'queue_event',
        subscriber => v_suscriptor
    );
    --
END;
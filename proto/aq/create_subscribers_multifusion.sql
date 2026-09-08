DECLARE
    --
    v_suscriptor SYS.AQ$_AGENT;
    --
BEGIN
    --
    -- Registrar el Primer Suscriptor
    v_suscriptor := SYS.AQ$_AGENT('CLIENTE_A', NULL, NULL);
    --
    DBMS_AQADM.ADD_SUBSCRIBER(
        queue_name => 'queue_difusion',
        subscriber => v_suscriptor
    );
    --
    -- Registrar el Segundo Suscriptor
    v_suscriptor := SYS.AQ$_AGENT('CLIENTE_B', NULL, NULL);
    --
    DBMS_AQADM.ADD_SUBSCRIBER(
        queue_name => 'queue_difusion',
        subscriber => v_suscriptor
    );
    --
END;
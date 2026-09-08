BEGIN 
    --
    DBMS_AQADM.REMOVE_SUBSCRIBER(
        queue_name => 'cola_difusion',
        subscriber => SYS.AQ$_AGENT('CLIENTE_FILTRADO', NULL, NULL)
    );
    --
END;
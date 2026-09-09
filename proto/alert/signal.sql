BEGIN
    --
    -- Tomar en cuenta que sea asincronica esta transaccion 
    --
    -- 1. Registrar la señal indicando el nombre de la alerta y un mensaje opcional
    DBMS_ALERT.SIGNAL(
        name    => 'nuevo_inventario_critico',
        message => 'Stock del artículo XYZ ha caído por debajo del mínimo.'
    );
    --
    -- 2. IMPORTANTE: La alerta NO se enviará hasta que ocurra el COMMIT
    COMMIT; 
    --
END;
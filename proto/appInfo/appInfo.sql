DECLARE
    -- Variables para simular el proceso
    v_total_registros NUMBER := 100;
    v_progreso        NUMBER := 0;
BEGIN
    -- 1. Registrar el nombre de la aplicación y el módulo principal
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'Usuario: Servidor_Aplicaciones_01');
    DBMS_APPLICATION_INFO.SET_MODULE(
        module_name => 'FACTURACION_MENSUAL',
        action_name => 'INICIANDO PROCESO'
    );

    -- Simular una pausa inicial
    DBMS_LOCK.SLEEP(2); 

    -- ==========================================
    -- FASE 1: VALIDACIÓN DE DATOS
    -- ==========================================
    -- Cambiamos la acción actual sin modificar el módulo
    DBMS_APPLICATION_INFO.SET_ACTION(action_name => 'VALIDANDO_CONTRATOS');
    
    -- Código de tu lógica de negocio aquí
    DBMS_LOCK.SLEEP(3); -- Simulación de carga de trabajo

    -- ==========================================
    -- FASE 2: ACTUALIZACIÓN DE FACTURAS Y PROGRESO
    -- ==========================================
    DBMS_APPLICATION_INFO.SET_ACTION(action_name => 'ACTUALIZANDO_SALDOS');

    FOR i IN 1..v_total_registros LOOP
        -- Tu lógica de actualización aquí...
        
        -- Simulamos procesamiento
        DBMS_LOCK.SLEEP(0.05); 
        
        -- 2. Registrar el progreso de operaciones largas
        v_progreso := v_progreso + 1;
        DBMS_APPLICATION_INFO.SET_SESSION_LONGOPS(
            rindex      => DBMS_APPLICATION_INFO.SET_SESSION_LONGOPS_NOHINT,
            slno        => v_progreso,
            op_name     => 'Procesando Facturas',
            target      => 0,
            context     => 0,
            sofar       => v_progreso,
            totalwork   => v_total_registros,
            target_desc => 'Tabla: FACTURAS_DETALLE',
            units       => 'Registros'
        );
    END LOOP;

    -- ==========================================
    -- FASE 3: LIMPIEZA / FINALIZACIÓN
    -- ==========================================
    -- Al terminar, es una buena práctica limpiar los datos de la sesión
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => NULL, action_name => NULL);
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => NULL);

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, registrar dónde falló antes de propagar
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => 'ERROR: ' || SUBSTR(SQLERRM, 1, 25));
        RAISE;
END;
/

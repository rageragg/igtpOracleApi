/**
    PROPOSITO: Simular la inclusion de un flete
*/
DECLARE 
    --
    -- locales
    l_reg_freight   freights%ROWTYPE        := NULL;
    l_reg_customer  customers%ROWTYPE       := NULL;
    l_reg_route     routes%ROWTYPE          := NULL;
    l_reg_cargo     type_cargos%ROWTYPE     := NULL;
    l_reg_vehicle   type_vehicles%ROWTYPE   := NULL;
    l_type_freight  type_freights%ROWTYPE   := NULL;
    --
BEGIN 
    --
    -- buscamos el cliente
    l_reg_customer.customer_co := 'MKR';
    l_reg_customer := dsc_api_k_customer.get_record( p_customer_co => l_reg_customer.customer_co );
    --
    -- completamos el registro
    l_reg_freight.customer_id := l_reg_customer.id;
    --
    -- buscamos la ruta
    l_reg_route.route_co := '21-41';
    l_reg_route := lgc_api_k_route.get_record( p_route_co => l_reg_route.route_co );
    -- completamos el registro
    l_reg_freight.route_id := l_reg_route.id;
    --
    -- buscamos el tipo de carga
    l_reg_cargo.type_cargo_co := 'REF';
    l_reg_cargo := dsc_api_k_typ_cargo.get_record( p_type_cargo_co => l_reg_cargo.type_cargo_co );
    -- completamos el registro
    l_reg_freight.type_cargo_id := l_reg_cargo.id;
    --
    -- buscamos el tipo de vehiculo 
    -- ! SOLO EL TIPO DE TRACTOMULA
    l_reg_vehicle.type_vehicle_co := 'CH2';
    l_reg_vehicle := dsc_api_k_typ_vehicle.get_record( p_type_vehicle_co => l_reg_vehicle.type_vehicle_co );
    --
    -- buscamos el tipo de viaje
    l_type_freight.type_freight_co := 'PTP';
    l_type_freight := dsc_api_k_type_freigt.get_record( p_type_freight_co => l_type_freight.type_freight_co );
    -- 
    -- TODO: Construir el proceso de tipos de viajes
    --
    -- completamos el registro
    l_reg_freight.type_vehicle_id   := l_reg_vehicle.id;   
    l_reg_freight.k_regimen         := lgc_api_k_freight.K_REGIMEN_FREIGHT;
    l_reg_freight.k_status          := lgc_api_k_freight.K_STATUS_PLANNED;
    l_reg_freight.k_process         := lgc_api_k_freight.K_PROCESS_LOGISTY;
    l_reg_freight.upload_at         := to_date('03012018','ddmmyyyy');
    l_reg_freight.notes             := 'Viajes 2018 MELENDEZ CASTILLO JOHNNY ERNESTO';
    l_reg_freight.user_id           := 1;
    l_reg_freight.freights_co       := '71803';
    l_reg_freight.type_freight_id   := l_type_freight.id;
    --
    dbms_output.put_line( 'Flete       : ' || l_reg_freight.freights_co );
    dbms_output.put_line( 'Cliente     : ' || l_reg_customer.description );
    dbms_output.put_line( 'Ruta        : ' || l_reg_route.description );
    dbms_output.put_line( 'Carga       : ' || l_reg_cargo.description );
    dbms_output.put_line( 'Tipo Flete  : ' || l_type_freight.description );
    dbms_output.put_line( 'Tipo Tracto : ' || l_reg_vehicle.description );
    dbms_output.put_line( 'Estado      : ' || l_reg_freight.k_status );
    dbms_output.put_line( 'Notas       : ' || l_reg_freight.notes );
    --
    -- ! SE DEBE VALIDAR ES ESTATUS: SEGUN SEA EL CASO, SE DEBE VALIDAR QUE LOS
    -- ! REGISTROS ASOCIADOS ESTEN COMPLETOS O NO.
    --
    -- incluimos el registro
    lgc_api_k_freight.ins( p_rec => l_reg_freight );
    --
    COMMIT;
    --
    dbms_output.put_line( 'Registro Exitoso' );
    --
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            dbms_output.put_line(sqlerrm);
            dbms_output.put_line('NOT_DATA_FOUND');
        WHEN OTHERS THEN 
            dbms_output.put_line(sqlerrm);    
END;
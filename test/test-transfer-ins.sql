/**
    PROPOSITO: Simular la inclusion de un flete
*/
DECLARE 
    --
    -- locales
    l_reg_freight   freights%ROWTYPE        := NULL;
    l_reg_transfer  transfers%ROWTYPE       := NULL;
    l_reg_route     routes%ROWTYPE          := NULL;
    l_reg_cargo     type_cargos%ROWTYPE     := NULL;
    l_reg_vehicle   type_vehicles%ROWTYPE   := NULL;
    l_type_freight  type_freights%ROWTYPE   := NULL;
    --
BEGIN 
    --
    -- buscamos el viaje
    l_reg_freight := lgc_api_k_freight.get_record( p_freight_co => 71819 );
    --
    -- buscamos la ruta
    l_reg_route.id :=l_reg_freight.route_id;
    l_reg_route := lgc_api_k_route.get_record( p_id => l_reg_route.id );
    -- buscamos el tipo de carga
    l_reg_cargo.id := l_reg_freight.type_cargo_id;
    l_reg_cargo := dsc_api_k_typ_cargo.get_record( p_id => l_reg_cargo.id );
    --
    -- buscamos el tipo de vehiculo 
    l_reg_vehicle.id := l_reg_freight.type_vehicle_id;
    l_reg_vehicle := dsc_api_k_typ_vehicle.get_record( p_id => l_reg_vehicle.id );
    --
    -- buscamos el tipo de viaje
    l_type_freight.id := l_reg_freight.type_freight_id;
    l_type_freight := dsc_api_k_type_freigt.get_record( p_id => l_type_freight.id  );
    --
    dbms_output.put_line( 'Flete       : ' || l_reg_freight.freight_co );
    dbms_output.put_line( 'Ruta        : ' || l_reg_route.description );
    dbms_output.put_line( 'Carga       : ' || l_reg_cargo.description );
    dbms_output.put_line( 'Tipo Flete  : ' || l_type_freight.description );
    dbms_output.put_line( 'Tipo Tracto : ' || l_reg_vehicle.description );
    dbms_output.put_line( 'Estado      : ' || l_reg_freight.k_status );
    dbms_output.put_line( 'Notas       : ' || l_reg_freight.notes );
    --
    -- incluimos la primera transferencia, logistica 
    l_reg_transfer.freight_id       := l_reg_freight.id;
    l_reg_transfer.k_type_transfer  := lgc_api_k_transfer.K_TYPE_TRANS_BUSSINES;
    -- buscamos la ruta
    --l_reg_route.route_co := '21-15';
    --l_reg_route := lgc_api_k_route.get_record( p_route_co => l_reg_route.route_co );

    l_reg_transfer.route_id     := l_reg_route.id;
    l_reg_transfer.planed_at    := l_reg_freight.upload_at;
    --
    -- TODO: Realizar el proceso de busqueda de conductor por codigo externo
    l_reg_transfer.main_employee_id := 12;
    --
    -- TODO: Realizar el proceso de busqueda de tractomula y trailer por codigo externo
    l_reg_transfer.truck_id     := 13;
    l_reg_transfer.trailer_id   := 74;
    l_reg_transfer.user_id      := 1;
    --
    -- ! NO SE PUEDE CREAR UNA TRANSFERENCIAS SI HAY ALGUNA CON ESTATUS=PLANNED
    -- TODO: Realizar validacion de las transferencias
    --
    -- incluimos el registro
    lgc_api_k_transfer.ins( p_rec => l_reg_transfer );
    --
    dbms_output.put_line( 'Transferencia : ' || l_reg_transfer.sequence_number );
    dbms_output.put_line( 'Ruta          : ' || l_reg_route.description );
    dbms_output.put_line( 'Tipo          : ' || l_reg_transfer.k_type_transfer);
    dbms_output.put_line( 'Estado        : ' || l_reg_transfer.k_status );
    --
    --
    COMMIT;
    -- ROLLBACK;
    --
    dbms_output.put_line( 'Registro Exitoso' );
    --
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            dbms_output.put_line(sqlerrm);
            dbms_output.put_line('NOT_DATA_FOUND');
        WHEN OTHERS THEN 
            dbms_output.put_line(sqlerrm);    
            ROLLBACK;
END;
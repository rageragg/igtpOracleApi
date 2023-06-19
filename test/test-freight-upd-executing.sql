DECLARE 
    --
    /**
        PROPOSITO: Simular la inclusion de un flete
    */
    -- locales
    l_reg_freight   freights%ROWTYPE        := NULL;
    l_reg_transfer  transfers%ROWTYPE       := NULL;
    l_reg_route     routes%ROWTYPE          := NULL;
    l_reg_cargo     type_cargos%ROWTYPE     := NULL;
    l_reg_vehicle   type_vehicles%ROWTYPE   := NULL;
    l_reg_employee  employees%ROWTYPE       := NULL;
    l_reg_truck     trucks%ROWTYPE          := NULL;
    l_reg_trailer   trailers%ROWTYPE        := NULL;
    l_type_freight  type_freights%ROWTYPE   := NULL;
    --
    l_tab_transfers lgc_api_k_transfer.transfers_api_tab;
    --
BEGIN 
    --
    -- buscamos el viaje
    l_reg_freight := lgc_api_k_freight.get_record( p_freight_co => 71818 );
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
    -- incluimos iniciamos el viaje
    l_reg_freight.k_status := lgc_api_k_freight.K_STATUS_EXECUTING;
    l_reg_freight.start_at := l_reg_freight.upload_at;
    lgc_api_k_freight.upd( p_rec => l_reg_freight );
    --
    l_tab_transfers.DELETE;
    l_tab_transfers := lgc_api_k_transfer.get_list( p_freight_id => l_reg_freight.id );
    --
     dbms_output.put_line( l_tab_transfers.COUNT );
    --
    -- RECORREMOS LAS TRANSFERENCIAS
    FOR i IN 1..l_tab_transfers.COUNT LOOP
        --
        l_reg_transfer := l_tab_transfers(i);
        --
        IF l_reg_transfer.k_status = lgc_api_k_transfer.K_STATUS_PLANNED THEN 
            --
            l_reg_transfer.k_status   := lgc_api_k_transfer.K_STATUS_EXECUTING;
            --
            IF l_reg_transfer.start_at IS NULL THEN 
                l_reg_transfer.start_at := l_reg_freight.start_at;
            END IF;    
            --
            -- incluimos el registro
            lgc_api_k_transfer.upd( p_rec => l_reg_transfer );
            --
            -- actualizamos el empleado
            l_reg_employee := dsc_api_k_employee.get_record( p_id => l_reg_transfer.main_employee_id );
            l_reg_employee.transfer_id  := l_reg_transfer.id;
            l_reg_employee.truck_id     := l_reg_transfer.truck_id;
            l_reg_employee.trailer_id   := l_reg_transfer.trailer_id;
            l_reg_employee.k_status     := dsc_api_k_employee.K_STATUS_SERVING;
            dsc_api_k_employee.upd( p_rec => l_reg_employee );
            --
            -- actualizamos la tractomula
            l_reg_truck := dsc_api_k_truck.get_record( p_id => l_reg_transfer.truck_id );
            l_reg_truck.transfer_id     := l_reg_transfer.id;
            l_reg_truck.employee_id     := l_reg_transfer.main_employee_id;
            l_reg_truck.k_status     := dsc_api_k_truck.K_STATUS_SERVING;
            dsc_api_k_truck.upd( p_rec => l_reg_truck );
            --
            -- actualizamos el trailer
            l_reg_trailer := dsc_api_k_trailer.get_record( p_id => l_reg_transfer.trailer_id );
            l_reg_trailer.transfer_id   := l_reg_transfer.id;
            l_reg_trailer.employee_id   := l_reg_transfer.main_employee_id;    
            l_reg_trailer.k_status     := dsc_api_k_trailer.K_STATUS_SERVING;
            dsc_api_k_trailer.upd( p_rec => l_reg_trailer );    
            --
            -- actualizamos las transferencias planeadas
            dbms_output.put_line( 'Transferencia : ' || l_reg_transfer.sequence_number );
            dbms_output.put_line( 'Ruta          : ' || l_reg_route.description );
            dbms_output.put_line( 'Tipo          : ' || l_reg_transfer.k_type_transfer);
            dbms_output.put_line( 'Estado        : ' || l_reg_transfer.k_status );
            --
        END IF;
        --    
    END LOOP;

    --
    COMMIT;
    --ROLLBACK;
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
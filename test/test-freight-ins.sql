/**
    PROPOSITO: Simular la inclusion de un flete
*/
DECLARE 
    --
    -- parametros 
    p_freight_co        freights.freight_co%TYPE            := '71806';
    p_customer_co       customers.customer_co%TYPE          := 'MKR';
    p_type_cargo_co     type_cargos.type_cargo_co%TYPE      := 'REF';
    p_route_co          routes.route_co%TYPE                := '21-26';
    p_type_vehicle_co   type_vehicles.type_vehicle_co%TYPE  := 'CH2';
    p_type_freight_co   type_freights.type_freight_co%TYPE  := 'PMP';
    p_regimen           freights.k_regimen%TYPE             := lgc_api_k_freight.K_REGIMEN_FREIGHT;
    p_upload_at         freights.upload_at%TYPE             := to_date('03012018','ddmmyyyy');
    p_notes             freights.notes%TYPE                 := 'Viajes 2018 GALUE CASTILLO ANGEL JOSE';
    p_user_co           users.user_co%TYPE                  := 'rguerra';
    --
    -- locales
    l_reg_freight   freights%ROWTYPE        := NULL;
    l_reg_customer  customers%ROWTYPE       := NULL;
    l_reg_route     routes%ROWTYPE          := NULL;
    l_reg_cargo     type_cargos%ROWTYPE     := NULL;
    l_reg_vehicle   type_vehicles%ROWTYPE   := NULL;
    l_type_freight  type_freights%ROWTYPE   := NULL;
    l_reg_user      users%ROWTYPE           := NULL;
    --
    e_CUSTOMER_INH  EXCEPTION;
    --
    -- controlamos el cliente
    PROCEDURE pp_adm_customer IS  
    BEGIN 
        --
        l_reg_customer := dsc_api_k_customer.get_record( 
            p_customer_co => l_reg_customer.customer_co 
        );
        --
        -- TODO: verificamos que no este inhabilitado
        IF l_reg_customer.k_mca_inh = 'S' THEN 
            --
            -- TODO: lanzamos una exception de cliente no habilitado
            RAISE e_CUSTOMER_INH;
            --
        END IF;
        --
    END pp_adm_customer;
    --
    -- controlamos la ruta
    PROCEDURE pp_adm_route IS 
    BEGIN 
        --
        l_reg_route := lgc_api_k_route.get_record( 
            p_route_co => l_reg_route.route_co 
        );
        --
    END pp_adm_route;
    --
    -- controlamos el tipo de carga
    PROCEDURE pp_adm_type_carga IS 
    BEGIN
        --
        l_reg_cargo := dsc_api_k_typ_cargo.get_record( 
            p_type_cargo_co => l_reg_cargo.type_cargo_co 
        );
        --
    END pp_adm_type_carga;
    --
    -- controlamos el tipo de vehiculos
    PROCEDURE pp_adm_type_vehicle IS 
    BEGIN
        --
        l_reg_vehicle := dsc_api_k_typ_vehicle.get_record( 
            p_type_vehicle_co => l_reg_vehicle.type_vehicle_co 
        );
        --
         -- ! VALIDAR QUE EL TIPO DE VEHICULO SEA COMPATIBLE CON EL TIPO DE CARGA
        --
    END pp_adm_type_vehicle;
    --
    -- controlamos el tipo de viaje
    PROCEDURE pp_adm_type_freight IS 
    BEGIN 
        --
        l_type_freight := dsc_api_k_type_freight.get_record( 
            p_type_freight_co => l_type_freight.type_freight_co 
        );
        --
    END pp_adm_type_freight;
    --
    -- controlamos el usuario
    PROCEDURE pp_adm_user IS 
    BEGIN 
        --
        l_reg_user := sec_api_k_user.get_record( 
            p_user_co => p_user_co
        );
        --
    END pp_adm_user;    
    --
BEGIN 
    --
    -- parametros
    l_reg_customer.customer_co      := p_customer_co;
    l_reg_route.route_co            := p_route_co;
    l_reg_cargo.type_cargo_co       := p_type_cargo_co;
    l_reg_vehicle.type_vehicle_co   := p_type_vehicle_co;
    l_type_freight.type_freight_co  := p_type_freight_co;
    l_reg_freight.freight_co        := p_freight_co;
    l_reg_freight.k_regimen         := p_regimen;
    l_reg_freight.upload_at         := p_upload_at;
    l_reg_freight.notes             := p_notes;
    --
    -- TODO: 1.- invocar un proceso para asinar los parametros a las globales
    -- TODO: 2.- invocar un pre-proceso en PROCESSES
    --
    -- ! este numero es producto de una funcion del controlador
    IF l_reg_freight.freight_co IS NULL THEN 
        l_reg_freight.freight_co  :=  igtp.customers_seq.NEXTVAL;
    ELSE     
        l_reg_freight.freight_co  := p_freight_co; 
    END IF;    
    --
    -- buscamos el cliente
    pp_adm_customer;
    --
    -- buscamos la ruta
    pp_adm_route;
    --
    -- buscamos el tipo de carga
    pp_adm_type_carga;
    --
    -- buscamos el tipo de vehiculo 
    pp_adm_type_vehicle;
    --
    -- buscamos el tipo de viaje
    pp_adm_type_freight;
    --
    -- buscamos el usuario
    pp_adm_user;
    --
    -- completamos el registro
    l_reg_freight.customer_id       := l_reg_customer.id;
    l_reg_freight.route_id          := l_reg_route.id;
    l_reg_freight.type_cargo_id     := l_reg_cargo.id;
    l_reg_freight.type_vehicle_id   := l_reg_vehicle.id;   
    l_reg_freight.k_status          := lgc_api_k_freight.K_STATUS_PLANNED;
    l_reg_freight.k_process         := lgc_api_k_freight.K_PROCESS_LOGISTIC;
    l_reg_freight.user_id           := l_reg_user.id;
    l_reg_freight.type_freight_id   := l_type_freight.id;
    --
    dbms_output.put_line( 'Flete       : ' || l_reg_freight.freight_co );
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
    -- TODO: 3.- invocar un pre-INSERT en PROCESSES
    -- incluimos el registro
    lgc_api_k_freight.ins( p_rec => l_reg_freight );
    --
    COMMIT;
    -- ROLLBACK;
    --
    dbms_output.put_line( 'Registro Exitoso' );
    --
    EXCEPTION 
        WHEN e_CUSTOMER_INH THEN 
            dbms_output.put_line( 
                'Cliente : ' || l_reg_customer.description || ' inhabilitado'
            );
        WHEN NO_DATA_FOUND THEN 
            dbms_output.put_line(sqlerrm);
            dbms_output.put_line('NOT_DATA_FOUND');
        WHEN OTHERS THEN 
            dbms_output.put_line(sqlerrm);    
            ROLLBACK;
END;
/**
    PROPOSITO: Simular la inclusion de un flete
*/
DECLARE 
    --
    -- parametros 
    p_freight_co        freights.freight_co%TYPE            := '71805';
    p_route_co          routes.route_co%TYPE                := '21-22';
    p_user_co           users.user_co%TYPE                  := 'rguerra';
    p_employee_co       employees.employee_co%TYPE          := '106';
    p_truck_co          trucks.truck_co%TYPE                := '34C';
    p_trailer_co        trailers.trailer_co%TYPE            := '31T';
    --
    -- locales
    l_reg_freight   freights%ROWTYPE        := NULL;
    l_reg_transfer  transfers%ROWTYPE       := NULL;
    l_reg_route     routes%ROWTYPE          := NULL;
    l_reg_employee  employees%ROWTYPE       := NULL;
    l_reg_trucks    trucks%ROWTYPE          := NULL;
    l_reg_trailer   trailers%ROWTYPE        := NULL;
    l_reg_user      users%ROWTYPE           := NULL;
    --
    -- excepciones
    e_FREIGHT_NOT_VALID  EXCEPTION;    
    e_EMPLOYEE_NOT_EXIST EXCEPTION;   
    e_TRUCK_NOT_EXIST    EXCEPTION; 
    e_TRAILER_NOT_EXIST  EXCEPTION; 
    --
    -- controlamos el flete
    PROCEDURE pp_adm_freight IS  
    BEGIN 
        --
        l_reg_freight := lgc_api_k_freight.get_record( 
             p_freight_co => p_freight_co
        );
        --
        -- TODO: verificamos que no este INVALIDO
        IF l_reg_freight.k_status = 'INVALID' THEN 
            --
            -- TODO: lanzamos una exception 
            RAISE e_FREIGHT_NOT_VALID;
            --
        ELSIF l_reg_freight.k_status = 'PLANNED' THEN 
            --
            -- TODO: procesar el cambio de estado si es la primera transferencia
            -- TODO: si no es la primera transferencia entonces verificar el estado de las anteriores y ejecutar el cambio de estado
            --
        END IF;
        --
    END pp_adm_freight;
    --
    -- controlamos la ruta
    PROCEDURE pp_adm_route IS 
    BEGIN 
        --
        l_reg_route := lgc_api_k_route.get_record( 
            p_route_co => p_route_co
        );
        --
    END pp_adm_route;
    --
    -- controlamos la employee
    PROCEDURE pp_adm_employee IS 
    BEGIN 
        --
        l_reg_employee := dsc_api_k_employee.get_record( 
            p_employee_co => p_employee_co
        );
        --
        IF l_reg_employee.id IS NULL THEN 
            RAISE e_EMPLOYEE_NOT_EXIST;
        END IF;    
        --
    END pp_adm_employee;   
    --
    -- controlamos la tractomulas
    PROCEDURE pp_adm_truck IS 
    BEGIN 
        --
        l_reg_trucks := dsc_api_k_truck.get_record( 
            p_truck_co => p_truck_co
        );
        --
        IF l_reg_trucks.id IS NULL THEN 
            RAISE e_TRUCK_NOT_EXIST;
        END IF;    
        --
    END pp_adm_truck;       
    --
    -- controlamos la trailer
    PROCEDURE pp_adm_trailer IS 
    BEGIN 
        --
        l_reg_trailer := dsc_api_k_trailer.get_record( 
            p_trailer_co => p_trailer_co
        );
        --
        IF l_reg_trailer.id IS NULL THEN 
            RAISE e_TRAILER_NOT_EXIST;
        END IF;  
        --
    END pp_adm_trailer;  
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
    -------------------------------------------------------------------------------------
    -- TODO: 1.- invocar un proceso para asinar los parametros a las globales
    -- TODO: 2.- invocar un pre-proceso en PROCESSES
    --
    -- buscamos la informacion del viaje
    -- TODO: Verificar si el estado del viaje es PLANNED, para que se ejecute automaticamente
    -- TODO: Verificar si el estado del viaje es EXECUTING, 
    -- TODO: entonces realizar COMMIT a la transferencia anterior si la hubiese
    pp_adm_freight;
    --
    -- buscamos la informacion de la ruta
    pp_adm_route;
    --
    -- buscamos el conductor
    -- TODO: verificar si esta disponible
    pp_adm_employee;
    --
    -- buscamos la tractomula
    -- TODO: verificar si esta disponible
    pp_adm_truck;
    --
    -- buscamos el trailer
    -- TODO: verificar si esta disponible
    pp_adm_trailer;
    --
    -- buscamos el usuario
    pp_adm_user;
    -- 
    -- TRANSFERENCIA, ES UN VECTOR DE VARIOS REGISTOS
    -- incluimos la primera transferencia, logistica 
    l_reg_transfer.freight_id       := l_reg_freight.id;
    l_reg_transfer.k_order          := 1;
    l_reg_transfer.k_type_transfer  := lgc_api_k_transfer.K_TYPE_TRANS_BUSSINES;
    l_reg_transfer.route_id         := l_reg_route.id;
    l_reg_transfer.planed_at        := l_reg_freight.upload_at;
    l_reg_transfer.main_employee_id := l_reg_employee.id;
    --
    -- TODO: Realizar el proceso de busqueda de tractomula y trailer por codigo externo
    l_reg_transfer.truck_id     := l_reg_trucks.id;
    l_reg_transfer.trailer_id   := l_reg_trailer.id;
    l_reg_transfer.user_id      := l_reg_user.id;
    --
    -- incluimos el registro
    -- TODO: 3.- invocar un pre-INSERT en PROCESSES
    lgc_api_k_transfer.ins( p_rec => l_reg_transfer );
    -- TODO: 4.- invocar un post-INSERT en PROCESSES
    --
    dbms_output.put_line( 'Transferencia : ' || l_reg_transfer.sequence_number );
    dbms_output.put_line( 'Ruta          : ' || l_reg_route.description );
    dbms_output.put_line( 'Tipo          : ' || l_reg_transfer.k_type_transfer);
    dbms_output.put_line( 'Estado        : ' || l_reg_transfer.k_status );
    dbms_output.put_line( 'Tractomula    : ' || l_reg_trucks.truck_co );
    dbms_output.put_line( 'Trailer       : ' || l_reg_trailer.trailer_co );
    dbms_output.put_line( 'Tipo de Trans : ' || l_reg_transfer.k_type_transfer );
    dbms_output.put_line( 'Ruta          : ' || l_reg_route.description );
    dbms_output.put_line( 'Conductor     : ' || l_reg_employee.fullname );
    --
    --
    COMMIT;
    --
    -- TODO: 5.- invocar un post-process en PROCESSES
    --
    dbms_output.put_line( 'Registro Exitoso' );
    --
    -- TODO: Realizar un mejor uso de la mensajeria de errores
    EXCEPTION 
        WHEN e_FREIGHT_NOT_VALID THEN 
            dbms_output.put_line( 
                'Flete  : INVALIDO'
            );
        WHEN e_EMPLOYEE_NOT_EXIST THEN 
            dbms_output.put_line( 
                'Conductor : ' || p_employee_co ||' NO EXISTE'
            ); 
        WHEN e_TRUCK_NOT_EXIST THEN 
            dbms_output.put_line( 
                'Tractomula : ' || p_truck_co ||' NO EXISTE'
            ); 
        WHEN e_TRAILER_NOT_EXIST THEN 
            dbms_output.put_line( 
                'Trailer : ' || p_trailer_co ||' NO EXISTE'
            );                                     
        WHEN NO_DATA_FOUND THEN 
            dbms_output.put_line(sqlerrm);
            dbms_output.put_line('NOT_DATA_FOUND');
        WHEN OTHERS THEN 
            dbms_output.put_line(sqlerrm);    
            ROLLBACK;
END;
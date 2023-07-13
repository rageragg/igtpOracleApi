/**
    PROPOSITO: Simular la inclusion de un flete
*/
DECLARE 
    --
    -- parametros 
    p_freight_co        freights.freight_co%TYPE    := '71806';
    p_route_co          routes.route_co%TYPE        := '21-26';
    p_user_co           users.user_co%TYPE          := 'rguerra';
    p_employee_co       employees.employee_co%TYPE  := '109';
    p_truck_co          trucks.truck_co%TYPE        := '43C';
    p_trailer_co        trailers.trailer_co%TYPE    := '60T';
    p_type_transfer     VARCHAR2(20);
    p_status            VARCHAR2(20)                := 'EXECUTING';
    --
    -- locales
    l_reg_freight   freights%ROWTYPE        := NULL;
    --
    l_reg_transfer  transfers%ROWTYPE       := NULL;
    l_tab_transfers lgc_api_k_transfer.transfers_api_tab;
    --
    l_reg_route     routes%ROWTYPE          := NULL;
    l_reg_employee  employees%ROWTYPE       := NULL;
    l_reg_truck     trucks%ROWTYPE          := NULL;
    l_reg_trailer   trailers%ROWTYPE        := NULL;
    l_reg_user      users%ROWTYPE           := NULL;
    --
    -- excepciones
    e_FREIGHT_NOT_VALID  EXCEPTION;  
    e_ROUTE_NOT_EXIST    EXCEPTION;  
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
        IF l_reg_freight.id IS NULL OR l_reg_freight.k_status = 'INVALID' THEN 
            --
            -- TODO: lanzamos una exception 
            RAISE e_FREIGHT_NOT_VALID;
            --
        ELSIF l_reg_freight.k_status IN ( lgc_api_k_freight.K_STATUS_PLANNED, lgc_api_k_freight.K_STATUS_EXECUTING ) THEN 
            --
            -- TODO: procesar el cambio de estado si es la primera transferencia
            -- TODO: si no es la primera transferencia entonces verificar el estado de las anteriores y ejecutar el cambio de estado
            l_tab_transfers.DELETE;
            l_tab_transfers := lgc_api_k_transfer.get_list( 
                p_freight_id => l_reg_freight.id
            );
            --
            -- se verifica si hay transferencias anteriores
            IF l_tab_transfers.COUNT > 0 THEN 
                --
                -- se procesan las transferencias anteriores, se autocompletan
                FOR i IN 1 .. l_tab_transfers.COUNT LOOP 
                    --
                    IF l_tab_transfers(i).k_status = lgc_api_k_transfer.K_STATUS_PLANNED THEN 
                        --
                        -- TRANSFERENCIA PLANEADA
                        --
                        -- se cambia a en EJECUCION
                        l_tab_transfers(i).k_status := lgc_api_k_transfer.K_STATUS_EXECUTING;
                        --
                        IF l_tab_transfers(i).start_at IS NULL THEN 
                            l_tab_transfers(i).start_at := l_reg_freight.start_at;
                        END IF;   
                        --
                        lgc_api_k_transfer.upd( p_rec => l_tab_transfers(i) );
                        --
                        -- actualizamos el empleado con los recursos asociados
                        l_reg_employee := dsc_api_k_employee.get_record( p_id => l_tab_transfers(i).main_employee_id );
                        l_reg_employee.transfer_id  := l_tab_transfers(i).id;
                        l_reg_employee.truck_id     := l_tab_transfers(i).truck_id;
                        l_reg_employee.trailer_id   := l_tab_transfers(i).trailer_id;
                        l_reg_employee.k_status     := dsc_api_k_employee.K_STATUS_SERVING;
                        dsc_api_k_employee.upd( p_rec => l_reg_employee );
                        --
                        -- actualizamos la tractomula con los recursos asociados
                        l_reg_truck := dsc_api_k_truck.get_record( p_id => l_tab_transfers(i).truck_id );
                        l_reg_truck.transfer_id     := l_tab_transfers(i).id;
                        l_reg_truck.employee_id     := l_tab_transfers(i).main_employee_id;
                        l_reg_truck.k_status        := dsc_api_k_truck.K_STATUS_SERVING;
                        dsc_api_k_truck.upd( p_rec => l_reg_truck );
                        --
                        -- actualizamos el trailer con los recursos asociados
                        l_reg_trailer := dsc_api_k_trailer.get_record( p_id => l_tab_transfers(i).trailer_id );
                        l_reg_trailer.transfer_id   := l_tab_transfers(i).id;
                        l_reg_trailer.employee_id   := l_tab_transfers(i).main_employee_id;    
                        l_reg_trailer.k_status     := dsc_api_k_trailer.K_STATUS_SERVING;
                        dsc_api_k_trailer.upd( p_rec => l_reg_trailer );  
                        --
                    ELSIF l_tab_transfers(i).k_status = lgc_api_k_transfer.K_STATUS_EXECUTING THEN 
                        --
                        -- TRANSFERENCIA EJECUTANDOSE
                        --
                        -- se completa o se finaliza de forma automatica
                        l_tab_transfers(i).k_status   := lgc_api_k_transfer.K_STATUS_COMMIT;
                        --
                        IF l_tab_transfers(i).end_at IS NULL THEN 
                            l_tab_transfers(i).end_at := l_reg_freight.finish_at;
                        END IF;   
                        --
                        -- incluimos el registro
                        lgc_api_k_transfer.upd( p_rec => l_tab_transfers(i) );
                        --
                        -- actualizamos el empleado, liberamos el recurso
                        l_reg_employee := dsc_api_k_employee.get_record( p_id => l_tab_transfers(i).main_employee_id );
                        l_reg_employee.transfer_id  := NULL;
                        l_reg_employee.truck_id     := NULL;
                        l_reg_employee.trailer_id   := NULL;
                        l_reg_employee.k_status     := dsc_api_k_employee.K_STATUS_AVAILABLE;
                        dsc_api_k_employee.upd( p_rec => l_reg_employee );
                        --
                        -- actualizamos la tractomula, liberamos el recurso
                        l_reg_truck := dsc_api_k_truck.get_record( p_id => l_tab_transfers(i).truck_id );
                        l_reg_truck.transfer_id     := NULL;
                        l_reg_truck.employee_id     := NULL;
                        l_reg_truck.k_status        := dsc_api_k_truck.K_STATUS_AVAILABLE;
                        dsc_api_k_truck.upd( p_rec => l_reg_truck );
                        --
                        -- actualizamos el trailer, liberamos el recurso
                        l_reg_trailer := dsc_api_k_trailer.get_record( p_id => l_tab_transfers(i).trailer_id );
                        l_reg_trailer.transfer_id   := NULL;
                        l_reg_trailer.employee_id   := NULL;    
                        l_reg_trailer.k_status      := dsc_api_k_trailer.K_STATUS_AVAILABLE;
                        dsc_api_k_trailer.upd( p_rec => l_reg_trailer ); 
                        --
                    END IF;
                    --
                END LOOP; 
                --
            ELSE
                --
                l_reg_freight.k_status := lgc_api_k_freight.K_STATUS_EXECUTING;
                l_reg_freight.start_at := l_reg_freight.upload_at;
                lgc_api_k_freight.upd( p_rec => l_reg_freight );
                --    
            END IF;
            --
        ELSIF l_reg_freight.k_status = lgc_api_k_freight.K_STATUS_ELIMINATED THEN 
           --
            -- TODO: lanzamos una exception 
            RAISE e_FREIGHT_NOT_VALID;
            --
        ELSIF l_reg_freight.k_status = lgc_api_k_freight.K_STATUS_ARCHIVED THEN 
           --
            -- TODO: lanzamos una exception 
            RAISE e_FREIGHT_NOT_VALID;
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
        IF l_reg_route.id IS NULL THEN 
            RAISE e_ROUTE_NOT_EXIST;
        END IF;    
        --
        --
        IF l_reg_route.id <> l_reg_freight.route_id THEN 
            --
            p_type_transfer := lgc_api_k_transfer.K_TYPE_TRANS_LOGITIC;
            --
        ELSE  
            --  
            p_type_transfer := lgc_api_k_transfer.K_TYPE_TRANS_BUSSINES;
            --
        END IF;    
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
        l_reg_truck := dsc_api_k_truck.get_record( 
            p_truck_co => p_truck_co
        );
        --
        IF l_reg_truck.id IS NULL THEN 
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
    l_reg_transfer.k_type_transfer  := p_type_transfer;
    -- 
    -- TODO: Si se esta ejecutando se debe asociar los recursors
    l_reg_transfer.k_status         := p_status;
    --
    l_reg_transfer.route_id         := l_reg_route.id;
    l_reg_transfer.planed_at        := l_reg_freight.upload_at;
    l_reg_transfer.main_employee_id := l_reg_employee.id;
    --
    -- TODO: Realizar el proceso de busqueda de tractomula y trailer por codigo externo
    l_reg_transfer.truck_id     := l_reg_truck.id;
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
    dbms_output.put_line( 'Tractomula    : ' || l_reg_truck.truck_co );
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
        WHEN e_ROUTE_NOT_EXIST THEN 
            dbms_output.put_line( 
                'Ruta  : INVALIDA'
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
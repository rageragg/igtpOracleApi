/**
    PROPOSITO: Simular la inclusion de una ruta
*/
DECLARE 
    --
    -- locales
    l_reg_from_city   cities%ROWTYPE        := NULL;
    l_reg_to_city     cities%ROWTYPE        := NULL;
    l_reg_route       routes%ROWTYPE        := NULL;
    --
BEGIN 
    --
    -- buscamos la ciudad origen
    l_reg_from_city.city_co := 'LAR-BQTO';
    l_reg_from_city := cfg_api_k_city.get_record( p_city_co => l_reg_from_city.city_co );
    --
    -- buscamos la ciudad destino
    l_reg_to_city.city_co := 'LAR-ETYO';
    l_reg_to_city := cfg_api_k_city.get_record( p_city_co => l_reg_to_city.city_co );    
    --
    -- completamos el registro
    l_reg_route.from_city_id        := l_reg_from_city.id;
    l_reg_route.to_city_id          := l_reg_to_city.id;
    l_reg_route.description         := 'BARQUISIMETO - EL TOCUYO (LAR)';
    l_reg_route.route_co            := l_reg_from_city.id ||'-'||l_reg_to_city.id;
    l_reg_route.k_level_co          := 'C';
    l_reg_route.distance_km         :=  64;
    l_reg_route.estimated_time_hrs  :=  1;
    l_reg_route.slug                :=  'lar-bqto-etyo';
    l_reg_route.uuid                :=  sys_k_utils.f_uuid;
    l_reg_route.user_id             :=  1;
    --
    dbms_output.put_line( 'Descripcion : ' || l_reg_route.description );
    dbms_output.put_line( 'Codigo      : ' || l_reg_route.route_co );
    dbms_output.put_line( 'Desde       : ' || l_reg_from_city.description );
    dbms_output.put_line( 'Hasta       : ' || l_reg_to_city.description );
    dbms_output.put_line( 'Distancia   : ' || l_reg_route.distance_km );
    --
    -- incluimos el registro
    lgc_api_k_route.ins( p_rec => l_reg_route );
    --
    dbms_output.put_line( 'Codigo ID: '||l_reg_route.id );
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
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
    l_reg_from_city.city_co := 'YAR-YRTA';
    l_reg_from_city := cfg_api_k_city.get_record( p_city_co => l_reg_from_city.city_co );
    --
    -- buscamos la ciudad destino
    l_reg_to_city.city_co := 'MIR-OCU';
    l_reg_to_city := cfg_api_k_city.get_record( p_city_co => l_reg_to_city.city_co );    
    --
    -- completamos el registro
    l_reg_route.from_city_id        := l_reg_from_city.id;
    l_reg_route.to_city_id          := l_reg_to_city.id;
    l_reg_route.description         := 'YARITAGUA-OCUMARE DEL TUY';
    l_reg_route.route_co            := l_reg_from_city.id ||'-'||l_reg_to_city.id;
    l_reg_route.k_level_co          := 'A';
    l_reg_route.distance_km         :=  334.6;
    l_reg_route.estimated_time_hrs  :=  4;
    l_reg_route.slug                :=  'yrta-ocudt';
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
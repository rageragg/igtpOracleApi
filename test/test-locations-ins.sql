DECLARE 
    --
    /**
        PROPOSITO: Simular la inclusion de una locacion
    */
    -- locales
    l_reg_location locations%ROWTYPE   := NULL;
    l_reg_city      cities%ROWTYPE      := NULL;
    --
BEGIN 
    --
    l_reg_city.city_co := 'LAR-CDE';
    l_reg_city := cfg_api_k_city.get_record( p_city_co => l_reg_city.city_co );
    --
    l_reg_location.location_co  := 'CDE-CTRO';
    l_reg_location.description  := 'CABUDARE CENTRO';
    l_reg_location.postal_co    := l_reg_city.postal_co;
    l_reg_location.city_id      := l_reg_city.id;
    l_reg_location.uuid         := sys_k_utils.f_uuid();
    l_reg_location.slug         := 'ven-occ-lar-cde-ctro';
    l_reg_location.user_id      := 1;
    --
    dbms_output.put_line('Ciudad     : ' || l_reg_city.description );
    dbms_output.put_line('Locacion   : ' || l_reg_location.location_co );
    dbms_output.put_line('Descripcion: ' || l_reg_location.description );
    dbms_output.put_line('Postal     : ' || l_reg_location.postal_co );
    --
    cfg_api_k_location.ins( p_rec => l_reg_location );
    --
    dbms_output.put_line('Codigo     : ' || l_reg_location.id );
    --
    COMMIT;
    --
    dbms_output.put_line( 'Registro Exitoso' );
    --
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            dbms_output.put_line('NOT_DATA_FOUND');
            ROLLBACK;
        WHEN OTHERS THEN 
            dbms_output.put_line(sqlerrm);    
            ROLLBACK;
END;
DECLARE 
    --
    /**
        PROPOSITO: Simular la inclusion de una tiendas
    */
    -- locales
    l_reg_municipality municipalities%ROWTYPE   := NULL;
    l_reg_city         cities%ROWTYPE           := NULL;
    --
BEGIN 
    --
    -- TODO: validaciones de que exista la localidad
    l_reg_municipality.municipality_co := 'LAR-MOR';
    l_reg_municipality := cfg_api_k_municipality.get_record( p_municipality_co => l_reg_municipality.municipality_co );
    --
    -- TODO: validaciones de codigo no se repita
    l_reg_city.city_co          := 'LAR-ETYO';
    l_reg_city.description      := 'EL TOCUYO (LAR)';
    l_reg_city.municipality_id  := l_reg_municipality.id;
    l_reg_city.postal_co        := 3018;
    --
    l_reg_city.nu_gps_lat	    := 9.782222;
    l_reg_city.nu_gps_lon	    := -69.793056;
    l_reg_city.telephone_co	    := '251';
    l_reg_city.uuid             := sys_k_utils.f_uuid();
    l_reg_city.slug             := 'ven-occ-lar-etyo';
    l_reg_city.user_id          := 1;
    --
    dbms_output.put_line('Municipalidad: ' || l_reg_municipality.description );
    dbms_output.put_line('Postal      : ' || l_reg_city.postal_co );
    dbms_output.put_line('Codigo      : ' || l_reg_city.city_co  );
    dbms_output.put_line('Descripcion : ' || l_reg_city.description  );
    --
    cfg_api_k_city.ins( p_rec => l_reg_city );
    --
    dbms_output.put_line('ID          : ' || l_reg_city.id  );
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
DECLARE
    --
    -- datos del documento
    r_locacion_data         igtp.prs_k_api_location.location_api_doc;
    l_result        VARCHAR2(2048);
    l_ins_ok        BOOLEAN;
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Ciudades');
    -- TEST DE PROCESO DE INCLUIR UNA CIUDAD
    --
    dbms_output.put_line( '1.- llenado de documento');
    -- llenado de documento
    r_locacion_data.p_location_co := 'XXX-XXX';
    r_locacion_data.p_description := 'ELIMINAR';
    r_locacion_data.p_postal_co   := '000S';
    r_locacion_data.p_city_co     := 'ACGUA';
    r_locacion_data.p_uuid        := NULL;
    r_locacion_data.p_slug        := NULL;
    r_locacion_data.p_nu_gps_lat  := 0.222;
    r_locacion_data.p_nu_gps_lon  := 0.111;
    r_locacion_data.p_user_co     := 'RGUERRA';
    --
    --
    dbms_output.put_line( '2.- Eliminar Localidad');
    igtp.prs_k_api_location.delete_location(
        p_location_co   => r_locacion_data.p_location_co,
        p_result        => l_result
    );
    --
    COMMIT;
    --
    dbms_output.put_line( 'l_result: ' || l_result );
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            IF l_result IS NULL THEN 
              l_result := SQLERRM;
            END IF;
            dbms_output.put_line( 'Error: ' || l_result );
    --
END;
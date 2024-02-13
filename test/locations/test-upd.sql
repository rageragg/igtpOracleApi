DECLARE
    --
    -- datos del documento
    r_locacion_data         igtp.prs_k_api_location.location_api_doc;
    l_result        VARCHAR2(2048);
    l_ins_ok        BOOLEAN;
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Locacion');
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
    dbms_output.put_line( '2.- Actualizando Locacion');
    igtp.prs_k_api_location.update_location(
        p_rec       => r_locacion_data,
        p_result    => l_result
    );
    /*
    igtp.prs_k_api_location.update_location(
        p_location_co       => r_locacion_data.p_location_co,
        p_description       => r_locacion_data.p_description,
        p_postal_co         => r_locacion_data.p_postal_co,
        p_city_co           => r_locacion_data.p_city_co,
        p_uuid              => r_locacion_data.p_uuid,
        p_slug              => r_locacion_data.p_slug,
        p_nu_gps_lat 		=> r_locacion_data.p_nu_gps_lat,
	    p_nu_gps_lon 		=> r_locacion_data.p_nu_gps_lon,
        p_user_co           => r_locacion_data.p_user_co,
        p_result            => l_result
    );
    */
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
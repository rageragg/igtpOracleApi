DECLARE
    --
    -- datos del documento
    r_city_data         igtp.prs_api_k_city.city_api_doc;
    r_municipality_data igtp.municipalities%ROWTYPE;
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
    r_city_data.p_city_co           := 'BOL-CBOL';
    r_city_data.p_description       := 'CIUDAD BOLIVAR (Bolivar)';
    r_city_data.p_telephone_co      := '000';
    r_city_data.p_postal_co         := '0000';
    r_city_data.p_municipality_co   := 'BOL-CRN';
    r_city_data.p_uuid              := NULL;
    r_city_data.p_slug              := NULL;
    r_city_data.p_user_co           := 'RGUERRA';
    --
    --
    dbms_output.put_line( '2.- Incluir ciudad');
    /*
    igtp.prs_k_api_city.create_city(
        p_rec       => r_city_data,
        p_result    => l_result
    );
    */
    igtp.prs_api_k_city.create_city(
        p_city_co           => r_city_data.p_city_co,
        p_description       => r_city_data.p_description,
        p_telephone_co      => r_city_data.p_telephone_co,
        p_postal_co         => r_city_data.p_postal_co,
        p_municipality_co   => r_city_data.p_municipality_co,
        p_uuid              => r_city_data.p_uuid,
        p_slug              => r_city_data.p_slug,
        p_user_co           => r_city_data.p_user_co,
        p_result            => l_result
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
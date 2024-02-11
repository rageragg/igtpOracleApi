DECLARE
    --
    -- datos del documento
    r_city_data         igtp.prs_k_api_city.city_api_doc;
    r_municipality_data municipalities.municipality_co%TYPE;
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
    r_city_data.p_city_co           := 'SFAP';
    r_city_data.p_description       := 'SAN FERNANDO DE APURE';
    r_city_data.p_telephone_co      := '247';
    r_city_data.p_postal_co         := '7001';
    r_city_data.p_municipality_co   := 'SFAP';
    r_city_data.p_uuid              := NULL;
    r_city_data.p_slug              := 'ven-lla-apu-sfap';
    r_city_data.p_user_co           := 1;
    --
    dbms_output.put_line( 'PROBANDO');
    IF NOT cfg_api_k_municipality.exist( p_municipality_co =>  r_city_data.p_municipality_co ) THEN
        --
        NULL;
        --
    END IF;
    /*
    --
    dbms_output.put_line( '2.- Incluir ciudad');
    igtp.prs_k_api_city.create_city(
        p_rec       => r_city_data,
        p_result    => l_result
    );
    --
    COMMIT;
    --
    dbms_output.put_line( 'l_result: ' || l_result );
    --
    */
    EXCEPTION 
        WHEN OTHERS THEN 
            IF l_result IS NULL THEN 
              l_result := SQLERRM;
            END IF;
            dbms_output.put_line( 'Error: ' || l_result );
    --
END;
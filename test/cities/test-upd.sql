DECLARE
    --
    -- datos del documento
    r_city              igtp.cities%ROWTYPE;
    r_city_data         igtp.prs_api_k_city.city_api_doc;
    r_municipality_data igtp.municipalities%ROWTYPE;
    l_result        VARCHAR2(2048);
    l_ins_ok        BOOLEAN;
    --
    l_obj       json_object_t;
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Ciudades');
    -- TEST DE PROCESO DE INCLUIR UNA CIUDAD
    --
    dbms_output.put_line( '1.- llenado de documento');
    --
    -- seleccionamos una ciudad
    r_city_data := igtp.prs_api_k_city.get_record( 
        p_city_co => 'BOL-CBOL',
        p_result  => l_result
    );
    --
    l_obj       := json_object_t.parse(l_result);
    l_result    := NULL;
    --
    IF l_obj.get_string('status') = 'OK' THEN 
        --
        -- llenado de documento
        r_city_data.p_telephone_co      := '286';
        r_city_data.p_postal_co         := '80501';
        --
        dbms_output.put_line( '2.- Actualizando ciudad');
        --
        dbms_output.put_line(
            'p_city_co           => ' || r_city_data.p_city_co || chr(13) ||
            'p_description       => ' || r_city_data.p_description || chr(13) ||
            'p_telephone_co      => ' || r_city_data.p_telephone_co || chr(13) ||
            'p_postal_co         => ' || r_city_data.p_postal_co || chr(13) ||
            'p_municipality_co   => ' || r_city_data.p_municipality_co || chr(13) ||
            'p_uuid              => ' || r_city_data.p_uuid || chr(13) ||
            'p_slug              => ' || r_city_data.p_slug || chr(13) ||
            'p_user_co           => ' || r_city_data.p_user_co || chr(13) ||
            'p_result            => ' || l_result
        );
        --
        igtp.prs_api_k_city.update_city(
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
        l_obj       := json_object_t.parse(l_result);
        l_result    := NULL;
        --
        IF l_obj.get_string('status') = 'OK' THEN 
            --
            COMMIT;
            --
            dbms_output.put_line( 'SUCCESS' );
            --
        ELSE
            --
            ROLLBACK;
            --
            dbms_output.put_line( l_obj.get_string('message') );
            --
        END IF;
        --
    END IF;
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            IF l_result IS NULL THEN 
              l_result := SQLERRM;
            END IF;
            dbms_output.put_line( 'Error: ' || l_result );
    --
END;
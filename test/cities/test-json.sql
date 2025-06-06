DECLARE
    --
    -- datos del documento
    l_result        VARCHAR2(4096);
    json_city       JSON_OBJECT_T;
    json_city_doc   JSON_OBJECT_T;
    l_json_result   JSON_OBJECT_T;
    l_cities        JSON_ARRAY_T;
    l_locations     JSON_ARRAY_T;
    l_element       JSON_ELEMENT_T;
    --
    l_municipality  municipalities%ROWTYPE;
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Ciudades');
    --
    dbms_output.put_line( '1.- invocacion de API-JSON');
    --
    -- seleccionamos una ciudad
    json_city := igtp.json_api_k_city.get_json( 
        p_id      => 22,
        p_result  => l_result
    );
    --
    l_json_result := JSON_OBJECT_T.parse(l_result);
    --
    IF l_json_result.get_string('status') = 'OK' THEN 
        --
        --
        dbms_output.put_line( 'Descripcion: ' || json_city.get_string('description') );
        --
        -- procesando el objeto JSON_ARRAY l_locations
        IF json_city.has('locations') THEN 
            --
            l_locations := json_city.get_array('locations');
            --
            FOR i in 0..l_locations.get_size-1 LOOP
                --
                dbms_output.put_line( 'Location: ' || l_locations.get(i).to_string );
                --
            END LOOP;
            --
        END IF;
        --
    ELSE
        --
        dbms_output.put_line( 'Result: ' || l_result );
        --
    END IF;
    --
    -- seleccionamos una ciudad
    json_city_doc := igtp.prs_api_k_city.get_json( 
        p_city_co => 'ZUL-MCBO',
        p_result  => l_result
    );
    --
    l_json_result := JSON_OBJECT_T.parse(l_result);
    --
    IF l_json_result.get_string('status') = 'OK' THEN 
        --
        dbms_output.put_line( 'JSON: ' || json_city_doc.stringify );
        --
        IF json_city_doc.has('p_locations') THEN 
            --
            l_locations := json_city_doc.get_array('p_locations');
            --
            FOR i in 0..l_locations.get_size-1 LOOP
                --
                l_municipality := cfg_api_k_municipality.get_record( 
                    p_id => l_locations.get(i).to_number
                );
                --
                dbms_output.put_line( 
                    'Location: (' || l_locations.get(i).to_string || ') ' || 
                    l_municipality.municipality_co || ' - ' || l_municipality.description 
                );
                --
            END LOOP;
            --
        END IF;
        --
    END IF;
    --
    -- lista de json
    l_cities := igtp.json_api_k_city.get_list( 
        p_result => l_result
    );
    --
    l_json_result := JSON_OBJECT_T.parse(l_result);
    --
    IF l_json_result.get_string('status') = 'OK' THEN 
        --
        DBMS_OUTPUT.PUT_LINE('Cantidad : ' || l_cities.get_size);
        --
        /*
        FOR i IN 0 .. l_cities.get_size - 1 LOOP
            l_element :=  l_cities.get(i);
            DBMS_OUTPUT.PUT_LINE('Ciudad ' || (i+1) || ': ' || l_element.to_string);
        END LOOP;
        */
    ELSE
        --
        dbms_output.put_line( 'Result: ' || l_result );
        --
    END IF;
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            --
            IF l_result IS NULL THEN 
              l_result := SQLERRM;
            END IF;
            --
            dbms_output.put_line( 'Error: ' || l_result );
    --
END;
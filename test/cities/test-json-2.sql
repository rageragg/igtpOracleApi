DECLARE
    --
    -- datos del documento
    l_result        VARCHAR2(4096);
    l_cities        JSON_ARRAY_T;
    l_city          JSON_OBJECT_T;
    l_element       JSON_ELEMENT_T;
    l_json_result   JSON_OBJECT_T;
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Ciudades');
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
        FOR i IN 0 .. l_cities.get_size - 1 LOOP
            --
            l_element :=  l_cities.get(i);
            -- l_city := treat (l_element AS JSON_OBJECT_T);
            --
            dbms_output.put_line(
                'Ciudad ' || (i+1) || ': ' ||  l_element.get_string('description') 
            );
            --    
        END LOOP;
        --
    ELSE
        --
        dbms_output.put_line( 'Result: ' || l_result );
        --
    END IF;
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            --
            IF l_result IS NULL OR l_json_result.get_string('status') = 'OK' THEN 
              l_result := SQLERRM;
            END IF;
            --
            dbms_output.put_line( 'Error: ' || l_result );
    --
END;
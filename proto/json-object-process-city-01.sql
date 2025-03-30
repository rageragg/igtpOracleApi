declare
    --
    -- parametros
    p_city_co   igtp.cities.city_co%TYPE := 'MIR-CHVE';
    --
    l_result    VARCHAR2(4096);
    json_city   JSON_OBJECT_T;
    reg_city    igtp.prs_api_k_city.city_api_doc;
    --
    /*
        address     JSON_OBJECT_T;
        locations   JSON_ARRAY_T;
        location    JSON_OBJECT_T;
        zip     number;
    */
    --
begin
    --
    -- objeto JSON de ejemplo
    json_city := new JSON_OBJECT_T('{}'); 
    --
    -- obtenemos los datos de la ciudad
    reg_city := igtp.prs_api_k_city.get_record(
        p_city_co   => p_city_co,
        p_result    => l_result
    );
    --
    -- TODO: debemos obtener el patron de datos de la base de datos
    -- constriumos el objeto JSON
    json_city.put('city_co', reg_city.p_city_co);
    json_city.put('description', reg_city.p_description);
    json_city.put('telephone_co', reg_city.p_telephone_co);
    json_city.put('postal_co', reg_city.p_postal_co);
    json_city.put('municipality_co', reg_city.p_municipality_co);
    json_city.put('uuid', reg_city.p_uuid);
    json_city.put('slug', reg_city.p_slug);     
    json_city.put('nu_gps_lat', reg_city.p_nu_gps_lat);
    json_city.put('nu_gps_lon', reg_city.p_nu_gps_lon);
    json_city.put('user_co', reg_city.p_user_co);
    --
    dbms_output.put_line(json_city.to_string);
    --
    /*
        --
        -- procesando el objeto JSON address
        if data.has('address') then 
            --
            address := data.get_object('address');
            dbms_output.put_line(address.to_string);
            --
            -- 1) VALUE SEMANTICS for scalar values 
            -- (changing the value has no effect on container)
            zip := address.get_number('zip');
            dbms_output.put_line(zip);
            --
            zip := 12345;
            dbms_output.put_line(zip);
            --
            -- address is still the same
            dbms_output.put_line(address.to_string);
            -- 2) REFERENCE SEMANTICS for complex values
            --    'address' is a reference to the complex address values inside 'data'
            address.put('zip', 12345);
            address.put('street', 'Detour Road');
            dbms_output.put_line(data.to_string);
            --
        end if;
        --
        -- procesando el objeto JSON_ARRAY locations
        if data.has('locations') then 
            --
            -- se clona el array JSON para evitar que se modifique el original
            locations := data.get_array('locations').clone;
            dbms_output.put_line(locations.to_string);
            --
            for i in 0..locations.get_size-1 loop
                --
                dbms_output.put_line('Location: ' || (i+1) );
                --
                location := treat(locations.get(i) AS JSON_OBJECT_T);
                --
                if location is not null and location.has('city') then 
                    dbms_output.put_line('City    : ' || location.get_string('city'));
                    dbms_output.put_line('State   : ' || location.get_string('state'));
                else
                    dbms_output.put_line('City    : NULL' );
                end if;
                --
                -- dbms_output.put_line( treat(locations.get(i) AS JSON_OBJECT_T).get_string('city') );
                -- dbms_output.put_line('Location: ' || location.to_string);
                --
                -- dbms_output.put_line('Location: ' || i || ': ' || locations.get(i).to_string);
                -- dbms_output.put_line('City    : ' || locations.get(i).get_string('city'));
                -- dbms_output.put_line('State   : ' || locations.get(i).get_string('state'));
                --
                -- dbms_output.put_line('City    : ' || location.get_string('city'));
                -- dbms_output.put_line('State   : ' || location.get_string('State'));
                --
            end loop;
            --
            --
        end if;
        --
    */
end;

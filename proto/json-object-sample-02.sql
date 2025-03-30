declare
    --
    data        JSON_OBJECT_T;
    address     JSON_OBJECT_T;
    locations   JSON_ARRAY_T;
    location    JSON_OBJECT_T;
    zip     number;
    --
begin
    --
    -- objeto JSON de ejemplo
    data := new JSON_OBJECT_T('{
            "first": "John",
            "last": "Doe",
            "address": {
                "country": "USA",
                "zip": "94065"
            },
            "locations": [
                {
                    "city": "San Francisco",
                    "state": "CA"
                },
                {
                    "city": "New York",
                    "state": "NY"
                }
            ]
        }'
    ); 
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
end;

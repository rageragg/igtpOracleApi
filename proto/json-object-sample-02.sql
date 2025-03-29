declare
    --
    data    JSON_OBJECT_T;
    address JSON_OBJECT_T;
    zip     number;
    --
begin
    --
    data := new JSON_OBJECT_T('{
            "first": "John",
            "last": "Doe",
            "address": {
                "country": "USA",
                "zip": "94065"
            }
        }'
    ); 
    --
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
end;

declare 
    l_json      VARCHAR2(32000);
    l_obj       JSON_OBJECT_T;
    l_key_list  json_key_list; 
begin 
    --
    l_json := '{ "nombre":"Ronald", "apellido":"Guerra"}';
    l_obj  := json_object_t.parse(l_json);
    --
    l_key_list := l_obj.get_keys; 
    --
    FOR counter IN 1 .. l_key_list.COUNT 
    LOOP 
        --
        DBMS_OUTPUT.put_line ( 
             l_key_list (counter) 
        ); 
        --
    END LOOP; 
    --
    dbms_output.put_line( l_obj.get_string('nombre') );
    --
end;
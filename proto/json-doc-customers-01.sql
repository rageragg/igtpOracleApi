declare 
    l_json      VARCHAR2(32000);
    l_obj       json_object_t;
    l_key_list  json_key_list; 
    l_array     json_array_t;
    l_obj_subs  json_object_t;
begin 
    --
    l_json := trim('{ "customer_co":"MKR", 
                 "description":"MAKRO DE VENEZUELA",
                 "k_type_customer": "F",
                 "location_co": "CCS-002",
                 "address": "Av. Intercomunal de Antimano, Cruce con Av. Principal de La Yaguara, Parroquia la Vega, Caracas",
                 "telephone_co": "212",
                 "fax_co":"212",
                 "email":"makro@makro.com",
                 "fiscal_document_co":"RIF",
                 "k_category_co":"A",
                 "k_sector":"FOODS",
                 "name_contact":"RONALD GUERRA",
                 "telephone_contact":"+584245160109",
                 "email_contact":"rguerra@makro.com",
                 "slug":"ven-ctr-mkr",
                 "user_co":"RAGE",
                 "k_mca_inh":"N",
                 "subsidiaries": [
                    { "subsidiary_co":"MKR01", "subsidiary_co":"MKR01","slug":"ven-ctr-mkr-mkr01" },
                    { "subsidiary_co":"MKR02", "subsidiary_co":"MKR02","slug":"ven-ctr-mkr-mkr02" },
                    { "subsidiary_co":"MKR03", "subsidiary_co":"MKR03","slug":"ven-ctr-mkr-mkr03" }
                 ]
               }');   
    --
    l_obj   := json_object_t.parse(l_json);
    --
    l_key_list := l_obj.get_keys; 
    --
    -- lista las claves existentes
    FOR counter IN 1 .. l_key_list.COUNT 
    LOOP 
        --
        -- verifica las subsidiarias del cliente
        IF l_key_list(counter) = 'subsidiaries' THEN 
            -- 
            l_array := l_obj.get_array('subsidiaries');
            --
        END IF;
        --
    END LOOP; 
    --
    -- verificamos las subsidiarias del cliente
    FOR counter IN 0 .. l_array.get_size - 1
    LOOP
        --
        l_obj_subs := json_object_t(l_array.get(counter));
        dbms_output.put_line( l_obj_subs.get_string('subsidiary_co') );
        --
    END LOOP;
    --
    dbms_output.put_line( l_obj.get_string('description') );
    --
end;
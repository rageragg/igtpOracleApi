declare 
    l_json      VARCHAR2(32000);
    l_obj       json_object_t;
    l_key_list  json_key_list; 
    l_array     json_array_t;
    l_obj_subs  json_object_t;
    --
    r_customer  prs_api_k_customer.customer_api_doc;
    l_result    VARCHAR2(512);
    l_ok        BOOLEAN;
    --
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
    -- completamos los datos del registro customer
    r_customer.customer_co        := l_obj.get_string('customer_co');
    r_customer.description        := l_obj.get_string('description');
    r_customer.telephone_co       := l_obj.get_string('telephone_co');
    r_customer.fax_co             := l_obj.get_string('fax_co');
    r_customer.email              := l_obj.get_string('email');
    r_customer.address            := l_obj.get_string('address');
    r_customer.k_type_customer    := l_obj.get_string('k_type_customer');
    r_customer.k_sector           := l_obj.get_string('k_sector');
    r_customer.k_category_co      := l_obj.get_string('k_category_co');
    r_customer.fiscal_document_co := l_obj.get_string('fiscal_document_co');
    r_customer.location_co        := l_obj.get_string('location_co');
    r_customer.telephone_contact  := l_obj.get_string('telephone_contact');
    r_customer.name_contact       := l_obj.get_string('name_contact');
    r_customer.email_contact      := l_obj.get_string('email_contact');
    r_customer.slug               := l_obj.get_string('slug');
    r_customer.user_co            := l_obj.get_string('user_co');
    --
    l_ok := prs_api_k_customer.ins( 
        p_rec       => r_customer,
        p_result    => l_result
    );
    --
    -- verificacion de resultado
    IF NOT l_ok THEN 
        --
        dbms_output.put_line(l_result);
        ROLLBACK;
        --
    ELSE
        --
        COMMIT;
        --
    END IF;
    --
end;
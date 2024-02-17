DECLARE
    --
    -- datos del documento
    r_customer_doc igtp.prs_api_k_customer.customer_api_doc;
    l_result        VARCHAR2(1024);
    l_ins_ok        BOOLEAN;
    l_json          VARCHAR2(32000);
    --
BEGIN 
    --
    -- TEST DE PROCESO DE INCLUIR UN CLIENTE
    --
    -- llenado de documento
    r_customer_doc.p_customer_co           := 'XXX';
    r_customer_doc.p_description           := 'ELIMINAR.';
    r_customer_doc.p_telephone_co          := '+XXXXX-XXXXXXX';
    r_customer_doc.p_fax_co                := '';
    r_customer_doc.p_email                 := 'xxxxxx@gmail.com';
    r_customer_doc.p_address               := 'XXXXXXXXXXXXXXXXXXX';
    r_customer_doc.p_k_type_customer       := 'M';
    r_customer_doc.p_k_sector              := 'XXXXXXXX';
    r_customer_doc.p_k_category_co         := 'C';
    r_customer_doc.p_fiscal_document_co    := 'XX-000000';
    r_customer_doc.p_location_co           := 'BQTO-CTRO';
    r_customer_doc.p_telephone_contact     := '+XXXXX-XXXXXXX';
    r_customer_doc.p_name_contact          := 'XXXXXXXX';
    r_customer_doc.p_email_contact         := 'xxxxxx@gmail.com';
    r_customer_doc.p_slug                  := 'ven-occ-lar-bqto-xxxxx';
    r_customer_doc.p_user_co               := 'RGUERRA';
    --
    -- jSON
    l_json := '{ "customer_co":"XXX",'||
              '  "description":"ELIMINAR",'||
              '  "telephone_co":"+XXXXX-XXXXXXX",'||
              '  "fax_co":"",'||
              '  "email":"xxxxxx@gmail.com",'||
              '  "address":"XXXXXXXXXXXXXXXXXXX",'||
              '  "k_type_customer":"M",'||
              '  "k_sector":"XXXXXXXX",'||
              '  "k_category_co":"C",'||
              '  "fiscal_document_co":"XX-000000",'||
              '  "location_co":"BQTO-CTRO",'||
              '  "telephone_contact":"+XXXXX-XXXXXXX",'||
              '  "name_contact":"XXXXXXXX",'||
              '  "email_contact":"xxxxxx@gmail.com",'||
              '  "slug":"ven-occ-lar-bqto-xxxxx",'||
              '  "user_co":"RGUERRA"';
    --
    l_json := l_json || '}';
    /*
        -- test REC
        prs_api_k_customer.create_customer(
            p_rec       => r_customer_doc,
            p_result    => l_result
        );
    */
    --
    -- TEST JSON
    prs_api_k_customer.create_customer(
        p_json      => l_json,
        p_result    => l_result
    );
    --
    COMMIT;
    --
    dbms_output.put_line( l_result );
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line( l_result );
    --
END;
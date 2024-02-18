DECLARE
    --
    -- datos del documento
    r_shop_doc      igtp.prs_api_k_shop.shop_api_doc;
    l_result        VARCHAR2(1024);
    l_ins_ok        BOOLEAN;
    l_json          VARCHAR2(32000);
    --
BEGIN 
    --
    -- TEST DE PROCESO DE INCLUIR UNA TIEDA
    --
    -- llenado de documento
    r_shop_doc.p_shop_co        := 'XXX';
    r_shop_doc.p_description    := 'ELIMINAR';
    r_shop_doc.p_location_co    := 'BQTO-CTRO';
    r_shop_doc.p_address        := 'UNA DIRECCION';
    r_shop_doc.p_nu_gps_lat     := 0.00;
    r_shop_doc.p_nu_gps_lon     := 0.00;
    r_shop_doc.p_telephone_co   := '+00000-0000000';
    r_shop_doc.p_fax_co         := NULL;
    r_shop_doc.p_email          := 'xxxxxx@gmail.com';
    r_shop_doc.p_name_contact   := 'UN CONTACTO';
    r_shop_doc.p_email_contact  := 'xxxxxx@gmail.com';
    r_shop_doc.p_telephone_contact := '+00000-0000000';
    r_shop_doc.p_slug              := NULL;
    r_shop_doc.p_user_co           := 'RGUERRA';
    --
    -- jSON
    l_json := '{ "shop_co":"XXX",'||
              '  "description":"ELIMINAR",'||
              '  "telephone_co":"+XXXXX-XXXXXXX",'||
              '  "fax_co":"",'||
              '  "email":"xxxxxx@gmail.com",'||
              '  "address":"XXXXXXXXXXXXXXXXXXX",'||
              '  "location_co":"BQTO-CTRO",'||
              '  "telephone_contact":"+XXXXX-XXXXXXX",'||
              '  "name_contact":"XXXXXXXX",'||
              '  "email_contact":"xxxxxx@gmail.com",'||
              '  "slug":"ven-occ-lar-bqto-xxxxx",'||
              '  "user_co":"RGUERRA"';
    --
    l_json := l_json || '}';
    -- test REC
    prs_api_k_shop.create_shop(
        p_rec       => r_shop_doc,
        p_result    => l_result
    );
    --
    -- TEST JSON
    /*
        prs_api_k_shop.create_customer(
            p_json      => l_json,
            p_result    => l_result
        );
    */
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
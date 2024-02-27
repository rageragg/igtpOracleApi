DECLARE
    --
    -- datos del documento
    r_shop_doc          igtp.prs_api_k_shop.shop_api_doc;
    r_location_data     igtp.locations%ROWTYPE;
    l_result            VARCHAR2(2048);
    l_ins_ok            BOOLEAN;
    l_json              VARCHAR2(32000);
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Tienda');
    -- TEST DE PROCESO DE INCLUIR UNA CIUDAD
    --
    -- llenado de documento
    r_shop_doc.p_shop_co        := 'XXX';
    r_shop_doc.p_description    := 'ELIMINAR';
    r_shop_doc.p_location_co    := 'BQTO-CTRO';
    r_shop_doc.p_address        := 'UNA DIRECCION';
    r_shop_doc.p_nu_gps_lat     := 0.01;
    r_shop_doc.p_nu_gps_lon     := 0.01;
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
              '  "location_co":"BQTO-CTRO",'||
              '  "address":"XXXXXXXXXXXXXXXXXXX",'||
              '  "nu_gps_lat": 1.00,'||
              '  "nu_gps_lon": -2.00,'||
              '  "telephone_co":"+XXXXX-XXXXXXX",'||
              '  "fax_co":"",'||
              '  "email":"xxxxxx@gmail.com",'||
              '  "name_contact":"XXXXXXXX",'||
              '  "email_contact":"xxxxxx@gmail.com",'||
              '  "telephone_contact":"+XXXXX-XXXXXXX",'||
              '  "slug":"ven-occ-lar-bqto-xxxxx",'||
              '  "user_co":"RGUERRA"';
    --
    l_json := l_json || '}';
    --
    dbms_output.put_line( '2.- Actualizando tienda');
    --
    /*
        igtp.prs_api_k_shop.update_shop(
            p_rec       => r_shop_doc,
            p_result    => l_result
        );
    */
        --
        igtp.prs_api_k_shop.update_shop( 
            p_json      => l_json,
            p_result    => l_result
        );
    --
    COMMIT;
    --
    dbms_output.put_line( l_json );
    --
    dbms_output.put_line( 'l_result: ' || l_result );
    --
    EXCEPTION 
        WHEN OTHERS THEN 
            IF l_result IS NULL THEN 
              l_result := SQLERRM;
            END IF;
            dbms_output.put_line( 'Error: ' || l_result );
    --
END;
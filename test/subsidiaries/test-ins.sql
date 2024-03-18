DECLARE
    --
    -- datos del documento
    r_subsidiary_doc    prs_api_k_subsidiary.subsidiary_api_doc;
    l_result            VARCHAR2(1024);
    l_ins_ok            BOOLEAN;
    l_json              VARCHAR2(32000);
    --
    l_type_test         CHAR(1) := 'J';   -- R -> RECORD, J -> JSON
    --
BEGIN 
    --
    -- TEST DE PROCESO DE INCLUIR UNA SUBSIDIARIA
    --
    -- llenado de documento
    r_subsidiary_doc.p_subsidiary_co :=  'XXX';
    r_subsidiary_doc.p_customer_co   :=  'DFCA';
    r_subsidiary_doc.p_shop_co       :=  'ANSCA';
    r_subsidiary_doc.p_uuid          :=  NULL;
    r_subsidiary_doc.p_slug          :=  NULL;
    r_subsidiary_doc.p_user_co       :=  'RGUERRA';
    --
    -- jSON
    l_json := '{ "subsidiary_co":"XXS",'||
              '  "customer_co":"DFCA",'||
              '  "shop_co":"02-596",'||
              '  "slug":"ven-occ-lar-bqto-dfca-xxx",'||
              '  "user_co":"RGUERRA"';
    --
    l_json := l_json || '}';
    --
    IF l_type_test = 'R' THEN
        --
        -- test REC
        prs_api_k_subsidiary.create_subsidiary(
            p_rec       => r_subsidiary_doc,
            p_result    => l_result
        );
        --
    ELSIF l_type_test = 'J' THEN
        --
        -- TEST JSON
        prs_api_k_subsidiary.create_subsidiary(
            p_json      => l_json,
            p_result    => l_result
        );
        --
    END IF;
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
DECLARE
    --
    -- datos del documento
    r_customer_data igtp.prs_api_k_customer.customer_api_doc;
    l_result        VARCHAR2(1024);
    l_ins_ok        BOOLEAN;
    --
BEGIN 
    --
    -- TEST DE PROCESO DE INCLUIR UN CLIENTE
    --
    -- llenado de documento
    r_customer_data.customer_co           := 'DSB';
    r_customer_data.description           := 'COMERCIAL DISCOBAR.';
    r_customer_data.telephone_co          := '+58251-0000000';
    r_customer_data.fax_co                := '';
    r_customer_data.email                 := 'discobar@gmail.com';
    r_customer_data.address               := 'AV. LIBERTADOR LAS INDUSTRIAS';
    r_customer_data.k_type_customer       := 'M';
    r_customer_data.k_sector              := 'COSMETIC';
    r_customer_data.k_category_co         := 'C';
    r_customer_data.fiscal_document_co    := 'RIF-000000';
    r_customer_data.location_co           := 'BQTO-OES';
    r_customer_data.telephone_contact     := '251-0000000';
    r_customer_data.name_contact          := 'AMABLE BLANCO';
    r_customer_data.email_contact         := 'discobar@gmail.com';
    r_customer_data.slug                  := 'ven-occ-lar-bqto-discobar';
    r_customer_data.user_co               := 1;
    --
    l_ins_ok := prs_api_k_customer.ins(
        p_rec       => r_customer_data,
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
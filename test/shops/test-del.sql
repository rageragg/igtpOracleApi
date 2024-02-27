DECLARE
    --
    -- datos del documento
    r_shop_doc          igtp.prs_api_k_shop.shop_api_doc;
    l_result            VARCHAR2(2048);
    l_ins_ok            BOOLEAN;
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Tienda');
    --
    dbms_output.put_line( '1.- llenado de documento');
    -- llenado de documento
    r_shop_doc.p_shop_co := 'XXX';
    --
    dbms_output.put_line( '2.- Eliminar tienda');
    igtp.prs_api_k_shop.delete_shop(
        p_shop_co       => r_shop_doc.p_shop_co,
        p_result        => l_result
    );
    --
    COMMIT;
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
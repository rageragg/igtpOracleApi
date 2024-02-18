DECLARE
    --
    -- datos del documento
    r_customer_doc     igtp.prs_api_k_customer.customer_api_doc;
    l_result        VARCHAR2(2048);
    --
BEGIN 
    --
    dbms_output.put_line( 'Inicio de TEST Cliente');
    -- TEST DE PROCESO DE INCLUIR UNA CIUDAD
    --
    dbms_output.put_line( '1.- llenado de documento');
    -- llenado de documento
    r_customer_doc.p_customer_co := 'XXX';
    --
    dbms_output.put_line( '2.- Incluir Cliente');
    igtp.prs_api_k_customer.delete_customer(
        p_customer_co   => r_customer_doc.p_customer_co,
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
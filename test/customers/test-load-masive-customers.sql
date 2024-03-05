DECLARE
    --
    l_json      VARCHAR2(1024);
    l_result    VARCHAR2(1024);
    --
BEGIN 
    --
    l_json := '{"file_name":"customers.csv", "user_name":"RGUERRA"}';
    --
    prs_api_k_customer.load_file(
        p_json      => l_json,
        p_result    => l_result
    );
    --
    dbms_output.put_line( l_result );
    --
    EXCEPTION
      WHEN OTHERS THEN
            dbms_output.put_line( SQLERRM );
    --
END;
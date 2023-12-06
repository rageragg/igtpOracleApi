declare
    /* TEST 
     * Proceso de buscar de lenguaje de mensajeria
     *
    */
    --
    l_message   VARCHAR2(2048);
    --
begin 
    --
    l_message := prs_k_api_language.f_message( 
                    p_language_co => 'ES',
                    p_context     => 'GENERAL',
                    p_error_co    => '00001'
                );
    --
    dbms_output.put_line( l_message );

end;
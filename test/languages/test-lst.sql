declare
    /* TEST 
     * Proceso de lista de lenguaje de mensajeria
     *
    */
    --
    l_lista     prs_k_api_language.t_diccionary_tab;
    --
begin 
    --
    l_lista := prs_k_api_language.f_message_list(
                                        p_language_co =>  'ES',
                                        p_context     =>  NULL
                                    );
    --
    dbms_output.put_line( l_lista.COUNT );

end;
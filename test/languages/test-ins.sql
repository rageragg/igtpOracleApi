declare
    /* TEST 
     * Proceso de Inclusion de lenguaje de mensajeria
     *
    */
    --
    l_json      VARCHAR2(2048);
    l_result    VARCHAR2(2048);
    l_ok        BOOLEAN;
    --
begin 
    --
    l_json  := '{
        "language_co":"ES",
        "description": "ESPANOL",
        "context": "GENERAL",
        "code_error":"00003", 
        "description_error":"INSERTANDO",
        "cause_error": "PRUEBA!"
    }'; 
    --
    l_ok := prs_api_k_language.f_ins_upd_diccionary(
                                                    p_json          => l_json,
                                                    p_result        => l_result 
                                                );
    --
    dbms_output.put_line( l_result );

end;
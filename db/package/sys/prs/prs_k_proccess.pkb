
CREATE OR REPLACE PACKAGE BODY prs_k_proccess
IS
    ---------------------------------------------------------------------------
    --  DDL for Package PRS_K_PROCCESS (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    ---------------------------------------------------------------------------
    --
    g_lst_proccess  sys_k_proccess.proccess_api_tab;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    PROCEDURE p_execute_event(
        p_proccess_co       IN proccesses.proccess_co%TYPE,
        p_context           IN proccesses.context%TYPE,
        p_k_event_process   IN proccesses.k_event_process%TYPE
    ) IS 
    BEGIN 
        --
        g_lst_proccess := sys_k_proccess.get_lst_record( 
            p_proccess_co       => p_proccess_co,
            p_context           => p_context,
            p_k_event_process   => p_k_event_process
        );
        --
        IF g_lst_proccess.COUNT > 0 THEN 
            --
            FOR i IN 1..g_lst_proccess.COUNT LOOP 
                --
                IF g_lst_proccess.EXISTS(i) THEN 
                    --
                    sys_k_dinamic.p_exec_procedure(
                        p_procedure => g_lst_proccess(i).object_of_process
                    );
                    --
                END IF;
                --
            END LOOP;
            --
        END IF;
        --
    END p_execute_event;
    --
END prs_k_proccess;
/
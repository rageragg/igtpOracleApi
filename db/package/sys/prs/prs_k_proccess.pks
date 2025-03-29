CREATE OR REPLACE PACKAGE prs_k_proccess IS
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
    -- get DATA RETURN RECORD by PRELOAD with function exist
    PROCEDURE p_execute_event(
        p_proccess_co       IN proccesses.proccess_co%TYPE,
        p_context           IN proccesses.context%TYPE,
        p_k_event_process   IN proccesses.k_event_process%TYPE
    );
    --
END prs_k_proccess;
/
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
    --  2026-03-01  RGUERRA             Se agrega el proceso create_proccess
    ---------------------------------------------------------------------------
    --
    -- agrega un proceso
    PROCEDURE p_create_proccess(
        p_proccess_co       IN proccesses.proccess_co%TYPE,
        p_description       IN proccesses.description%TYPE,
        p_context           IN proccesses.context%TYPE,
        p_k_event_process   IN proccesses.k_event_process%TYPE,
        p_sequence          IN proccesses.sequence%TYPE,
        p_object_process    IN proccesses.object_of_process%TYPE,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL  
    );
    -- get Ejecuta un proceso
    PROCEDURE p_execute_event(
        p_proccess_co       IN proccesses.proccess_co%TYPE,
        p_context           IN proccesses.context%TYPE,
        p_k_event_process   IN proccesses.k_event_process%TYPE
    );
    --
END prs_k_proccess;
/
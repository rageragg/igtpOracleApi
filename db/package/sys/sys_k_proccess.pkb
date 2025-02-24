
CREATE OR REPLACE PACKAGE BODY sys_k_proccess
IS
    --
    g_record        proccesses%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN proccesses%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
    --
    -- insert
    PROCEDURE ins (
            p_id                IN proccesses.id%TYPE,
            p_process_co        IN proccesses.process_co%TYPE DEFAULT NULL,
            p_context           IN proccesses.context%TYPE DEFAULT NULL,
            p_description       IN PROCCESSES.description%TYPE DEFAULT NULL,
            p_k_event_process   IN proccesses.k_event_process%TYPE DEFAULT NULL,
            p_sequence          IN proccesses.sequence%TYPE DEFAULT NULL,
            p_object_of_process IN proccesses.object_of_process%TYPE DEFAULT NULL,
            p_k_mca_inh         IN proccesses.k_mca_inh%TYPE DEFAULT NULL,
            p_user_id           IN proccesses.user_id%TYPE DEFAULT NULL,
            p_created_at        IN proccesses.created_at%TYPE DEFAULT NULL,
            p_updated_at        IN proccesses.updated_at%TYPE DEFAULT NULL 
        ) IS
    BEGIN
        --
        INSERT INTO PROCCESSES(
            OBJECT_OF_PROCESS
            ,K_EVENT_PROCESS
            ,CREATED_AT
            ,DESCRIPTION
            ,SEQUENCE
            ,PROCESS_CO
            ,USER_ID
            ,UPDATED_AT
            ,ID
            ,K_MCA_INH
            ,CONTEXT
        ) VALUES (
            p_OBJECT_OF_PROCESS
            ,p_K_EVENT_PROCESS
            ,p_CREATED_AT
            ,p_DESCRIPTION
            ,p_SEQUENCE
            ,p_PROCESS_CO
            ,p_USER_ID
            ,p_UPDATED_AT
            ,p_ID
            ,p_K_MCA_INH
            ,p_CONTEXT
        );
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
    p_OBJECT_OF_PROCESS in PROCCESSES.OBJECT_OF_PROCESS%type default null 
    ,p_K_EVENT_PROCESS in PROCCESSES.K_EVENT_PROCESS%type default null 
    ,p_CREATED_AT in PROCCESSES.CREATED_AT%type default null 
    ,p_DESCRIPTION in PROCCESSES.DESCRIPTION%type default null 
    ,p_SEQUENCE in PROCCESSES.SEQUENCE%type default null 
    ,p_PROCESS_CO in PROCCESSES.PROCESS_CO%type default null 
    ,p_USER_ID in PROCCESSES.USER_ID%type default null 
    ,p_UPDATED_AT in PROCCESSES.UPDATED_AT%type default null 
    ,p_ID in PROCCESSES.ID%type
    ,p_K_MCA_INH in PROCCESSES.K_MCA_INH%type default null 
    ,p_CONTEXT in PROCCESSES.CONTEXT%type default null 
    ) is
    begin
    update PROCCESSES set
    OBJECT_OF_PROCESS = p_OBJECT_OF_PROCESS
    ,K_EVENT_PROCESS = p_K_EVENT_PROCESS
    ,CREATED_AT = p_CREATED_AT
    ,DESCRIPTION = p_DESCRIPTION
    ,SEQUENCE = p_SEQUENCE
    ,PROCESS_CO = p_PROCESS_CO
    ,USER_ID = p_USER_ID
    ,UPDATED_AT = p_UPDATED_AT
    ,K_MCA_INH = p_K_MCA_INH
    ,CONTEXT = p_CONTEXT
    where ID = p_ID;
    end;
    -- del
    PROCEDURE del (
    p_ID in PROCCESSES.ID%type
    ) is
    begin
    delete from PROCCESSES
    where ID = p_ID;
    end;
END sys_k_proccess;

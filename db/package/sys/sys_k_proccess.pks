CREATE OR REPLACE PACKAGE sys_k_proccess IS
    --
        --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'PROCCESSES';
    --
    TYPE proccess_api_tab IS TABLE OF igtp.proccesses%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN igtp.proccesses%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN igtp.proccesses.id%TYPE ) RETURN igtp.proccesses%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( 
        p_proccess_co   IN proccesses.proccess_co%TYPE,
        context         IN proccesses.proccess_co%TYPE,
        k_event_process IN proccesses.k_event_process%TYPE,
        sequence        IN proccesses.sequence%TYPE
    ) RETURN proccesses%ROWTYPE;
    --
    -- insert proccess by document
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
    );
    --
    -- update
    PROCEDURE upd (
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
    );
    --
    -- delete
    PROCEDURE del (
        p_id IN proccesses.id%TYPE
    );
    --
    -- exist
    FUNCTION exist( p_id IN proccesses.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( 
        p_proccess_co   IN proccesses.proccess_co%TYPE,
        context         IN proccesses.proccess_co%TYPE,
        k_event_process IN proccesses.k_event_process%TYPE,
        sequence        IN proccesses.sequence%TYPE
    ) RETURN BOOLEAN;
    --
END sys_k_proccess;
/
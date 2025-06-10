
CREATE OR REPLACE PACKAGE BODY sys_k_proccess
IS
    --
    g_record        proccesses%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN igtp.proccesses%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( 
            p_id IN igtp.proccesses.id%TYPE 
        ) RETURN igtp.proccesses%ROWTYPE IS 
        --
        --
        l_data igtp.proccesses%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.proccesses WHERE id = p_id;
        -- 
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_data;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_record;
    --
    -- get DATA RECORD BY CO
    FUNCTION get_record( 
            p_proccess_co       IN proccesses.proccess_co%TYPE,
            p_context           IN proccesses.context%TYPE,
            p_k_event_process   IN proccesses.k_event_process%TYPE,
            p_sequence          IN proccesses.sequence%TYPE
        ) RETURN igtp.proccesses%ROWTYPE IS 
        --
        l_data proccesses%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.proccesses 
             WHERE proccess_co      = p_proccess_co
               AND context          = p_context
               AND k_event_process  = p_k_event_process
               AND sequence         = p_sequence;
        -- 
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_data;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_record;
    --
    -- get LIST DATA RECORD BY CO
    FUNCTION get_lst_record( 
            p_proccess_co       IN proccesses.proccess_co%TYPE,
            p_context           IN proccesses.context%TYPE,
            p_k_event_process   IN proccesses.k_event_process%TYPE
        ) RETURN proccess_api_tab IS 
        --
        l_data proccesses%ROWTYPE;
        l_lst  proccess_api_tab;
        idx    PLS_INTEGER;
        --
        CURSOR c_data IS 
            SELECT * 
              FROM igtp.proccesses 
             WHERE proccess_co      = p_proccess_co
               AND context          = p_context
               AND k_event_process  = p_k_event_process
             ORDER BY sequence;
        -- 
    BEGIN 
        --
        idx := 0;
        --
        FOR r_data IN c_data LOOP 
            --
            idx         := idx + 1;
            l_lst(idx)  := r_data;
            --
        END LOOP;
        --
        RETURN l_lst;
        --
    END get_lst_record;
    --
    -- create incremental id
    FUNCTION inc_id RETURN NUMBER IS 
        --
        mx  NUMBER(8);
        --
    BEGIN
        --
        SELECT max(id)
          INTO mx
          FROM igtp.proccesses;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;   
    --
    -- insert
    PROCEDURE ins (
            p_id                IN proccesses.id%TYPE,
            p_process_co        IN proccesses.proccess_co%TYPE DEFAULT NULL,
            p_context           IN proccesses.context%TYPE DEFAULT NULL,
            p_description       IN proccesses.description%TYPE DEFAULT NULL,
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
        INSERT INTO proccesses(
            id,
            proccess_co,
            context,
            description,
            sequence,
            k_event_process,
            object_of_process,
            k_mca_inh,
            user_id,
            created_at,
            updated_at
        ) VALUES (
            p_id,
            p_process_co,
            p_context,
            p_description,
            p_sequence,
            p_k_event_process,
            p_object_of_process,
            p_k_mca_inh,
            p_user_id,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
            p_id                IN proccesses.id%TYPE,
            p_process_co        IN proccesses.proccess_co%TYPE DEFAULT NULL,
            p_context           IN proccesses.context%TYPE DEFAULT NULL,
            p_description       IN proccesses.description%TYPE DEFAULT NULL,
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
        UPDATE proccesses 
           SET proccess_co           = p_process_co,
               context              = p_context,
               description          = p_description,
               k_event_process      = p_k_event_process,
               sequence             = p_sequence,
               object_of_process    = p_object_of_process,
               k_mca_inh            = p_k_mca_inh,
               user_id              = p_user_id,
               created_at           = p_created_at,        
               updated_at           = p_updated_at
         WHERE id = p_id;
        --
    END upd;
    --
    -- del
    PROCEDURE del (
            p_ID IN proccesses.ID%type
        ) IS
    BEGIN
        --
        DELETE FROM proccesses
            WHERE id = p_id;
        --
    END del;
    --
    -- exist
    FUNCTION exist( p_id IN proccesses.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( 
            p_proccess_co       IN proccesses.proccess_co%TYPE,
            p_context           IN proccesses.context%TYPE,
            p_k_event_process   IN proccesses.k_event_process%TYPE,
            p_sequence          IN proccesses.sequence%TYPE
        ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( 
            p_proccess_co       => p_proccess_co,
            p_context           => p_context,
            p_k_event_process   => p_k_event_process,
            p_sequence          => p_sequence
        );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
END sys_k_proccess;
/
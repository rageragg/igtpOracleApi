
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
    --  2026-03-01  RGUERRA             Se agrega el proceso create_proccess
    ---------------------------------------------------------------------------
    --
    g_lst_proccess  sys_k_proccess.proccess_api_tab;
    g_reg_user      users%ROWTYPE;
    g_hay_error     BOOLEAN;
    g_msg_error     VARCHAR2(512);
    g_cod_error     NUMBER;
    --
    -- raise_error 
    PROCEDURE raise_error( 
            p_cod_error NUMBER,
            p_msg_error VARCHAR2
        ) IS 
    BEGIN 
        --
        -- TODO: regionalizacion de mensajes
        g_cod_error := p_cod_error;
        g_hay_error := TRUE;
        --
        g_msg_error := nvl(g_msg_error, p_msg_error );
        --
        raise_application_error(g_cod_error, g_msg_error );
        -- 
    END raise_error;
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
    ) IS 
        --
        l_exist_proccess        BOOLEAN := FALSE;
        l_registered_proccess   proccesses%ROWTYPE;
        --
    BEGIN   
        --
        l_exist_proccess := sys_k_proccess.exist( 
            p_proccess_co       => p_proccess_co,
            p_context           => p_context,
            p_k_event_process   => p_k_event_process,
            p_sequence          => p_sequence
        );
        --
        IF l_exist_proccess THEN 
            --
            RAISE_APPLICATION_ERROR(-20001, 'THE PROCESS ALREADY EXISTS');
            --
        ELSE 
            --
            l_registered_proccess.id                := NULL;
            l_registered_proccess.proccess_co       := p_proccess_co;
            l_registered_proccess.context           := p_context;
            l_registered_proccess.description       := p_description; 
            l_registered_proccess.k_event_process   := p_k_event_process;  
            l_registered_proccess.sequence          := p_sequence;
            l_registered_proccess.object_of_process := p_object_process;
            l_registered_proccess.k_mca_inh         := 'N';
            --
            IF NOT sec_api_k_user.exist( p_user_co =>  p_user_co ) THEN
                --
                raise_error( 
                    p_cod_error => -20002,
                    p_msg_error => 'INVALID USER CODE'
                );
                -- 
            ELSE 
                --
                g_reg_user := sec_api_k_user.get_record;
                l_registered_proccess.user_id    := g_reg_user.id;
                l_registered_proccess.created_at := SYSDATE;    
                --            
            END IF;
            --
            sys_k_proccess.ins (
                p_id                => l_registered_proccess.id,
                p_process_co        => l_registered_proccess.proccess_co,
                p_context           => l_registered_proccess.context,
                p_description       => l_registered_proccess.description,
                p_k_event_process   => l_registered_proccess.k_event_process,
                p_sequence          => l_registered_proccess.sequence,
                p_object_of_process => l_registered_proccess.object_of_process,
                p_k_mca_inh         => l_registered_proccess.k_mca_inh,
                p_user_id           => l_registered_proccess.user_id,
                p_created_at        => l_registered_proccess.created_at,
                p_updated_at        => l_registered_proccess.updated_at
            );
            --
        END IF;
        --
    END p_create_proccess;  
    --
    -- get Ejecuta un proceso
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
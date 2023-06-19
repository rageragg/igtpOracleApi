--------------------------------------------------------
--  DDL for Package Body TRANSFERS_api
--------------------------------------------------------

CREATE OR REPLACE PACKAGE lgc_api_k_transfer IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'TRANSFERS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    K_REGIMEN_FREIGHT       CONSTANT VARCHAR2(20)  := 'FREIGHT';
    K_REGIMEN_WEIGHT        CONSTANT VARCHAR2(20)  := 'WEIGHT';
    K_REGIMEN_DISTANCE      CONSTANT VARCHAR2(20)  := 'DISTANCE';
    K_REGIMEN_MANIFEST      CONSTANT VARCHAR2(20)  := 'AMOUNT-MANIFEST';
    --
    K_TYPE_TRANS_LOGITIC    CONSTANT VARCHAR2(20)  := 'LOGISTIC';
    K_TYPE_TRANS_BUSSINES   CONSTANT VARCHAR2(20)  := 'BUSSINES';
    K_TYPE_TRANS_DEFAULT    CONSTANT VARCHAR2(20)  := 'TRANSFERENCE';
    --
    K_STATUS_PLANNED        CONSTANT VARCHAR2(20)  := 'PLANNED';
    K_STATUS_EXECUTING      CONSTANT VARCHAR2(20)  := 'EXECUTING';
    K_STATUS_COMMIT         CONSTANT VARCHAR2(20)  := 'COMMIT';
    K_STATUS_ELIMINATED     CONSTANT VARCHAR2(20)  := 'ELIMINATED';
    K_STATUS_INCOMPLETE     CONSTANT VARCHAR2(20)  := 'INCOMPLETE';
    K_STATUS_INVOICED       CONSTANT VARCHAR2(20)  := 'INVOICED';
    K_STATUS_ARCHIVED       CONSTANT VARCHAR2(20)  := 'ARCHIVED';
    --
    K_PROCESS_LOGISTIC      CONSTANT VARCHAR2(20)  := 'LOGISTIC';
    K_PROCESS_INVOICING     CONSTANT VARCHAR2(20)  := 'INVOICING';
    K_PROCESS_ARCHIVING     CONSTANT VARCHAR2(20)  := 'ARCHIVING';
    --
    TYPE transfers_api_tab IS TABLE OF transfers%ROWTYPE INDEX BY PLS_INTEGER;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN transfers.id%TYPE ) RETURN transfers%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by FREIGHT ID
    FUNCTION get_record( p_freight_id       IN transfers.freight_id%TYPE,
                         p_sequence_number  IN transfers.sequence_number%TYPE DEFAULT NULL
                       ) RETURN transfers%ROWTYPE;     
    --
    -- get DATA RETURN RECORD by current sequence
    FUNCTION get_current_sequence( p_freight_id IN transfers.freight_id%TYPE ) RETURN transfers%ROWTYPE;
    --
    -- get DATA Array
    FUNCTION get_list( p_freight_id IN transfers.freight_id%TYPE ) RETURN transfers_api_tab;      
    --
    -- insert
    PROCEDURE ins (
        p_id                IN transfers.id%TYPE,
        p_freight_id        IN transfers.freight_id%TYPE DEFAULT NULL,
        p_sequence_number   IN transfers.sequence_number%TYPE DEFAULT NULL,
        p_k_order           IN transfers.k_order%TYPE DEFAULT NULL,
        p_route_id          IN transfers.route_id%TYPE DEFAULT NULL,
        p_k_regimen         IN transfers.k_regimen%TYPE DEFAULT 'FREIGHT',
        p_k_status          IN transfers.k_status%TYPE DEFAULT 'PLANNED',
        p_k_process         IN transfers.k_process%TYPE DEFAULT 'LOGISTIC',
        p_k_type_transfer   IN transfers.k_type_transfer%TYPE DEFAULT 'TRANSFERENCE',
        p_planed_at         IN transfers.planed_at%TYPE DEFAULT NULL,
        p_start_date        IN transfers.start_at%TYPE DEFAULT NULL,
        p_end_date          IN transfers.end_at%TYPE DEFAULT NULL,
        p_main_employee_id  IN transfers.main_employee_id%TYPE DEFAULT NULL,
        p_aux_employee_id   IN transfers.aux_employee_id%TYPE DEFAULT NULL,
        p_truck_id          IN transfers.truck_id%TYPE DEFAULT NULL,
        p_trailer_id        IN transfers.trailer_id%TYPE DEFAULT NULL,
        p_user_id           IN transfers.user_id%TYPE DEFAULT NULL,
        p_created_at        IN transfers.created_at%TYPE DEFAULT sysdate,
        p_updated_at        IN transfers.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT transfers%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN transfers.id%TYPE,
        p_freight_id        IN transfers.freight_id%TYPE DEFAULT NULL,
        p_sequence_number   IN transfers.sequence_number%TYPE DEFAULT NULL,
        p_k_order           IN transfers.k_order%TYPE DEFAULT NULL,
        p_route_id          IN transfers.route_id%TYPE DEFAULT NULL,
        p_k_regimen         IN transfers.k_regimen%TYPE DEFAULT 'FREIGHT',
        p_k_status          IN transfers.k_status%TYPE DEFAULT 'PLANNED',
        p_k_process         IN transfers.k_process%TYPE DEFAULT 'LOGISTIC',
        p_k_type_transfer   IN transfers.k_type_transfer%TYPE DEFAULT NULL,
        p_planed_at       IN transfers.planed_at%TYPE DEFAULT NULL,
        p_start_date        IN transfers.start_at%TYPE DEFAULT NULL,
        p_end_date          IN transfers.end_at%TYPE DEFAULT NULL,
        p_main_employee_id  IN transfers.main_employee_id%TYPE DEFAULT NULL,
        p_aux_employee_id   IN transfers.aux_employee_id%TYPE DEFAULT NULL,
        p_truck_id          IN transfers.truck_id%TYPE DEFAULT NULL,
        p_trailer_id        IN transfers.trailer_id%TYPE DEFAULT NULL,
        p_user_id           IN transfers.user_id%TYPE DEFAULT NULL,
        p_created_at        IN transfers.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN transfers.updated_at%TYPE DEFAULT sysdate 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT transfers%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN transfers.id%TYPE );
    --
END lgc_api_k_transfer;
/
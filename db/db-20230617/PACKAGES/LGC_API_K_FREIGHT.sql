--------------------------------------------------------
--  DDL for Package LGC_API_K_FREIGHT
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."LGC_API_K_FREIGHT" IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'FREIGHTS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    K_REGIMEN_FREIGHT       CONSTANT VARCHAR2(20)  := 'FREIGHT';
    K_REGIMEN_WEIGHT        CONSTANT VARCHAR2(20)  := 'WEIGHT';
    K_REGIMEN_DISTANCE      CONSTANT VARCHAR2(20)  := 'DISTANCE';
    K_REGIMEN_MANIFEST      CONSTANT VARCHAR2(20)  := 'AMOUNT-MANIFEST';
    --
    K_STATUS_PLANNED        CONSTANT VARCHAR2(20)  := 'PLANNED';
    K_STATUS_EXECUTING      CONSTANT VARCHAR2(20)  := 'EXECUTING';
    K_STATUS_COMMIT         CONSTANT VARCHAR2(20)  := 'COMMIT';
    K_STATUS_ELIMINATED     CONSTANT VARCHAR2(20)  := 'ELIMINATED';
    K_STATUS_INCOMPLETE     CONSTANT VARCHAR2(20)  := 'INCOMPLETE';
    K_STATUS_INVOICED       CONSTANT VARCHAR2(20)  := 'INVOICED';
    K_STATUS_ARCHIVED       CONSTANT VARCHAR2(20)  := 'ARCHIVED';
    --
    K_PROCESS_LOGISTY       CONSTANT VARCHAR2(20)  := 'LOGISTY';
    K_PROCESS_INVOICING     CONSTANT VARCHAR2(20)  := 'INVOICING';
    K_PROCESS_ARCHIVING     CONSTANT VARCHAR2(20)  := 'ARCHIVING';
    --
    TYPE freights_api_tab is table of freights%ROWTYPE;
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN freights.id%TYPE ) RETURN freights%ROWTYPE;    
    --
    -- get DATA Array
    FUNCTION get_list RETURN freights_api_tab;  
    --
    -- insert
    PROCEDURE ins (
        p_id                IN freights.id%TYPE,
        p_freights_co       IN freights.freights_co%TYPE DEFAULT NULL,
        p_customer_id       IN freights.customer_id%TYPE DEFAULT NULL,
        p_route_id          IN freights.route_id%TYPE DEFAULT NULL,
        p_type_cargo_id     IN freights.type_cargo_id%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN freights.type_vehicle_id%TYPE DEFAULT NULL,
        p_k_regimen         IN freights.k_regimen%TYPE DEFAULT 'FREIGHT',
        p_upload_at         IN freights.upload_at%TYPE DEFAULT NULL,
        p_start_at          IN freights.start_at%TYPE DEFAULT NULL,
        p_finish_at         IN freights.finish_at%TYPE DEFAULT NULL,
        p_notes             IN freights.notes%TYPE DEFAULT NULL,
        p_k_status          IN freights.k_status%TYPE DEFAULT 'PLANNED',
        p_k_process         IN freights.k_process%TYPE DEFAULT 'LOGISTY',
        p_user_id           IN freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN freights.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT freights%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN freights.id%TYPE,
        p_freights_co       IN freights.freights_co%TYPE DEFAULT NULL,
        p_customer_id       IN freights.customer_id%TYPE DEFAULT NULL,
        p_route_id          IN freights.route_id%TYPE DEFAULT NULL,
        p_type_cargo_id     IN freights.type_cargo_id%TYPE DEFAULT NULL,
        p_type_vehicle_id   IN freights.type_vehicle_id%TYPE DEFAULT NULL,
        p_k_regimen         IN freights.k_regimen%TYPE DEFAULT NULL,
        p_upload_at         IN freights.upload_at%TYPE DEFAULT NULL,
        p_start_at          IN freights.start_at%TYPE DEFAULT NULL,
        p_finish_at         IN freights.finish_at%TYPE DEFAULT NULL,
        p_notes             IN freights.notes%TYPE DEFAULT NULL,
        p_k_status          IN freights.k_status%TYPE DEFAULT NULL,
        p_k_process         IN freights.k_process%TYPE DEFAULT NULL,
        p_user_id           IN freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN freights.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT freights%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN freights.ID%TYPE );
    --
end lgc_api_k_freight;

/

--------------------------------------------------------
--  DDL for Package Body RAILERS_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE dsc_api_k_trailer IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'TRAILERS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    K_STATUS_AVAILABLE      CONSTANT VARCHAR2(20)  := 'AVAILABLE';
    K_STATUS_MAINTENANCE    CONSTANT VARCHAR2(20)  := 'MAINTENANCE';
    K_STATUS_SERVING        CONSTANT VARCHAR2(20)  := 'SERVING';
    K_STATUS_DISCARDED      CONSTANT VARCHAR2(20)  := 'DISCARDED';
    K_STATUS_LOCATED        CONSTANT VARCHAR2(20)  := 'LOCATED';
    --
    type trailers_api_tab is table of trailers%ROWTYPE;
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN trailers.id%TYPE ) RETURN trailers%ROWTYPE;   
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_trailer_co IN trailers.trailer_co%TYPE ) RETURN trailers%ROWTYPE;       
    --
    -- get DATA Array
    FUNCTION get_list RETURN trailers_api_tab;  
    --
    -- insert
    PROCEDURE ins (
        p_id               IN trailers.id%TYPE,
        p_trailer_co       IN trailers.trailer_co%TYPE DEFAULT NULL,
        p_external_co      IN trailers.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id  IN trailers.type_vehicle_id%TYPE DEFAULT NULL,
        p_model            IN trailers.model%TYPE DEFAULT NULL,
        p_serial_chassis   IN trailers.serial_chassis%TYPE DEFAULT NULL,
        p_year             IN trailers.year%TYPE DEFAULT NULL,
        p_color            IN trailers.color%TYPE DEFAULT NULL, 
        p_partner_id       IN trailers.partner_id%TYPE DEFAULT NULL,
        p_k_status         IN trailers.k_status%TYPE DEFAULT 'AVAILABLE',
        p_employee_id      IN trailers.employee_id%TYPE DEFAULT NULL, 
        p_location_id      IN trailers.location_id%TYPE DEFAULT NULL,
        p_transfer_id      IN trailers.transfer_id%TYPE DEFAULT NULL, 
        p_user_id          IN trailers.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN trailers.created_at%TYPE DEFAULT sysdate,
        p_updated_at       IN trailers.updated_at%TYPE DEFAULT NULL
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT trailers%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id               IN trailers.id%TYPE,
        p_trailer_co       IN trailers.trailer_co%TYPE DEFAULT NULL,
        p_external_co      IN trailers.external_co%TYPE DEFAULT NULL,
        p_type_vehicle_id  IN trailers.type_vehicle_id%TYPE DEFAULT NULL,
        p_model            IN trailers.model%TYPE DEFAULT NULL,
        p_serial_chassis   IN trailers.serial_chassis%TYPE DEFAULT NULL,
        p_year             IN trailers.year%TYPE DEFAULT NULL,
        p_color            IN trailers.color%TYPE DEFAULT NULL, 
        p_partner_id       IN trailers.partner_id%TYPE DEFAULT NULL,
        p_k_status         IN trailers.k_status%TYPE DEFAULT 'AVAILABLE',
        p_employee_id      IN trailers.employee_id%TYPE DEFAULT NULL, 
        p_location_id      IN trailers.location_id%TYPE DEFAULT NULL,
        p_transfer_id      IN trailers.transfer_id%TYPE DEFAULT NULL, 
        p_user_id          IN trailers.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN trailers.created_at%TYPE DEFAULT NULL,
        p_updated_at       IN trailers.updated_at%TYPE DEFAULT sysdate
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT trailers%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN trailers.id%TYPE );
    --
END dsc_api_k_trailer;

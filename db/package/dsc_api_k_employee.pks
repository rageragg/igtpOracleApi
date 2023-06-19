--------------------------------------------------------
--  DDL for Package Body EMPLOYEES_api
--------------------------------------------------------

CREATE OR REPLACE PACKAGE dsc_api_k_employee
is
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'EMPLOYEES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    K_STATUS_AVAILABLE      CONSTANT VARCHAR2(20)  := 'AVAILABLE';
    K_STATUS_VACATIONS      CONSTANT VARCHAR2(20)  := 'VACATIONS';
    K_STATUS_SERVING        CONSTANT VARCHAR2(20)  := 'SERVING';
    K_STATUS_DISCARDED      CONSTANT VARCHAR2(20)  := 'DISCARDED';
    K_STATUS_LOCATED        CONSTANT VARCHAR2(20)  := 'LOCATED';
    K_STATUS_ARCHIVED       CONSTANT VARCHAR2(20)  := 'ARCHIVED';
    --
    K_LEVEL_A               CONSTANT CHAR(01) := 'A';
    K_LEVEL_B               CONSTANT CHAR(01) := 'B';
    K_LEVEL_C               CONSTANT CHAR(01) := 'C';
    --
    TYPE employees_api_tab is table of employees%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN employees.id%TYPE ) RETURN employees%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_employee_co IN employees.employee_co%TYPE ) RETURN employees%ROWTYPE;    
    --
    -- get DATA Array
    FUNCTION get_list RETURN employees_api_tab;  
    --
    -- insert
    PROCEDURE ins (
        p_id            IN employees.id%TYPE,
        p_employee_co   IN employees.employee_co%TYPE DEFAULT NULL,
        p_fullname      IN employees.fullname%TYPE DEFAULT NULL,
        p_k_level       IN employees.k_level%TYPE DEFAULT NULL,
        p_k_status      IN employees.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id    IN employees.partner_id%TYPE DEFAULT NULL,
        p_transfer_id   IN employees.transfer_id%TYPE DEFAULT NULL,
        p_truck_id      IN employees.truck_id%TYPE DEFAULT NULL,
        p_trailer_id    IN employees.trailer_id%TYPE DEFAULT NULL,
        p_location_id   IN employees.location_id%TYPE DEFAULT NULL,
        p_user_id       IN employees.user_id%TYPE DEFAULT NULL,
        p_created_at    IN employees.created_at%TYPE DEFAULT sysdate,
        p_updated_at    IN employees.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT employees%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id            IN employees.id%TYPE,
        p_employee_co   IN employees.employee_co%TYPE DEFAULT NULL,
        p_fullname      IN employees.fullname%TYPE DEFAULT NULL,
        p_k_level       IN employees.k_level%TYPE DEFAULT NULL,
        p_k_status      IN employees.k_status%TYPE DEFAULT 'AVAILABLE',
        p_partner_id    IN employees.partner_id%TYPE DEFAULT NULL,
        p_transfer_id   IN employees.transfer_id%TYPE DEFAULT NULL,
        p_truck_id      IN employees.truck_id%TYPE DEFAULT NULL,
        p_trailer_id    IN employees.trailer_id%TYPE DEFAULT NULL,
        p_location_id   IN employees.location_id%TYPE DEFAULT NULL,
        p_user_id       IN employees.user_id%TYPE DEFAULT NULL,
        p_created_at    IN employees.created_at%TYPE DEFAULT NULL,
        p_updated_at    IN employees.updated_at%TYPE DEFAULT sysdate 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT employees%ROWTYPE );    
    --
    -- delete
    PROCEDURE del ( p_id IN employees.id%TYPE );
    --
END dsc_api_k_employee;
/

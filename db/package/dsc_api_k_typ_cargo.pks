--------------------------------------------------------
--  DDL for Package Body TYPE_CARGOS_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE dsc_api_k_typ_cargo IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'TYPE_CARGOS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE type_cargos_api_tab IS TABLE OF type_cargos%ROWTYPE;
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN type_cargos.id%TYPE ) RETURN type_cargos%ROWTYPE;    
    --
    -- get DATA Array
    FUNCTION get_list RETURN type_cargos_api_tab;    
    --
    -- insert
    procedure ins (
        p_id            IN type_cargos.id%TYPE,
        p_type_cargo_co IN type_cargos.type_cargo_co%TYPE DEFAULT NULL, 
        p_description   IN type_cargos.description%TYPE DEFAULT NULL, 
        p_k_active      IN type_cargos.k_active%TYPE DEFAULT NULL, 
        p_user_id       IN type_cargos.user_id%TYPE DEFAULT NULL, 
        p_created_at    IN type_cargos.created_at%TYPE DEFAULT NULL, 
        p_updated_at    IN type_cargos.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT type_cargos%ROWTYPE );
    --
    -- update
    procedure upd (
        p_id            IN type_cargos.id%TYPE,
        p_type_cargo_co IN type_cargos.type_cargo_co%TYPE DEFAULT NULL, 
        p_description   IN type_cargos.description%TYPE DEFAULT NULL, 
        p_k_active      IN type_cargos.k_active%TYPE DEFAULT NULL, 
        p_user_id       IN type_cargos.user_id%TYPE DEFAULT NULL, 
        p_created_at    IN type_cargos.created_at%TYPE DEFAULT NULL, 
        p_updated_at    IN type_cargos.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT type_cargos%ROWTYPE );
    --
    -- delete
    procedure del ( p_id IN type_cargos.id%TYPE );
    --
end dsc_api_k_typ_cargo;

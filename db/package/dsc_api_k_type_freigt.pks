--------------------------------------------------------
--  DDL for Package Body TYPE_FREIGHTS_api
--------------------------------------------------------

CREATE OR REPLACE PACKAGE dsc_api_k_type_freigt IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'TYPE_FREIGHTS';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE type_freigts_api_tab IS TABLE OF type_freights%ROWTYPE;
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id IN type_freights.id%TYPE ) RETURN type_freights%ROWTYPE;    
    --  
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_type_freight_co IN type_freights.type_freight_co%TYPE ) RETURN type_freights%ROWTYPE;
    --
    -- get DATA Array
    FUNCTION get_list RETURN type_freigts_api_tab;    
    --
    -- insert
    procedure ins (
        p_id                IN type_freights.id%TYPE,
        p_type_freight_co   IN type_freights.type_freight_co%TYPE DEFAULT NULL,
        p_description       IN type_freights.description%TYPE DEFAULT NULL,
        p_k_multi_delivery  IN type_freights.k_multi_delivery%TYPE DEFAULT NULL,
        p_k_multi_load      IN type_freights.k_multi_load%TYPE DEFAULT NULL,
        p_user_id           IN type_freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_freights.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT type_freights%ROWTYPE );
    --
    -- update
    procedure upd (
        p_id                IN type_freights.id%TYPE,
        p_type_freight_co   IN type_freights.type_freight_co%TYPE DEFAULT NULL,
        p_description       IN type_freights.description%TYPE DEFAULT NULL,
        p_k_multi_delivery  IN type_freights.k_multi_delivery%TYPE DEFAULT NULL,
        p_k_multi_load      IN type_freights.k_multi_load%TYPE DEFAULT NULL,
        p_user_id           IN type_freights.user_id%TYPE DEFAULT NULL,
        p_created_at        IN type_freights.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN type_freights.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT type_freights%ROWTYPE );    
    --
    -- delete
    procedure del ( p_id IN type_freights.id%TYPE );
    --
END dsc_api_k_type_freigt;
/

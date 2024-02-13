--------------------------------------------------------
--  DDL for Package Body USERS_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE sec_api_k_user IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'users';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE users_api_tab IS TABLE OF users%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN users%ROWTYPE;
    --
    -- get DATA RETURN RECORD by id
    FUNCTION get_record( p_id IN users.id%TYPE ) RETURN users%ROWTYPE;
    --
    -- get DATA RECORD by CO
    FUNCTION get_record( p_user_co in users.user_co%TYPE )  RETURN users%ROWTYPE;
    --
    -- get DATA Array
    FUNCTION get_list RETURN users_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id                IN users.id%TYPE,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_name              IN users.name%TYPE DEFAULT NULL,
        p_email             IN users.email%TYPE DEFAULT NULL,
        p_email_verified_at IN users.email_verified_at%TYPE DEFAULT NULL,
        p_password          IN users.password%TYPE DEFAULT NULL,
        p_api_token         IN users.api_token%TYPE DEFAULT NULL,
        p_token_at          IN users.token_at%TYPE DEFAULT NULL,
        p_uuid              IN users.uuid%TYPE DEFAULT NULL,
        p_rol               IN users.rol%TYPE DEFAULT NULL,
        p_device_id         IN users.device_id%TYPE DEFAULT NULL,
        p_remember_token    IN users.remember_token%TYPE DEFAULT NULL,
        p_k_valid           IN users.k_valid%TYPE DEFAULT NULL,
        p_address_ip        IN users.address_ip%TYPE DEFAULT NULL,
        p_created_at        IN users.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN users.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT users%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN users.id%TYPE,
        p_user_co           IN users.user_co%TYPE DEFAULT NULL,
        p_name              IN users.name%TYPE DEFAULT NULL,
        p_email             IN users.email%TYPE DEFAULT NULL,
        p_email_verified_at IN users.email_verified_at%TYPE DEFAULT NULL,
        p_password          IN users.password%TYPE DEFAULT NULL,
        p_api_token         IN users.api_token%TYPE DEFAULT NULL,
        p_token_at          IN users.token_at%TYPE DEFAULT NULL,
        p_uuid              IN users.uuid%TYPE DEFAULT NULL,
        p_rol               IN users.rol%TYPE DEFAULT NULL,
        p_device_id         IN users.device_id%TYPE DEFAULT NULL,
        p_remember_token    IN users.remember_token%TYPE DEFAULT NULL,
        p_k_valid           IN users.k_valid%TYPE DEFAULT NULL,
        p_address_ip        IN users.address_ip%TYPE DEFAULT NULL,
        p_created_at        IN users.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN users.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT users%ROWTYPE );    
    --
    -- delete
    PROCEDURE del ( p_id IN users.id%TYPE );
    --
    --
    -- exist
    FUNCTION exist( p_id IN users.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( p_user_co IN users.user_co%TYPE ) RETURN BOOLEAN;    
    --
end sec_api_k_user;
/
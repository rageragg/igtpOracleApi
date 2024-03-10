CREATE OR REPLACE PACKAGE dsc_api_k_subsidiaries IS
    ---------------------------------------------------------------------------
    --  DDL for Package SUBSIDIARIES_API (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de creacion de
    --                                  subsidiaries
    ---------------------------------------------------------------------------
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := sys_k_constant.K_SUBSIDIARY_TABLE;
    K_CONTEXT    CONSTANT VARCHAR2(30)  := sys_k_constant.K_SUBSIDIARY_CONTEXT;
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE subsidiaries_api_tab IS TABLE OF subsidiaries%ROWTYPE;    
    --
    -- get DATA
    FUNCTION get_record RETURN subsidiaries%ROWTYPE;   
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN subsidiaries.id%TYPE ) RETURN subsidiaries%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_subsidiary_co IN subsidiaries.subsidiary_co%TYPE ) RETURN subsidiaries%ROWTYPE;        
    --
    -- get DATA Array
    FUNCTION get_list RETURN subsidiaries_api_tab;    
    --
    -- insert
    PROCEDURE ins (
        p_id                IN subsidiaries.ID%type,
        p_subsidiary_co     IN subsidiaries.subsidiary_co%type default null, 
        p_customer_id       IN subsidiaries.customer_id%type default null, 
        p_shop_id           IN subsidiaries.shop_id%type default null, 
        p_slug              IN subsidiaries.slug%type default null, 
        p_uuid              IN subsidiaries.uuid%type default null,
        p_created_at        IN subsidiaries.created_at%type default null,
        p_updated_at        IN subsidiaries.updated_at%type default null,
        p_user_id           IN subsidiaries.user_id%type default null 
    );  
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT subsidiaries%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
            p_id            IN subsidiaries.ID%type,
            p_subsidiary_co IN subsidiaries.subsidiary_co%type default null, 
            p_customer_id   IN subsidiaries.CUSTOMER_ID%type default null,
            p_shop_id       IN subsidiaries.shop_id%type default null,
            p_slug          IN subsidiaries.slug%type default null,
            p_uuid          IN subsidiaries.uuid%type default null,
            p_created_at    IN subsidiaries.created_at%type default null,
            p_updated_at    IN subsidiaries.updated_at%type default null,
            p_user_id       IN subsidiaries.user_id%type default null
        );    
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT subsidiaries%ROWTYPE );
    --
    -- TODO: desarrollar las funciones que evaluan la existencia
    -- exist shop by id
    FUNCTION exist( p_id IN subsidiaries.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist shop by code
    FUNCTION exist( p_subsidiary_co IN subsidiaries.subsidiary_co%TYPE DEFAULT NULL ) RETURN BOOLEAN;
    --
END dsc_api_k_subsidiaries;    
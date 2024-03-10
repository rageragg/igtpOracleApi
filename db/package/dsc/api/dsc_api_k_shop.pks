
CREATE OR REPLACE PACKAGE dsc_api_k_shop IS
    ---------------------------------------------------------------------------
    --  DDL for Package SHOPS_API (Process)
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
    --                                  tiendas
    ---------------------------------------------------------------------------
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := sys_k_constant.K_SHOP_TABLE;
    K_CONTEXT    CONSTANT VARCHAR2(30)  := sys_k_constant.K_SHOP_CONTEXT;
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE shops_api_tab IS TABLE OF shops%ROWTYPE;
    --
    -- get DATA
    FUNCTION get_record RETURN shops%ROWTYPE;   
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN shops.id%TYPE ) RETURN shops%ROWTYPE;    
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_shop_co IN shops.shop_co%TYPE ) RETURN shops%ROWTYPE;        
    --
    -- get DATA Array
    FUNCTION get_list RETURN shops_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id                IN shops.id%TYPE,
        p_shop_co           IN shops.shop_co%TYPE DEFAULT NULL,
        p_description       IN shops.description%TYPE DEFAULT NULL, 
        p_location_id       IN shops.location_id%TYPE DEFAULT NULL,
        p_address           IN shops.address%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN shops.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN shops.nu_gps_lon%TYPE DEFAULT NULL, 
        p_telephone_co      IN shops.telephone_co%TYPE DEFAULT NULL, 
        p_fax_co            IN shops.fax_co%TYPE DEFAULT NULL,
        p_email             IN shops.email%TYPE DEFAULT NULL, 
        p_name_contact      IN shops.name_contact%TYPE DEFAULT NULL,
        p_email_contact     IN shops.email_contact%TYPE DEFAULT NULL,
        p_telephone_contact IN shops.telephone_contact%TYPE DEFAULT NULL, 
        p_uuid              IN shops.uuid%TYPE DEFAULT NULL,
        p_slug              IN shops.slug%TYPE DEFAULT NULL,
        p_user_id           IN shops.user_id%TYPE DEFAULT NULL,
        p_created_at        IN shops.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN shops.updated_at%TYPE DEFAULT NULL
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT shops%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                IN shops.id%TYPE,
        p_shop_co           IN shops.shop_co%TYPE DEFAULT NULL,
        p_description       IN shops.description%TYPE DEFAULT NULL, 
        p_location_id       IN shops.location_id%TYPE DEFAULT NULL,
        p_address           IN shops.address%TYPE DEFAULT NULL, 
        p_nu_gps_lat        IN shops.nu_gps_lat%TYPE DEFAULT NULL,
        p_nu_gps_lon        IN shops.nu_gps_lon%TYPE DEFAULT NULL, 
        p_telephone_co      IN shops.telephone_co%TYPE DEFAULT NULL, 
        p_fax_co            IN shops.fax_co%TYPE DEFAULT NULL,
        p_email             IN shops.email%TYPE DEFAULT NULL, 
        p_name_contact      IN shops.name_contact%TYPE DEFAULT NULL,
        p_email_contact     IN shops.email_contact%TYPE DEFAULT NULL,
        p_telephone_contact IN shops.telephone_contact%TYPE DEFAULT NULL, 
        p_uuid              IN shops.uuid%TYPE DEFAULT NULL,
        p_slug              IN shops.slug%TYPE DEFAULT NULL,
        p_user_id           IN shops.user_id%TYPE DEFAULT NULL,
        p_created_at        IN shops.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN shops.updated_at%TYPE DEFAULT NULL
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT shops%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN shops.id%TYPE );
    --
    -- TODO: desarrollar las funciones que evaluan la existencia
    -- exist shop by id
    FUNCTION exist( p_id IN shops.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist shop by code
    FUNCTION exist( p_shop_co IN shops.shop_co%TYPE DEFAULT NULL ) RETURN BOOLEAN;
    --    
END dsc_api_k_shop;
/
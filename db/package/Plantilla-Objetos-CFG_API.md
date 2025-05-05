# Plantilla de Objetos CFG_API 
------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    --  DDL for Package XXXXXX_API
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    ---------------------------------------------------------------------------
    --
    **K_PROCESS**    CONSTANT VARCHAR2(20);
    **K_OWNER**      CONSTANT VARCHAR2(20);
    **K_TABLE_NAME** CONSTANT VARCHAR2(30);
    **K_LIMIT_LIST** CONSTANT PLS_INTEGER;
    **K_ORDER_LIST** CONSTANT PLS_INTEGER;
    --
    TYPE tabla_api_tab IS TABLE OF tabla%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN tabla%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN tabla.id%TYPE ) RETURN tabla%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_city_co IN tabla.city_co%TYPE ) RETURN tabla%ROWTYPE;
    --
    -- get DATA RETURN Array
    FUNCTION get_list RETURN tabla_api_tab;
    --
    -- insert
    PROCEDURE ins (
       ..
    );
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT tabla%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
       ...
    );
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT tabla%ROWTYPE );    
    --
    -- delete
    PROCEDURE del ( p_id in tabla.id%TYPE );
    --
    -- exist
    FUNCTION exist( p_id IN tabla.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( p_city_co IN tabla.tabla_co%TYPE ) RETURN BOOLEAN;
    --

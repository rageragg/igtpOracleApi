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

END dsc_api_k_subsidiaries;    
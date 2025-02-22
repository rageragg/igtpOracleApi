CREATE OR REPLACE PACKAGE prs_api_k_language IS
    ---------------------------------------------------------------------------
    --  DDL for Package PRS_API_K_LANGUAGE (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --  CFG_API_K_CONFIGURATION         PAQUETE DE BASE
    --  SYS_K_CONSTANT                  PAQUETE DE BASE
    --  SYS_K_GLOBAL                    PAQUETE DE BASE
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  2023-08-12  RAGECA - RGUERRA    Actualizacion de metodos de procesos
    --                                  administrativos de lenguaje
    ---------------------------------------------------------------------------
    --
    K_OWNER         CONSTANT VARCHAR2(20)  := sys_k_constant.K_OWNER_APP;
    K_CONTEXT       CONSTANT VARCHAR2(30)  := 'LANGUAGE-ADMINISTRATOS';
    K_TABLE_NAME    CONSTANT VARCHAR2(30)  := 'LANGUAGES';
    K_LIMIT_LIST    CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST    CONSTANT PLS_INTEGER   := 2;
    --
    -- tipo de diccionario
    TYPE t_diccionary IS RECORD (
        context             VARCHAR2(60),
        error_co            VARCHAR2(60),
        error_description   VARCHAR2(512),
        error_cause         VARCHAR2(512)
    );
    --
    -- tabla de diccionario
    TYPE t_diccionary_tab IS TABLE OF t_diccionary INDEX BY PLS_INTEGER;
    --
    -- incluir o actualizar diccionario
    FUNCTION f_ins_upd_diccionary( 
        p_json          IN VARCHAR2,
        p_result        OUT VARCHAR2 
    ) RETURN BOOLEAN;
    --
    -- incluir o actualizar diccionario
    FUNCTION p_ins_upd_diccionary(
        p_language_co       IN VARCHAR2, 
        p_description       IN VARCHAR2,
        p_context           IN VARCHAR2,
        error_code          IN VARCHAR2,
        error_descripcion   IN VARCHAR2,
        error_cause         IN VARCHAR2 
    ) RETURN BOOLEAN; 
    --
    -- devuelve el mensaje del diccionario
    FUNCTION f_message( 
        p_language_co IN VARCHAR2,
        p_context     IN VARCHAR2,
        p_error_co    IN VARCHAR2 
    ) RETURN VARCHAR2;
    --
    -- devuelve el mensaje del diccionario
    FUNCTION f_message_list( 
        p_language_co IN VARCHAR2,
        p_context     IN VARCHAR2 
    ) RETURN t_diccionary_tab;
    --
END prs_api_k_language;
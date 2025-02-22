CREATE OR REPLACE PACKAGE cfg_api_k_language IS
    ---------------------------------------------------------------------------
    --  DDL for Package CFG_API_K_LANGUAGE (Process)
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
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'LANGUAGES';
    --
    TYPE languages_api_tab IS TABLE OF igtp.languages%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN igtp.languages.id%TYPE ) RETURN igtp.languages%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_language_co IN languages.language_co%TYPE ) RETURN languages%ROWTYPE;     
    --
    -- insert
    PROCEDURE ins (
        p_id              languages.id%TYPE,
        p_language_co     languages.language_co%TYPE,
        p_description     languages.description%TYPE,
        p_diccionary      languages.diccionary%TYPE,
        p_updated_at      languages.updated_at%TYPE,
        p_created_at      languages.created_at%TYPE
    );
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT igtp.languages%ROWTYPE ); 
    --
    -- update
    PROCEDURE upd (
        p_id              languages.id%TYPE,
        p_language_co     languages.language_co%TYPE,
        p_description     languages.description%TYPE,
        p_diccionary      languages.diccionary%TYPE,
        p_updated_at      languages.updated_at%TYPE,
        p_created_at      languages.created_at%TYPE
    );
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT igtp.languages%ROWTYPE );
    --
    -- delete
    PROCEDURE del (
        p_id    languages.id%TYPE
    );
    --
END cfg_api_k_language;
/



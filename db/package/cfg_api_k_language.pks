--------------------------------------------------------
--  DDL for Package Body cfg_api_k_language
--------------------------------------------------------

CREATE OR REPLACE PACKAGE cfg_api_k_language IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'LANGUAGES';
    --
    TYPE languages_api_tab IS TABLE OF igtp.languages%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN igtp.languages.id%TYPE ) RETURN igtp.languages%ROWTYPE;
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



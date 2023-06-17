--------------------------------------------------------
--  DDL for Package CFG_API_K_MUNICIPALITY
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."CFG_API_K_MUNICIPALITY" IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'MUNICIPALITIES';
    --
    -- get DATA RETURN RECORD
    FUNCTION get_record( p_id in municipalities.id%TYPE ) RETURN municipalities%ROWTYPE;
    --
    -- insert
    PROCEDURE ins (
        p_id               IN municipalities.id%TYPE,
        p_municipality_co  IN municipalities.municipality_co%TYPE DEFAULT NULL, 
        p_description      IN municipalities.description%TYPE DEFAULT NULL, 
        p_province_id      IN municipalities.province_id%TYPE DEFAULT NULL, 
        p_uuid             IN municipalities.uuid%TYPE DEFAULT NULL,
        p_slug             IN municipalities.slug%TYPE DEFAULT NULL, 
        p_user_id          IN municipalities.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN municipalities.created_at%TYPE DEFAULT NULL, 
        p_updated_at       IN municipalities.updated_at%TYPE DEFAULT NULL
    );
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec  IN OUT municipalities%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id               IN municipalities.id%TYPE,
        p_municipality_co  IN municipalities.municipality_co%TYPE DEFAULT NULL, 
        p_description      IN municipalities.description%TYPE DEFAULT NULL, 
        p_province_id      IN municipalities.province_id%TYPE DEFAULT NULL, 
        p_uuid             IN municipalities.uuid%TYPE DEFAULT NULL,
        p_slug             IN municipalities.slug%TYPE DEFAULT NULL, 
        p_user_id          IN municipalities.user_id%TYPE DEFAULT NULL, 
        p_created_at       IN municipalities.created_at%TYPE DEFAULT NULL, 
        p_updated_at       IN municipalities.updated_at%TYPE DEFAULT NULL
    );
    --
    -- update RECORD
    PROCEDURE upd ( p_rec  IN OUT municipalities%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN municipalities.id%TYPE );
    --
END cfg_api_k_municipality;


/

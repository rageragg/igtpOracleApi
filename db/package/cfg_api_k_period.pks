--------------------------------------------------------
--  DDL for Package Body PERIODS_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE cfg_api_k_period IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'PERIODS';
    --
    TYPE periods_api_tab IS TABLE OF igtp.periods%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN igtp.periods.id%TYPE ) RETURN igtp.periods%ROWTYPE;
    --
    -- insert
    PROCEDURE ins (
        p_id                            IN periods.id%TYPE,
        p_period_co 			        IN periods.period_co%TYPE, 
        p_period_description 			IN periods.period_description%TYPE, 
        p_from_date                     IN periods.from_date%TYPE,
        p_to_date                       IN periods.to_date%TYPE,
        p_created_at 					IN periods.created_at%TYPE, 
        p_updated_at 					IN periods.updated_at%TYPE
    );
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT igtp.periods%ROWTYPE ); 
    --
    -- update
    PROCEDURE upd (
        p_id                            IN periods.id%TYPE,
        p_period_co 			        IN periods.period_co%TYPE, 
        p_period_description 			IN periods.period_description%TYPE, 
        p_from_date                     IN periods.from_date%TYPE,
        p_to_date                       IN periods.to_date%TYPE,
        p_created_at 					IN periods.created_at%TYPE, 
        p_updated_at 					IN periods.updated_at%TYPE
    );
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT igtp.periods%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN igtp.periods.id%TYPE );
    --
END cfg_api_k_period;

--------------------------------------------------------
--  DDL for Package Body periods_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_period IS
    --
    -- get record
    FUNCTION get_record( p_id IN igtp.periods.id%TYPE ) RETURN igtp.periods%ROWTYPE IS 
        --
        l_rec periods%ROWTYPE;
        --
    BEGIN 
        --
        SELECT *
          INTO l_rec
          FROM igtp.periods 
         WHERE id = p_id;
        --
        RETURN l_rec;
        --
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                RETURN NULL;  
        --
    END get_record;
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
    ) IS
    BEGIN
        --
        INSERT INTO igtp.periods(
            id,
            period_co, 
            period_description, 
            from_date,
            to_date,
            created_at, 
            updated_at
        ) 
        VALUES (
            p_id,
            p_period_co, 
            p_period_description, 
            p_from_date,
            p_to_date,
            p_created_at, 
            p_updated_at
        );
        --
    END ins;
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT igtp.periods%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        INSERT INTO igtp.periods 
             VALUES p_rec
             RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;
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
    ) IS
    BEGIN
        --
        UPDATE igtp.periods SET
            id                 = p_id,
            period_co 	     = p_period_co, 
            period_description = p_period_description, 
            from_date          = p_from_date,
            to_date            = p_to_date,
            created_at 		 = p_created_at, 
            updated_at 		 = p_updated_at
          WHERE id = p_id;
        --
    END upd;
        --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT igtp.periods%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.periods 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id IN igtp.periods.id%TYPE
    ) IS
    BEGIN
        --
        DELETE FROM igtp.periods
              WHERE id = p_id;
        --
    END del;
    --
END cfg_api_k_period;
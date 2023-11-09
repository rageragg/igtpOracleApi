--------------------------------------------------------
--  DDL for Type TYP_CONFIGURATION
--------------------------------------------------------

CREATE OR REPLACE NONEDITIONABLE TYPE "IGTP"."TYP_CONFIGURATION" IS OBJECT(
    --
    id	                            NUMBER(8,0),
    local_currency_co	            VARCHAR2(3 byte),
    foreign_currency_co	            VARCHAR2(3 byte),
    last_foreign_currency_q_value	NUMBER(10,2),
    last_foreign_currency_q_date	DATE,
    days_per_year	                INTEGER,
    weeks_per_year	                INTEGER,
    months_per_year	                INTEGER,
    days_per_month	                INTEGER,
    days_per_week	                INTEGER,
    hours_per_day	                INTEGER,
    --
    CONSTRUCTOR FUNCTION typ_configuration(
            SELF IN OUT NOCOPY typ_configuration, 
            id	                          NUMBER,
            local_currency_co             VARCHAR2,
            foreign_currency_co           VARCHAR2,
            last_foreign_currency_q_value NUMBER,
            last_foreign_currency_q_date  DATE 
        ) RETURN SELF AS RESULT,
    --
    MAP MEMBER FUNCTION get_id RETURN NUMBER,
    MEMBER FUNCTION get_hours_per_week RETURN INTEGER,
    MEMBER FUNCTION get_currenvy_value( p_local_value IN NUMBER ) RETURN NUMBER
    --
);
/
CREATE OR REPLACE NONEDITIONABLE TYPE BODY "IGTP"."TYP_CONFIGURATION" AS
    --
    CONSTRUCTOR FUNCTION typ_configuration(
            SELF IN OUT NOCOPY typ_configuration, 
            id	                            NUMBER,
            local_currency_co               VARCHAR2,
            foreign_currency_co             VARCHAR2,
            last_foreign_currency_q_value   NUMBER,
            last_foreign_currency_q_date	DATE 
        ) RETURN SELF AS RESULT IS
    BEGIN
        --
        SELF.id                             := id;
        SELF.local_currency_co              := local_currency_co;
        SELF.foreign_currency_co            := foreign_currency_co;
        SELF.last_foreign_currency_q_value  := last_foreign_currency_q_value;
        SELF.last_foreign_currency_q_date   := last_foreign_currency_q_date;
        --
        SELF.days_per_year	 := 360;
        SELF.weeks_per_year	 := 52;
        SELF.months_per_year := 12;
        SELF.days_per_month	 := 30;
        SELF.days_per_week	 := 7;
        SELF.hours_per_day	 := 24;
        --
        RETURN;
        --
    END;
    --
    MAP MEMBER FUNCTION get_id RETURN NUMBER IS
    BEGIN
        --
        RETURN id;
        --
    END get_id;
    --
    MEMBER FUNCTION get_hours_per_week RETURN INTEGER IS 
    BEGIN 
        --
        RETURN hours_per_day * days_per_week;
        --
    END get_hours_per_week;
    --
    MEMBER FUNCTION get_currenvy_value( p_local_value IN NUMBER ) RETURN NUMBER IS 
    BEGIN 
        --
        RETURN p_local_value * NVL(last_foreign_currency_q_value,0);
        --
    END get_currenvy_value;    
    --
END;

/

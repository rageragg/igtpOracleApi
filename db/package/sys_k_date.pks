--------------------------------------------------------
--  DDL for Package sys_k_date
--------------------------------------------------------
/*
    Calendaring Syntax
    ---------------------------------------------------------------
    freq=daily	                                            Run once per day
    freq=daily;bymonthday=2	                                Run once on each 2nd day of a month
    freq=daily;bymonthday=-1	                            Run on the last day of a month
    freq=daily;byday=tue	                                Run on Tuesdays. For a strange reason, the given value freq= is irrelevant: 
                                                            freq=monthly;byday=tue or freq=minutely;byday=tue etc. produce the same calendar!
    freq=daily;byday=tue; byhour=12; byminute=0; bysecond=0	Run on tuesdays almost exactly at noon (the fraction of a second cannot be specified).
    freq=monthly;byday=2                                    tue	Run on each month's second tuesday
    freq=minutely;interval=5	                            Run every fifth minute.
    freq=hourly;byminute=7,31,42	                        Runs three times per hour: on each hour's 7th, 31st and 42nd minute.
    freq=minutely;byhour=7,8,16,17	                        Runs every minute, but only between 7:00 and 9:00, and between 16:00 and 18:00.
    freq=monthly;byday=mon,tue,wed,thu,fri;bysetpos=1	    Runs on each month's first business day.
    freq=monthly;byday=mon,tue,wed,thu,fri;bysetpos=-1	    Runs on each month's last business day.
    freq=daily;byday=mon,tue,wed,thu,fri;exclude=holidays	Run daily, Monday through Friday, but exclude days referenced in the schedule named holidays.
*/

CREATE OR REPLACE PACKAGE sys_k_date IS
    /*
        Purpose:    Package handles functionality related to DATE and time
        Remarks:    
        Who     DATE        Description
        ------  ----------  -------------------------------------
        MBR     19.09.2006  Created
    */
    --
    K_DATE_FMT_DATE                CONSTANT VARCHAR2(30) := 'dd/mm/yyyy';
    K_DATE_FMT_DATE_HOUR_MIN       CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi';
    g_date_fmt_date_hour_min_sec   CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
    --
    g_months_in_quarter            CONSTANT NUMBER := 3;
    g_months_in_year               CONSTANT NUMBER := 12;
    --
    TYPE t_period_date IS RECORD (
        year           NUMBER,
        month          NUMBER,
        day            NUMBER,
        days_in_month  NUMBER,
        the_date       DATE
    );
    --
    TYPE t_period_date_tab IS TABLE OF t_period_date;
    --
    -- RETURN year based on DATE
    FUNCTION get_year (p_date IN DATE) RETURN NUMBER;
    --
    -- RETURN month based on DATE
    FUNCTION get_month (p_date IN DATE) RETURN NUMBER;
    --
    -- RETURN start DATE of year based on DATE
    FUNCTION get_start_date_year (p_date IN DATE) RETURN DATE;
    --
    -- RETURN start DATE of year
    FUNCTION get_start_date_year (p_year IN NUMBER) RETURN DATE;
    --
    -- RETURN end DATE of year based on DATE
    FUNCTION get_end_date_year (p_date IN DATE) RETURN DATE;
    --
    -- RETURN end DATE of year
    FUNCTION get_end_date_year (p_year IN NUMBER) RETURN DATE;
    --
    -- RETURN start DATE of month based on DATE
    FUNCTION get_start_date_month (p_date IN DATE) RETURN DATE;
    --    
    -- RETURN start DATE of month
    FUNCTION get_start_date_month ( p_year  IN NUMBER,
                                    p_month IN NUMBER
                                  ) RETURN DATE;  
    --                          
    -- RETURN end DATE of month based on DATE
    FUNCTION get_end_date_month (p_date IN DATE) RETURN DATE;
    --
    -- RETURN end DATE of month
    FUNCTION get_end_date_month(p_year  IN NUMBER,
                                p_month IN NUMBER
                               ) RETURN DATE;
    --
    -- RETURN NUMBER of days IN given month
    FUNCTION get_days_in_month (p_year IN NUMBER,
                                p_month IN NUMBER) RETURN NUMBER;
    --
    -- RETURN NUMBER of days IN one period that fall within another period
    FUNCTION get_days_in_period (p_from_date_1 IN DATE,
                                 p_to_date_1 IN DATE,
                                 p_from_date_2 IN DATE,
                                 p_to_date_2 IN DATE) RETURN NUMBER;
    --
    -- returns true if period falls within range
    FUNCTION is_period_in_range (p_year IN NUMBER,
                                 p_month IN NUMBER,
                                 p_from_year IN NUMBER,
                                 p_from_month IN NUMBER,
                                 p_to_year IN NUMBER,
                                 p_to_month IN NUMBER) RETURN boolean;
    --                           
    -- get quarter based on month
    FUNCTION get_quarter (p_month IN NUMBER) RETURN NUMBER;
    --
    -- get time formatted as days, hours, minutes, seconds
    FUNCTION fmt_time (p_days IN NUMBER) RETURN varchar2;
    --
    -- get time between two dates formatted as days, hours, minutes, seconds
    FUNCTION fmt_time ( p_from_date IN DATE,
                        p_to_date IN DATE) RETURN varchar2;
    --                    
    -- get DATE formatted as DATE
    FUNCTION fmt_date (p_date IN DATE) RETURN varchar2;
    --
    -- get DATE formatted as DATE and time
    FUNCTION fmt_datetime (p_date IN DATE) RETURN varchar2;
    --
    -- get NUMBER of days IN year
    FUNCTION get_days_in_year (p_year IN NUMBER) RETURN NUMBER;

    -- returns collection of dates IN specified month
    FUNCTION explode_month (p_year IN NUMBER,
                            p_month IN NUMBER
                           ) RETURN t_period_date_tab pipelined;
    --
    -- get table of dates based on specified calendar string
    FUNCTION get_date_tab ( p_calendar_string IN varchar2,
                            p_from_date IN DATE := null,
                            p_to_date IN DATE := null
                          ) RETURN t_date_array pipelined;

end sys_k_date;
/
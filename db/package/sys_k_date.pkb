--------------------------------------------------------
--  DDL for Package sys_k_date
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY sys_k_date IS

    /*
        Purpose:    Package handles functionality related to DATE and time
        Remarks:    
        Who     DATE        Description
        ------  ----------  -------------------------------------
        MBR     19.09.2006  Created
    */
    --
    -- RETURN year based on DATE
    FUNCTION get_year (p_date IN DATE) RETURN NUMBER IS
        --
        l_returnvalue NUMBER;
        --
    BEGIN
        --
        l_returnvalue := to_number(to_char(p_date, 'YYYY'));
        --
        RETURN l_returnvalue;
        --
    END get_year;
    --
    -- RETURN month based on DATE
    FUNCTION get_month (p_date IN DATE) RETURN NUMBER IS
        --
        l_returnvalue NUMBER;
        --
    BEGIN
        --
        l_returnvalue := to_number(to_char(p_date, 'MM'));
        --
        RETURN l_returnvalue;
        --
    END get_month;
    --
    -- RETURN start DATE of year based on DATE
    FUNCTION get_start_date_year (p_date IN DATE) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --    
        l_returnvalue   := to_date( '01/01/' || to_char(get_year(p_date)), K_DATE_FMT_DATE);
        --
        RETURN l_returnvalue;
        --
    END get_start_date_year;
    --
    -- RETURN start DATE of year
    FUNCTION get_start_date_year (p_year IN NUMBER) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --
        l_returnvalue := to_date('01/01/' || to_char(p_year), K_DATE_FMT_DATE );
        --
        RETURN l_returnvalue;
        --
    END get_start_date_year;
    --
    -- RETURN END DATE of year based on DATE
    FUNCTION get_end_date_year (p_date IN DATE) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --
        l_returnvalue := to_date('31/12/' || to_char(get_year(p_date)), K_DATE_FMT_DATE);
        --
        RETURN l_returnvalue;
        --
    END get_end_date_year;
    --
    -- RETURN end DATE of year 
    FUNCTION get_end_date_year (p_year IN NUMBER) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --
        l_returnvalue := to_date('31/12/' || to_char(p_year), K_DATE_FMT_DATE);
        --
        RETURN l_returnvalue;
        --
    END get_end_date_year;
    --
    -- RETURN start DATE of month based on DATE
    FUNCTION get_start_date_month (p_date IN DATE) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --
        l_returnvalue := to_date('01/' || to_char(lpad(get_month(p_date),2,'0')) || '/' || to_char(get_year(p_date)), K_DATE_FMT_DATE);
        --
        RETURN l_returnvalue;
        --
    END get_start_date_month;
    --
    -- RETURN end DATE of month
    FUNCTION get_start_date_month ( p_year  IN NUMBER,
                                    p_month IN NUMBER) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --        
        l_returnvalue := to_date('01/' || to_char(lpad(p_month,2,'0')) || '/' || to_char(p_year), K_DATE_FMT_DATE);
        --
        RETURN l_returnvalue;
        --
    END get_start_date_month;
    --
    -- RETURN end DATE of month based on DATE                            
    FUNCTION get_end_date_month (p_date IN DATE) RETURN DATE IS
        --
        l_returnvalue DATE;
        --
    BEGIN
        --
        l_returnvalue := last_day(trunc(p_date));
        --
        RETURN l_returnvalue;
        --
    END get_end_date_month;
    --
    -- RETURN end DATE of month
    FUNCTION get_end_date_month ( p_year IN NUMBER,
                                  p_month IN NUMBER) RETURN DATE IS
        --  
        l_returnvalue DATE;
        --
    BEGIN
        --
        l_returnvalue := last_day(trunc(get_start_date_month(p_year, p_month)));
        --
        RETURN l_returnvalue;
        --
    END get_end_date_month;
    --
    -- RETURN NUMBER of days IN given month
    FUNCTION get_days_in_month ( p_year IN NUMBER,
                                 p_month IN NUMBER) RETURN NUMBER IS
        --
        l_returnvalue NUMBER;
        --
    BEGIN
        --
        l_returnvalue := get_end_date_month(p_year, p_month) - get_start_date_month(p_year, p_month) + 1;
        --    
        RETURN l_returnvalue;
        --
    END get_days_in_month;
    --
    -- RETURN NUMBER of days IN one period that fall within another period
    FUNCTION get_days_in_period ( p_from_date_1 IN DATE,
                                  p_to_date_1   IN DATE,
                                  p_from_date_2 IN DATE,
                                  p_to_date_2   IN DATE
                                ) RETURN NUMBER IS 
        --
        l_returnvalue   NUMBER;
        l_begin_date    DATE;
        l_end_date      DATE;
        --
    BEGIN
        --
        IF p_to_date_2 > p_from_date_1 THEN
            --
            IF p_from_date_1 < p_from_date_2 THEN
                l_begin_date := p_from_date_2;
            ELSE
                l_begin_date := p_from_date_1;
            END if;

            IF p_to_date_1 > p_to_date_2 THEN
                l_end_date := p_to_date_2;
            ELSE
                l_end_date := p_to_date_1;
            END if;
            --
            l_returnvalue := l_end_date - l_begin_date;
            --
        ELSE
            --
            l_returnvalue := 0;
            --
        END if;
        --
        IF l_returnvalue < 0 THEN
            l_returnvalue := 0;
        END if;
        --
        RETURN l_returnvalue;

    END get_days_in_period;
    --
    -- returns TRUE IF period falls within range
    FUNCTION is_period_in_range ( p_year        IN NUMBER,
                                  p_month       IN NUMBER,
                                  p_from_year   IN NUMBER,
                                  p_from_month  IN NUMBER,
                                  p_to_year     IN NUMBER,
                                  p_to_month    IN NUMBER
                                ) RETURN BOOLEAN IS
        --
        l_returnvalue BOOLEAN := false;
        --
        l_date        DATE;
        l_start_date  DATE;
        l_end_date    DATE;
        --
    BEGIN
        --
        l_date          := get_start_date_month(p_year, p_month);
        l_start_date    := get_start_date_month (p_from_year, p_from_month);
        l_end_date      := get_end_date_month (p_to_year, p_to_month);
        --
        IF l_date between l_start_date AND l_end_date THEN
            l_returnvalue := TRUE;
        END if;
        --
        RETURN l_returnvalue;
        --
    END is_period_in_range;
    --
    -- get quarter based on month
    FUNCTION get_quarter (p_month IN NUMBER) RETURN NUMBER IS
        --
        l_returnvalue NUMBER;
        --
    BEGIN
        --
        IF p_month IN (1,2,3) THEN
            l_returnvalue := 1;
        ELSIF p_month IN (4,5,6) THEN
            l_returnvalue := 2;
        ELSIF p_month IN (7,8,9) THEN
            l_returnvalue := 3;
        ELSIF p_month IN (10,11,12) THEN
            l_returnvalue := 4;
        END if;
        --
        RETURN l_returnvalue;
        --
    END get_quarter;
    --
    -- get time formatted as days, hours, minutes, seconds
    FUNCTION fmt_time (p_days IN NUMBER) RETURN VARCHAR2 IS 
        --
        l_days            NUMBER;
        l_hours           NUMBER;
        l_minutes         NUMBER;
        l_seconds         NUMBER;
        l_sign            VARCHAR2(6);
        l_returnvalue     VARCHAR2(8000);
        --
    BEGIN
        --    
        l_days      := nvl(trunc(p_days),0);
        l_hours     := nvl(((p_days - l_days) * 24), 0);
        l_minutes   := nvl(((l_hours - trunc(l_hours))) * 60, 0);
        l_seconds   := nvl(((l_minutes - trunc(l_minutes))) * 60, 0);
        --
        IF p_days < 0 THEN
            l_sign := 'minus ';
        ELSE
            l_sign := '';
        END if;
        --
        l_days      := abs(l_days);
        l_hours     := trunc(abs(l_hours));
        l_minutes   := trunc(abs(l_minutes));
        l_seconds   := round(abs(l_seconds));
        --
        IF l_minutes = 60 THEN
            l_hours:=l_hours + 1;
            l_minutes:=0;
        END if;
        --
        IF (l_days > 0) and (l_hours = 0) THEN
            l_returnvalue := sys_k_string_util.get_str('%1 days', l_days);
        ELSIF (l_days > 0) THEN
            l_returnvalue := sys_k_string_util.get_str('%1 days, %2 hours, %3 minutes', l_days, l_hours, l_minutes);
        ELSIF (l_hours > 0) and (l_minutes = 0) THEN
            l_returnvalue := sys_k_string_util.get_str('%1 hours', l_hours);
        ELSIF (l_hours > 0) THEN
            l_returnvalue := sys_k_string_util.get_str('%1 hours, %2 minutes', l_hours, l_minutes);
        ELSIF (l_minutes > 0) and (l_seconds = 0) THEN
            l_returnvalue := sys_k_string_util.get_str('%1 minutes', l_minutes);
        ELSIF (l_minutes > 0) THEN
            l_returnvalue := sys_k_string_util.get_str('%1 minutes, %2 seconds', l_minutes, l_seconds);
        ELSE
            l_returnvalue := sys_k_string_util.get_str('%1 seconds', l_seconds);
        END if;
        --
        l_returnvalue := l_sign || l_returnvalue;
        --
        RETURN l_returnvalue;
        --
    END fmt_time;
    --
    -- get time between two dates formatted as days, hours, minutes, seconds
    FUNCTION fmt_time ( p_from_date IN DATE,
                        p_to_date   IN DATE ) RETURN VARCHAR2 IS
    BEGIN
        --
        RETURN fmt_time (p_to_date - p_from_date);
        --
    END fmt_time;
    --
    -- format DATE as DATE
    FUNCTION fmt_date (p_date IN DATE) RETURN VARCHAR2 IS 
        --
        l_returnvalue     sys_k_string_util.t_max_pl_varchar2;
        --
    BEGIN
        --    
        l_returnvalue := to_char(p_date, K_DATE_FMT_DATE);
        --
        RETURN l_returnvalue;
        --
    END fmt_date;
    --
    -- format DATE as datetime
    FUNCTION fmt_datetime (p_date IN DATE) RETURN VARCHAR2 AS 
        --
        l_returnvalue     VARCHAR2(8000);
        --
    BEGIN
        --
        l_returnvalue := to_char(p_date, K_DATE_FMT_DATE_HOUR_MIN);
        --
        RETURN l_returnvalue;
        --
    END fmt_datetime;
    --
    -- get NUMBER of days IN year
    FUNCTION get_days_in_year (p_year IN NUMBER) RETURN NUMBER IS 
        --
        l_returnvalue NUMBER;
        --
    BEGIN 
        --
        l_returnvalue := get_start_date_month ((p_year + 1), 1) - get_start_date_month (p_year, 1);
        --
        RETURN l_returnvalue;
        --
    END get_days_in_year;
    --
    -- returns collection of dates IN specified month
    FUNCTION explode_month ( p_year IN NUMBER,
                             p_month IN NUMBER 
                           ) RETURN t_period_date_tab pipelined IS
        --                   
        l_date        DATE;
        l_start_date  DATE;
        l_end_date    DATE;
        l_day         pls_integer := 0;
        l_returnvalue t_period_date;
        --
    BEGIN
        --    
        l_returnvalue.year  := p_year; 
        l_returnvalue.month := p_month; 
        --
        l_start_date := get_start_date_month (p_year, p_month);
        l_end_date   := get_end_date_month (p_year, p_month);
        --
        l_returnvalue.days_in_month := l_end_date - l_start_date + 1; 
        l_date := l_start_date;
        --
        LOOP
            --
            l_day := l_day + 1;
            l_returnvalue.day := l_day;
            l_returnvalue.the_date := l_date;
            --
            PIPE ROW (l_returnvalue);
            --
            IF l_date >= l_end_date THEN
                EXIT;
            END if; 
            --
            l_date := l_date + 1;
            --
        END LOOP;
        --
        RETURN;
        --
    END explode_month;
    --
    -- get table of dates based on specified calendar string
    FUNCTION get_date_tab ( p_calendar_string IN VARCHAR2,
                            p_from_date IN DATE := null,
                            p_to_date IN DATE := null
                        ) RETURN t_date_array PIPELINED IS 
        --
        l_from_date   DATE := coalesce(p_from_date, sysdate);
        l_to_date     DATE := coalesce(p_to_date, add_months(l_from_date,12));
        l_date_after  DATE;
        l_next_date   DATE;
        --
    BEGIN
        --
        l_date_after := l_from_date - 1;
        --
        LOOP
            --
            dbms_scheduler.evaluate_calendar_string (
                calendar_string   => p_calendar_string,
                start_date        => l_from_date,
                return_date_after => l_date_after,
                next_run_date     => l_next_date
            );
            --
            EXIT WHEN l_next_date > l_to_date;
            --
            PIPE ROW (l_next_date);
            --
            l_date_after := l_next_date;
            --
        END LOOP;
        --
        RETURN;
        --
    END get_date_tab;
    --
END sys_k_date;
/
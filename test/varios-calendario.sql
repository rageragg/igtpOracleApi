select sys_k_date.get_days_in_year(2022) from dual;

select * 
  from sys_k_date.explode_month( 
                             p_year  => 2023,
                             p_month => 10
                           );

select rownum, t.*
  from sys_k_date.get_date_tab(
             p_calendar_string => 'FREQ=WEEKLY; BYDAY=MON,WED,FRI', 
             p_from_date       => trunc(sysdate), 
             p_to_date         => trunc(sysdate+90)
       ) t;
       
declare
   dt_start    date := date '2023-10-01';
   dt_after    date := dt_start;
   dt_next     date;
  
begin
 
   loop
 
     dbms_scheduler.evaluate_calendar_string(
        'freq     = monthly;'             ||
        'byday    = mon,tue,wed,thu,fri', --||
        --'bysetpos = 3'                    ,
         ---------------------------------
         dt_start                         ,
         return_date_after => dt_after    ,
         next_run_date     => dt_next
     );
    
     exit when dt_next > sysdate;
    
     dbms_output.put_line('next run date: ' || to_char(dt_next, 'yyyy-mm-dd'));
     dt_after := dt_next;
       
   end loop;
  
end;
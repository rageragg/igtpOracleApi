declare
    cursor c_cities is
        select *
          from cities ;
    --
    type typ_tab_cities is table of cities%rowtype index by pls_integer;
    --
    l_tab_cities    typ_tab_cities;
    l_count_rep     number  := 0;
    --
begin
    --
    open c_cities;
    loop
        --
        fetch c_cities
        bulk collect into l_tab_cities
        limit 5;
        --
        if l_tab_cities.count > 0  then
            --
            l_count_rep := l_count_rep + 1;
            --
            dbms_output.put_line( '----- ' || to_char( l_tab_cities.count ) || 'Rep: ('|| l_count_rep || ') -----');
            --
            for indx in l_tab_cities.first .. l_tab_cities.last loop
                dbms_output.put_line( 
                    l_tab_cities( indx ).city_co
                    || ' '
                    || l_tab_cities( indx ).description
                );
            end loop;
            --
        else
            exit;
        end if;
        --
    end loop;
    --
    close c_cities;
    --
end;
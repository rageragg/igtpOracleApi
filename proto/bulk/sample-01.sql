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
    -- crear el archivo log
    --
    open c_cities;
    loop
        --
        -- seleccion de los primeros 512 registros, y lo coloca en memoria (array, vector)
        fetch c_cities
        bulk collect into l_tab_cities
        limit 512;
        --
        -- se verifica si hay datos en la tabla de memoria (array, vector)
        if l_tab_cities.count > 0  then
            --
            l_count_rep := l_count_rep + 1;
            --
            dbms_output.put_line( '----- ' || to_char( l_tab_cities.count ) || 'Rep: ('|| l_count_rep || ') -----');
            --
            -- se recorre la tabla  de memoria (array, vector)
            for indx in l_tab_cities.first .. l_tab_cities.last loop
                --
                -- crear el log memoria
                --
            end loop;
            --
            -- vuelcas el log. en el archivo fisico ( con atributo escritura "append" )
            --
        else
            exit;
        end if;
        --
    end loop;
    --
    close c_cities;
    --
    -- cierras el archivo log
    --
end;
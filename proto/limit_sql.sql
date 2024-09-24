declare
    --
    CURSOR c_dutch_drivers IS
        SELECT drv.*
          FROM f1data.drivers drv
         WHERE drv.nationality = 'Dutch';
    --
    TYPE dutch_drivers_tt IS TABLE OF f1data.drivers%rowtype INDEX BY pls_integer;
    --
    l_dutch_drivers dutch_drivers_tt;
    --
BEGIN
    --
    OPEN c_dutch_drivers;
    LOOP
        --
        FETCH c_dutch_drivers BULK COLLECT INTO l_dutch_drivers LIMIT 500;
        --   
        dbms_output.put_line( 
            '----- '|| to_char( l_dutch_drivers.count )|| ' -----'
        );
        --
        if l_dutch_drivers.count > 0 then
            --
            for indx in l_dutch_drivers.first .. l_dutch_drivers.last loop
                --
                dbms_output.put_line( 
                    l_dutch_drivers( indx ).forename || ' ' || l_dutch_drivers( indx ).surname
                );
                --
            end loop;
            --
        else
            exit;
        end if;
        --
    END LOOP;
    --
    CLOSE c_dutch_drivers;
    --
END;
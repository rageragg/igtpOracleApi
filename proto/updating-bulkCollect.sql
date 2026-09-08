DECLARE 
    --
    TYPE t_tab_salarios IS TABLE OF NUMBER;
    --
    tab_salarios t_tab_salarios;
    --
BEGIN 
    --
    UPDATE EMPLEADOS 
       SET salario = (salario*1.15)
      RETURNING salario BULK COLLECT INTO tab_salarios;
    --
    FOR i IN 1..tab_salarios.COUNT LOOP 
        --
        dbms_output.put_line(
            i||' - '||tab_salarios(i)
        );
        --
    END LOOP;
    --
END;   
DECLARE
    --
    l_directory VARCHAR2(30)    := 'APP_OUTDIR';
    l_file_name VARCHAR2(128)   := 'freights.csv';
    --
    TYPE typ_data_freigth IS RECORD(
        freight_co	    VARCHAR2(20 byte),
        customer_co	    VARCHAR2(10 byte),
        route_co	    VARCHAR2(10 byte),
        type_cargo_co	VARCHAR2(10 byte),
        type_vehicle_co	VARCHAR2(10 byte),
        type_freight_co	VARCHAR2(10 byte),
        k_regimen	    VARCHAR2(20 byte),
        upload_at	    DATE,
        k_process	    VARCHAR2(20 byte),
        k_valid         CHAR(1) DEFAULT 'N',
        observations    VARCHAR2(80)
    );
    --
    TYPE tab_data_file          IS TABLE OF VARCHAR2(32000)         INDEX BY BINARY_INTEGER;
    TYPE tab_data_freigth       IS TABLE OF typ_data_freigth        INDEX BY BINARY_INTEGER;
    --
    g_data_file         tab_data_file;
    g_data_freigth      tab_data_freigth;
    --
    -- leemos los datos del archivo .CSV y lo cargamos en memoria
    PROCEDURE pp_lee_dato_archivo IS
        -- Local variables here
        l_file          utl_file.file_type;
        v_line          VARCHAR2(2048);
        l_cont          NUMBER := 0;
        l_error_archivo VARCHAR2(1) := 'N';
        --
    BEGIN
        --
        -- inicializamos los datos de las transacciones
        g_data_file.DELETE;
        --
        l_file := utl_file.fopen(l_directory, l_file_name, 'r');
        --
        LOOP
            --
            BEGIN
                --
                utl_file.get_line(l_file, v_line);
                --
                -- la primera iteracion es la cabecera
                IF l_cont > 0 THEN
                    --
                    -- tomamos las lineas
                    g_data_file(l_cont) := v_line;
                    --    
                END IF;
                --
                l_cont := l_cont + 1;
                --
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    EXIT;
            END;
            --
        END LOOP;
        --
        IF g_data_file.COUNT > 0 THEN 
            --
            dbms_output.put_line(
                'Datos Cargados, Cantidad de Registros: ' || l_cont
            );
            --
        END IF;
        --
        utl_file.fclose(l_file);
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                --
                IF utl_file.is_open(l_file) THEN
                    utl_file.fclose(l_file);
                END IF;
            --
            WHEN OTHERS THEN
                --
                dbms_output.put_line(
                    SQLERRM
                );
                --
                IF utl_file.is_open(l_file) THEN
                    utl_file.fclose(l_file);
                END IF;
                --
    END pp_lee_dato_archivo;
    --
    -- procesamos los datos que estan en memoria
    PROCEDURE pp_procesa_dato IS
        --
        l_reg_freigth   typ_data_freigth;
        --
        -- cursor recursivo para separar los datos en columnas
        CURSOR c_datos(pp_line VARCHAR2) IS
            SELECT rownum, regexp_substr(pp_line, '[^;]+', 1, LEVEL) dato
            FROM DUAL
            CONNECT BY regexp_substr(pp_line, '[^;]+', 1, LEVEL) IS NOT NULL;
        --
    BEGIN
        --
        -- eliminamos los datos iniciales
        g_data_freigth.DELETE;
        --
        -- leemos las lineas
        FOR i IN 1 .. g_data_file.COUNT LOOP
            --
            IF g_data_file.EXISTS(i) THEN   
                --
                -- leemos las columnas
                FOR reg IN c_datos(g_data_file(i)) LOOP
                    --
                    reg.dato := trim(reg.dato);
                    --
                    IF reg.rownum = 1 THEN 
                        --
                        -- codigo del viaje
                        l_reg_freigth.freight_co :=reg.dato; 
                        --
                    ELSIF reg.rownum = 2 THEN 
                        --
                        -- fecha de viaje
                        l_reg_freigth.upload_at := to_date(reg.dato, 'ddmmyyyy'); 
                        --                        
                    ELSIF reg.rownum = 3 THEN 
                        --
                        -- codigo del cliente
                        l_reg_freigth.customer_co := reg.dato; 
                        --
                    ELSIF reg.rownum = 4 THEN 
                        --
                        -- codigo del conductor
                        -- TODO: tratamiento en fase posterior
                        NULL;
                        --  
                    ELSIF reg.rownum = 5 THEN 
                        --
                        -- codigo del tipo de carga
                        l_reg_freigth.type_cargo_co := reg.dato; 
                        --   
                    ELSIF reg.rownum = 6 THEN 
                        --
                        -- codigo de la ruta
                        l_reg_freigth.route_co := reg.dato; 
                        --
                    ELSIF reg.rownum = 7 THEN 
                        --
                        -- codigo del tipo de vehiculo
                        l_reg_freigth.type_vehicle_co := reg.dato; 
                        --  
                    ELSIF reg.rownum = 8 THEN 
                        --
                        -- codigo del tipo de viaje
                        l_reg_freigth.type_freight_co := reg.dato; 
                        --    
                    ELSIF reg.rownum = 9 THEN 
                        --
                        -- codigo del regimen de viaje
                        l_reg_freigth.k_regimen := reg.dato; 
                        --  
                    ELSIF reg.rownum = 10 THEN 
                        --
                        -- codigo proceso a aplicar
                        l_reg_freigth.k_process := reg.dato; 
                        --                                         
                    END IF;
                    --   
                END LOOP;
                --
                -- cargamos el registro en memoria
                g_data_freigth(i) := l_reg_freigth;
                --
            END IF;
            --
        END LOOP;
        --
        -- eliminamos los datos temporales
        g_data_file.DELETE;
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN OTHERS THEN
                --
                dbms_output.put_line(
                    SQLERRM
                );
                --
    END pp_procesa_dato;        
    --
    -- lista contenido de registros de memoria
    PROCEDURE pp_listar IS 
        --
        l_reg_freigth   typ_data_freigth;
        --
    BEGIN 
        --
        FOR i IN 1..g_data_freigth.COUNT LOOP 
            --
            l_reg_freigth := g_data_freigth(i);
            --
            dbms_output.put_line(
                l_reg_freigth.freight_co ||' '||
                l_reg_freigth.customer_co ||' '||
                l_reg_freigth.route_co ||' '||
                l_reg_freigth.type_cargo_co ||' '||
                l_reg_freigth.type_vehicle_co ||' '||
                l_reg_freigth.type_freight_co ||' '||
                l_reg_freigth.k_regimen ||' '||
                l_reg_freigth.upload_at ||' '||
                l_reg_freigth.k_process
            );
            --
        END LOOP;
        --
    END pp_listar;
    --
BEGIN
    --
    pp_lee_dato_archivo;
    --
    pp_procesa_dato;
    --
    pp_listar;
    --
    -- TODO: Validar los datos que se han cargado
    --
END;
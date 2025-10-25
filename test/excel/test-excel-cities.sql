DECLARE
    /*
        Flujo de uso
            1.- Crear el documento
            2.- Agregar estilos (opcional)
            3.- Crear la hoja del documento
            4.- Crear contenido del documento
            5.- Cerrar el documento
    */
    --
    -- variables
    l_directorio            VARCHAR2(128) := 'APP_OUTDIR';
    l_libro_excel           VARCHAR2(128) := 'reporte-localidades.xls';
    --
    l_hoja_trabajo          VARCHAR2(30)  := 'LOCALIDADES';
    l_titulo_localidades    VARCHAR2(30)  := 'LOCALIDADES EN CIUDADES';
    l_fila                  NUMBER := 1;
    l_columna               NUMBER := 1;
    --
    -- creacion fisica del archivo xls
    PROCEDURE pp_crear_archivo IS  
    BEGIN 
        --
        utl_k_gen_xls.create_excel(
            p_directory => l_directorio,
            p_file_name => l_libro_excel
        );
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(
                    'ERROR: pp_crear_archivo -> ' || SQLERRM
                );
        --        
    END pp_crear_archivo;
    --
    -- crea los estilos de celdas
    PROCEDURE pp_crear_estilos IS 
    BEGIN   
        --
        utl_k_gen_xls.create_style(
            p_style_name  => 'Titulo',
            p_fontname    => 'Arial',
            p_fontcolor   => 'White',
            p_fontsize    => 14,
            p_bold        => True,
            p_italic      => True,
            p_underline   => 'False',
            p_backcolor   => 'Gray'
        );
        --
        utl_k_gen_xls.create_style(
            p_style_name  => 'Normal_Right',
            p_fontsize    => 12,
            p_h_alignment => 'Right'
        );
        --
        utl_k_gen_xls.create_style(
            p_style_name  => 'Normal_Left',
            p_fontsize    => 12,
            p_h_alignment => 'Left'
        );
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(
                    'ERROR: pp_crear_estilos -> ' || SQLERRM
                );
        -- 
    END pp_crear_estilos;
    --
    -- crea la hoja de trabajo dentro del libro
    PROCEDURE pp_crear_hoja IS 
    BEGIN
        --
        utl_k_gen_xls.create_worksheet(
            p_worksheet_name => l_hoja_trabajo
        );
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(
                    'ERROR: pp_crear_hoja -> ' || SQLERRM
                );
        -- 
    END pp_crear_hoja;
    --
    -- CONTENIDO DE LA HOJA DE TRABAJO
    -- titulos y encabezados de columnas
    PROCEDURE pp_encabezado IS 
        --
        l_estilo    VARCHAR2(64);
        --
        -- titulos de las columnas del reporte
        CURSOR c_columns IS 
            SELECT *
              FROM all_tab_columns 
             WHERE owner       = 'IGTP'
               AND table_name  = 'CITIES'
               AND column_name IN ('ID', 'CITY_CO', 'DESCRIPTION', 'POSTAL_CO', 'TELEPHONE_CO', 'NU_GPS_LAT', 'NU_GPS_LON')
            ORDER BY column_id;
        --   
        TYPE typ_tab_columns IS TABLE OF all_tab_columns%ROWTYPE INDEX BY PLS_INTEGER;
        --
        l_tab_columns   typ_tab_columns;            
        --
    BEGIN 
        --
        utl_k_gen_xls.set_column_width(
            p_column    => 1, 
            p_width     => 200, 
            p_worksheet => l_hoja_trabajo
        );
        --
        -- ! titulos del reporte 
        utl_k_gen_xls.write_cell_char(
            p_row            => l_fila,
            p_column         => l_columna,
            p_worksheet_name => l_hoja_trabajo,
            p_value          => l_titulo_localidades,
            p_style          => 'Titulo'
        );
        --
        l_columna := 0;
        l_fila    := 2;
        --
        -- ! encabezados de columna
        OPEN c_columns;
        LOOP
            --
            FETCH c_columns
            BULK COLLECT INTO l_tab_columns
            LIMIT 512;
            --
            dbms_output.put_line(l_tab_columns.count);
            --
            IF l_tab_columns.count > 0 THEN
                --
                FOR indx IN l_tab_columns.FIRST .. l_tab_columns.LAST LOOP
                    --
                    l_columna := l_columna + 1;
                    --
                    IF l_tab_columns( indx ).data_type = 'NUMBER' THEN 
                        --
                        l_estilo := 'Normal_Right';
                        --
                    ELSE
                        --
                        l_estilo := 'Normal_Left';
                        --
                    END IF; 
                    --
                    dbms_output.put_line(l_tab_columns( indx ).column_name);
                    --
                    utl_k_gen_xls.write_cell_char(
                        p_row            => l_fila,
                        p_column         => l_columna,
                        p_worksheet_name => l_hoja_trabajo,
                        p_value          => l_tab_columns( indx ).column_name,
                        p_style          => l_estilo
                    );
                    --
                END LOOP;
                --
            ELSE
                --
                EXIT;
                --
            END IF;
            --
        END LOOP;
        --
        CLOSE c_columns;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(
                    'ERROR: pp_encabezado -> ' || SQLERRM
                );
        --
    END pp_encabezado;
    --
    -- detalle del reporte
    PROCEDURE pp_detalle IS 
        --
        -- datos
        CURSOR c_ciudades IS 
            SELECT id, city_co, description, postal_co, telephone_co, nu_gps_lat, nu_gps_lon 
              FROM cities 
              ORDER BY 2;
        --
        PROCEDURE pp_agrega_celda( 
                p_valor     VARCHAR2, 
                p_estilo    VARCHAR2,
                p_tipo      VARCHAR2 DEFAULT 'VARCHAR2'
            ) IS 
        BEGIN 
            --
            l_columna := l_columna + 1;
            --
            IF p_tipo = 'NUMBER' THEN 
                --
                utl_k_gen_xls.write_cell_num(
                    p_row            => l_fila,
                    p_column         => l_columna,
                    p_worksheet_name => l_hoja_trabajo,
                    p_value          => nvl(p_valor,0),
                    p_style          => p_estilo
                );
                --
            ELSE
                --
                utl_k_gen_xls.write_cell_char(
                    p_row            => l_fila,
                    p_column         => l_columna,
                    p_worksheet_name => l_hoja_trabajo,
                    p_value          => nvl(p_valor,' '),
                    p_style          => p_estilo
                );
                --
            END IF;
            --
        END pp_agrega_celda;
        --
    BEGIN 
        --
        FOR r_ciudad IN c_ciudades LOOP
            --
            l_fila := l_fila + 1;
            l_columna := 0;
            --
            pp_agrega_celda( r_ciudad.id, 'Normal_Left' );
            pp_agrega_celda( r_ciudad.city_co, 'Normal_Left' );
            pp_agrega_celda( r_ciudad.description, 'Normal_Left' );
            pp_agrega_celda( r_ciudad.postal_co, 'Normal_Left' );
            pp_agrega_celda( r_ciudad.telephone_co, 'Normal_Left' );
            pp_agrega_celda( r_ciudad.nu_gps_lat, 'Normal_Right', 'NUMBER' );
            pp_agrega_celda( r_ciudad.nu_gps_lon, 'Normal_Right', 'NUMBER' );
            --
        END LOOP;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(
                    'ERROR: pp_detalle -> ' || SQLERRM
                );
        --
    END pp_detalle;
    --
    -- cierra el archivo excel
    PROCEDURE pp_cierra_archivo IS 
    BEGIN 
        --
        utl_k_gen_xls.close_file;    
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line(
                    'ERROR: pp_cierra_archivo -> ' || SQLERRM
                );
        --
    END pp_cierra_archivo;
    --
BEGIN
    --
    utl_k_gen_xls.DEBUG_FLAG := FALSE;
    --
    -- ! se crea el archivo fisico (libro), en el directorio
    pp_crear_archivo;
    --
    -- ! se agregan estilos para las celdas
    pp_crear_estilos;
    --
    -- ! se crea una hoja en el libro
    pp_crear_hoja;
    --
    -- ! encabezado del reporte
    pp_encabezado;   
    -- 
    -- ! detalles del reporte
    pp_detalle;
    --
    -- ! se cierra el archivo
    pp_cierra_archivo;
    --
END;
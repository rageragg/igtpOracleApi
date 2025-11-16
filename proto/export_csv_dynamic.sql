/*
EXEC export_csv_dynamic(
   p_query       => 'SELECT id, nombre, salario FROM empleados',
   p_filename    => 'empleados.csv',
   p_separator   => ';',
   p_with_header => TRUE
);
*/

CREATE OR REPLACE PROCEDURE export_csv_dynamic (
    p_query       VARCHAR2,   -- Consulta SQL dinámica
    p_filename    VARCHAR2,   -- Nombre del archivo CSV
    p_separator   VARCHAR2 DEFAULT ',', -- Separador configurable
    p_with_header BOOLEAN DEFAULT TRUE  -- Incluir encabezado
) IS
    v_file    UTL_FILE.FILE_TYPE;
    v_cursor  SYS_REFCURSOR;
    v_line    VARCHAR2(32767);
    v_col_cnt INTEGER;
    v_desc    DBMS_SQL.DESC_TAB;
    v_cursor_id INTEGER;
BEGIN
    -- Abrimos archivo en directorio Oracle previamente creado
    v_file := UTL_FILE.FOPEN('EXPORT_DIR', p_filename, 'W');

    -- Preparamos cursor dinámico
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor_id, p_query, DBMS_SQL.NATIVE);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_cnt, v_desc);

    -- Escribimos encabezado si corresponde
    IF p_with_header THEN
        v_line := '';
        FOR i IN 1 .. v_col_cnt LOOP
            v_line := v_line || v_desc(i).col_name ||
                    CASE WHEN i < v_col_cnt THEN p_separator ELSE '' END;
        END LOOP;
        UTL_FILE.PUT_LINE(v_file, v_line);
    END IF;

    -- Definimos variables para cada columna
    FOR i IN 1 .. v_col_cnt LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_line, 32767);
    END LOOP;

    -- Ejecutamos y recorremos resultados
    v_cursor := DBMS_SQL.TO_REFCURSOR(v_cursor_id);
    LOOP
        EXIT WHEN DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0;
        v_line := '';
        FOR i IN 1 .. v_col_cnt LOOP
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_line);
            v_line := v_line || CASE WHEN i < v_col_cnt THEN p_separator ELSE '' END;
        END LOOP;
        UTL_FILE.PUT_LINE(v_file, v_line);
    END LOOP;

    -- Cerramos recursos
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    UTL_FILE.FCLOSE(v_file);

    -- Logging de auditoría
    COMMIT;
    --
EXCEPTION
    WHEN OTHERS THEN
        -- Manejo de errores robusto
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        IF UTL_FILE.IS_OPEN(v_file) THEN
            UTL_FILE.FCLOSE(v_file);
        END IF;
        RAISE;
END export_csv_dynamic;

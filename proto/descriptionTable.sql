DECLARE
    /*
        PL/SQL Block Template
        PROCESO: Descripcion de metadatos de una determinada tabla
        AUTOR: RAGE
        FECHA CREACION: 2025-10-25  
        FECHA MODIFICACION:
        VERSION: 1.0     
    */
    --
    l_owner         VARCHAR2(100)   := 'IGTP';
    l_table_name    VARCHAR2(100)   := 'CITIES';
    l_sql_query     VARCHAR2(16384) := '';
    l_sql_select    VARCHAR2(8192)  := 'SELECT ';
    l_sql_fields    VARCHAR2(1024)  := '';
    l_sql_from      VARCHAR2(1024)  := ' FROM ';
    l_sql_where     VARCHAR2(1024)  := ' WHERE ';
    l_sql_order     VARCHAR2(512)   := ' ORDER BY 1';
    --
    -- estructuras de datos del diccionario de datos
    l_data_map_rec  igtp.sys_k_utils.data_map_rec;
    l_data_map_tab  igtp.sys_k_utils.data_map_tab;
    l_idx           VARCHAR2(30);
    --
    TYPE t_key_list IS TABLE OF PLS_INTEGER;
    l_sorted_keys t_key_list;
    --
    FUNCTION get_sorted_keys_from_assoc(
            p_tab IN igtp.sys_k_utils.data_map_tab
        ) RETURN t_key_list IS
        --
        l_keys t_key_list := t_key_list();
        --
        -- reusar quicksort_str pero para keys
        PROCEDURE swap_key(
                p_list IN OUT NOCOPY t_key_list, 
                i IN PLS_INTEGER, 
                j IN PLS_INTEGER
            ) IS
            --
            tmp VARCHAR2(30);
            --
        BEGIN
            tmp         := p_list(i);
            p_list(i)   := p_list(j);
            p_list(j)   := tmp;
            --
        END swap_key;

        PROCEDURE quicksort_key(
                p_list  IN OUT NOCOPY t_key_list, 
                lo      IN PLS_INTEGER, 
                hi      IN PLS_INTEGER
            ) IS
            --
            i       PLS_INTEGER := lo;
            j       PLS_INTEGER := hi;
            pivot   PLS_INTEGER;
            --
        BEGIN
            --
            IF lo >= hi THEN 
                RETURN; 
            END IF;
            --
            pivot := p_list((lo+hi)/2);
            --
            WHILE i <= j LOOP
                --
                WHILE p_list(i) < pivot LOOP i := i + 1; END LOOP;
                --
                WHILE p_list(j) > pivot LOOP j := j - 1; END LOOP;
                --
                IF i <= j THEN
                    --
                    swap_key(p_list, i, j);
                    --
                    i := i + 1;
                    j := j - 1;
                    --
                END IF;
                --
            END LOOP;
            --
            IF lo < j THEN quicksort_key(p_list, lo, j); END IF;
            IF i < hi THEN quicksort_key(p_list, i, hi); END IF;
            --
        END quicksort_key;
        --
    BEGIN
        --
        -- poblar lista de claves usando FIRST / NEXT
        l_idx := p_tab.FIRST;
        --
        WHILE l_idx IS NOT NULL LOOP
            --
            l_keys.EXTEND;
            l_keys(l_keys.COUNT) := p_tab(l_idx).column_id; -- l_idx;
            l_idx := p_tab.NEXT(l_idx);
            --
        END LOOP;

        IF l_keys.COUNT > 1 THEN
            --
            quicksort_key(l_keys, 1, l_keys.COUNT);
            --
        END IF;
        --
        RETURN l_keys;
        --
    END get_sorted_keys_from_assoc;
    --
BEGIN
    --
    -- obtener la descripcion de la tabla
    l_data_map_tab := igtp.sys_k_utils.get_map_data(
        p_owner      => l_owner,
        p_table_name => l_table_name
    );
    --
    -- obtener las claves ordenadas
    l_sorted_keys := get_sorted_keys_from_assoc(l_data_map_tab);
    --
    -- mostrar la descripcion de la tabla
    -- Iterar seguro usando FIRST / NEXT
    l_idx := l_sorted_keys.FIRST;
    --
    WHILE l_idx IS NOT NULL LOOP
        --
        -- obtener el registro
        -- l_data_map_rec := l_data_map_tab(l_sorted_keys(l_idx));
        l_data_map_rec := igtp.sys_k_utils.get_map_data_rec_by_id( 
            p_column_id => l_sorted_keys(l_idx),
            p_mdata     => l_data_map_tab 
        );
        --
        -- armar cadena de salida
        l_sql_fields := l_sql_fields || l_data_map_rec.column_name;
        --
        l_idx := l_sorted_keys.NEXT(l_idx);
        --
        IF l_idx IS NOT NULL THEN
            --
            l_sql_fields := l_sql_fields || ', ';
            --
        END IF;
        --
    END LOOP;
    --
    -- mostrar la informacion
    l_sql_query := l_sql_select || 
                   l_sql_fields || 
                   l_sql_from || 
                   l_owner || '.' || 
                   l_table_name || 
                   l_sql_order;
    --
    dbms_output.put_line(
        l_sql_query
    );
    --
END;
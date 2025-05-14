DECLARE
    --
    -- parameters
    l_owner         VARCHAR2(30) := 'IGTP';
    l_table_name    VARCHAR2(30) := 'CITIES';
    --
    l_tab_map       igtp.sys_k_utils.data_map_tab;
    l_idx           VARCHAR2(30);
    --
BEGIN 
    --
    l_tab_map := igtp.sys_k_utils.get_map_data(
        p_owner         => l_owner, 
        p_table_name    => l_table_name
    );
    --
    dbms_output.put_line('Test');
    --
    -- Obtener el primer índice
    l_idx := l_tab_map.FIRST;
    --
    -- Recorrer el arreglo asociativo
    WHILE l_idx IS NOT NULL LOOP
        --
        -- Imprimir el índice y el valor
        dbms_output.put_line('Column Name: ' || l_tab_map(l_idx).column_name);
        dbms_output.put_line('Data Type  : ' || l_tab_map(l_idx).data_type);
        dbms_output.put_line('Data Length: ' || l_tab_map(l_idx).data_length);
        dbms_output.put_line('Comments   : ' || l_tab_map(l_idx).comments);
        --
        -- Obtener el siguiente índice
        l_idx := l_tab_map.NEXT(l_idx);
        --
    END LOOP;
    /*
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'column_name' VALUE a.column_name,
                'data_type' VALUE a.data_type,
                'data_length' VALUE a.data_length,
                'comments' VALUE b.comments,
                'column_id' VALUE a.column_id 
            )
        ) AS cities_json
            FROM all_tab_columns a
            INNER JOIN all_col_comments b ON a.owner       = b.owner
                                        AND a.table_name  = b.table_name
                                        AND a.column_name = b.column_name
            WHERE a.owner = 'IGTP' 
                AND a.table_name = 'CITIES' 
                ORDER BY a.column_id;
    */
    --
END;
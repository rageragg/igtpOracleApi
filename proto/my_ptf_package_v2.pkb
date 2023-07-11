
/*
 * Tratamiento de tablas polimorficas
*/
CREATE OR REPLACE PACKAGE BODY my_ptf_package_v2 AS
    --
    -- el metodo describe es obligatorio segun la implementacion de
    -- tablas polimorficas
    FUNCTION describe (
        tab             IN OUT dbms_tf.table_t, 
        cols2stay       IN dbms_tf.columns_t,
        new_col_name    IN DBMS_ID DEFAULT 'AGG_COL'
    ) RETURN dbms_tf.describe_t IS
    BEGIN
        --
        -- recorremos todas las columnas de la tabla pasada como parametros
        FOR I IN 1 .. tab.COLUMN.COUNT LOOP  
            --
            -- verificamos las columnas que no son excluida de la salida,
            -- son las que no se especifican en el parametro cols2stay
            IF NOT tab.COLUMN(i).description.name MEMBER OF cols2stay THEN
                tab.column(i).pass_through := FALSE; -- no formara parte de la salida
                tab.column(i).for_read := TRUE;      -- se procesaran en FETCH_ROWS
            END IF;
            --
        END LOOP;
        --
        -- creamos una nueva columna y la retornamos para que se agrege
        -- a la descripcion
        RETURN dbms_tf.describe_t( 
            new_columns => dbms_tf.columns_new_t( 
                    1 => dbms_tf.column_metadata_t(
                            name => new_col_name,  
                            type => dbms_tf.type_varchar2
                         )
                    )
            );
        --    
    END describe; 
    --
    /*
     * Tratamiento de la transformacion de la informacion
     * segun cada necesidad
    */
    PROCEDURE fetch_rows(new_col_name IN DBMS_ID DEFAULT 'AGG_COL')  IS
        --
        inp_rs dbms_tf.row_set_t; -- datos actuales
        out_rs dbms_tf.row_set_t; 
        colcnt PLS_INTEGER;
        rowcnt PLS_INTEGER;
        --
    BEGIN
        --
        -- Obtenemos las filas de la base de datos marcadas como 
        -- for_read = TRUE, desde la funcion describe
        dbms_tf.get_row_set( 
            rowset      => inp_rs, 
            row_count   => rowcnt, 
            col_count   => colcnt
        );
        --
        -- recorremos las filas actuales procedente de la base de datos
        FOR r IN 1..rowcnt LOOP
            --
            -- inicializamos el objeto de salida
            out_rs(1).tab_varchar2(r) := '';
            --
            -- recorremos las columnas
            FOR c IN 1..colcnt LOOP
                --
                -- con inp_rs(c) obtenemos el valor de la columna en una determinada fila
                -- en este caso usamos la coleccion tab_varchar2 para almacenar cadenas de 
                -- caracteres
                out_rs(1).tab_varchar2(r) := 
                                    out_rs(1).tab_varchar2(r)||';'||
                                    dbms_tf.col_to_char(inp_rs(c), r);
                --
            END LOOP;
            --
            -- eliminamos el primer caracter ';'
            out_rs(1).tab_varchar2(r) := ltrim(out_rs(1).tab_varchar2(r) ,';'); 
            --
        END LOOP;
        --
        -- colocamos el conjunto de nuevas columnas resultantes luego 
        -- de la transformacion
        dbms_tf.put_row_set(
            rowset => out_rs
        ); 
        --
    END fetch_rows;
    --
END my_ptf_package_v2;
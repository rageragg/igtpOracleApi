CREATE OR REPLACE PACKAGE BODY pro_k_add_cols IS 
    --
    FUNCTION describe( 
        tab     IN OUT dbms_tf.table_t,
        cols    IN dbms_tf.columns_t
    ) RETURN dbms_tf.describe_t IS 
        --
        new_cols    dbms_tf.columns_new_t;
        --
    BEGIN 
        --
        -- recorremos las columnas 
        FOR i IN 1 .. cols.COUNT LOOP    
            --
            new_cols(i) := dbms_tf.column_metadata_t( 
                name => cols(i),
                type => dbms_tf.type_number,
                max_len => 10
            );
            --
        END LOOP;
        --
        RETURN dbms_tf.describe_t( new_columns => new_cols );
        --
    END describe;
    --
    PROCEDURE fetch_rows IS 
        --
        env     dbms_tf.env_t;
        cols    dbms_tf.tab_number_t;
        --
    BEGIN 
        --
        env := dbms_tf.get_env();
        --
        -- recorremos las columnas agregadas
        FOR clmn IN 1 .. env.ref_put_col.COUNT LOOP 
            --
            FOR rw IN 1 .. env.row_count LOOP 
                --
                cols(rw) :=  rw * clmn;
                --
            END LOOP;
            --
            dbms_tf.put_col(clmn, cols );
            --
        END LOOP;
        --
        --
    END fetch_rows;    
    --
END pro_k_add_cols;
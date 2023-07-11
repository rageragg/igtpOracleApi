CREATE OR REPLACE PACKAGE pro_k_add_cols IS 
    --
    FUNCTION describe( 
        tab     IN OUT dbms_tf.table_t,
        cols    IN dbms_tf.columns_t
    ) RETURN dbms_tf.describe_t;
    --
    PROCEDURE fetch_rows;
    --
END pro_k_add_cols;
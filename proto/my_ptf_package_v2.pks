CREATE OR REPLACE PACKAGE my_ptf_package_v2 AS
    --
    -- USO: select * from my_ptf_package_v2.my_ptf( tab => t, cols2stay => COLUMNS(A) );   
    /*
    || Tabla: t( A, B, C )
    || Salida: 
    || A    AGG_COL
    || ---- ----------
    || 1	2;3;"ONE"
    || 4	5;6;"TWO"
    || 7	8;9;"THREE"     
    */
    FUNCTION my_ptf (
        tab             IN TABLE,
        cols2stay       IN COLUMNS DEFAULT NULL,
        new_col_name    IN VARCHAR2 DEFAULT 'AGG_COL'
    ) RETURN TABLE PIPELINED ROW POLYMORPHIC 
             USING my_ptf_package_v2;
    --
    FUNCTION describe(
        tab             IN OUT dbms_tf.table_t,
        cols2stay       IN dbms_tf.columns_t,
        new_col_name    IN DBMS_ID DEFAULT 'AGG_COL'
    ) RETURN dbms_tf.describe_t; 
    --
    PROCEDURE fetch_rows (new_col_name IN DBMS_ID DEFAULT 'AGG_COL');
    --    
END my_ptf_package_v2;
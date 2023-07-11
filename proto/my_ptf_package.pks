/*
    Uso: SELECT *
           FROM my_ptf_package.my_ptf(t, COLUMNS(C), 'D', 'Hello world!');
*/
CREATE OR REPLACE PACKAGE my_ptf_package AS
    --
    FUNCTION my_ptf (
        tab             TABLE,
        cols_to_discard COLUMNS DEFAULT NULL,
        new_col_name    VARCHAR2 DEFAULT NULL,
        new_col_val     VARCHAR2 DEFAULT NULL
    ) RETURN TABLE PIPELINED ROW POLYMORPHIC 
             USING my_ptf_package;
    --
    FUNCTION describe(
        tab             IN OUT dbms_tf.table_t,
        cols_to_discard IN dbms_tf.columns_t DEFAULT NULL,
        new_col_name    IN VARCHAR2 DEFAULT NULL,
        new_col_val     IN VARCHAR2 DEFAULT NULL
    ) RETURN dbms_tf.describe_t;
    --
    PROCEDURE fetch_rows (
        new_col_name    IN VARCHAR2 DEFAULT NULL,
        new_col_val     IN VARCHAR2 DEFAULT NULL
    );
    --
END my_ptf_package;
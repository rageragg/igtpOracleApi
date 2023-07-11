/*
  Uso: 
  select * 
  from add_columns( dual, columns( c1, c2, c3 ) );
*/
CREATE OR REPLACE FUNCTION add_columns( 
    tab     TABLE,
    cols    COLUMNS
) RETURN 
  TABLE PIPELINED 
  TABLE POLYMORPHIC
  USING pro_k_add_cols;
  
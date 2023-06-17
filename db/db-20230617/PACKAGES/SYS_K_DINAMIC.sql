--------------------------------------------------------
--  DDL for Package SYS_K_DINAMIC
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."SYS_K_DINAMIC" AS
    --
    /* -------------------- DESCRIPCION -------------------- 
    || Permite realizar acciones dinamicas, tales como eje-
    || cuciones de procedimientos, sentencias, etc.
    */ -----------------------------------------------------
    --
    TYPE t_t_values IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
    TYPE c_return1 IS REF CURSOR;
    --
    PROCEDURE p_set_val( p_nam_col VARCHAR2, p_val_col VARCHAR2);
    --
    /* --------------------------------------------------------
    || Rellena tabla PL con los valores que se necesitan para
    || la condicion del cursor variable
    */ --------------------------------------------------------
    --
    PROCEDURE p_set_val( p_nam_col VARCHAR2, p_val_col NUMBER );
    --
    /* --------------------------------------------------------
    || Rellena tabla PL con los valores que se necesitan para
    || la condicion del cursor variable
    */ --------------------------------------------------------
    --
    PROCEDURE p_set_val( p_nam_col VARCHAR2, p_val_col DATE );
    --
    /* --------------------------------------------------------
    || Rellena tabla PL con los valores que se necesitan para
    || la condicion del cursor variable
    */ --------------------------------------------------------
    --
    FUNCTION f_value_in_table(
                                p_table   VARCHAR2,
                                p_column VARCHAR2,
                                p_where   VARCHAR2
                             ) RETURN VARCHAR2;
    --
    /* --------------------------------------------------------
    || Devuelve la primera fila que comple la condicion de la
    || columna y tabla eviada como parametro
    */ --------------------------------------------------------
    --
    FUNCTION f_value_in_table(
                                p_table     VARCHAR2,
                                p_column   VARCHAR2,
                                p_where     VARCHAR2,
                                p_t_values t_t_values 
                             ) RETURN VARCHAR2;
    --
    /* --------------------------------------------------------
    || Devuelve la primera fila que cumple la condicion de la
    || columna y tabla eviada como parametro.
    || Se le pasan los parametros que necesita la sentencia SQL 
    || en la variable de tipo tabla p_t_values
    */ --------------------------------------------------------
    --
    PROCEDURE p_exec_procedure(p_procedure VARCHAR2);
    --
    /* --------------------------------------------------------
    || Ejecuta el procedimiento enviado como parametro
    */ --------------------------------------------------------
    --
    PROCEDURE p_exec_procedure(p_procedure VARCHAR2, p_t_values t_t_values);
    --
    /* --------------------------------------------------------
    || Ejecuta el procedimiento enviado como par?metro asignadose
    || las variables que tambi?n se env?an como par?metro en 
    || p_t_values.
    */ --------------------------------------------------------
    --
    FUNCTION f_exec_statement(p_statement VARCHAR2) RETURN NUMBER;
    --
    /* --------------------------------------------------------
    || Ejecuta la sentencia SQL eviada como parametro. Si la 
    || sentencia es un INSERT, UPDATE O DELETE, ademas devuelve
    || el numero de filas procesadas
    */ --------------------------------------------------------
    --
    FUNCTION f_exec_statement(   
                                    p_statement VARCHAR2, 
                                    p_t_values t_t_values 
                                ) RETURN NUMBER;
    --
    /* --------------------------------------------------------
    || Ejecuta la sentencia SQL eviada como parametro. Si la 
    || sentencia es un INSERT, UPDATE O DELETE, ademas devuelve
    || el numero de filas procesadas.
    || Los parametros de la sentencia SQL, se reciben en el 
    || par?metro p_t_values de tipo tabla
    */ --------------------------------------------------------
    --
    PROCEDURE p_ejecuta_sentencia(p_statement VARCHAR2);
    --
    /* --------------------------------------------------------
    || Ejecuta la sentencia SQL eviada como parametro.
    */ --------------------------------------------------------
    --
    PROCEDURE p_ejecuta_sentencia(p_statement VARCHAR2,
                                p_t_values t_t_values);
    --
    /* --------------------------------------------------------
    || Ejecuta la sentencia SQL eviada como parametro.
    || Los par?metros que lleve la sentencia SQL, se reciben
    || en el par?metro p_t_values de tipo tabla.
    */ --------------------------------------------------------
    PROCEDURE p_statement_session(p_statement VARCHAR2);
    --
    PROCEDURE p_statement_and_commit(p_statement VARCHAR2);
    --
    --
    /**---------------------------------------------------------------------------
    || Funcion f_open_cursor.
    || Recibe la tabla con los valores de los campos a sustituir y la select de
    || la lista y retorna un cursor con los datos obtenidos al ejecutar la select.
    ||
    || #param    p_t_values        IN      Tabla PL con los valores a sustuir en la where.
    || #param    p_select           IN      Cadena con la SELECT (solo los campos).
    || #param    p_from             IN      Cadena con el FROM.
    || #param    p_where            IN      Cadena con la WHERE (incluidos filtros).
    || #param    p_where_rest      IN      Cadena con group by, etc.., si existiera.
    || #param    p_order_by         IN      Cadena con el ORDER BY.
    */ ----------------------------------------------------------------------------
    --
    FUNCTION f_open_cursor( p_t_values   t_t_values,
                            p_select      VARCHAR2,
                            p_from        VARCHAR2,
                            p_where       VARCHAR2,
                            p_where_rest VARCHAR2,
                            p_order_by    VARCHAR2) RETURN c_return1;
    --
END sys_k_dinamic;


/

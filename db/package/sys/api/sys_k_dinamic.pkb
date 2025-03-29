--------------------------------------------------------
--  DDL for Package Body sys_k_dinamic
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.sys_k_dinamic AS
    ---------------------------------------------------------------------------
    --  DDL for Package PRS_K_PROCCESS (Process)
    --  REFERENCIAS
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --                                  Permite realizar acciones dinamicas, tales como eje-
    --                                  cuciones de procedimientos, sentencias, etc.
    ---------------------------------------------------------------------------
    --
    /* --------------------------------------------------------
    || Aqui comienza la declaracion de tablas GLOBALES
    */ --------------------------------------------------------
    --
    g_cod_message     VARCHAR2(128);
    g_anx_message     VARCHAR2(512);
    g_cod_language    VARCHAR2(02)   := 'ES';
    --
    g_error_n_parameters EXCEPTION;  
    --
    TYPE record_variables IS RECORD(
        nam_col VARCHAR2(60),
        val_col VARCHAR2(80)
    );
    --
    TYPE tab_variables IS TABLE OF record_variables INDEX BY BINARY_INTEGER;
    --
    g_tb_variables tab_variables;
    --
    /* ----------------------------------------------------
    || Aqui comienza la declaracion de subprogramas LOCALES
    */ ----------------------------------------------------
    --
    /* --------------------------------------------------------
    || mx :
    ||
    || Genera la traza
    */ --------------------------------------------------------
    --
    PROCEDURE mx( 
            p_tit VARCHAR2, 
            p_val VARCHAR2
        ) IS
    BEGIN
        --
        sys_k_global.seter('fic_traza','dangel'      );
        sys_k_global.seter('cab_traza','trn_p_dina->');
        --
    END mx;
    --
    /* --------------------------------------------------------
    || mx :
    ||
    || Genera la traza
    */ --------------------------------------------------------
    --
    PROCEDURE mx(p_tit VARCHAR2,  p_val BOOLEAN ) IS
    BEGIN
        --
        sys_k_global.seter('fic_traza','dangel'      );
        sys_k_global.seter('cab_traza','trn_p_dina->');
        --
    END mx;
    --
    /* --------------------------------------------------------
    || p_return_error :
    ||
    */ --------------------------------------------------------
    --
    PROCEDURE p_return_error IS
    BEGIN
        --
        IF g_cod_message BETWEEN 20000 AND 20999 THEN
            --
            RAISE_APPLICATION_ERROR(-g_cod_message, g_anx_message );
            --
        ELSE
            RAISE_APPLICATION_ERROR(-20000, g_anx_message );
            --
        END IF;
        --
    END p_return_error;
    --
    --
    /* --------------------------------------------------------
    || pp_bind_variable :
    ||
    || 
    */ --------------------------------------------------------
    -- 
    PROCEDURE pp_bind_variable(
            p_cursor INTEGER
        ) IS
    BEGIN
        --
        FOR l_row_c IN NVL(g_tb_variables.FIRST,0)..NVL(g_tb_variables.LAST,-1) LOOP
            --
            dbms_sql.bind_variable( 
                c       =>  p_cursor,
                name    =>  g_tb_variables(l_row_c).nam_col,
                value   =>  g_tb_variables(l_row_c).val_col
            );
            --
        END LOOP;
        --
    END pp_bind_variable;
    --
    /* --------------------------------------------------------
    || Aqui comienza la declaracion de subprogramas del PACKAGE
    */ --------------------------------------------------------
    --
    /* --------------------------------------------------------
    || p_set_val :
    ||
    || Rellena tabla PL con los valores que se necesitan para
    || la condicion del cursor variable
    */ --------------------------------------------------------
    --
    PROCEDURE p_set_val(
            p_nam_col VARCHAR2,
            p_val_col VARCHAR2
        ) IS
        --
        l_position INTEGER;
        --
    BEGIN
        --
        l_position := NVL(g_tb_variables.LAST,0) + 1;
        --
        g_tb_variables(l_position).nam_col := p_nam_col;
        g_tb_variables(l_position).val_col := p_val_col;
        --
    END p_set_val;
    --
    /* --------------------------------------------------------
    || p_set_val :
    ||
    || Rellena tabla PL con los valores que se necesitan para
    || la condicion del cursor variable
    */ --------------------------------------------------------
    --
    PROCEDURE p_set_val( 
            p_nam_col VARCHAR2,
            p_val_col NUMBER
        ) IS
        --
        l_position INTEGER;
        --
    BEGIN
        --
        l_position := NVL(g_tb_variables.LAST,0) + 1;
        --
        g_tb_variables(l_position).nam_col := p_nam_col;
        g_tb_variables(l_position).val_col := TO_CHAR(p_val_col);
        --
    END p_set_val;
    --
    /* --------------------------------------------------------
    || p_set_val :
    ||
    || Rellena tabla PL con los valores que se necesitan para
    || la condicion del cursor variable
    */ --------------------------------------------------------
    --
    PROCEDURE p_set_val( 
            p_nam_col VARCHAR2,
            p_val_col DATE 
        ) IS
        --
        l_position INTEGER;
        --
    BEGIN
        --
        l_position := NVL(g_tb_variables.LAST,0) + 1;
        --
        g_tb_variables(l_position).nam_col := p_nam_col;
        g_tb_variables(l_position).val_col := TO_CHAR(p_val_col);
        --
    END p_set_val;
    --
    /* --------------------------------------------------------
    || f_value_in_table :
    ||
    || Devuelve la primera fila que comple la condicion de la
    || columna y tabla eviada como parametro
    */ --------------------------------------------------------
    --
    FUNCTION f_value_in_table( 
            p_table   VARCHAR2,
            p_column VARCHAR2,
            p_where   VARCHAR2
        ) RETURN VARCHAR2 IS
        --
        l_cursor      INTEGER;
        l_rows        INTEGER;
        --
        l_value       VARCHAR2(0100);
        l_statement   VARCHAR2(2000) := 'SELECT ' || p_column || '  FROM ' || p_table   || ' ' || p_where;
        --
        l_k_lng       CONSTANT PLS_INTEGER     := 100;
        --
    BEGIN
        --
        l_cursor := dbms_sql.open_cursor;
        --
        dbms_sql.parse(l_cursor,l_statement,dbms_sql.v7);
        --
        dbms_sql.define_column(l_cursor,1,l_value,l_k_lng);
        --
        pp_bind_variable(l_cursor);
        --
        l_rows := dbms_sql.execute(l_cursor);
        l_rows := dbms_sql.fetch_rows(l_cursor);
        --
        dbms_sql.column_value(l_cursor,1,l_value);
        --
        dbms_sql.close_cursor(l_cursor);
        --
        g_tb_variables.DELETE;
        --
        RETURN l_value;
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                dbms_sql.close_cursor(l_cursor);
                --
                g_tb_variables.DELETE;
                --
                RAISE;
                --
    END f_value_in_table;
    --
    /* --------------------------------------------------------
    || f_value_in_table :
    ||
    || Devuelve la primera fila del cursor que devuelve la 
    || funci?n f_open_cursor
    || Los valores de los parametros de la sentencia se reciben
    || en el parametro p_t_values de tipo tabla
    */ --------------------------------------------------------
    --
    FUNCTION f_value_in_table(
            p_table     VARCHAR2,
            p_column    VARCHAR2,
            p_where     VARCHAR2,
            p_t_values  t_t_values
        ) RETURN VARCHAR2 IS
        --
        l_value       VARCHAR2(0100);
        l_statement   VARCHAR2(2000) := 'SELECT ' || p_column || '  FROM ' || p_table   || ' ' || p_where;
        --
        l_c_cursor    c_return1;
        --
    BEGIN
        --  
        l_c_cursor := f_open_cursor ( 
            p_t_values      => p_t_values,
            p_select        => l_statement,
            p_from          => NULL,
            p_where         => NULL,
            p_where_rest    => NULL,
            p_order_by      => NULL
        );
        --
        FETCH l_c_cursor INTO l_value;
        --
        CLOSE l_c_cursor;                                                  
        --
        RETURN l_value;
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                RAISE;
                --
    END f_value_in_table;
    --
    /* --------------------------------------------------------
    || p_exec_procedure :
    ||
    || Ejecuta el procedimiento enviado como parametro
    */ --------------------------------------------------------
    --
    PROCEDURE p_exec_procedure(
            p_procedure VARCHAR2
        ) IS
        --
        l_k_init  CONSTANT VARCHAR2(05) := 'BEGIN';
        l_k_end   CONSTANT VARCHAR2(06) := '; END;';
        --
    BEGIN
        --
        EXECUTE IMMEDIATE l_k_init || ' ' || p_procedure || l_k_end;
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                DECLARE
                --
                l_txt_error   VARCHAR2(600)  := SQLERRM;
                l_cod_message VARCHAR2(8000) := SQLCODE;
                --
                BEGIN
                --
                IF l_cod_message BETWEEN -20999 AND -20000 THEN
                    --
                    RAISE_APPLICATION_ERROR(l_cod_message,'['                                    || 
                                                            p_procedure                        || 
                                                            ']'                                    ||
                                                            SUBSTR(l_txt_error,INSTR(l_txt_error  ,
                                                                                    l_cod_message,
                                                                                    -1
                                                                                    ) + 7
                                                                )
                                            );
                    --
                    ELSE
                    --
                    RAISE_APPLICATION_ERROR(-20000, '[' || p_procedure|| '] ' || l_txt_error);
                    --
                END IF;
                --
                END;
                --
    END p_exec_procedure;
    --
    /* --------------------------------------------------------
    || p_exec_procedure :
    ||
    || Ejecuta el procedimiento enviado como parametro
    */ --------------------------------------------------------
    --
    PROCEDURE p_exec_procedure(
                                    p_procedure VARCHAR2,
                                    p_t_values t_t_values
                                ) IS
        --
        l_k_init   CONSTANT VARCHAR2(05) := 'BEGIN';
        l_k_end      CONSTANT VARCHAR2(06) := '; END;';
        --
        l_rows  INTEGER;
        --
    BEGIN
        --
        l_rows := f_exec_statement( 
                l_k_init||' '||p_procedure||l_k_end,
                p_t_values
        );
        --
    EXCEPTION
        WHEN OTHERS THEN
            --
            DECLARE
                --
                l_txt_error   VARCHAR2(600)  := SQLERRM;
                l_cod_message VARCHAR2(8000) := SQLCODE;
                --
            BEGIN
                --
                IF l_cod_message BETWEEN -20999 AND -20000 THEN
                --
                RAISE_APPLICATION_ERROR(l_cod_message,'['                                    || 
                                                        p_procedure                        || 
                                                        ']'                                    ||
                                                        SUBSTR(l_txt_error,INSTR(l_txt_error  ,
                                                                                l_cod_message,
                                                                                -1
                                                                                ) + 7
                                                                )
                                        );
                --
                ELSE
                --
                RAISE_APPLICATION_ERROR(-20000, '[' || p_procedure|| '] ' || l_txt_error);
                --
                END IF;
                --
            END;
            --
    END p_exec_procedure;
    --
    /* --------------------------------------------------------
    || f_exec_statement :
    ||
    || Ejecuta la sentencia SQL eviada como parametro. Si la
    || sentencia es un INSERT, UPDATE O DELETE, ademas devuelve
    || el numero de filas procesadas
    */ --------------------------------------------------------
    --
    FUNCTION f_exec_statement(p_statement VARCHAR2) RETURN NUMBER IS
        --
        l_cursor INTEGER;
        l_rows  INTEGER;
        --
    BEGIN
        --
        l_cursor := dbms_sql.open_cursor;
        --
        dbms_sql.parse(l_cursor,p_statement,dbms_sql.v7);
        --
        pp_bind_variable(l_cursor);
        --
        l_rows := dbms_sql.EXECUTE(l_cursor);
        --
        dbms_sql.close_cursor(l_cursor);
        --
        g_tb_variables.DELETE;
        --
        RETURN l_rows;
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                dbms_sql.close_cursor(l_cursor);
                --
                g_tb_variables.DELETE;
                --
                RAISE;
                --
    END f_exec_statement;
    --
    /* --------------------------------------------------------
    || f_exec_statement :
    ||
    || Ejecuta la sentencia SQL eviada como parametro. Si la 
    || sentencia es un INSERT, UPDATE O DELETE, ademas devuelve
    || el numero de filas procesadas
    */ --------------------------------------------------------
    --
    FUNCTION f_exec_statement( p_statement VARCHAR2,
                               p_t_values t_t_values
                             ) RETURN NUMBER IS
    BEGIN
        --
        CASE p_t_values.COUNT
            WHEN 0 THEN
                EXECUTE IMMEDIATE p_statement;
            WHEN 1 THEN
                EXECUTE IMMEDIATE p_statement 
                    USING p_t_values(1);
            WHEN 2 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2);
            WHEN 3 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3);
            WHEN 4 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4);
            WHEN 5 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5);
            WHEN 6 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),
                        p_t_values(6);
            WHEN 7 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),
                          p_t_values(6),p_t_values(7);
            WHEN 8 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),
                          p_t_values(6), p_t_values(7),p_t_values(8);
            WHEN 9 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),
                          p_t_values(6),p_t_values(7),p_t_values(8),p_t_values(9);
            WHEN 10 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),
                          p_t_values(6),p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10);
            WHEN 11 THEN
            EXECUTE IMMEDIATE p_statement
                USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                        p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11);
            WHEN 12 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),
                          p_t_values(6),p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),
                          p_t_values(11),p_t_values(12);
            WHEN 13 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),p_t_values(13);
            WHEN 14 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14);
            WHEN 15 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15);
            WHEN 16 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16);
            WHEN 17 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17);
            WHEN 18 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18);
            WHEN 19 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19);
            WHEN 20 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20);
            WHEN 21 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21);
            WHEN 22 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22);
            WHEN 23 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23);
            WHEN 24 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24);
            WHEN 25 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),p_t_values(25);
            WHEN 26 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),p_t_values(25),p_t_values(26);
            WHEN 27 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27);
            WHEN 28 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28);
            WHEN 29 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29);
            WHEN 30 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30);
            WHEN 31 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31);
            WHEN 32 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32);
            WHEN 33 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33);
            WHEN 34 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34);
            WHEN 35 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34),p_t_values(35);
            WHEN 36 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34),p_t_values(35),p_t_values(36);
            WHEN 37 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34),p_t_values(35),p_t_values(36),
                            p_t_values(37);
            WHEN 38 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34),p_t_values(35),p_t_values(36),
                            p_t_values(37),p_t_values(38);
            WHEN 39 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34),p_t_values(35),p_t_values(36),
                            p_t_values(37),p_t_values(38),p_t_values(39);
            WHEN 40 THEN
                EXECUTE IMMEDIATE p_statement
                    USING p_t_values(1),p_t_values(2),p_t_values(3),p_t_values(4),p_t_values(5),p_t_values(6),
                            p_t_values(7),p_t_values(8),p_t_values(9),p_t_values(10),p_t_values(11),p_t_values(12),
                            p_t_values(13),p_t_values(14),p_t_values(15),p_t_values(16),p_t_values(17),p_t_values(18),
                            p_t_values(19),p_t_values(20),p_t_values(21),p_t_values(22),p_t_values(23),p_t_values(24),
                            p_t_values(25),p_t_values(26),p_t_values(27),p_t_values(28),p_t_values(29),p_t_values(30),
                            p_t_values(31),p_t_values(32),p_t_values(33),p_t_values(34),p_t_values(35),p_t_values(36),
                            p_t_values(37),p_t_values(38),p_t_values(39),p_t_values(40);
        ELSE
            RAISE g_error_n_parameters;
        END CASE;        
        --
        RETURN SQL%ROWCOUNT;
        --
        EXCEPTION
            WHEN g_error_n_parameters THEN
                --
                g_cod_message := -20252;
                g_anx_message := NULL;
                --
                p_return_error;     
                --
            WHEN OTHERS THEN
                --
                RAISE;
                --
    END f_exec_statement;
    --
    /* --------------------------------------------------------
    || p_ejecuta_sentencia :
    ||
    || Ejecuta la sentencia SQL eviada como parametro.
    */ --------------------------------------------------------
    --
    PROCEDURE p_ejecuta_sentencia(p_statement VARCHAR2) IS
        --
        l_rows  INTEGER;
        --
    BEGIN
        --
        l_rows := f_exec_statement(p_statement);
        --
    END p_ejecuta_sentencia;
    --
    /* --------------------------------------------------------
    || p_ejecuta_sentencia :
    ||
    || Ejecuta la sentencia SQL eviada como parametro.
    */ --------------------------------------------------------
    --
    PROCEDURE p_ejecuta_sentencia( p_statement VARCHAR2,
                                   p_t_values t_t_values
                                 ) IS
        --
        l_rows  INTEGER;
        --
    BEGIN
        --
        l_rows := f_exec_statement(p_statement, p_t_values);
        --
    END p_ejecuta_sentencia;
    --
    /* --------------------------------------------------------
    || p_statement_session :
    ||
    ||
    */ --------------------------------------------------------
    --
    PROCEDURE p_statement_session(p_statement VARCHAR2) IS
    BEGIN
        --
        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE COMMIT IN PROCEDURE';
        --
        EXECUTE IMMEDIATE p_statement;
        --
        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE COMMIT IN PROCEDURE';
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                RAISE;
                --
    END p_statement_session;
    --
    /* --------------------------------------------------------
    || p_statement_and_commit :
    ||
    ||
    */ --------------------------------------------------------
    --
    PROCEDURE p_statement_and_commit(p_statement VARCHAR2) IS
    BEGIN
        --
        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE COMMIT IN PROCEDURE';
        --
        EXECUTE IMMEDIATE p_statement;
        --
        EXECUTE IMMEDIATE 'COMMIT';
        --
        EXECUTE IMMEDIATE 'ALTER SESSION DISABLE COMMIT IN PROCEDURE';
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                RAISE;
                --
    END p_statement_and_commit;
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
                            p_order_by    VARCHAR2
                          ) RETURN c_return1 IS
        --
        pc_datos      c_return1;
        --
    BEGIN
        --
        CASE p_t_values.COUNT
            WHEN 0 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by;
                --
            WHEN 1 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1);
                --
            WHEN 2 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2);
                --
            WHEN 3 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3);
                --
            WHEN 4 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4);
                --
            WHEN 5 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5);
                --
            WHEN 6 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6);
                --
            WHEN 7 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7);
                --
            WHEN 8 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8);
                --
            WHEN 9 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9);
                --
            WHEN 10 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10);
                --
            WHEN 11 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11);
                --
            WHEN 12 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12);
                --
            WHEN 13 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13);
                --
            WHEN 14 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14);
                --
            WHEN 15 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15);
                --
            WHEN 16 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16);
                --
            WHEN 17 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17);
                --
            WHEN 18 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18);
                --
            WHEN 19 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19);
                --
            WHEN 20 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20);
                --
            WHEN 21 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21);
                --
            WHEN 22 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22);
                --
            WHEN 23 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23);
                --
            WHEN 24 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24);
                --
            WHEN 25 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25);
                --
            WHEN 26 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26);
                --
            WHEN 27 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27);
                --
            WHEN 28 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28);
                --
            WHEN 29 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29);
                --
            WHEN 30 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30);
                --
            WHEN 31 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                            p_t_values(31);
                --
            WHEN 32 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                            p_t_values(31), p_t_values(32);
                --
            WHEN 33 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                            p_t_values(31), p_t_values(32), p_t_values(33);
                --
            WHEN 34 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                            p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34);
                --
            WHEN 35 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                            p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                            p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                            p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                            p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                            p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34), p_t_values(35);
                --
            WHEN 36 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                    p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                    p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                    p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                    p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                    p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34), p_t_values(35), p_t_values(36);
                --
            WHEN 37 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                    p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                    p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                    p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                    p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                    p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34), p_t_values(35), p_t_values(36), 
                    p_t_values(37);
                --
            WHEN 38 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                    p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                    p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                    p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                    p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                    p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34), p_t_values(35), p_t_values(36), 
                    p_t_values(37), p_t_values(38);
                --
            WHEN 39 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                    p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                    p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                    p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                    p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                    p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34), p_t_values(35), p_t_values(36), 
                    p_t_values(37), p_t_values(38), p_t_values(39);
                --
            WHEN 40 THEN
                OPEN pc_datos FOR p_select || ' ' || p_from ||' '|| p_where || ' ' || p_where_rest || p_order_by
                    USING p_t_values(1), p_t_values(2), p_t_values(3), p_t_values(4), p_t_values(5), p_t_values(6), 
                    p_t_values(7), p_t_values(8), p_t_values(9), p_t_values(10), p_t_values(11), p_t_values(12), 
                    p_t_values(13), p_t_values(14), p_t_values(15), p_t_values(16), p_t_values(17), p_t_values(18), 
                    p_t_values(19), p_t_values(20), p_t_values(21), p_t_values(22), p_t_values(23), p_t_values(24), 
                    p_t_values(25), p_t_values(26), p_t_values(27), p_t_values(28), p_t_values(29), p_t_values(30), 
                    p_t_values(31), p_t_values(32), p_t_values(33), p_t_values(34), p_t_values(35), p_t_values(36), 
                    p_t_values(37), p_t_values(38), p_t_values(39), p_t_values(40);
                --
        ELSE
            RAISE g_error_n_parameters;
            --
        END CASE;
        --
        RETURN pc_datos;
        --
        EXCEPTION
            WHEN g_error_n_parameters THEN
                --
                g_cod_message := -20503;
                g_anx_message := NULL;
                --
                p_return_error;     
                --  
    END f_open_cursor;
    --
END sys_k_dinamic;

/

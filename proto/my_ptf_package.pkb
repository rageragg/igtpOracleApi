CREATE OR REPLACE PACKAGE BODY my_ptf_package AS
    --
    FUNCTION describe(
        tab             IN OUT dbms_tf.table_t,
        cols_to_discard IN dbms_tf.columns_t DEFAULT NULL,
        new_col_name    IN VARCHAR2 DEFAULT NULL,
        new_col_val     IN VARCHAR2 DEFAULT NULL
    ) RETURN dbms_tf.describe_t IS
    BEGIN
        --
        FOR i IN 1 .. tab.column.COUNT LOOP
            --
            -- descartamos las columnas indicadas en el tabla cols_to_discard 
            IF tab.column(i).description.name MEMBER OF cols_to_discard THEN
                --
                -- esta columna no aparecera en el resultado
                tab.column(i).pass_through := false;
                --
            END IF;
            --
        END LOOP;
        --
        IF new_col_name IS NOT NULL AND new_col_val IS NOT NULL THEN 
            --
            -- agregamos nuevas columnas
            RETURN dbms_tf.describe_t(
                new_columns => dbms_tf.columns_new_t(
                        1 => dbms_tf.column_metadata_t(
                            name => new_col_name,
                            type => dbms_tf.type_varchar2
                        )
                ));
            --
        ELSE 
            --
            RETURN NULL;
            --
        END IF;   
    END describe; 
    --
    PROCEDURE fetch_rows(
        new_col_name    IN VARCHAR2 DEFAULT NULL,
        new_col_val     IN VARCHAR2 DEFAULT NULL
    ) IS
        --
        valcol dbms_tf.tab_varchar2_t;
        env    dbms_tf.env_t := dbms_tf.get_env();
        --
    BEGIN
        --
        -- For all rows just assign a constant value
        FOR i IN 1..env.row_count LOOP
            valcol(nvl(valcol.last+1,1)) := new_col_val;
        END LOOP;
        --
        -- Put the collection with values back
        dbms_tf.put_col(1, valcol);
        --
    END fetch_rows;
    --
END my_ptf_package;
CREATE PACKAGE BODY echo_package AS
    /*
        --
        TYPE columns_t          IS TABLE OF dbms_quoted_id;
        TYPE referenced_cols_t  IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;
        --
        TYPE column_metadata_t IS RECORD( 
            type        PLS_INTEGER,
            max_len     PLS_integer DEFAULT -1,
            name        VARCHAR2(32767),
            name_len    PLS_INTEGER,
            precision   PLS_INTEGER,
            scale       PLS_INTEGER,
            charsetid   PLS_INTEGER,
            charsetform PLS_INTEGER,
            collation   PLS_INTEGER 
        );
        --
        TYPE table_metadata_t IS TABLE OF column_metadata_t INDEX BY PLS_INTEGER;
        --
        TYPE columns_new_t IS TABLE OF column_metadata_t INDEX BY PLS_INTEGER;
        --
        TYPE column_data_t IS RECORD( 
            description         column_metadata_t,
            tab_varchar2        tab_varchar2_t,
            tab_number          tab_number_t,
            tab_date            tab_date_t,
            tab_binary_float    tab_binary_float_t,
            tab_binary_double   tab_binary_double_t,
            tab_raw             tab_raw_t,
            tab_char            tab_char_t,
            tab_clob            tab_clob_t,
            tab_blob            tab_blob_t,
            tab_timestamp       tab_timestamp_t,
            tab_timestamp_tz    tab_timestamp_tz_t,
            tab_interval_ym     tab_interval_ym_t,
            tab_interval_ds     tab_interval_ds_t,
            tab_timestamp_ltz   tab_timestamp_ltz_t,
            tab_rowid           tab_rowid_t
        );
        --
        TYPE row_set_t IS TABLE OF column_data_t INDEX BY PLS_INTEGER;
        --
        TYPE column_t IS RECORD (
            description     column_metadata_t,
            pass_through    BOOLEAN,
            for_read        BOOLEAN
        );
        Field           Description
        --------------- -----------------------------------
        description     Column metadata
        pass_through    Is this a pass through column
        for_read        Is this column read by the PTF
        --------------- -----------------------------------
        --
        TYPE table_columns_t IS TABLE OF column_t;
        --
        TYPE table_t IS RECORD(
            column          table_columns_t,
            schema_name     dbms_id,
            package_name    dbms_id,
            ptf_name        dbms_id
        );
        -- 
        Field           Description
        --------------- -----------------------------------
        column          Column information
        schema_name     The PTF schema name
        package_name    The PTF implementation package name
        ptf_name        The PTF name invoked
        --------------- -----------------------------------
        --
        TYPE describe_t IS RECORD( 
            new_columns     columns_new_t   default columns_new_t(),
            cstore_chr      cstore_chr_t    default cstore_chr_t(),
            cstore_num      cstore_num_t    default cstore_num_t(),
            cstore_bol      cstore_bol_t    default cstore_bol_t(),
            cstore_dat      cstore_dat_t    default cstore_dat_t(),
            method_names    methods_t       default methods_t()
        );
        --
        TYPE parallel_env_t IS RECORD (
            instance_id      PLS_INTEGER,  -- QC instance ID 
            session_id       PLS_INTEGER,  -- QC session ID
            slave_svr_grp    PLS_INTEGER,  -- Slave server group
            slave_set_no     PLS_INTEGER,  -- Slave server set num
            no_slocal_slaves PLS_INTEGER,  -- Num of sibling slaves (including self)
            global_slave_no  PLS_INTEGER,  -- Global slave number (base 0) 
            no_local_slaves  PLS_INTEGER,  -- Num of sibling slaves running on instance
            local_slave_no   PLS_INTEGER   -- Local slave number (base 0)
        );
        --
        -- 
            Type: ENV_T

            This record contains metadata about execution time properties for
            polymorphic table functions.

            get_columns:  meta data about the columns read by PTF.
            put_columns:  meta data about columns sent back to RDBMS.
            ref_put_col:  TRUE if the put column was referenced in the query.
            parallel_env: Various properties about Parallel query when query is
                        running in parallel.
            query_optim:  TRUE, if the query was running on behalf of optimizer.
            row_count:    Number of rows in current set.

        --
        TYPE env_t IS RECORD (
            get_columns     table_metadata_t,
            put_columns     table_metadata_t,
            ref_put_col     referenced_cols_t,
            parallel_env    parallel_env_t,
            query_optim     BOOLEAN,
            row_count       PLS_INTEGER,
            row_replication BOOLEAN,
            row_insertion   BOOLEAN
        );
        --
    */
    --
    FUNCTION describe(
            tab     IN OUT dbms_tf.table_t,
            cols    IN dbms_tf.columns_t
        ) RETURN dbms_tf.describe_t AS
        --
        -- Collection for new columns
        new_cols    dbms_tf.columns_new_t;
        col_id      PLS_INTEGER := 1;
        --
    BEGIN
        --
        FOR I IN 1 .. tab.column.COUNT LOOP
            --
            FOR J IN 1 .. cols.COUNT LOOP
                --
                IF ( tab.column(i).description.name = cols(j) ) THEN
                    --
                    IF ( NOT dbms_tf.supported_type(tab.column(i).description.type) ) THEN
                        --
                        RAISE_APPLICATION_ERROR(
                            -20102, 
                            'Unsupported column type [' ||
                                tab.column(i).description.TYPE||']'
                        );
                        --
                    END IF;
                    --
                    tab.column(i).for_read := TRUE;
                    new_cols(col_id)       := tab.column(i).description;
                    new_cols(col_id).name  := prefix || tab.column(i).description.name;
                    col_id := col_id + 1;
                    --
                    EXIT;
                    --
                END IF;
                --
            END LOOP;
            --
        END LOOP;
        --
        -- Verify all columns were found
        IF ( col_id - 1 != cols.COUNT ) THEN
            RAISE_APPLICATION_ERROR(-20101, 'column mismatch ['||col_id - 1||'], ['||cols.COUNT||']');
        END IF;
        --
        RETURN dbms_tf.describe_t(new_columns => new_cols);
        --
    END describe;
    --
    PROCEDURE fetch_rows AS
        -- 
        -- Data for a rowset record
        rowset dbms_tf.row_set_t;
        --
    BEGIN
        --
        dbms_tf.GET_ROW_SET(rowset);
        dbms_tf.PUT_ROW_SET(rowset);
        --
    END fetch_rows;
    --
END echo_package;    
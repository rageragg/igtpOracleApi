CREATE PACKAGE skip_col_pkg AS
    
    FUNCTION skip_col_by_name( tab TABLE, 
                               col COLUMNS)
            RETURN TABLE PIPELINED ROW POLYMORPHIC USING skip_col_pkg;
    --
    
    CREATE FUNCTION skip_col_by_type(tab TABLE, 
                                 type_name VARCHAR2,
                                 flip VARCHAR2 DEFAULT 'False')
            RETURN TABLE PIPELINED ROW POLYMORPHIC USING skip_col_pkg;

    -- USE: SELECT * FROM skip_col_pkg.skip_col(scott.emp, COLUMNS(comm, hiredate, mgr)) WHERE deptno = 20;
    -- OVERLOAD 1: Skip by name --
    FUNCTION skip_col(tab TABLE, 
                        col COLUMNS)
            RETURN TABLE PIPELINED ROW POLYMORPHIC USING skip_col_pkg;

    FUNCTION describe(tab IN OUT DBMS_TF.TABLE_T, 
                        col        DBMS_TF.COLUMNS_T)
            RETURN DBMS_TF.DESCRIBE_T;
    -- USE: SELECT * FROM skip_col_pkg.skip_col(scott.dept, 'number');
    -- USE: SELECT * FROM skip_col_pkg.skip_col(scott.dept, 'number', flip => 'True');
    -- OVERLOAD 2: Skip by type --
    FUNCTION skip_col(tab       TABLE, 
                        type_name VARCHAR2,
                        flip      VARCHAR2 DEFAULT 'False') 
            RETURN TABLE PIPELINED ROW POLYMORPHIC USING skip_col_pkg;

    FUNCTION describe(tab       IN OUT DBMS_TF.TABLE_T, 
                        type_name        VARCHAR2, 
                        flip             VARCHAR2 DEFAULT 'False') 
            RETURN DBMS_TF.DESCRIBE_T;

END skip_col_pkg; 
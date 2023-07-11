CREATE PACKAGE echo_package AS
    --
    prefix DBMS_ID := 'ECHO_';
    --
    FUNCTION describe(  
        tab IN OUT DBMS_TF.TABLE_T,
        cols IN DBMS_TF.COLUMNS_T
    ) RETURN DBMS_TF.DESCRIBE_T;
    --
    PROCEDURE fetch_rows;
    --
END echo_package;    
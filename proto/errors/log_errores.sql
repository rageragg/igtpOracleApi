CREATE TABLE log_errores (
    id_log        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha         DATE DEFAULT SYSDATE,
    usuario       VARCHAR2(100),
    modulo        VARCHAR2(100),
    error_msg     VARCHAR2(4000),
    error_trace   CLOB -- Usamos CLOB porque la traza puede ser muy larga
);

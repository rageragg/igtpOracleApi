--------------------------------------------------------
--  DDL for Package SYS_K_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."SYS_K_GLOBAL" AS
    --
    /* -------------------- DESCRIPCION -------------------- 
    || - Permite :
    ||   - almacenar variables.
    ||   - recuperar variables.
    ||   - borrar variables.
    ||   - borrar todas las variables.
    ||   - Salvar todas las variables.
    ||   - Restaurar todas las variables salvadas.
    */ -----------------------------------------------------
    --
    k_format_date        CONSTANT VARCHAR2(8) := 'ddmmyyyy';
    --
    PROCEDURE seter(p_variable VARCHAR2, p_value VARCHAR2);
    --
    PROCEDURE p_seter(p_variable VARCHAR2, p_value VARCHAR2);
    PROCEDURE p_seter(p_variable VARCHAR2, p_value NUMBER  );
    PROCEDURE p_seter(p_variable VARCHAR2, p_value DATE    );
    --
    /* -------------------- DESCRIPCION -------------------- 
    || seter el valor de la variable
    */ -----------------------------------------------------
    --
    FUNCTION geter    (p_variable VARCHAR2) RETURN VARCHAR2;
    --
    FUNCTION f_geter_c(p_variable VARCHAR2) RETURN VARCHAR2;
    FUNCTION f_geter_n(p_variable VARCHAR2) RETURN NUMBER;
    FUNCTION f_geter_f(p_variable VARCHAR2) RETURN DATE;
    --
    /* -------------------- DESCRIPCION -------------------- 
    || geter el valor de la variable en formato VARCHAR2
    */ -----------------------------------------------------
    --
    FUNCTION ref_f_global(p_variable VARCHAR2) RETURN VARCHAR2;
    --
    /* -------------------- DESCRIPCION -------------------- 
    || geter el valor de la variable. En caso de no 
    || existir, la crea con NULL.
    */ -----------------------------------------------------
    --
    PROCEDURE delete_variable(p_variable VARCHAR2);
    --
    /* -------------------- DESCRIPCION -------------------- 
    || Borra la variable indicada.
    */ -----------------------------------------------------
    --
    FUNCTION list RETURN VARCHAR2;
    --
    /* -------------------- DESCRIPCION -------------------- 
    || geter una a una todas las variables. Cuando acaba
    || de devolver todas, geter el valor NULL.
    */ -----------------------------------------------------
    --
    PROCEDURE save_variable;
    --
    /* -------------------- DESCRIPCION -------------------- 
    || Salva todas las variables que se tengan.
    */ -----------------------------------------------------
    --
    PROCEDURE restore_variable;
    --
    /* -------------------- DESCRIPCION -------------------- 
    || Restaura las variables previamente salvadas.
    */ -----------------------------------------------------
    --
    PROCEDURE init_variables;
    --
    /* -------------------- DESCRIPCION -------------------- 
    || Iniciliaza la global g_globales_salvadas 
    */ ----------------------------------------------------
    --
END sys_k_global;


/

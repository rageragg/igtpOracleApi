--------------------------------------------------------
--  DDL for Package Body SYS_K_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "IGTP"."SYS_K_GLOBAL" AS
   --
   /* --------------------------------
   || Tratamiento de Globales (PL/SQL)
   */---------------------------------
   --
   /* --------------------------------------------------
   || Aqui comienza la declaracion de variables GLOBALES
   */ --------------------------------------------------
   --
   SUBTYPE t_nam_variable IS VARCHAR2(0100);
   SUBTYPE t_val_variable IS VARCHAR2(2000);
   --
   TYPE reg_table IS RECORD(
      nam_variable t_nam_variable,
      val_variable T_VAL_VARIABLE
   );
   --
   TYPE tab_variables IS TABLE OF reg_table INDEX BY t_nam_variable;
   --
   g_tb_variables         tab_variables;
   g_tb_variables_copy   tab_variables;
   --
   g_row                 t_nam_variable := NULL;
   g_globals_saved    BOOLEAN        := FALSE;
   --
   E_GLOBAL_NO_DEFINED   EXCEPTION;
   --
   PRAGMA EXCEPTION_INIT(E_GLOBAL_NO_DEFINED, -20001);
   --
   /* ---------------------------------------------------
   || Aqui comienza la declaracion de constantes GLOBALES
   */ ---------------------------------------------------
   --
   K_SEPARATOR CONSTANT VARCHAR2(3) := '[~]';
   --
   /* ----------------------------------------------------
   || Aqui comienza la declaracion de subprogramas LOCALES
   */ ----------------------------------------------------
   --
   /* --------------------------------------------------------
   || p_extractor :
   || 
   || get el contenido que se encuentra entre el 
   || K_SEPARATOR
   */ --------------------------------------------------------
   --
   PROCEDURE p_extractor( p_val     IN            CLOB       ,
                        p_sep     IN            VARCHAR2   ,
                        p_pos_ini IN OUT NOCOPY PLS_INTEGER,
                        p_pos_end IN OUT NOCOPY PLS_INTEGER,
                        p_return    OUT NOCOPY VARCHAR2   
                      ) IS
      --
      l_lng_sep INTEGER := LENGTH(p_sep);
      --
   BEGIN
      --
      p_pos_end := INSTR( p_val, p_sep,  p_pos_ini + l_lng_sep );
      --
      IF p_pos_end != 0 THEN
         --
         IF p_pos_ini + l_lng_sep != p_pos_end THEN
            --
            p_return := SUBSTR(
               p_val                            ,
               p_pos_ini + l_lng_sep            ,
               p_pos_end - p_pos_ini - l_lng_sep
            );
            --
         END IF;
         --
         p_pos_ini := p_pos_end;
         --
      END IF;
      --
   END p_extractor;
   --
   /* --------------------------------------------------------
   || Aqui comienza la declaracion de subprogramas del PACKAGE
   */ --------------------------------------------------------
   --
   /* ----------------------------------------------------
   || seter :
   ||
   || seter el valor de la variable
   */ ----------------------------------------------------
   --
   PROCEDURE seter( p_variable VARCHAR2, 
                     p_value    VARCHAR2
                  ) IS
      --
      l_nam_variable t_nam_variable := UPPER(p_variable);
      --
   BEGIN
      --
      g_tb_variables(l_nam_variable).nam_variable := l_nam_variable;
      g_tb_variables(l_nam_variable).val_variable := p_value;
      --
   END seter;
   --
   /* ----------------------------------------------------
   || p_seter :
   ||
   || seter el valor de la variable
   */ ----------------------------------------------------
   --
   PROCEDURE p_seter(  p_variable VARCHAR2, 
                        p_value    VARCHAR2
                     ) IS
   BEGIN
      --
      seter(p_variable, p_value);
      --
   END p_seter;
   --
   /* ----------------------------------------------------
   || p_seter :
   ||
   || seter el valor de la variable
   */ ----------------------------------------------------
   --
   PROCEDURE p_seter( p_variable VARCHAR2, 
                       p_value    NUMBER  
                     ) IS
   BEGIN
      --
      seter( p_variable, to_char(p_value) );
      --
   END p_seter;
   --
   /* ----------------------------------------------------
   || seter :
   ||
   || seter el valor de la variable
   */ ----------------------------------------------------
   --
   PROCEDURE p_seter(  p_variable VARCHAR2, 
                        p_value    DATE
                     ) IS
   BEGIN
      --
      seter( p_variable, to_char(p_value, sys_k_global.k_format_date ) );
      --
   END p_seter;
   --
   /* ----------------------------------------------------
   || geter :
   ||
   || geter el valor de la variable en formato VARCHAR2
   */ ----------------------------------------------------
   --
   FUNCTION geter(p_variable VARCHAR2) RETURN VARCHAR2 IS
      --
      l_nam_variable t_nam_variable := UPPER(p_variable);
      --
   BEGIN
      --
      /* --------------------------------------
      || Aqu? se produce un NO_DATA_FOUND si no
      || existe la variable
      */ --------------------------------------
      --
      RETURN g_tb_variables(l_nam_variable).val_variable;
      --
   EXCEPTION
      --
      WHEN NO_DATA_FOUND THEN
         --
         RAISE_APPLICATION_ERROR(-20001, 'sys_k_global.geter <<' || p_variable || '>>');
         --
   END geter;
   --
   /* --------------------------------------------------------
   || f_geter_c :
   ||
   || geter el valor de la variable en formato VARCHAR2
   */ --------------------------------------------------------
   --
   FUNCTION f_geter_c(p_variable VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN geter(p_variable);
      --
   END f_geter_c;
   --
   /* --------------------------------------------------------
   || f_geter_n :
   ||
   || geter una variable en formato NUMBER
   */ --------------------------------------------------------
   --
   FUNCTION f_geter_n(p_variable VARCHAR2) RETURN NUMBER IS
   BEGIN
      --
      RETURN to_number( geter(p_variable) );
      --
   END f_geter_n;
   --
   /* --------------------------------------------------------
   || f_geter_f :
   ||
   || geter una variable en formato DATE
   */ --------------------------------------------------------
   --
   FUNCTION f_geter_f(p_variable VARCHAR2) RETURN DATE IS
   BEGIN
      --
      RETURN to_date(geter(p_variable), sys_k_global.k_format_date);
      --
   END f_geter_f;
   --
   /* ----------------------------------------------------
   || ref_f_global :
   ||
   || get el valor de la variable
   || que se encuentra en la Tabla.
   || Si no existe, crea la variable con valor "NULL".
   */ ----------------------------------------------------
   --
   FUNCTION ref_f_global(p_variable VARCHAR2) RETURN VARCHAR2 IS
      --          
      l_val_variable T_VAL_VARIABLE;
      --
   BEGIN
      --
      BEGIN
         --
         /* ---------------------------------------
         || Aqu? se produce un E_GLOBAL_NO_DEFINED
         || si no existe la variable
         */ ---------------------------------------
         --
         l_val_variable := geter(p_variable);
         --
         EXCEPTION
            WHEN E_GLOBAL_NO_DEFINED THEN
            --
            l_val_variable := NULL;
            --
            seter(p_variable, l_val_variable);
            --
      END;
      --
      RETURN l_val_variable;
      --
   END ref_f_global;
   --
   --
   /* ----------------------------------------------------
   || save_variable :
   ||
   || Salva todas las variables que se tengan.
   */ ----------------------------------------------------
   --
   PROCEDURE save_variable IS
   BEGIN
      --
      IF NOT g_globals_saved THEN
         --
         g_tb_variables_copy := g_tb_variables;
         g_globals_saved  := TRUE;
         --
      ELSE
         --
         RAISE_APPLICATION_ERROR(-20000, 'YA EXISTE UNA COPIA DE LAS GLOBALES');
         --
      END IF;
      --
   END save_variable;
   --
   /* ----------------------------------------------------
   || restore_variable :
   ||
   || Restaura las variables previamente salvadas.
   */ ----------------------------------------------------
   --
   PROCEDURE restore_variable IS
   BEGIN
      --
      IF g_globals_saved THEN
         --
         g_tb_variables      := g_tb_variables_copy;
         g_globals_saved := FALSE;
         --
         g_tb_variables_copy.DELETE;
         --
      ELSE
         --
         RAISE_APPLICATION_ERROR(-20000, 'NO EXISTE UNA COPIA DE LAS GLOBALES');
         --
      END IF;
      --
   END restore_variable;
   --
   /* ----------------------------------------------------
   || delete_variable :
   ||
   || Borra la ocurrencia de la Tabla donde se encuentra
   || la variable.
   */ ----------------------------------------------------
   --
   PROCEDURE delete_variable(p_variable VARCHAR2) IS
   BEGIN
      --
      /* --------------------------------------
      || En esta asignacion se produce un
      || NO_DATA_FOUND si no existe la variable
      */ --------------------------------------
      --
      g_tb_variables.DELETE( UPPER(p_variable) );
      --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --
         NULL;
         --
   END delete_variable;
   --
   /* ----------------------------------------------------
   || list :
   ||
   || get las globales hasta que la funcion
   || retorna "NULL"
   */ ----------------------------------------------------
   --
   FUNCTION list RETURN VARCHAR2 IS
      --
      l_retorno T_VAL_VARIABLE := NULL;
      --
   BEGIN
      --
      IF g_tb_variables.COUNT > 0
         THEN
         --
         IF g_row IS NULL
         THEN
            --
            g_row    := g_tb_variables.FIRST;
            l_retorno := g_tb_variables(g_row).nam_variable || ' <' || g_tb_variables(g_row).val_variable || '>';
            --
         ELSIF g_row != g_tb_variables.LAST
            THEN
            --
            g_row    := g_tb_variables.NEXT(g_row);
            l_retorno := g_tb_variables(g_row).nam_variable || ' <' || g_tb_variables(g_row).val_variable || '>';
            --
            ELSE
            --
            g_row := NULL;
            --
         END IF;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END list;
   --
   /* --------------------------------------------------- 
   || init_variables:
   ||
   || Iniciliaza la global g_globals_saved 
   */ ----------------------------------------------------
   --
   PROCEDURE init_variables IS
   --
   BEGIN
      --
      g_globals_saved := FALSE;
      --
   END init_variables;
 --
END sys_k_global;

/

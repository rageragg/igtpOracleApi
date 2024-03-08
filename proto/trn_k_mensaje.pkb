CREATE OR REPLACE PACKAGE BODY trn_k_mensaje
AS
/**
|| Package para crear mensajes desde PL/SQL
||
|| Los mensajes se envian por un canal y se puedan consultar
|| desde otro programa.
*/
--
/* ----------------- VERSION = 1.01 ------------------------------------ */
--
/* ----------------- MODIFICACIONES ---------------------------------
|| 2003-11-20 - JJIMEN1 - v 1.01
||    Documentacion
*/ ------------------------------------------------------------------
   g_directorio VARCHAR2(100) := trn_k_global.mspool_dir;
   g_id      UTL_FILE.FILE_TYPE;
   g_linea   NUMBER;
   g_columna NUMBER;
   g_mensaje VARCHAR2(2000);
   --
   g_status NUMBER;
   --
   g_id_listado UTL_FILE.FILE_TYPE;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE texto(p_mensaje IN VARCHAR2)
   IS
      l_posicion VARCHAR2(30);
   BEGIN
      IF g_linea IS NOT NULL
      THEN
         l_posicion := CHR(27)||'['||TO_CHAR(g_linea)||';'||
                                    TO_CHAR(g_columna)||'H';
      END IF;
      DBMS_PIPE.PACK_MESSAGE(l_posicion||p_mensaje);
      g_mensaje := p_mensaje;
   END texto;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE texto(p_mensaje IN VARCHAR2,
                   p_linea IN NUMBER,
                   p_columna IN NUMBER)
   IS
      l_linea   NUMBER;
      l_columna NUMBER;
   BEGIN
      l_linea   := g_linea;
      l_columna := g_columna;
      g_linea   := p_linea;
      g_columna := p_columna;
      texto (p_mensaje);
      g_linea   := l_linea;
      g_columna := l_columna;
   END texto;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE canal(p_nombre IN VARCHAR2)
   IS
   BEGIN
      -- Borra contenido anterior del canal
      DBMS_PIPE.PURGE(p_nombre);
      --
      g_status := DBMS_PIPE.CREATE_PIPE(p_nombre,256,FALSE); --Pipe Publico
   END canal;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE directorio(p_nombre IN VARCHAR2)
   IS
   BEGIN
      g_directorio := p_nombre;
   END directorio;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE archivo(p_nombre IN VARCHAR2)
   IS
   BEGIN
      IF NOT UTL_FILE.IS_OPEN (g_id)
      THEN
         UTL_FILE.FCLOSE(g_id);  -- cierra el archivo abierto anteriormente
         g_id := UTL_FILE.FOPEN (g_directorio, p_nombre, 'w');
      END IF;
   END archivo;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE posicion(p_linea IN NUMBER, p_columna IN NUMBER)
   IS
   BEGIN
      g_linea   := p_linea;
      g_columna := p_columna;
      IF g_linea > 25
      THEN
         g_linea:=25;
      END IF;
      IF g_linea IS NOT NULL
         AND g_columna IS NULL
      THEN
         g_columna:=1;
      END IF;
      IF g_columna > 80
      THEN
         g_columna:=80;
      END IF;
   END posicion;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE envia(p_canal IN VARCHAR2)
   IS
   BEGIN
      -- Se borra para evitar uso innecesario de memoria
      DBMS_PIPE.PURGE(p_canal);
      g_status := DBMS_PIPE.SEND_MESSAGE(p_canal);
      IF g_status != 0
      THEN
         RAISE_APPLICATION_ERROR(-20000,
                                'trn_k_mensaje error status:'||TO_CHAR(g_status));
      END IF;
      --
      IF UTL_FILE.IS_OPEN (g_id)
      THEN
         UTL_FILE.PUT_LINE(g_id,
                 '('||p_canal||')'||
                 '['||TO_CHAR(SYSDATE,'DDMMYYYY HH24MISS')||']:'||
                 g_mensaje);
      END IF;
      --
   END envia;
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE termina (p_canal IN VARCHAR2)
   IS
   BEGIN
      --
      -- Indicar al programa C que ha termiando la emision de mensajes
      -- al este canal
      DBMS_PIPE.PACK_MESSAGE('FIN');
      g_status := DBMS_PIPE.SEND_MESSAGE(p_canal);
      --
      -- g_status := dbms_pipe.remove_pipe(p_canal);
      --
      IF UTL_FILE.IS_OPEN (g_id)
      THEN
         UTL_FILE.FCLOSE (g_id);
      END IF;
   END termina;
   --
   -- -----------------------------------
   -- Procedimientos para Imprimir Mensajes Visualizados en el Forms V3
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE abrir_listado (p_directorio IN VARCHAR2,
                            p_listado    IN VARCHAR2,
                            p_modo       IN VARCHAR2)
   IS
   BEGIN
      g_id_listado := trn_k_lis.FOPEN (p_directorio, p_listado, p_modo);
   END;
   -- -----------------------------------
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE imprimir_linea (p_texto IN VARCHAR2)
   IS
   BEGIN
     trn_k_lis.PUT_LINE (g_id_listado,p_texto);
   END;
   -- -----------------------------------
   --
   -- --------------------------------------------------------------------
   /**
   ||
   */
   PROCEDURE cerrar_listado
   IS
   BEGIN
      trn_k_lis.FCLOSE (g_id_listado);
   END;
   --
END trn_k_mensaje;

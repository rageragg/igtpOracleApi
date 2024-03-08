CREATE OR REPLACE PACKAGE trn_k_mensaje
AS
/**
|| Package para crear mensajes desde PL/SQL
||
|| Los mensajes se envian por un canal y se puedan consultar
|| desde otro programa.
*/ ------------------------------------------------------------------
   --
/* --------------------------- VERSION = 1.01 ------------------------- */
--
/* -------------------------- MODIFICACIONES --------------------------
|| 2003-11-20 - JJIMEN1 - Documentacion
*/ --------------------------------------------------------------------
--
   --
   /**
   || Crea canal para los mensajes
   */
   PROCEDURE canal (
      p_nombre   IN   VARCHAR2 := USER);
   --
   /**
   || Prepara el texto del mensaje
   || pendiente de enviar (procedimiento envia)
   */
   PROCEDURE texto (
      p_mensaje   IN   VARCHAR2);
   --
   /**
   || Prepara el texto del mensaje indicando posicion de pantalla
   || pendiente de enviar (procedimiento envia)
   */
   PROCEDURE texto (
      p_mensaje   IN   VARCHAR2,
      p_linea     IN   NUMBER,
      p_columna   IN   NUMBER := 1);
   --
   /**
   || Indicar la posicion
   */
   PROCEDURE posicion (
      p_linea     IN   NUMBER := NULL,
      p_columna   IN   NUMBER := NULL);
   --
   /**
   || Enviar el mensaje al canal indicado
   || Tambien imprime el mensaje si el archivo ha sido previamente indicado
   */
   PROCEDURE envia (
      p_canal   IN   VARCHAR2);
   --
   /**
   || Indicar el directorio para generar listado con los mensajes
   */
   PROCEDURE directorio (
      p_nombre   IN   VARCHAR2 := trn_k_global.mspool_dir);
   --
   /**
   || Indicar el archivo para imprimir los mensajes
   || Realiza el Open del archivo
   */
   PROCEDURE archivo (
      p_nombre   IN   VARCHAR2 :=    USER
                                  || trn_k_lis.ext_mspool);
   --
   /**
   || Terminar el envio de mensajes. Cierra el canal
   || Tambien cierra el archivo de impresion de los mensajes
   */
   PROCEDURE termina (
      p_canal   IN   VARCHAR2 := USER);
   --
   --
   -- Procedimientos para Imprimir Mensajes Visualizados en el Forms V3
   --
   /**
   || Abrir fichero para imprimir listados
   ||
   || #param p_directorio nombre del directorio utl_file
   || #param p_listado    nombre del archivo
   || #param p_modo       modo de apertura del fichero, normalmente: w
   */
   PROCEDURE abrir_listado (
      p_directorio   IN   VARCHAR2,
      p_listado      IN   VARCHAR2,
      p_modo         IN   VARCHAR2);
   --
   /**
   || Imprimir linea al fichero
   */
   PROCEDURE imprimir_linea (
      p_texto   IN   VARCHAR2);
   --
   /**
   || Cerrar fichero de impresion
   */
   PROCEDURE cerrar_listado;
--
END trn_k_mensaje;

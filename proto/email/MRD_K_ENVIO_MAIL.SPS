
  CREATE OR REPLACE  PACKAGE MRD_K_ENVIO_MAIL is
 /*
  Version:   1.7
  Responsbale:    Leomaris Reyes Rosario - LRR
  Descripci�n:    Agrega la tabla_respuesta_envio en la que se puede
                  guardar las respuestas obtenidas al enviar un correo y
                  las guarda en la tabla A5029825 por medio del procedimiento
                  gc_k_notificaciones_mrd.p_transacciones_correos.
 */
  --
  /* --------------------- DESCRIPTION ----------------------
  || Procedure for the sending of mails
  */ --------------------------------------------------------
  --
  /* -------------------- VERSION = 1.06 -------------------- */
  --
  /* -------------------- MODIFICATIONS ---------------------
  || 2011/04/08 - RFRIVERO - 1.01 - (MS_2010_09_01210)
  || Se cambia la declaracion del campo t_tab_texto a VARCHAR2(1000)
  */ --------------------------------------------------------
  --
   -- LRR V1.07
  TYPE reg_respuesta_envio IS RECORD
      (
          num_secu        A5029825.NUM_SECU%TYPE,
          tip_dest        A5029825.TIP_DESTINATARIO%TYPE,
          cod_resp        A5029825.RESP_ENVIO%TYPE,
          desc_resp       A5029825.RESP_ENVIO%TYPE ,
          email           A5029825.EMAIL%TYPE
      );
  -- LRR V1.07
  TYPE tabla_respuesta_envio IS TABLE OF reg_respuesta_envio
           INDEX BY BINARY_INTEGER;
  --
  TYPE t_tab_destinatarios IS TABLE OF VARCHAR2(256)  INDEX BY BINARY_INTEGER;
  --
  --TYPE t_rec_ficheros      IS RECORD (dir VARCHAR2(100), nombre VARCHAR2(50));
  TYPE t_rec_ficheros      IS RECORD (dir VARCHAR2(100), nombre VARCHAR2(50), tipo varchar2(15) default 'text/plain');
  --
  TYPE t_tab_ficheros      IS TABLE OF t_rec_ficheros INDEX BY BINARY_INTEGER;
  --
  TYPE t_tab_texto         IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  --
/********************************************************
*
*   Procedure principal. Recibe como parametros los destinatarios del mail.
*   p_remitente : direcci�n del remitente sin el nombre del dominio
*   p_nombre_remitente : etiqueta que aparecer� en el From del mail
*   p_prioridad : valores de prioridad de envio. Desde el 1 ( prioridad alta )
*                 hasta 5 (prioridad baja). Por defecto ser� 3 (intermedia)
*   p_tab_destinatario : tabla con la direccion completa de los destinatarios.
*                        Son las direcciones que aparecen en el To :
*   p_tab_concopia : tabla con la direccion completa de los destinatarios CC.
*                        Son las direcciones que aparecen en el CC :
*   p_tab_concopiaoculta : tabla con la direccion completa de los
*                          destinatarios  ocultos
*   p_tab_ficheros : lista de ficheros del servidor que deben ser adjuntados.
*                    Se compone de dos campos :
*                         1.dir : nombre del directorio l�gico.
*                                 Se debe hacer un create directory en Oracle para
*                                 que pueda ser utilizado por el utl_file.
*                         2. nombre : nombre del fichero con la extensi�n incluida
*   p_tab_texto : tabla con el texto del mail. Incluye el formateo y los espacios
*                 a la izquierda. Cada registro llevar� un retorno de carro
*********************************************************/
-- marca la prioridad : 1, 2, 3, 4 o 5.

PROCEDURE p_envio_mail ( p_host_smtp          VARCHAR2,
                         p_puerto_smtp        PLS_INTEGER,
                         p_dominio            VARCHAR2,
                         p_remitente          VARCHAR2,
                         p_nombre_remitente   VARCHAR2,
                         p_prioridad          VARCHAR2,
                         --p_tab_destinatario   trn_k_envio_mail.t_tab_destinatarios,   ---V 1.05
                         p_tab_destinatario   t_tab_destinatarios,
                         --p_tab_concopia       trn_k_envio_mail.t_tab_destinatarios,   ---V 1.05
                         p_tab_concopia       t_tab_destinatarios,
                         --p_tab_concopiaoculta trn_k_envio_mail.t_tab_destinatarios,   ---V 1.05
                         p_tab_concopiaoculta t_tab_destinatarios,
                         --p_tab_ficheros       trn_k_envio_mail.t_tab_ficheros,        ---V 1.05
                         p_tab_ficheros       t_tab_ficheros,
                         --p_tab_texto          trn_k_envio_mail.t_tab_texto,           ---V 1.05
                         p_tab_texto          t_tab_texto,
                         p_asunto             VARCHAR2);
END mrd_k_envio_mail;
/

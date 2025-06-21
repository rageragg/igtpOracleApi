/*
    Para usar el paquete UTL_SMTP de Oracle y enviar correos electrónicos desde la base de datos, debes tener en cuenta las siguientes consideraciones de configuración:

    1. Permisos de Red (ACL)
    Oracle restringe el acceso a la red desde la base de datos por seguridad. Debes crear una Access Control List (ACL) para permitir que el usuario de la base de datos acceda al servidor SMTP.

    Ejemplo:

    Reemplaza 'USUARIO_BD' por el usuario que ejecutará el envío.

    2. Permisos de Ejecución
    El usuario debe tener permisos para ejecutar el paquete UTL_SMTP:

    3. Servidor SMTP
    Debes conocer el host y puerto del servidor SMTP.
    Si el servidor requiere autenticación, deberás implementar el protocolo AUTH LOGIN manualmente (UTL_SMTP no soporta autenticación TLS/SSL nativa).
    Si el servidor SMTP está fuera de tu red, asegúrate de que la base de datos tenga acceso de red a ese host y puerto.
    4. Directorio para Adjuntos
    Si vas a enviar archivos adjuntos, debes tener un DIRECTORY Oracle creado y permisos de lectura para el usuario de la base de datos.

    5. Firewall y Seguridad
    Asegúrate de que el firewall permita la conexión desde el servidor de base de datos al servidor SMTP en el puerto correspondiente.

    6. Configuración de Oracle Wallet (si usas TLS/SSL)
    Si necesitas enviar correos a través de un servidor SMTP seguro (STARTTLS/SSL), deberás configurar Oracle Wallet y usar UTL_MAIL (a partir de 12c) o una librería externa, ya que UTL_SMTP no soporta TLS/SSL directamente.

    7. Tamaño de Mensaje y Adjuntos
    Verifica los límites de tamaño de mensaje y adjuntos permitidos por tu servidor SMTP.

    8. Pruebas
    Haz pruebas con correos simples antes de implementar funcionalidades avanzadas (adjuntos, HTML, etc.).

    Resumen:

    Configura ACL para acceso a red.
    Otorga permisos de ejecución.
    Verifica acceso y configuración del servidor SMTP.
    Configura directorios y permisos para adjuntos.
    Considera seguridad de red y límites del servidor.
*/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host       => 'smtp.tuservidor.com', -- o la IP del servidor SMTP
    lower_port => 25,                    -- o el puerto que uses (25, 587, etc.)
    upper_port => 25,
    ace        => xs$ace_type(privilege_list => xs$name_list('connect'),
                              principal_name => 'USUARIO_BD',
                              principal_type => xs_acl.ptype_db)
  );
END;

GRANT EXECUTE ON UTL_SMTP TO USUARIO_BD;

DECLARE
    l_mailhost   VARCHAR2(64) := 'smtp.tuservidor.com'; -- Cambia por tu servidor SMTP
    l_port       NUMBER := 25;                          -- Puerto SMTP (25, 587, etc.)
    l_conn       UTL_SMTP.CONNECTION;
    l_sender     VARCHAR2(64) := 'remitente@tudominio.com';
    l_recipient  VARCHAR2(64) := 'destinatario@dominio.com';
    l_subject    VARCHAR2(128) := 'Prueba desde Oracle';
    l_message    VARCHAR2(4000) := 'Este es un correo de prueba enviado desde Oracle usando UTL_SMTP.';
    l_crlf       VARCHAR2(2) := CHR(13) || CHR(10);
BEGIN
    -- Abrir conexión SMTP
    l_conn := UTL_SMTP.OPEN_CONNECTION(l_mailhost, l_port);
    UTL_SMTP.HELO(l_conn, l_mailhost);

    -- Especificar remitente y destinatario
    UTL_SMTP.MAIL(l_conn, l_sender);
    UTL_SMTP.RCPT(l_conn, l_recipient);

    -- Iniciar el cuerpo del mensaje
    UTL_SMTP.OPEN_DATA(l_conn);

    -- Escribir cabeceras y cuerpo
    UTL_SMTP.WRITE_DATA(l_conn, 'From: ' || l_sender || l_crlf);
    UTL_SMTP.WRITE_DATA(l_conn, 'To: ' || l_recipient || l_crlf);
    UTL_SMTP.WRITE_DATA(l_conn, 'Subject: ' || l_subject || l_crlf);
    UTL_SMTP.WRITE_DATA(l_conn, l_crlf || l_message || l_crlf);

    -- Finalizar y cerrar conexión
    UTL_SMTP.CLOSE_DATA(l_conn);
    UTL_SMTP.QUIT(l_conn);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error enviando correo: ' || SQLERRM);
END;

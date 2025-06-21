DECLARE
    l_mailhost   VARCHAR2(64) := 'smtp.tuservidor.com'; -- Cambia por tu servidor SMTP
    l_port       NUMBER       := 25;                    -- Puerto SMTP (25, 587, etc.)
    l_mail_conn  UTL_SMTP.connection;
    l_sender     VARCHAR2(64) := 'remitente@tudominio.com';
    l_recipient  VARCHAR2(64) := 'destinatario@dominio.com';
    l_subject    VARCHAR2(100):= 'Prueba de correo desde Oracle';
    l_message    VARCHAR2(4000);
BEGIN
    -- Construir el mensaje
    l_message := 'Este es un correo de prueba enviado desde Oracle usando UTL_SMTP.';

    -- Conectar al servidor SMTP
    l_mail_conn := UTL_SMTP.open_connection(l_mailhost, l_port);

    -- Iniciar la sesión SMTP
    UTL_SMTP.helo(l_mail_conn, l_mailhost);

    -- Especificar el remitente y destinatario
    UTL_SMTP.mail(l_mail_conn, l_sender);
    UTL_SMTP.rcpt(l_mail_conn, l_recipient);

    -- Iniciar el cuerpo del mensaje
    UTL_SMTP.open_data(l_mail_conn);

    -- Escribir los encabezados y el cuerpo
    UTL_SMTP.write_data(l_mail_conn, 'From: ' || l_sender || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'To: ' || l_recipient || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || l_subject || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || l_message);

    -- Finalizar el mensaje
    UTL_SMTP.close_data(l_mail_conn);

    -- Cerrar la conexión SMTP
    UTL_SMTP.quit(l_mail_conn);

    DBMS_OUTPUT.put_line('Correo enviado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error al enviar correo: ' || SQLERRM);
END;
/
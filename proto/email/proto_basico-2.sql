DECLARE
    --
    l_mailhost   VARCHAR2(64) := 'sandbox.smtp.mailtrap.io';
    l_port       NUMBER := 25;
    l_user       VARCHAR2(64) := '19952d30894e49'; 
    l_pass       VARCHAR2(64) := '018c31a3aceaad';         
    l_conn       utl_smtp.connection;
    l_sender     VARCHAR2(64) := 'rageragg2004@yahoo.es';
    l_recipient  VARCHAR2(64) := 'rageragg2004@gmail.com';
    l_auth       VARCHAR2(512);
    
BEGIN
    -- Conectar al servidor SMTP
    l_conn := utl_smtp.open_connection(l_mailhost, l_port);
    --
    -- Iniciar la sesión SMTP
    utl_smtp.helo(l_conn, l_mailhost);
    --
    -- Autenticación LOGIN (Base64)
    l_auth := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(l_user)));
    utl_smtp.command(l_conn, 'AUTH LOGIN');
    utl_smtp.command(l_conn, l_auth);

    l_auth := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(l_pass)));
    UTL_SMTP.COMMAND(l_conn, l_auth);

    -- Especificar remitente y destinatario
    UTL_SMTP.MAIL(l_conn, l_sender);
    UTL_SMTP.RCPT(l_conn, l_recipient);

    -- Iniciar el cuerpo del mensaje
    UTL_SMTP.OPEN_DATA(l_conn);

    -- Escribir los encabezados y el cuerpo
    UTL_SMTP.WRITE_DATA(l_conn, 'From: ' || l_sender || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(l_conn, 'To: ' || l_recipient || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(l_conn, 'Subject: Prueba con autenticación' || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(l_conn, UTL_TCP.CRLF); -- Línea en blanco entre encabezados y cuerpo
    UTL_SMTP.WRITE_DATA(l_conn, '¡Este es un correo de prueba enviado desde Oracle con autenticación!');

    -- Finalizar el mensaje
    UTL_SMTP.CLOSE_DATA(l_conn);

    -- Cerrar la conexión
    UTL_SMTP.QUIT(l_conn);
EXCEPTION
    WHEN OTHERS THEN
        IF l_conn IS NOT NULL THEN
            UTL_SMTP.QUIT(l_conn);
        END IF;
        RAISE;
END;

  CREATE OR REPLACE  PROCEDURE P_SEND_MAIL_MRD (from_name varchar2,
                      to_names varchar2,
                      subject varchar2,
                      message varchar2 default null,
                      html_message varchar2 default null,
                      cc_names varchar2 default null,
                      bcc_names varchar2 default null,
                      filename1 varchar2 default null,
                      filetype1 varchar2 default 'text/plain',
                      filename2 varchar2 default null,
                      filetype2 varchar2 default 'text/plain',
                      filename3 varchar2 default null,
                      filetype3 varchar2 default 'text/plain',
                      p_prioridad varchar2 default null)
IS
/* ------------------- VERSION = 1.06 -----------------*/
-- ------------------- Luis Daniel Andujar---------
--08-04-2016
--Se cambi� el HOST SMTP y este no es compatible con la autenticacion
--actual. Se comento la parte de la autenticacion.
---------------------------------------------------------
/* ------------------- VERSION = 1.05 -----------------*/
-- ------------------- Carlos Hern�ndez cordero---------
--19-03-2014
--Modificado para incluir la prioridad en los coreos
---------------------------------------------------------
/* ------------------- VERSION = 1.04 -----------------*/
-- ------------------- Hilario Aquino------------------
-- 16-09-2011
-- Modificado para que lea el host, puerto desde un procedimiento
-- que a su vez trae los datos desde la tabla G1010107
--                                                      --
------------------------------------------------------------
/* ------------------- VERSION = 1.03 -----------------*/
/* -------------------- 02.04.2006     --------------- */
-- ------------------- Cristina Jimenez------------------
-- Procedimieto p_send_mail
-- Para corregir el ip del servidor que maneja los correos
--                                                      --
------------------------------------------------------------
-- yalarramendi v1.03 8-nov-2010
-- se comentan los dbms_output. en correos masivos, genera error
/* ------------------- VERSION = 1.01 -----------------*/
--
-- Procedimieto p_send_mail (Oracle 9.2 y superiores)
-- Permite el envio de mails
-- diferentes formatos, adjuntar hasta 3 archivos
-- UTL_SMTP paquete para enviar e-mail
-- DBMS_LOB package para leer archivos binarios
-- UTL_ENCODE package para convertir los adjuntos binarios a BASE64
--
-- Listado de parametros
--    from_name - name and e-mail address to put in the From field
--    to_names - names and e-mail addresses for the To field (separated by commas or semicolons)
--    subject - text string for Subject field
--    message - text string or text file name for Message, if any
--    html_message - html string or html file name for Message, if any
--    cc_names - names and e-mail addresses for the Cc field, if any
--    (separated by commas or semicolons)
--    bcc_names - names and e-mail addresses for the Bcc field, if any separated by commas or semicolons
--    filename1 - first unix file pathname to attach, if any
--    filetype1 - mime type of first file (defaults to 'text/plain')
--    filename2 - second unix file pathname to attach, if any
--    filetype2 - mime type of second file (defaults to 'text/plain')
--    filename3 - third unix file pathname to attach, if any
--    filetype3 - mime type of third file (defaults to 'text/plain')

--    Ejemplo
--     begin
--     email_files(from_name    => 'oracle' ,
--                   to_names     => 'prueba@pruebadom.com',
--                   subject      => 'Una prueba',
--                   message      => 'Mensaje de Prueba',
--                   html_message => '<h2>A <u><i>test</i></u>message</h2>',
--                   filename1    => '/tmp/web_ptrbdca.txt',
--                   filename2    => '/tmp/password_standards.pdf',
--                   filetype2    => 'application/pdf',
--                   filename3    => '/tmp/wb703.jpg',
--                   filetype3    => 'image/jpeg');
--    end;

   -- Escribir el nombre o la direccion IP y el puerto del servidor SMTP
   --smtp_host          varchar2(256) := '130.0.0.200';
   --v.1.02
   --smtp_host          varchar2(256) := '10.160.224.5';
   --smtp_port          number := 25;

    -------V. 1.04--------
         /* Host, Puerto, Usuario y Contrasena*/
    l_cod_usr         varchar2(50):= 'TRON2000';
    -- Host
    --10.160.225.138
    smtp_host varchar2(256):= trn_k_ap101107.traer_propiedad(p_cod_usr  =>  l_cod_usr,
                                             p_txt_nombre_variable      =>  'HOST.SMTP');
    -- Puerto
    smtp_port number:= trn_k_ap101107.traer_propiedad(p_cod_usr         =>  l_cod_usr,
                                             p_txt_nombre_variable      =>  'PUERTO.SMTP');

    l_Usr_Auth  Varchar2(50):= trn_k_ap101107.traer_propiedad(p_cod_usr         =>  l_cod_usr,
                                             p_txt_nombre_variable      =>  'USUARIO.SMTP');

    l_Pas_Auth  Varchar2(50):= trn_k_ap101107.traer_propiedad(p_cod_usr         =>  l_cod_usr,
                                             p_txt_nombre_variable      =>  'CONTRASENA.SMTP');
   -----------


   -- Change the boundary string, if needed, which demarcates
   -- boundaries of
   -- parts in a multi-part email, and should not appear inside the
   -- body of any part of the e-mail:

   boundary           constant varchar2(256) := 'CES.Boundary.DACA587499938898';
   recipients         varchar2(32767);
   directory_path     varchar2(256);
   file_name          varchar2(256);
   crlf               varchar2(2):= chr(13) || chr(10);
   mesg               varchar2(32767);
   conn               UTL_SMTP.CONNECTION;
   type varchar2_table is table of varchar2(256) index by
binary_integer;
   file_array         varchar2_table;
   type_array         varchar2_table;
   i                  binary_integer;


   -- Function to return the next email address in the list of email
   --addresses,
   -- separated by either a , or a ;.  From Oracle's demo_mail.
   --The format
   -- of mailbox may be in one of these:
   --    someone@some-domain
   --    Someone at some domain <someone@some-domain>
   --    Someone at some domain <someone@some-domain>

   FUNCTION get_address(addr_list IN OUT VARCHAR2) RETURN VARCHAR2 IS

      addr VARCHAR2(256);
      i    pls_integer;


      FUNCTION lookup_unquoted_char(str  IN VARCHAR2,
                                    chrs IN VARCHAR2) RETURN
pls_integer IS
         c            VARCHAR2(5);
         i            pls_integer;
         len          pls_integer;
         inside_quote BOOLEAN;

      BEGIN

         inside_quote := false;
         i := 1;
         len := length(str);
         WHILE (i <= len) LOOP
            c := substr(str, i, 1);
            IF (inside_quote) THEN
               IF (c = '') THEN
                  inside_quote := false;
               ELSIF (c = '\') THEN
                  i := i + 1; -- Skip the quote character
               END IF;
               GOTO next_char;
            END IF;
            IF (c = '') THEN
               inside_quote := true;
               GOTO next_char;
            END IF;
            IF (instr(chrs, c) >= 1) THEN
               RETURN i;
            END IF;
            <<next_char>>
            i := i + 1;
         END LOOP;
         RETURN 0;
      END;

   BEGIN

      addr_list := ltrim(addr_list);
      i := lookup_unquoted_char(addr_list, ',;');
      IF (i >= 1) THEN
         addr := substr(addr_list, 1, i - 1);
         addr_list := substr(addr_list, i + 1);
      ELSE
         addr := addr_list;
         addr_list := '';
      END IF;
      i := lookup_unquoted_char(addr, '<');
      IF (i >= 1) THEN
         addr := substr(addr, i + 1);
         i := instr(addr, '>');
         IF (i >= 1) THEN
            addr := substr(addr, 1, i - 1);
         END IF;
      END IF;
      RETURN addr;
   END;

   -- Procedure to split a file pathname into its directory path and
--file name
   -- components.

   PROCEDURE split_path_name(file_path IN VARCHAR2, directory_path OUT
VARCHAR2,
      file_name OUT VARCHAR2) IS

      pos number;

   begin

      -- Separate the filename from the directory name

      pos := instr(file_path,'/',-1);
      if pos = 0 then
         pos := instr(file_path,'\',-1);
      end if;
      if pos = 0 then
         directory_path := null;
      else
         directory_path := substr(file_path,1,pos - 1);
      end if;
      file_name := substr(file_path,pos + 1);

   end;

   -- Procedure to append a file's contents to the e-mail

   PROCEDURE append_file(directory_path IN VARCHAR2, file_name IN
VARCHAR2,
      file_type IN VARCHAR2, conn IN OUT UTL_SMTP.CONNECTION) IS

--      generated_name  varchar2(30) := 'EMAIL_FILES\CESDIR' || to_char(sysdate,'HH24MISS');
      generated_name  varchar2(30) := 'CESDIR' || to_char(sysdate,'HH24MISS');
      directory_name  varchar2(30);
      file_handle     utl_file.file_type;
      bfile_handle    bfile;
      bfile_len       number;
      pos             number;
      read_bytes      number;
      line            varchar2(1000);
      data            raw(200);
      my_code         number;
      my_errm         varchar2(32767);

   begin

      begin

         -- Grant access to the directory, unless already defined, and open
         -- the file (as a bfile for a binary file, otherwise as a text file).
         line := directory_path;
         --dbms_output.put_line(generated_name);--v1.03
--         directory_name:='CESDIR145858';
         --p--
         begin
            select dd.directory_name into directory_name from dba_directories dd
               where dd.directory_path = line and rownum = 1;
         exception
            when others then -- when no_data_found then
                my_code := SQLCODE;
                my_errm := SQLERRM;
               directory_name := generated_name;
         end;
         --directory_name := 'PDF';
         if directory_name = generated_name THEN
             --dbms_output.put_line('create or replace directory'||directory_name||directory_path );--v1.03
            EXECUTE immediate 'create or replace directory ' || directory_name || ' as ''' || directory_path || '''';
             --dbms_output.put_line('create1111');--v1.03
            execute IMMEDIATE 'grant read on directory ' || directory_name || ' to public';
             --dbms_output.put_line('create or 222');--v1.03
         end if;
                  --dbms_output.put_line('create or ');--v1.03
         --p--
         if substr(file_type,1,4) != 'text' then
            --dbms_output.put_line(directory_name||' '||file_name);--v1.03
            bfile_handle := bfilename(directory_name,file_name);
            bfile_len := dbms_lob.getlength(bfile_handle);
            pos := 1;
            dbms_lob.open(bfile_handle,dbms_lob.lob_readonly);
         else
            file_handle := utl_file.fopen(directory_name,file_name,'r');
         end if;

         -- Append the file contents to the end of the message
         --dbms_output.put_line('continua');--v1.03
         loop

            -- If it is a binary file, process it 57 bytes at a time,
            -- reading them in with a LOB read, encoding them in BASE64,
            -- and writing out the encoded binary string as raw data

            if substr(file_type,1,4) != 'text' then
               if pos + 57 - 1 > bfile_len then
                  read_bytes := bfile_len - pos + 1;
               else
                  read_bytes := 57;
               end if;
               dbms_lob.read(bfile_handle,read_bytes,pos,data);
               utl_smtp.write_raw_data(conn,utl_encode.base64_encode(data));
               pos := pos + 57;
               if pos > bfile_len then
                  exit;
               end if;

            -- If it is a text file, get the next line of text, append a
            -- carriage return / line feed to it, and write it out

            else
               utl_file.get_line(file_handle,line);
               utl_smtp.write_data(conn,line || crlf);
            end if;

         end loop;

      -- Output any errors, except at end when no more data is found

 exception
         when no_data_found then
            null;
         when others then
            my_code := SQLCODE;
            my_errm := SQLERRM;
            --dbms_output.put_line('Error code ' || my_code || ': ' || my_errm);--v1.03
      end;

      -- Close the file (binary or text)

      if substr(file_type,1,4) != 'text' then
         dbms_lob.close(bfile_handle);
      else
         utl_file.fclose(file_handle);
      end if;
         --p--
/*      if directory_name = generated_name then
         execute immediate 'drop directory ' || directory_name;
      end if;*/
         --p--
   end;

begin

   -----------
   file_array(1) := filename1;
   file_array(2) := filename2;
   file_array(3) := filename3;
   type_array(1) := filetype1;
   type_array(2) := filetype2;
   type_array(3) := filetype3;

   -- Open the SMTP connection and set the From and To e-mail addresses

   conn := utl_smtp.open_connection(smtp_host,smtp_port);

   utl_smtp.helo(conn,smtp_host);
   recipients := from_name;

/*-----------------------------------------------------
|| Eliminacion de la autenticacion a solicitud de Seguridad para enviar los correos a travez de
|| otro servidor, V 1.06 LDA
--------------Autenticacion  (VERSION 1.04)
    utl_smtp.command(conn, 'AUTH LOGIN');
    utl_smtp.command(conn, utl_raw.cast_to_varchar2( utl_encode.base64_encode( utl_raw.cast_to_raw( l_Usr_Auth))) );
    utl_smtp.command(conn, utl_raw.cast_to_varchar2( utl_encode.base64_encode( utl_raw.cast_to_raw( l_Pas_Auth))) );
---------------Fin Autenticacion...
-----------------------------------------------------*/

   utl_smtp.mail(conn,get_address(recipients));
   recipients := to_names;


   while recipients is not null loop
      utl_smtp.rcpt(conn,get_address(recipients));
   end loop;
   recipients := cc_names;


   while recipients is not null loop
      utl_smtp.rcpt(conn,get_address(recipients));
   end loop;
   recipients := bcc_names;


   while recipients is not null loop
      utl_smtp.rcpt(conn,get_address(recipients));
   end loop;


   utl_smtp.open_data(conn);

   -- Build the start of the mail message

   mesg := 'Date: ' || TO_CHAR(SYSDATE,'dd Mon yy hh24:mi:ss') || crlf
||
      'From: ' || from_name || crlf ||
      'Subject: ' || subject || crlf ||
      'To: ' || to_names || crlf;
   if cc_names is not null then
      mesg := mesg || 'Cc: ' || cc_names || crlf;
   end if;
   if bcc_names is not null then
      mesg := mesg || 'Bcc: ' || bcc_names || crlf;
   end if;
   if p_prioridad is not null then
      mesg := mesg || 'X-Priority: ' ||p_prioridad || crlf;
   end if;
   mesg := mesg || 'Mime-Version: 1.0' || crlf ||
      'Content-Type: multipart/mixed; boundary=' || boundary || '' ||
      crlf || crlf ||
      'This is a Mime message, which your current mail reader may not'
|| crlf ||
      'understand. Parts of the message will appear as text. If the
remainder' || crlf ||
      'appears as random characters in the message body, instead of as'
|| crlf ||
      'attachments, then you''ll have to extract these parts and decode
them' || crlf ||
      'manually.' || crlf || crlf;

   utl_smtp.write_data(conn,mesg);

   -- Write the text message or message file, if any
    --dbms_output.put_line('sigue');--v1.03

   if message is not null then
      mesg := '--' || boundary || crlf ||
         'Content-Type: text/plain; name=message.txt;
charset=US-ASCII' ||
          crlf ||
         'Content-Disposition: inline; filename=message.txt' || crlf
||
         'Content-Transfer-Encoding: 7bit' || crlf || crlf;

      utl_smtp.write_data(conn,mesg);
      if substr(message,1,1) = '/' then
         split_path_name(message,directory_path,file_name);
         append_file(directory_path,file_name,'text',conn);
         --dbms_output.put_line('message 12');--v1.03
         utl_smtp.write_data(conn,crlf);
      else
         utl_smtp.write_data(conn,message || crlf);
      end if;
   end if;

   -- Write the HTML message or message file, if any

   if html_message is not null then
      mesg := '--' || boundary || crlf ||
         'Content-Type: text/html; name=message.html;
charset=US-ASCII' ||
         crlf ||
         'Content-Disposition: inline; filename=message.html' || crlf
||
         'Content-Transfer-Encoding: 7bit' || crlf || crlf;
      utl_smtp.write_data(conn,mesg);
      if substr(html_message,1,1) = '/' then
         split_path_name(html_message,directory_path,file_name);
         append_file(directory_path,file_name,'text',conn);
         utl_smtp.write_data(conn,crlf);
      else
         utl_smtp.write_data(conn,html_message || crlf);
      end if;
   end if;

   -- Append the files

   for i in 1..3 loop

      -- If the filename has been supplied ...

      if file_array(i) is not null then
            --dbms_output.put_line('sigue 1 - ' ||file_array(i));--v1.03
         split_path_name(file_array(i),directory_path,file_name);

         -- Generate the MIME boundary line according to the file (mime) type
         -- specified.

         mesg := crlf || '--' || boundary || crlf;

         --dbms_output.put_line('sigue 1 - ' ||file_array(i) ||type_array(i));--v1.03

         if substr(type_array(i),1,4) != 'text' then
            --dbms_output.put_line(substr(type_array(i),1,4));--v1.03

            mesg := mesg || 'Content-Type: ' || type_array(i) ||
               '; name=' || file_name || '' || crlf ||
               'Content-Disposition: attachment; filename=' ||
               file_name || '' || crlf ||
               'Content-Transfer-Encoding: base64' || crlf || crlf ;

           --dbms_output.put_line(mesg);--v1.03
         else
            mesg := mesg || 'Content-Type: application/octet-stream;
name=' ||
               file_name || '' || crlf ||
               'Content-Disposition: attachment; filename=' ||
               file_name || '' || crlf ||
               'Content-Transfer-Encoding: 7bit' || crlf || crlf ;
         end if;

         utl_smtp.write_data(conn,mesg);

         --dbms_output.put_line('sigue 10');--v1.03
         -- Append the file contents to the end of the message

         --dbms_output.put_line(directory_path||' - '||file_name||' -'||type_array(i));--v1.03

         append_file(directory_path,file_name,type_array(i),conn);

         utl_smtp.write_data(conn,crlf);

      end if;
   end loop;

   -- Append the final boundary line

   --dbms_output.put_line('sigue 1');--v1.03

   mesg := crlf || '--' || boundary || '--' || crlf;

   utl_smtp.write_data(conn,mesg);
   -- Close the SMTP connection

   utl_smtp.close_data(conn);
   utl_smtp.quit(conn);
exception
         when others then
           NULL;
end p_send_mail_mrd;
/

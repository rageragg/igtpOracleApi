CREATE OR REPLACE PACKAGE BODY bpm_k_message_pipe_api
 AS
  PROCEDURE send (idMessage IN VARCHAR2,
                  p_text    IN VARCHAR2,
                  p_date    IN DATE DEFAULT SYSDATE) AS
    l_status  NUMBER;
  BEGIN
    DBMS_PIPE.pack_message(p_text);
    DBMS_PIPE.pack_message(p_date);

    l_status := DBMS_PIPE.send_message(idMessage);
    IF l_status != 0 THEN
      RAISE_APPLICATION_ERROR(-20001, idMessage||' error');
    END IF;
  END;

  PROCEDURE receive (id        IN VARCHAR2,
                     p_text    IN OUT VARCHAR2)
  AS
    l_result  INTEGER;
    l_number  NUMBER;
    l_text    VARCHAR2(32767);
    l_date    DATE;
  BEGIN
    l_result := DBMS_PIPE.receive_message (
                  pipename => id,
                  timeout  => 0); --no se bloquea

                  --DBMS_PIPE.maxwait); 1000 dias

    IF l_result = 0 THEN
      -- Mensaje recibido correctamente
      DBMS_PIPE.unpack_message(l_text);
      DBMS_PIPE.unpack_message(l_date);

      DBMS_OUTPUT.put_line('l_text  : ' || l_text);
      DBMS_OUTPUT.put_line('l_date  : ' || l_date);

      p_text := l_text;

    ELSE
      RAISE_APPLICATION_ERROR(-20002, 'message_api.receive was unsuccessful. Return result: ' || l_result);
    END IF;
  END receive;
  --

  PROCEDURE createMessage (idMessage VARCHAR2)
  AS
  l_result  INTEGER;
  BEGIN
  -- Creo la pipa publica
  l_result := DBMS_PIPE.create_pipe(pipename => idMessage,
                                    private  => FALSE);

  --
  --l_result := DBMS_PIPE.create_pipe(pipename => 'explicit_private_pipe');
END;

PROCEDURE deleteMessage (idMessage VARCHAR2)
AS
   l_result  INTEGER;
BEGIN
  -- Elimino la pipa publica
  l_result := DBMS_PIPE.remove_pipe(pipename => idMessage);

  --
  --l_result := DBMS_PIPE.remove_pipe(pipename => 'explicit_private_pipe');
END;


END bpm_k_message_pipe_api;

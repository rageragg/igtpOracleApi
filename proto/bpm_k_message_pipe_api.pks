CREATE OR REPLACE PACKAGE bpm_k_message_pipe_api
AS
  PROCEDURE send
             (idMessage        IN VARCHAR2,
              p_text    IN  VARCHAR2,
              p_date    IN  DATE DEFAULT SYSDATE);
--
  PROCEDURE receive
            (id       IN VARCHAR2,
             p_text   IN OUT VARCHAR2);
--
  PROCEDURE createMessage
             (idMessage VARCHAR2);
  PROCEDURE deleteMessage
             (idMessage VARCHAR2);
END bpm_k_message_pipe_api;

SELECT queue_table, object_type, recipients 
FROM user_queue_tables;

-- Ver si la cola está activa para recibir y entregar mensajes
SELECT name, queue_table, enqueue_enabled, dequeue_enabled 
FROM user_queues 
WHERE name = 'QUEUE_NOTIFICATIONS';

-- Ver el contenido físico de la cola (mientras el mensaje no haya sido desencolado con COMMIT)
SELECT * 
FROM tbl_queue_notifications;

SELECT * 
FROM tbl_queue_difusion;
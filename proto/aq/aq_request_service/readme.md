# CREACION DE COLA

> Colas de datos en Oracle / plsql

## FLUJO DE CREACION
### CONFIGURACION
1. Creacion de tipo de datos que soportara la tabla de cola (type_aq_event.sql)
2. Crear la tabla que se usara para establecer la cola de datos (create_queue_table_event.sql)
### APLICACION
1. Se inserta datos en la cola (enqueue_message_event) 
2. Suscribirse a la cola deseada (create_subscribers_event)
3. Obtener el datos de la cola (dequeue_message_event)
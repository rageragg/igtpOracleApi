/*
    Para este objeto, o campo "data_json" é utilizado para armazenar informações adicionais em formato JSON.
    y se puede utilizar para enviar datos estructurados junto con la notificación.
    su estructa convesional es la siguiente:
    {
        "type_json": "EVENT_TYPE",
        "call_back": "some_callback_function",
        "content": {
            "key1": "value1",
            "key2": "value2"
        }
        ...
    }
*/
CREATE OR REPLACE TYPE typ_aq_event AS OBJECT (
    id              NUMBER,
    k_event         VARCHAR2(100),
    to_user         VARCHAR2(100),
    from_user       VARCHAR2(100),
    data_json       VARCHAR2(4000),
    create_at       DATE
);
/
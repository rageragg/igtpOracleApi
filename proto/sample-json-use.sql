/*
    La función JSON_TRANSFORM de Oracle SQL modifica documentos JSON. Usted especifica la modificación
    operaciones a realizar y expresiones de ruta SQL/JSON que apuntan a los lugares a modificar.
    Las operaciones se aplican a los datos de entrada en el orden especificado: cada operación actúa sobre el
    resultado de aplicar todas las operaciones anteriores.

    La función JSON_TRANSFORM es atómica: si intentar alguna de las operaciones genera un error, entonces
    ninguna de las operaciones surte efecto. JSON_TRANSFORM tiene éxito por completo, de modo que el
    los datos se modifican según sea necesario, o los datos permanecen sin cambios. JSON_TRANSFORM devuelve el
    datos originales, modificados según lo expresado en los argumentos.
    Puede utilizar JSON_TRANSFORM en una instrucción SQL UPDATE para actualizar los documentos en un
    columna JSON. El ejemplo 11-1 ilustra esto.

    Puede usarlo en una lista SELECT, para modificar los documentos seleccionados. Los documentos modificados
    se puede devolver o procesar más. El ejemplo 11-2 ilustra esto.
    La función JSON_TRANSFORM puede aceptar como entrada y devolver como salida cualquier tipo de datos SQL que
    admite datos JSON.

    El tipo de datos de retorno (salida) predeterminado es el mismo que el tipo de datos de entrada. (Si la entrada es
    VARCHAR2 de cualquier tamaño, el valor predeterminado es VARCHAR2(4000)).
*/

/*
    Ejemplo 11-1 Actualización de una columna JSON usando JSON_TRANSFORM
    Este ejemplo actualiza todos los documentos en j_purchaseorder.po_document, configurando el
    valor del campo lastUpdated a la marca de tiempo actual.
    Si el campo ya existe, se reemplaza su valor; de lo contrario, el campo y su valor
    se agregan. (Es decir, se utilizan los controladores predeterminados: REEMPLAZAR EN EXISTENTE y CREAR
    EN DESAPARECIMIENTO.) -> "REPLACE ON EXISTING and CREATE ON MISSING.)"
*/
UPDATE j_purchaseorder 
    SET po_document = json_transform(po_document, SET '$.lastUpdated' = SYSTIMESTAMP);

/*
    Ejemplo 11-2 Modificación de datos JSON sobre la marcha con JSON_TRANSFORM
    Este ejemplo selecciona todos los documentos en j_purchaseorder.po_document y devuelve
    copias bonitas e impresas y actualizadas de ellos, donde el campo "Instrucciones especiales" ha sido
    removido
    No hace nada (no se genera ningún error) si el campo no existe: IGNORE ON FALTING es el
    comportamiento por defecto.
    El tipo de datos devuelto es CLOB.
*/
SELECT json_transform(po_document, REMOVE '$."Special Instructions"' RETURNING CLOB )
  FROM j_purchaseorder;

DATA
----------------------------------------------------------------------------
{"PONumber":1600,"Reference":"ABULL-20140421","Requestor":"Alexis Bull","Us
{"PONumber":672,"Reference":"SBELL-20141017","Requestor":"Sarah Bell","User

/*
    Ejemplo 11-3 Agregar un campo usando JSON_TRANSFORM
    Estos dos usos de json_tranform son equivalentes. Cada uno agrega el campo Comentarios con
    valor "Útil". Se genera un error si el campo ya existe. La entrada para el campo.
    El valor es una cadena SQL literal "Útil". El comportamiento predeterminado para SET es CREAR EN
    DESAPARECIDO.
*/
UPDATE j_purchaseorder 
    SET  po_document = json_transform(po_document, INSERT '$.Comments' = 'Helpful');

UPDATE j_purchaseorder 
    SET po_document = json_transform(po_document, SET '$.Comments' = 'Helpful' ERROR ON EXISTING)

SQL Error: ORA-40763: existing value in JSON_TRANSFORM ()
40763. 00000 -  "existing value in JSON_TRANSFORM (%s)"
*Cause:    An attempt was made to work with a value in JSON_TRANSFORM that already existed.
*Action:   Correct your path expression or change the ON EXISTING clause in the JSON_TRANSFORM operation.

/*
    Ejemplo 11-4 Eliminación de un campo mediante JSON_TRANSFORM
    Este ejemplo elimina el campo Instrucciones especiales. No hace nada (no se genera ningún error) si el
    El campo no existe: IGNORAR SI FALTA es el comportamiento predeterminado.
*/
UPDATE j_purchaseorder 
    SET po_document = json_transform(po_document, REMOVE '$.Comments');

/*
    Ejemplo 11-5 Crear o reemplazar un valor de campo usando JSON_TRANSFORM
    Esto establece el valor del campo Dirección en el objeto JSON {"street":"8 Timbly Lane",
    "ciudad":"Penobsky", "estado":"Utah"}. Crea el campo si no existe y lo reemplaza.
    cualquier valor existente para el campo. La entrada para el valor del campo es una cadena SQL literal. El
    El valor del campo actualizado es un objeto JSON, porque se especifica FORMAT JSON para el valor de entrada.

    NOTA -- ! AGREGA LA PROPIEDAD AL FINAL DEL OBJETO 
         Ejemplo: "lastUpdated":"2024-04-07T09:37:41.177000+08:00","Address":{"street":"8 Timbly Rd.","city":"Penobsky","state":"UT"}}

    Sin utilizar FORMAT JSON, el valor del campo Dirección sería una cadena JSON que corresponde
    a la cadena de entrada SQL. Cada uno de los caracteres entre comillas dobles (") en la entrada sería
    escapó en la cadena JSON: "{\"calle\":\"8 Timbly Rd.\","ciudad\":\"Penobsky\",\"estado\":\"UT\"}"
*/

UPDATE j_purchaseorder 
    SET po_document = json_transform(po_document, SET '$.Address' =
        '{"street":"8 Timbly Rd.", "city":"Penobsky", "state":"UT"}'
        FORMAT JSON
    )
WHERE ID = 'FA08E1FC592A4EF2A12952E622887F3A';

/*
    Ejemplo 11-6 Reemplazo de un valor de campo existente usando JSON_TRANSFORM
    Esto establece el valor del campo Dirección en el objeto JSON {"street":"8 Timbly Lane",
    "ciudad":"Penobsky", "estado":"Utah"}. Reemplaza un valor existente para el campo y no
    nada si el campo no existe. La única diferencia entre este ejemplo y
    El ejemplo 11-5 es la presencia del controlador IGNORAR SI FALTA.
*/

UPDATE j_purchaseorder 
    SET po_document = json_transform(po_document,
            SET '$.Address' = '{"street":"8 Timbly Rd.", "city":"Penobsky", "state":"UT"}'
            FORMAT JSON
            IGNORE ON MISSING
    )
WHERE ID = 'FA08E1FC592A4EF2A12952E622887F3A';

/*
    Ejemplo 11-7 Uso de FORMAT JSON para establecer un valor booleano JSON
    Este ejemplo establece el valor del campo AllowPartialShipment en el valor booleano en lenguaje JSON.
    valor true. Sin las palabras clave FORMAT JSON, en su lugar establecería el campo en la cadena de lenguaje JSON "true".
*/

UPDATE j_purchaseorder 
    SET po_document = json_transform( po_document,
            SET '$.AllowPartialShipment' = 'true' FORMAT JSON
    )
WHERE ID = 'FA08E1FC592A4EF2A12952E622887F3A';

/*
    Ejemplo 11-8 Configuración de un elemento de matriz usando JSON_TRANSFORM
    Esto establece el primer elemento de la matriz Phone en la cadena JSON "909-555-1212".
*/
UPDATE j_purchaseorder 
    SET po_document = json_transform(po_documento,
            SET '$.ShippingInstructions.Phone[0]' = '909-555-1212'
    );

-- * Si el valor de la matriz Phone antes de la operación es este:
[   {"tipo":"Oficina","número":"909-555-7307"}, {"tipo":"Móvil","número":415-555-1234"} ]

-- * Entonces este es el valor después de la modificación:
[   "909-555-1212", {"tipo":"Movil","numero":415-555-1234"} ]

/*
    Ejemplo 11-9 Anteponer un elemento de matriz usando JSON_TRANSFORM
    Esto antepone el elemento "909-555-1212" a la matriz Teléfono. La inserción en la posición 0 desplaza todos
    elementos existentes a la derecha: el elemento N se convierte en el elemento N+1.
*/
UPDATE j_purchaseorder 
    SET po_document =  json_transform(po_documento,
            INSERT '$.ShippingInstructions.Phone[0]' = '909-555-1212'
    );

/*
    Ejemplo 11-10 Agregar un elemento de matriz usando JSON_TRANSFORM
    Estos dos usos de json_tranform son equivalentes. Cada uno de ellos añade un elemento.
    "909-555-1212" al teléfono de la matriz.
*/
UPDATE j_purchaseorder 
    SET po_document = json_transform(po_documento,
        APPEND '$.ShippingInstructions.Phone' =
        '909-555-1212'
    );

UPDATE j_purchaseorder 
    SET po_document = json_transform(po_documento,
        INSERT '$.ShippingInstructions.Phone[last+1]' =
        '909-555-1212'
    );

/*
    QUERY JSON 
    SIMPLE DOT-NOTATION ACCESS TO JSON DATA
*/

/*
    Ejemplo 14-1 Consulta de notación de puntos JSON comparada con JSON_VALUE
*/
SELECT po.po_document.PONumber FROM j_purchaseorder po;

PONUMBER                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
------------
1600
672

SELECT json_value(po_document, '$.PONumber') FROM j_purchaseorder;

PONUMBER                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
------------
1600
672

/*
    Ejemplo 14-2 Consulta de notación de puntos JSON comparada con JSON_QUERY
*/

SELECT po.po_document.ShippingInstructions.Phone FROM j_purchaseorder po;

SHIPPINGINSTRUCTIONS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
---------------------------------------------------------------------------------------
[{"type":"Office","number":"909-555-7307"},{"type":"Mobile","number":"415-555-1234"}]
983-555-6509

SELECT json_query(po_document, '$.ShippingInstructions.Phone') FROM j_purchaseorder;

JSON_QUERY(PO_DOCUMENT,'$.SHIPPINGINSTRUCTIONS.PHONE')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
---------------------------------------------------------------------------------------
[{"type":"Office","number":"909-555-7307"},{"type":"Mobile","number":"415-555-1234"}]
"983-555-6509"

SELECT po.po_document.ShippingInstructions.Phone.type FROM j_purchaseorder po;
SHIPPINGINSTRUCTIONS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
["Office","Mobile"]

/* 
    Siendo el JSON:
        "Phone":[
            {"type":"Office","number":"909-555-7307"},
            {"type":"Mobile","number":"415-555-1234"}
        ]
*/

SELECT json_query(po_document, '$.ShippingInstructions.Phone.type' WITH WRAPPER) FROM j_purchaseorder;

/*
    -- TODO
    SQL/JSON PATH EXPRESSIONS
*/
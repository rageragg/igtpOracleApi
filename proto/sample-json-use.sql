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

-- DATA
-- ----------------------------------------------------------------------------
-- {"PONumber":1600,"Reference":"ABULL-20140421","Requestor":"Alexis Bull","Us
-- {"PONumber":672,"Reference":"SBELL-20141017","Requestor":"Sarah Bell","User

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

-- SQL Error: ORA-40763: existing value in JSON_TRANSFORM ()
-- 40763. 00000 -  "existing value in JSON_TRANSFORM (%s)"
-- *Cause:    An attempt was made to work with a value in JSON_TRANSFORM that already existed.
-- *Action:   Correct your path expression or change the ON EXISTING clause in the JSON_TRANSFORM operation.

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
-- [   {"tipo":"Oficina","número":"909-555-7307"}, {"tipo":"Móvil","número":415-555-1234"} ]

-- * Entonces este es el valor después de la modificación:
-- [   "909-555-1212", {"tipo":"Movil","numero":415-555-1234"} ]

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

-- PONUMBER                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
-- ------------
-- 1600
-- 672

SELECT json_value(po_document, '$.PONumber') FROM j_purchaseorder;

-- PONUMBER                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
-- ------------
-- 1600
-- 672

/*
    Ejemplo 14-2 Consulta de notación de puntos JSON comparada con JSON_QUERY
*/

SELECT po.po_document.ShippingInstructions.Phone FROM j_purchaseorder po;

-- SHIPPINGINSTRUCTIONS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
-- ---------------------------------------------------------------------------------------
-- [{"type":"Office","number":"909-555-7307"},{"type":"Mobile","number":"415-555-1234"}]
-- 983-555-6509

SELECT json_query(po_document, '$.ShippingInstructions.Phone') FROM j_purchaseorder;

-- JSON_QUERY(PO_DOCUMENT,'$.SHIPPINGINSTRUCTIONS.PHONE')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
-- ---------------------------------------------------------------------------------------
-- [{"type":"Office","number":"909-555-7307"},{"type":"Mobile","number":"415-555-1234"}]
-- "983-555-6509"

SELECT po.po_document.ShippingInstructions.Phone.type FROM j_purchaseorder po;

-- SHIPPINGINSTRUCTIONS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ["Office","Mobile"]

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

/*
    Oracle Database proporciona acceso SQL a datos JSON mediante expresiones de ruta SQL/JSON.

        • Descripción general de las expresiones de ruta SQL/JSON
            Oracle Database proporciona acceso SQL a datos JSON mediante expresiones de ruta SQL/JSON.
        • Sintaxis de expresión de ruta SQL/JSON
            Las expresiones de ruta SQL/JSON coinciden con las funciones y condiciones SQL/JSON
            contra datos JSON, para seleccionar partes de ellos. Las expresiones de ruta pueden usar comodines y matrices.
            rangos. La coincidencia distingue entre mayúsculas y minúsculas.
        • Métodos de elemento de expresión de ruta SQL/JSON
            Se describen los métodos de elementos de Oracle disponibles para una expresión de ruta SQL/JSON.
        • Compatibilidad con fecha y hora ISO 8601
            La norma 8601 de la Organización Internacional de Normalización (ISO) describe una
            forma aceptada de representar fechas y horas. Oracle Database es compatible con muchas de las normas ISO.
            8601 formatos de fecha y hora.
        • Tipos en comparaciones
            Las comparaciones en las condiciones del filtro de expresión de ruta SQL/JSON se escriben estáticamente en
            tiempo de compilación. Si no se sabe que los tipos efectivos de operandos de una comparación son
            lo mismo, entonces a veces se intenta reconciliarlos mediante el encasillamiento.

    Descripción general de las expresiones de ruta SQL/JSON
        Oracle Database proporciona acceso SQL a datos JSON mediante expresiones de ruta SQL/JSON.
        JSON es una notación para valores de JavaScript. Cuando los datos JSON se almacenan en la base de datos, puede
        consultarlo usando expresiones de ruta que son algo análogas a XQuery o XPath
        Expresiones para datos XML. Similar a la forma en que SQL/XML permite el acceso SQL a datos XML
        Usando expresiones XQuery, Oracle Database proporciona acceso SQL a datos JSON usando SQL/
        Expresiones de ruta JSON.
        Las expresiones de ruta SQL/JSON tienen una sintaxis simple. Una expresión de ruta selecciona cero o más
        Valores JSON que coinciden o lo satisfacen.
        La condición SQL/JSON json_exists devuelve verdadero si al menos un valor coincide y falso si no
        coincidencias de valores. Si un solo valor coincide, entonces la función SQL/JSON json_value devuelve ese
        valor si es escalar y genera un error si no es escalar. Si ningún valor coincide con la ruta
        expresión entonces json_value devuelve SQL NULL.
        La función SQL/JSON json_query devuelve todos los valores coincidentes, es decir, puede devolver
        múltiples valores. Puede pensar en este comportamiento como si devolviera una secuencia de valores, como en
        XQuery, o puede considerarlo como si devolviera múltiples valores. (No se muestra ninguna secuencia visible para el usuario).
        manifestado.)
        En todos los casos, la coincidencia de expresión de ruta intenta hacer coincidir cada paso de la expresión de ruta, en
        doblar. Si falla la coincidencia de algún paso, no se intenta igualar los pasos siguientes, y
        La coincidencia de la expresión de ruta falla. Si la coincidencia de cada paso tiene éxito, entonces la coincidencia de los
        La expresión de la ruta tiene éxito.

    Sintaxis de expresión de ruta SQL/JSON
        Las expresiones de ruta SQL/JSON coinciden con las funciones y condiciones SQL/JSON
        contra datos JSON, para seleccionar partes de ellos. Las expresiones de ruta pueden utilizar comodines y
        rangos de matriz. La coincidencia distingue entre mayúsculas y minúsculas.
        Pasa una expresión de ruta SQL/JSON y algunos datos JSON a una función SQL/JSON
        o condición. La expresión de ruta se compara con los datos y los datos coincidentes
        es procesado por la función o condición SQL/JSON particular. Puedes pensar en esto
        proceso de coincidencia en términos de la expresión de ruta que devuelve los datos coincidentes al
        función o condición.
        • Sintaxis básica de expresión de ruta SQL/JSON
            Se presenta la sintaxis básica de una expresión de ruta SQL/JSON. Esta compuesto de
            un símbolo de elemento de contexto ($) seguido de cero o más objetos, matrices y descendientes
            pasos, cada uno de los cuales puede ir seguido de una expresión de filtro, seguida opcionalmente de
            un paso de función. Se proporcionan ejemplos.
        • Relajación de la sintaxis de la expresión de ruta SQL/JSON
            La sintaxis básica de expresión de ruta SQL/JSON se relaja para permitir matrices implícitas.
            envolver y desenvolver. Esto significa que no es necesario cambiar una ruta.
            expresión en su código si sus datos evolucionan para reemplazar un valor JSON con una matriz
            de tales valores, o viceversa. Se proporcionan ejemplos.
            Temas relacionados
        • Acerca de la sintaxis JSON estricta y laxa
            La sintaxis predeterminada de Oracle para JSON es laxa. En particular: refleja el JavaScript
            sintaxis para campos de objetos; los valores booleanos y nulos no distinguen entre mayúsculas y minúsculas; y eso
            es más permisivo con respecto a los números, los espacios en blanco y el escape de Unicode
            caracteres.
        • Diagramas para la sintaxis básica de expresión de ruta SQL/JSON
            Diagramas de sintaxis y descripciones de sintaxis correspondientes del formulario Backus-Naur (BNF)
            se presentan para la sintaxis básica de expresión de ruta SQL/JSON.

*/

SELECT json_query('["alpha", 42, "10.4"]', '$[*].stringOnly()' WITH ARRAY WRAPPER) FROM dual;

-- JSON_QUERY('["ALPHA",42,"10.4"]','$[*].STRINGONLY()'WITHARRAYWRAPPER)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
-- -----------------------------------------------------------------------
-- ["alpha","10.4"]

SELECT json_query('["alpha", 42, "10.4"]', '$[*].numberOnly()' WITH ARRAY WRAPPER) FROM dual;

-- JSON_QUERY('["ALPHA",42,"10.4"]','$[*].NUMBERONLY()'WITHARRAYWRAPPER)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
-- ---------------------------------------------------------------------
-- [42]

SELECT json_value('[19, "Oracle", {"a":1},[1,2,3]]', '$.type()') FROM dual;

-- JSON_VALUE('[19,"ORACLE",{"A":1},[1,2,3]]','$.TYPE()')                                              
-- -------------------------------------------------------
-- array

/*
    Temas relacionados
    • Cláusula de campo vacío para funciones de consulta SQL/JSON
        Las funciones de consulta SQL/JSON json_value, json_query y json_table aceptan una opción
        Cláusula ON EMPTY, que especifica el manejo que se utilizará cuando un campo JSON de destino es
        ausente de los datos consultados. Esta cláusula y el comportamiento predeterminado (sin cláusula ON EMPTY)
        se describen aquí.
    • Función SQL/JSON JSON_TABLE
        La función SQL/JSON json_table proyecta datos JSON específicos en columnas de varios SQL
        tipos de datos. Se utiliza para asignar partes de un documento JSON a las filas y columnas de un
        nueva mesa virtual, que también puede considerar como una vista en línea.
    • Función SQL/JSON JSON_QUERY
        La función SQL/JSON json_query selecciona uno o más valores de los datos JSON y devuelve
        una cadena (instancia VARCHAR2, CLOB o BLOB) que representa los valores JSON. Puede
        por lo tanto, utilice json_query para recuperar fragmentos de un documento JSON.
    • Función SQL/JSON JSON_VALUE
        La función SQL/JSON json_value selecciona datos JSON y devuelve un escalar SQL o un
        instancia de un tipo de objeto SQL definido por el usuario o un tipo de colección SQL (varray, tabla anidada).
    • Función SQL de Oracle JSON_SERIALIZE
        La función json_serialize de Oracle SQL toma datos JSON (de cualquier tipo de datos SQL, VARCHAR2,
        CLOB o BLOB) como entrada y devuelve una representación textual del mismo (como VARCHAR2, CLOB o
        datos BLOB). VARCHAR2(4000) es el tipo de devolución predeterminado.
    • Condición SQL/JSON JSON_EXISTS
        La condición SQL/JSON json_exists le permite usar una expresión de ruta SQL/JSON como una fila
        filtro, para seleccionar filas según el contenido de los documentos JSON. Puedes usar la condición.
        json_exists en una expresión CASE o la cláusula WHERE de una declaración SELECT.
    • Cláusula ON MISMATCH para JSON_VALUE
        Cuando la cláusula RETURNING especifica un tipo de objeto o tipo de colección definido por el usuario
        Por ejemplo, la función json_value acepta una cláusula opcional ON MISMATCH, que especifica
        manejo a utilizar cuando un valor JSON objetivo no coincide con el retorno SQL especificado
        valor. Esta cláusula y su comportamiento predeterminado (sin cláusula ON MISMATCH) se describen aquí.
*/

/*
    Usando filtros con JSON_EXISTS
    "AllowPartialShipment":true,
    "LineItems":[
        {
            "ItemNumber":1,
            "Part":{
                "Description":"One Magic Christmas",
                "UnitPrice":19.95,
                "UPCCode":85391628927
            },
            "Quantity":9
        }
*/

SELECT po.po_document FROM j_purchaseorder po WHERE json_exists(po.po_document, '$.LineItems.Part.UPCCode');

-- PO_DOCUMENT                                                                     
-- --------------------------------------------------------------------------------
-- '{"PONumber":1600,"Reference":"ABULL-20140421","Requestor":"Alexis Bull","User":"
-- {"PONumber":672,"Reference":"SBELL-20141017","Requestor":"Sarah Bell","User":"SB"'

SELECT po.po_document FROM j_purchaseorder po WHERE json_exists(po.po_document, '$?(@.LineItems.Part.UPCCode == 85391628927)');

-- PO_DOCUMENT                                                                     
-- --------------------------------------------------------------------------------
-- '{"PONumber":1600,"Reference":"ABULL-20140421","Requestor":"Alexis Bull","User":"'


/*
    Ejemplo 17-3 JSON_EXISTS: Las condiciones del filtro dependen del elemento actual
    Este ejemplo selecciona documentos de orden de compra que tienen un artículo en línea con una parte que
    tiene el código UPC 85391628927 y un artículo de línea con una cantidad de pedido superior a 3. El alcance
    de cada filtro, es decir, el elemento actual, es en este caso el elemento de contexto. Cada condición de filtro
    se aplica de forma independiente (al mismo documento); las dos condiciones no necesariamente se aplican a
    la misma partida.
*/
SELECT po.po_document 
  FROM j_purchaseorder po 
 WHERE json_exists(po.po_document, '$?(@.LineItems.Part.UPCCode == 85391628927 && @.LineItems.Quantity > 3)');

-- PO_DOCUMENT                                                                     
-- --------------------------------------------------------------------------------
-- {"PONumber":1600,"Reference":"ABULL-20140421","Requestor":"Alexis Bull","User":"

/*
    Ejemplo 17-4 JSON_EXISTS: reducción de alcance del filtro
    Este ejemplo es similar al ejemplo 17-3, pero actúa de manera bastante diferente. Selecciona documentos de orden de compra que tengan 
    una partida con una pieza que tenga código UPC y con un pedido cantidad mayor que 3. 
    El alcance del elemento actual en el filtro está en un nivel inferior; No lo es
    el elemento de contexto sino un elemento de matriz LineItems. Es decir, la misma partida debe satisfacer ambas
    condiciones, para que json_exists devuelva verdadero.
*/

SELECT po.po_document 
  FROM j_purchaseorder po
 WHERE json_exists(po.po_document, '$.LineItems[*]?(@.Part.UPCCode == 85391628927 && @.Quantity > 3)');

/*
    Ejemplo 17-5 JSON_EXISTS: Existe una expresión de ruta que utiliza Path-Expression Condición
    Este ejemplo muestra cómo reducir el alcance de una parte de un filtro y dejar otra parte.
    con alcance a nivel de documento (elemento de contexto). Selecciona documentos de orden de compra que
    tienen un campo Usuario cuyo valor es "ABULL" y documentos que tienen una línea de pedido con un
    pieza que tiene código UPC y con una cantidad de pedido mayor a 3. Es decir, selecciona el
    mismos documentos seleccionados en el Ejemplo 17-4, así como todos los documentos que tienen
    "ABULL" como usuario. El argumento para que el predicado de expresión de ruta exista es una ruta
    expresión que especifica artículos de línea particulares; el predicado devuelve verdadero si hay una coincidencia
    encontrados, es decir, si existen tales partidas individuales.
    (Si usa este ejemplo o similar con SQL*Plus entonces debe usar SET DEFINE OFF
    primero, para que SQL*Plus no interprete && existe como una variable de sustitución y
    le pedirá que lo defina).
*/

SELECT po.po_document 
  FROM j_purchaseorder po
 WHERE json_exists(po.po_document, '$?(@.User == "ABULL" && exists(@.LineItems[*]?( @.Part.UPCCode == 85391628927dd && @.Quantity > 3)))');

/*
    -- todo
    SQL/JSON Function JSON_VALUE
*/

/*
    Ejemplo 18-1 JSON_VALUE: Devolver un valor booleano JSON a PL/SQL como BOOLEANO
    PL/SQL también tiene manejo de excepciones. Este ejemplo utiliza la cláusula ERROR ON ERROR, para generar una
    error (que puede ser manejado por código de usuario) en caso de error.
*/
DECLARE
    --
    b BOOLEAN;
    jsonData CLOB;
    --
BEGIN
    --
    SELECT po_document 
      INTO jsonData 
      FROM j_purchaseorder 
     WHERE rownum = 1;
    --
    b := json_value(jsonData, '$.AllowPartialShipment' RETURNING BOOLEAN ERROR ON ERROR);
    --
    if b then
        dbms_output.put_line('verdad');
    end if;
    --
END;

/*
    Example 18-2, JSON_VALUE: Devolver un valor JSON a SQL como VARCHAR2
*/

SELECT json_value(po_document, '$.Address.street') street
  FROM j_purchaseorder;

-- STREET                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
-- --------------------
-- 8 Timbly Rd.

/*
    JSON_TABLE generaliza funciones y condiciones de consulta SQL/JSON 
    La función SQL/JSON json_table generaliza la condición SQL/JSON json_exists y las 
    funciones SQL/JSON json_value y json_query. Todo lo que puedes hacer usando estas funciones 
    lo puedes hacer usando json_table. Para los trabajos que realizan, 
    la sintaxis de estas funciones es más sencilla de usar que la sintaxis de json_table.
*/

/*
    Ejemplo 18-3 Crear una instancia de un objeto definido por el usuario a partir de datos JSON con JSON_VALUE
    Este ejemplo define los tipos de objetos SQL Shipping_t y addr_t. El tipo de objeto envío_t tiene atributos nombre y dirección, que tienen tipos VARCHAR2(30) y addr_t, respectivamente.
    El tipo de objeto addr_t tiene atributos calle y ciudad.
    El ejemplo utiliza json_value para seleccionar el objeto JSON que es el valor del campo ShippingInstructions y devolver una instancia del tipo de objeto SQL envío_t. Los nombres de los atributos de tipo de objeto se comparan con los nombres de campos de objetos JSON sin distinguir entre mayúsculas y minúsculas, por lo que
    que, por ejemplo, el atributo dirección (que es lo mismo que DIRECCIÓN) del tipo de objeto SQL envío_t coincide con la dirección del campo JSON.
    (El resultado de la consulta se muestra aquí bastante impreso, para mayor claridad).

    CREATE TYPE addr_t AS OBJECT(
        street VARCHAR2(100),
        city VARCHAR2(30)
    );
    --
    CREATE TYPE shipping_t AS OBJECT(
        name VARCHAR2(30),
        address addr_t
    ); 
    --
    CREATE TYPE part_t AS OBJECT(
        description     VARCHAR2(30),
        unitprice       NUMBER,
        upccode         NUMBER
    );
    --
    CREATE TYPE parts_t AS VARRAY(10) OF part_t;
    --
    CREATE TYPE item_t AS OBJECT(
        itemnumber  NUMBER,
        part        part_t,
        quantity    NUMBER
    );
    --
    CREATE TYPE items_t AS VARRAY(10) OF item_t;
    --
*/
--
SELECT json_value(po_document, '$.ShippingInstructions' RETURNING shipping_t) as ShippingInstructions
  FROM j_purchaseorder;

-- SHIPPINGINSTRUCTIONS(NAME, ADDRESS(STREET, CITY))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
-- -----------------------------------------------------------------------------------
-- SHIPPING_T('Alexis Bull', ADDR_T('200 Sporting Green', 'South San Francisco'))
-- SHIPPING_T('Sarah Bell', ADDR_T('200 Sporting Green', 'South San Francisco'))

SELECT json_value(po_document, '$.LineItems' RETURNING items_t)
 FROM j_purchaseorder;

-- JSON_VALUE(PO_DOCUMENT,'$.LINEITEMS'RETURNINGITEMS_TUSIN
--------------------------------------------------------
-- ITEMS_T(ITEM_T(1, PART_T('One Magic Christmas', 19.95)),
--   ITEM_T(2, PART_T('Lethal Weapon', 19.95)))
-- ITEMS_T(ITEM_T(1, PART_T('Making the Grade', 20)),
--   ITEM_T(2, PART_T('Nixon', 19.95)),

/*
    La función SQL/JSON json_value puede verse como un caso especial de la función 
    json_table.
    El ejemplo 18-5 ilustra la equivalencia: las dos sentencias SELECT tienen el mismo 
    efecto. Además de quizás ayudarte a comprender mejor json_value, esta equivalencia es
    importante en la práctica, porque significa que puedes usar cualquiera de las funciones 
    para obtener el mismo efecto.
    En particular, si usa json_value más de una vez, o lo usa en combinación con 
    json_exists o json_query (que también se puede expresar usando json_table), para acceder 
    a los mismos datos, entonces una sola invocación de json_table presenta la ventaja de 
    que los datos son analizado sólo una vez.
    Debido a esto, el optimizador a menudo reescribe automáticamente múltiples 
    invocaciones de json_exists, json_value y json_query (cualquier combinación) 
    en menos invocaciones de json_table.
    Ejemplo 18-5 JSON_VALUE expresado usando JSON_TABLE
*/

SELECT json_value(column, json_path RETURNING data_type error_hander ON ERROR)
  FROM table;
--
SELECT jt.column_alias
  FROM table,
       json_table( column, 
                   '$' error_handler ON ERROR
                   COLUMNS ("COLUMN_ALIAS" data_type PATH json_path)
                 ) AS "JT";
            
/*
    La función SQL/JSON json_query selecciona uno o más valores de los datos JSON y devuelve una cadena (instancia VARCHAR2, CLOB o BLOB) 
    que representa los valores JSON. Así puedes utilizar json_query para recuperar fragmentos de un documento JSON.
    El primer argumento de json_query es una expresión SQL que devuelve una instancia de un tipo de datos SQL escalar 
    (es decir, no un objeto o un tipo de datos de colección). Puede ser de tipo de datos VARCHAR2,
    CLOB o BLOB. Puede ser un valor de columna de tabla o vista, una variable PL/SQL o una variable de enlace con la conversión adecuada. 
    El resultado de evaluar la expresión SQL se utiliza como elemento de contexto. para evaluar la expresión de ruta.
    El segundo argumento de json_query es una expresión de ruta SQL/JSON seguida de cláusulas opcionales RETURNING, WRAPPER, ON ERROR y ON EMPTY. La expresión de ruta puede apuntar a cualquier
    número de valores JSON.

    En la cláusula RETURNING puede especificar el tipo de datos VARCHAR2, CLOB o BLOB. Un resultado BLOB está en el juego de caracteres AL32UTF8. 
    (VARCHAR2 es el valor predeterminado). El valor devuelto siempre contiene datos JSON bien formados. Esto incluye garantizar que los caracteres 
    ue no sean ASCII en los valores de cadena se escapen según sea necesario. Por ejemplo, un carácter ASCII TAB (carácter Unicode CARACTER
    TABULACIÓN, U+0009) se escapa como \t. Las palabras clave FORMAT JSON no son necesarias (ni están disponibles) para json_query: 
    el formato JSON está implícito en el valor de retorno.
    La cláusula contenedora determina la forma del valor de cadena devuelto.
    La cláusula de error para json_query puede especificar EMPTY ON ERROR, lo que significa que se devuelve una matriz vacía ([]) en caso de error (no se genera ningún error).
    
    El ejemplo 19-1 muestra un ejemplo del uso de la función SQL/JSON json_query con un contenedor de matriz. Para cada documento devuelve un valor VARCHAR2 cuyo contenido representa un JSON
    Matriz con elementos de los tipos de teléfono, en un orden no especificado. Para el documento del Ejemplo 4-2, los tipos de teléfono son "Oficina" y "Móvil", y la matriz devuelta es
    ["Móvil", "Oficina"] o ["Oficina", "Móvil"].
    Tenga en cuenta que si se utilizara la expresión de ruta $.ShippingInstructions.Phone.type en

    Ejemplo 19-1 daría el mismo resultado. Debido a la sintaxis de expresión de ruta SQL/JSON
    relajación, [*].type es equivalente a .type.
*/

SELECT json_query(po_document, '$.ShippingInstructions.Phone[*].type' WITH WRAPPER) 
  FROM j_purchaseorder;

-- JSON_QUERY(PO_DOCUMENT,'$.SHIPPINGINSTRUCTIONS.PHONE[*].TYPE'WITHWRAPPER)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
-- --------------------------------------------------------------------------
-- ["Office","Mobile"]

/*
    La función QL/JSON json_table proyecta datos JSON específicos en columnas de varios tipos de datos SQL. Lo utiliza para asignar partes de un documento JSON a las filas y 
    columnas de una nueva tabla virtual, que también puede considerar como una vista en línea.

    Luego puede insertar esta tabla virtual en una tabla de base de datos preexistente o puede consultarla usando SQL (en una expresión de unión, por ejemplo).
    Un uso común de json_table es crear una vista de datos JSON. Puede utilizar dicha vista del mismo modo que utilizaría cualquier tabla o vista. Esto permite que las aplicaciones, 
    herramientas y programadores operen con datos JSON sin tener en cuenta la sintaxis de JSON o las expresiones de ruta JSON.
    
    Definir una vista sobre datos JSON asigna de hecho un tipo de esquema a esos datos. Este mapeo es posterior al hecho: los datos JSON subyacentes se pueden definir y crear sin tener en 
    cuenta un esquema o patrón de uso particular. Primero los datos, después el esquema.
    
    Dicho esquema (mapeo) no impone ninguna restricción sobre el tipo de documentos JSON que se pueden almacenar en la base de datos (aparte de ser datos JSON bien formados). 
    La vista expone sólo datos que se ajustan al mapeo (esquema) que define la vista. Para cambiar el esquema, simplemente redefina la vista; no es necesario reorganizar los datos 
    JSON subyacentes.

    Utiliza json_table en una cláusula FROM de SQL. Es una fuente de fila: genera una fila de datos de tabla virtual para cada valor JSON seleccionado mediante una expresión de ruta de fila 
    (patrón de fila). El Las columnas de cada fila generada se definen mediante las expresiones de ruta de columna de la cláusula COLUMNAS.

    Normalmente, una invocación json_table se une lateralmente, implícitamente, con una tabla fuente en la lista FROM, cuyas filas contienen cada una un documento JSON que se utiliza 
    como entrada para la función.

    JSON_TABLE genera cero o más filas nuevas, según lo determinado al evaluar la expresión de ruta de fila con el documento de entrada.
    El primer argumento de json_table es una expresión SQL. Puede ser un valor de columna de tabla o vista, una variable PL/SQL o una variable de enlace con la conversión adecuada. 
    
    El resultado de evaluar la expresión se utiliza como elemento de contexto para evaluar la expresión de ruta de fila.

    El segundo argumento de json_table es la expresión de ruta de fila SQL/JSON seguida de una cláusula de error opcional para manejar la fila y la cláusula COLUMNS (obligatoria), que define
    las columnas de la tabla virtual que se va a crear. No existe una cláusula de RETURNING.
    
    Hay dos niveles de manejo de errores para json_table, correspondientes a los dos niveles de expresiones de ruta: fila y columna. Cuando está presente, un controlador de errores de 
    columna anula el nivel de fila manejo de errores. El controlador de errores predeterminado para ambos niveles es NULL ON ERROR.

    Como alternativa a pasar el argumento del elemento de contexto y la expresión de ruta de fila, puede utilizar una sintaxis simple de notación de puntos. 
    (Aún puedes usar una cláusula de error, y la cláusula COLUMNAS es  aún es necesario.) La notación de puntos especifica una tabla o columna de vista junto con una ruta simple a 
    los datos JSON de destino. Por ejemplo, estas dos consultas son equivalentes:
    
    json_table(t.j, '$.ShippingInstructions.Phone[*]' ...)
    json_table(tjShippingInstructions.Phone[*] ...)
    
    Y en los casos en los que la expresión de la ruta de la fila sea solo '$', que apunta a todo el documento, puede omitir la parte de la ruta. Estas consultas son equivalentes:
    
    json_table(tj, '$' ...)
    json_table(tj...)

    El ejemplo 20-1 ilustra la diferencia entre usar la notación de punto simple y usar la notación más completa y explícita.

    Ejemplo 20-1 Consultas JSON_TABLE equivalentes: sintaxis simple y completa
    Este ejemplo utiliza json_table para dos consultas equivalentes. La primera consulta utiliza la sintaxis simple de notación de puntos para las expresiones dirigidas a los datos 
    de filas y columnas.

    El segundo utiliza la sintaxis completa.

    A excepción de la columna Instrucciones especiales, cuyo identificador SQL está entre comillas, los nombres de las columnas SQL están, de hecho, en mayúsculas. (El identificador de instrucciones especiales contiene un carácter de espacio).
    En la primera consulta, los nombres de las columnas se escriben exactamente igual que los nombres de los campos del objeto de destino, incluso con respecto a las letras mayúsculas. Independientemente de si se citan, se interpretan distinguiendo entre mayúsculas y minúsculas a los efectos de establecer la
    ruta predeterminada (la ruta utilizada cuando no hay una cláusula PATH explícita).
    La segunda consulta tiene:
    • Argumentos separados de una expresión de columna JSON y una expresión de ruta de fila SQL/JSON
    • Tipos de datos de columna explícitos de VARCHAR2(4000)
    • Cláusulas PATH explícitas con expresiones de ruta de columna SQL/JSON, para apuntar a los campos de objeto que se proyectan

*/

SELECT jt.*
 FROM j_purchaseorder po,
      JSON_TABLE( po.po_document COLUMNS ("Special Instructions", NESTED LineItems[*]
                                    COLUMNS (
                                        ItemNumber NUMBER, 
                                        Description PATH Part.Description
                                    )
                                )
                ) AS "JT";

"Special Instructions"	"ITEMNUMBER"	"DESCRIPTION"
----------------------  ------------    ---------------------------------
""	                    1	            "One Magic Christmas"
""	                    2	            "Lethal Weapon"
"Courier"	            1	            "Making the Grade"
"Courier"	            2	            "Nixon"
"Courier"	            3	            "Eric Clapton: Best Of 1981-1999"
----------------------  ------------    ---------------------------------

SELECT jt.*
  FROM j_purchaseorder po,
       JSON_TABLE( po.po_document, '$'
       COLUMNS ( "Special Instructions" VARCHAR2(4000) PATH '$."Special Instructions"',
                 NESTED PATH '$.LineItems[*]'
                   COLUMNS ( ItemNumber NUMBER PATH '$.ItemNumber',
                             Description VARCHAR(4000) PATH '$.Part.Description'
                           )
               )
       ) AS "JT";

"Special Instructions"	"ITEMNUMBER"	"DESCRIPTION"
----------------------  ------------    ---------------------------------
""	                    1	            "One Magic Christmas"
""	                    2	            "Lethal Weapon"
"Courier"	            1	            "Making the Grade"
"Courier"	            2	            "Nixon"
"Courier"	            3	            "Eric Clapton: Best Of 1981-1999"
----------------------  ------------    ---------------------------------

/*
    En una cláusula SELECT, a menudo puede usar una cláusula NESTED en lugar de la función SQL/JSON json_table. Esto puede significar una expresión de consulta más simple. 
    También tiene la ventaja de incluir filas con columnas relacionales no NULL cuando la columna JSON es NULL.
    La cláusula NESTED es un atajo para usar json_table con una unión externa izquierda ANSI. Es decir, estas dos consultas son equivalentes:
*/

SELECT ... 
  FROM mytable NESTED jcol COLUMNS (...);

SELECT ...
  FROM mytable t1 
  LEFT OUTER JOIN json_table(t1.jcol COLUMNS (...) ON 1=1;

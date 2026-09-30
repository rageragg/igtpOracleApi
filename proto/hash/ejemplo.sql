DECLARE
    -- 1. Definimos la estructura del registro que queremos guardar en memoria
    TYPE t_registro_datos IS RECORD (
        monto_total    NUMBER,
        codigo_usuario VARCHAR2(30)
    );

    -- 2. Definimos el tipo de Arreglo/Colección indexado por el Hash (RAW o VARCHAR2)
    TYPE t_vector_hash IS TABLE OF t_registro_datos INDEX BY VARCHAR2(64);
    
    -- 3. Declaramos la variable de nuestro vector en memoria
    v_mi_vector t_vector_hash;
    
    -- Variables temporales para el ejemplo
    v_hash_llave  VARCHAR2(64);
    v_datos_nodo  t_registro_datos;
BEGIN
    
    -- SIMULACIÓN: Supongamos que procesamos una fila con Clave Primaria Compuesta:
    -- id_tienda = 101, id_factura = 55890, linea_articulo = 3
    
    -- A) Creamos el Hash Único usando SHA-256
    v_hash_llave := RAWTOHEX(
        STANDARD_HASH(101 || '|' || 55890 || '|' || 3, 'SHA256')
    );
    
    -- B) Asignamos los datos que acompañarán a esa clave en memoria
    v_datos_nodo.monto_total := 1550.75;
    v_datos_nodo.codigo_usuario := 'USR_PREMIUM';
    
    -- C) Guardamos la información en el vector usando el hash como índice directo
    v_mi_vector(v_hash_llave) := v_datos_nodo;
    
    
    -- --- CÓMO CONSULTAR EL VECTOR POSTERIORMENTE ---
    -- Si en otra parte del código necesitas verificar si esa combinación existe:
    IF v_mi_vector.EXISTS(v_hash_llave) THEN
        DBMS_OUTPUT.PUT_LINE('¡Clave encontrada en memoria!');
        DBMS_OUTPUT.PUT_LINE('Monto guardado: ' || v_mi_vector(v_hash_llave).monto_total);
    END IF;

END;
/

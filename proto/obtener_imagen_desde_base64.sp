CREATE OR REPLACE FUNCTION obtener_imagen_desde_base64 (
    p_id IN NUMBER
) RETURN BLOB
AS
    l_clob         CLOB;
    l_blob         BLOB;
    l_temp_blob    BLOB;
    l_buffer_vchar VARCHAR2(32760); -- Buffer para leer CLOB (múltiplo de 4 para Base64)
    l_buffer_raw   RAW(32760);      -- Buffer RAW para texto Base64
    l_decoded_raw  RAW(32767);      -- Buffer para RAW decodificado
    l_clob_offset  INTEGER := 1;
    l_clob_len     INTEGER;
    l_chunk_len    INTEGER := 24576; -- Tamaño de lectura del CLOB (múltiplo de 4, <= 32760)
BEGIN
    -- Obtener el CLOB de la tabla
    SELECT imagen_clob INTO l_clob
    FROM imagenes_en_texto_plsql
    WHERE id = p_id;

    IF l_clob IS NULL OR DBMS_LOB.GETLENGTH(l_clob) = 0 THEN
       RETURN NULL; -- O lanzar excepción si se prefiere
    END IF;

    l_clob_len := DBMS_LOB.GETLENGTH(l_clob);

    -- Crear un BLOB temporal para el resultado
    DBMS_LOB.CREATETEMPORARY(l_temp_blob, TRUE, DBMS_LOB.SESSION);

    -- Leer el CLOB en chunks, decodificar desde Base64 y añadir al BLOB temporal
    WHILE l_clob_offset <= l_clob_len LOOP
        -- Determinar cuánto leer
         IF l_clob_len - l_clob_offset + 1 < l_chunk_len THEN
             l_chunk_len := l_clob_len - l_clob_offset + 1;
        ELSE
             l_chunk_len := 24576; -- Reestablecer
        END IF;

        -- Leer chunk del CLOB
        DBMS_LOB.READ(l_clob, l_chunk_len, l_clob_offset, l_buffer_vchar);

        -- Convertir el VARCHAR2 a RAW
        l_buffer_raw := UTL_RAW.CAST_TO_RAW(l_buffer_vchar);

        -- Decodificar el chunk RAW desde Base64
        l_decoded_raw := UTL_ENCODE.BASE64_DECODE(l_buffer_raw);

        -- Añadir el RAW decodificado al BLOB temporal
        DBMS_LOB.WRITEAPPEND(l_temp_blob, UTL_RAW.LENGTH(l_decoded_raw), l_decoded_raw);

        -- Mover el offset
        l_clob_offset := l_clob_offset + l_chunk_len;
    END LOOP;

    -- Devolver el BLOB temporal (el llamador es responsable de su gestión si es necesario)
    -- O copiar a un BLOB permanente si la función lo requiere.
    -- Para este ejemplo, devolvemos el temporal.
    RETURN l_temp_blob;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- O lanzar excepción
    WHEN OTHERS THEN
        -- Asegurarse de liberar el LOB temporal en caso de error
        IF DBMS_LOB.ISTEMPORARY(l_temp_blob) = 1 THEN
            DBMS_LOB.FREETEMPORARY(l_temp_blob);
        END IF;
        RAISE; -- Relanzar la excepción
END;

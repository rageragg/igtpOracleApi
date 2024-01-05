DECLARE
    --
    input_string    VARCHAR2 (200) := 'id=2523521'||chr(38)||'tip=DL'; -- 'https://clientes/mapfre.com.uy/pagos/?id=2523521'||chr(38)||'tip=DL';
    output_string   VARCHAR2 (200);
    encrypted_raw   RAW (64);         -- stores encrypted binary text
    decrypted_raw   RAW (64);         -- stores decrypted binary text
    num_key_bytes   NUMBER := 8;    -- key length 64 bits (32 bytes)
    key_bytes_raw   RAW (8);           -- stores 128-bit encryption key
    iv_raw          RAW (8);
    --
    encryption_type PLS_INTEGER := -- total encryption type
                                DBMS_CRYPTO.ENCRYPT_DES
                                + DBMS_CRYPTO.CHAIN_CBC
                                + DBMS_CRYPTO.PAD_PKCS5
                                ;
    --
BEGIN
    --
    DELETE x_eliminar;
    --
    DBMS_OUTPUT.PUT_LINE ( 
        'Original string: ' || input_string
    );
    --
    key_bytes_raw   := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
    iv_raw          := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);

    encrypted_raw   := DBMS_CRYPTO.ENCRYPT(
        src     => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
        typ     => encryption_type,
        key     => key_bytes_raw,
        iv      => iv_raw
    );
    --
    INSERT INTO x_eliminar( id, content, key ) values( 1, encrypted_raw, key_bytes_raw );
    --
    output_string := UTL_I18N.RAW_TO_CHAR (encrypted_raw, 'AL32UTF8');
    --
    DBMS_OUTPUT.PUT_LINE (
        'Encripted string: ' || output_string || chr(13) ||
        encrypted_raw || chr(13) ||
        UTL_I18N.STRING_TO_RAW (output_string, 'AL32UTF8')
    );
    --
    -- The encrypted value "encrypted_raw" can be used here
    decrypted_raw := DBMS_CRYPTO.DECRYPT(
        src     => encrypted_raw,
        typ     => encryption_type,
        key     => key_bytes_raw,
        iv      => iv_raw
    );
    --
    output_string := 'https://clientes/mapfre.com.uy/pagos/?'||UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
    --
    DBMS_OUTPUT.PUT_LINE (
        'Decrypted string: ' || output_string
    );
    --
END;
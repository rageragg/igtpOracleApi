DECLARE
    --
    input_string    VARCHAR2 (200) := 'Secret Message';
    output_string   VARCHAR2 (200);
    encrypted_raw   RAW (2000); -- stores encrypted binary text
    decrypted_raw   RAW (2000); -- stores decrypted binary text
    num_key_bytes   NUMBER := 256/8; -- key length 256 bits (32 bytes)
    key_bytes_raw   RAW (32); -- stores 256-bit encryption key
    /*
    encryption_type PLS_INTEGER := -- total encryption type
                                DBMS_CRYPTO.ENCRYPT_AES256
                                + DBMS_CRYPTO.CHAIN_CBC
                                + DBMS_CRYPTO.PAD_PKCS5;
    */
    encryption_type PLS_INTEGER := DBMS_CRYPTO.HASH_MD5;
    iv_raw RAW (16);
    --
BEGIN
    --
    DBMS_OUTPUT.PUT_LINE ( 
        'Original string: ' || input_string
    );
    --
    key_bytes_raw   := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
    iv_raw          := DBMS_CRYPTO.RANDOMBYTES (16);
    encrypted_raw   := DBMS_CRYPTO.ENCRYPT(
        src => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),
        typ => encryption_type,
        key => key_bytes_raw,
        iv => iv_raw
    );
    -- The encrypted value "encrypted_raw" can be used here
    decrypted_raw := DBMS_CRYPTO.DECRYPT(
        src => encrypted_raw,
        typ => encryption_type,
        key => key_bytes_raw,
        iv => iv_raw
    );
    --
    output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
    --
    DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);
    --
END;
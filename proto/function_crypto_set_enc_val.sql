
/*
|| Encriptar
*/
CREATE OR REPLACE FUNCTION set_enc_val(
        p_in    IN VARCHAR2,
        p_key   IN RAW
    ) RETURN RAW IS
    --
    l_enc_val       RAW(2000);
    l_mod           NUMBER := dbms_crypto.ENCRYPT_AES128 + 
                              dbms_crypto.CHAIN_CBC +
                              dbms_crypto.PAD_PKCS5;
BEGIN
    --
    l_enc_val := dbms_crypto.encrypt(
                    utl_i18n.string_to_raw(p_in, 'AL32UTF8'),
                    l_mod,
                    p_key
            );
    --        
    RETURN l_enc_val;
    --
 END get_enc_val;

 
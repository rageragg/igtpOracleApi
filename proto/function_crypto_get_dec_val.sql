
/*
|| Encriptar
*/

CREATE OR REPLACE FUNCTION get_dec_val(
        p_in    IN RAW,
        p_key   in raw
    ) RETURN VARCHAR2 IS
    --
    l_ret       VARCHAR2 (2000);
    l_dec_val   RAW (2000);
    l_mod       NUMBER := dbms_crypto.ENCRYPT_AES128 + 
                          dbms_crypto.CHAIN_CBC + 
                          dbms_crypto.PAD_PKCS5;
    --                    
BEGIN
    --
    l_dec_val := dbms_crypto.decrypt(
                    p_in,
                    l_mod,
                    p_key
                );
    --
    l_ret:= utl_i18n.raw_to_char(l_dec_val, 'AL32UTF8');
    --
    RETURN l_ret;
    --
END get_dec_val;
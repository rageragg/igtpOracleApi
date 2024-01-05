declare

   txt varchar2(100) := 'https://clientes/mapfre.com.uy/pagos/?id=2523521'||chr(38)||'tip=DL';
   md5 raw(16); -- MD5 is 128 = 16 * 8 bits

begin

   md5 := dbms_crypto.hash(
            utl_i18n.string_to_raw(txt, 'AL32UTF8'),
            dbms_crypto.hash_md5
          );

   dbms_output.put_line('MD5 is: ' || md5);

end;
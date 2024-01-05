declare
    --
	g_cod_cia       	NUMBER(2) 	:= 1;
	g_order_id 			VARCHAR2(80);
	g_generador_clave	NUMBER 		:= 256/8;
	g_clave_raw   		RAW (32);
	g_iv_raw          	RAW (16);
	g_tipo_encriptacion PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256
									+ DBMS_CRYPTO.CHAIN_CBC
									+ DBMS_CRYPTO.PAD_PKCS5;	
    --
    l_token  	        VARCHAR2(128);
    --
    PROCEDURE p_encriptar( 
		p_order_id 	IN  VARCHAR2,
		p_entrada 	IN  VARCHAR2,
		p_dias_vig  IN  NUMBER,
		p_token  	OUT VARCHAR2
	) IS 
		--
		l_token_generado	RAW (1024);
		l_salida_row        RAW (1024); 
		l_dias_vig  		NUMBER(02) := p_dias_vig;
		--
	BEGIN 
		--
		g_order_id  := p_order_id;
		g_clave_raw	:= DBMS_CRYPTO.RANDOMBYTES (g_generador_clave);
		g_iv_raw	:= DBMS_CRYPTO.RANDOMBYTES (16);
		--
		-- generamos el token
		l_token_generado := DBMS_CRYPTO.ENCRYPT(
			src     => UTL_I18N.STRING_TO_RAW (p_entrada, 'AL32UTF8'),
			typ     => g_tipo_encriptacion,
			key     => g_clave_raw,
			iv      => g_iv_raw
		);
		--
		-- devolvemos el token
		p_token := substr( ' '|| l_token_generado, 2 );
		--
		-- registramos el token
		BEGIN 
			--
			IF l_dias_vig > 10 THEN 
				l_dias_vig := 10;
			END IF;
			--
			EXCEPTION 
				WHEN OTHERS THEN 
					p_token := NULL;
		END;
		--
	END p_encriptar;
    --
begin
    --
    null;
    --
end;
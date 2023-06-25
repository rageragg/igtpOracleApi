DECLARE 
    --
    /**
        PROPOSITO: Simular la inclusion de una tiendas
    */
    -- locales
    l_reg_location locations%ROWTYPE    := NULL;
    l_reg_shops    shops%ROWTYPE        := NULL;
    --
BEGIN 
    --
    -- TODO: validaciones de que exista la localidad
    l_reg_location.location_co := 'BQTO-OES';
    l_reg_location := cfg_api_k_location.get_record( p_location_co => l_reg_location.location_co );
    --
    -- TODO: validaciones de codigo no se repita
    l_reg_shops.shop_co         := '02-601';
    l_reg_shops.description     := 'BODEGON EL GRAN YO SOY 2019 C.A';
    l_reg_shops.location_id     := l_reg_location.id;
    l_reg_shops.address         := 'CALLE 3 ENTRE VEREDA 18 Y 19 CASA NRO 18-45 BARRIO CERRITO BLANCO BARQUISIMETO ESTADO LARA';
    --
    l_reg_shops.nu_gps_lat	        := 0;
    l_reg_shops.nu_gps_lon	        := 0;
    l_reg_shops.telephone_co	    := 'XX';
    l_reg_shops.fax_co	            := NULL;
    -- TODO: validaciones de formato de email
    l_reg_shops.email	            := 'email@email.com';
    l_reg_shops.name_contact	    := 'FRANCISCO CARO';
    l_reg_shops.email_contact	    := 'email@email.com';
    -- TODO: validaciones de formato de formato telefonico
    l_reg_shops.telephone_contact	:= '(999)9999999';
    --
    l_reg_shops.uuid         := sys_k_utils.f_uuid();
    l_reg_shops.slug         := 'shop-'||l_reg_shops.shop_co;
    l_reg_shops.user_id      := 1;
    --
    dbms_output.put_line('Locacion    : ' || l_reg_location.description );
    dbms_output.put_line('Postal      : ' || l_reg_location.postal_co );
    dbms_output.put_line('Codigo      : ' || l_reg_shops.shop_co  );
    dbms_output.put_line('Descripcion : ' || l_reg_shops.description  );
    --
    dsc_api_k_shop.ins( p_rec => l_reg_shops );
    --
    dbms_output.put_line('ID          : ' || l_reg_shops.id  );
    --
    COMMIT;
    --
    dbms_output.put_line( 'Registro Exitoso' );
    --
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            dbms_output.put_line('NOT_DATA_FOUND');
            ROLLBACK;
        WHEN OTHERS THEN 
            dbms_output.put_line(sqlerrm);    
            ROLLBACK;
END;
# PROTOCOLO DE CREACION DE CLIENTES

## DECLARACION DE CLIENTE
### TAREAS
1. Establecer codigo del cliente para identificacion interna.
2. Identificador de Localidad.
3. Determinar su tipo de cliente, entre Fabrica, Distribuidora y/o Mercado.
4. Identificacion fiscal.
5. Categoria de cliente, entre A,B y C.
6. Sector a que pertenece el cliente (ALIMENTOS, QUIMICOS...)

## CONFIGURACION DE SUBSIDIARIAS
1. CREAR TIENDAS
    1. Determinar su localidad.
    2. Establecer codigo de la tienda para identificacion interna.
    3. Identificacion fiscal de la tienda.
2. Asociar las tiendas a los clientes como subsidiarias y determinar su codigo interno.

## CONFIGURACION DE FLETES O CONTRATOS
1. Determinar el tipo de carga que el cliente puede transladar.
2. Determinar el tipo de vehiculo que el cliente puede emplear.
3. Determinar la ruta que se emplea.
4. Determinar el regimen de negocio y logistica.
5. Determinar el proceso antes de establecer la cobfiguracion de fletes.
6. Determinar el proceso luego de establecer la cobfiguracion de fletes.

## DATOS DEL DOCUMENTO (Ejemplo)
1. CODIGO DE CLIENTE             : MKR 
2. DESCRIPCION DEL CLIENTE       : MAKRO DE VENEZUELA
3. TIPO DE CLIENTE               : DISTRIBUTION ( FACTORY, DSITRIBUTION, MARKET )
4. CATEGORIA DE CLIENTE          : A ( A, B, C )
5. SECTOR DE MERCADO             : FOODS ( ALIMENTOS, BEBIDAS, LINEA BLANCA, CONSTRUCCION, QUIMICO, PETROLERO )
6. CODIGO DE LA LOCALIDAD FISICA : CCS-01
7. DIRECCION FISICA              : CARACAS LA URBINA
8. TELEFONO EMPRESARIAL          : 0212-0000000
9. CORREO ELECTRONICO            : makro.ccs.logistica@makro.com
    
    ### CONTACTO EMPRESARIAL
    1. NOMBRE DE CONTACTO        : RONALD GUERRA
    2. TELEFONO DE CONTACTO      : 0424-0000000
    3. CORREO ELECTRONICO CONTAC.: ronaldg.css.logistica@makro.com
    
    ### SUBSIDIARIAS (OPCIONAL)
    **CODIGO SUBSIDIARIA  CODIGO TIENDA   DESCRIPCION DE TIENDA   DIRECCION**
    -----------------------------------------------------------------------------------------------------------------
    1.  MKR-S-01            SHOP-123        MAKRO LA URBINA         LA URBINA CARACAS
    2.  MKR-S-02            SHOP-231        MAKRO LA YAGUARA        LA YAGUARA CARACAS

    ### CONFIGURACION DE FLETES O CONTRATOS
    **CODIGO RUTA     TIPO CARGA      TIPO VEHICULO       TIPO DE FLETE   REGIMEN DE CARGA**
    -----------------------------------------------------------------------------------------------------------------
    1.  CCS-BQTO        CRF             T3E                 PTP             FLETE
    2.  CCS-BQTO        CSE             T2E                 PTP             FLETE             

--------------------------------------------------------
--  DDL for Package Body CUSTOMER_API
--  PROCESS
--------------------------------------------------------

/*
	"ID" 					NUMBER(8,0) DEFAULT IGTP.CUSTOMERS_SEQ.NEXTVAL, 
	"CUSTOMER_CO" 			VARCHAR2(10 BYTE), 
	"DESCRIPTION" 			VARCHAR2(80 BYTE), 
	"K_TYPE_CUSTOMER" 		CHAR(1 BYTE) DEFAULT 'F', 
	"LOCATION_ID" 			NUMBER(8,0), 
	"ADDRESS" 				VARCHAR2(250 BYTE), 
	"TELEPHONE_CO" 			VARCHAR2(50 BYTE), 
	"FAX_CO" 				VARCHAR2(50 BYTE), 
	"EMAIL" 				VARCHAR2(60 BYTE), 
	"FISCAL_DOCUMENT_CO" 	VARCHAR2(20 BYTE), 
	"K_CATEGORY_CO" 		CHAR(1 BYTE) DEFAULT 'C', 
	"K_SECTOR" 				VARCHAR2(30 BYTE), 
	"NAME_CONTACT" 			VARCHAR2(20 BYTE), 
	"TELEPHONE_CONTACT" 	VARCHAR2(20 BYTE), 
	"EMAIL_CONTACT" 		VARCHAR2(60 BYTE), 
	"SLUG" 					VARCHAR2(60 BYTE), 
	"UUID" 					VARCHAR2(60 BYTE), 
	"K_MCA_INH"				CHAR(01) DEFAULT 'N',
	"USER_ID" 				NUMBER(8,0), 
	"CREATED_AT" 			DATE DEFAULT sysdate, 
	"UPDATED_AT" 			DATE DEFAULT sysdate
*/

CREATE OR REPLACE PACKAGE BODY prs_api_k_customer IS
    --
    -- GLOBALES
    g_rec_customer      customer_api_doc;
    g_rec_locations     igtp.locations%ROWTYPE;
     --
    -- TODO: crear el manejo de errores para transferirlo al nivel superior
    --
    -- VALIDATE type customer
    FUNCTION validate_type_customer RETURN BOOLEAN IS 
    BEGIN
        --
        -- se verifica que el tipo de cliente este dentro de los siguientes valores
        RETURN g_rec_customer.k_type_customer IN (
            K_TYPE_CUSTOMER_FACTORY,
            K_TYPE_CUSTOMER_DISTRIBUTOR,
            K_TYPE_CUSTOMER_MARKET
        );
        --
    END validate_type_customer;
    --
    -- VALIDATE type customer
    FUNCTION validate_location RETURN BOOLEAN IS 
    BEGIN
        --
        -- Se toma el registro de location por codigo
        g_rec_locations := igtp.cfg_api_k_location.get_record(
                                    p_location_co => g_rec_customer.location_co
                                );

        RETURN g_rec_locations IS NOT NULL;
        --
    END validate_location;
    --
    -- VALIDATE email
    FUNCTION validate_email RETURN BOOLEAN IS 
    BEGIN
        --
        -- Se valida el email
        RETURN validate_email( g_rec_customer.email );
        --
    END validate_location;
    --
    -- CREATE CUSTOMER BY DOCUMENT
    FUNCTION create( p_rec IN OUT customer_api_doc ) RETURN BOOLEAN IS
        --
        -- 
    BEGIN 
        --
        -- se establece el valor a la global 
        g_rec_customer := p_rec;
        --
        -- valida tipo de cliente 
        IF validate_type_customer THEN 
            -- TODO: completar
            NULL;
        END IF;
        --
        -- validamos el codigo de la localidad del cliente
        IF validate_location THEN 
            -- TODO: completar
            NULL;
        END IF;
        --
        -- TODO: Completar
        RETURN TRUE;
        --
    END create;
    --
END prs_api_k_customer;

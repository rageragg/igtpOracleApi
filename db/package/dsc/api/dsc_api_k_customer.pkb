
CREATE OR REPLACE PACKAGE BODY dsc_api_k_customer IS
    --------------------------------------------------------
    --  DDL for Package Body CUSTOMER_API
    --------------------------------------------------------
    --
    g_record        customers%ROWTYPE;
    --
    -- get DATA 
    FUNCTION get_record RETURN customers%ROWTYPE IS
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;     
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id in customers.id%TYPE ) RETURN customers%ROWTYPE IS
        --
        l_data customers%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.customers WHERE id = p_id;
        -- 
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_data;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_record;    
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_customer_co IN customers.customer_co%TYPE ) RETURN customers%ROWTYPE IS 
            --
        l_data customers%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.customers WHERE customer_co = p_customer_co;
        -- 
    BEGIN 
        --
        OPEN c_data;
        FETCH c_data INTO l_data;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_record;           
    --
    -- get DATA Array
    FUNCTION get_list RETURN customer_api_tab IS
        --
        l_data customer_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.customers ORDER BY K_ORDER_LIST;
        -- 
    BEGIN 
        --
        OPEN c_data;
        LOOP
            FETCH c_data BULK COLLECT INTO l_data LIMIT K_LIMIT_LIST;   
            EXIT WHEN c_data%NOTFOUND;
        END LOOP;
        CLOSE c_data;
        --
        RETURN l_data;
        --
    END get_list;    
    --
    -- create incremental id
    FUNCTION inc_id RETURN NUMBER IS 
        --
        mx  NUMBER(8);
        --
    BEGIN
        --
        SELECT max(id)
          INTO mx
          FROM igtp.customers;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;
    --
    -- insert
    PROCEDURE ins (
        p_id                    IN customers.id%TYPE,
        p_customer_co           IN customers.customer_co%TYPE DEFAULT NULL,
        p_description           IN customers.description%TYPE DEFAULT NULL,
        p_telephone_co          IN customers.telephone_co%TYPE DEFAULT NULL,
        p_fax_co                IN customers.fax_co%TYPE DEFAULT NULL,
        p_email                 IN customers.email%TYPE DEFAULT NULL,
        p_address               IN customers.address%TYPE DEFAULT NULL,
        p_k_type_customer       IN customers.k_type_customer%TYPE DEFAULT NULL,
        p_k_sector              IN customers.k_sector%TYPE DEFAULT NULL,
        p_k_category_co         IN customers.k_category_co%TYPE DEFAULT NULL,
        p_fiscal_document_co    IN customers.fiscal_document_co%TYPE DEFAULT NULL,
        p_location_id           IN customers.location_id%TYPE DEFAULT NULL,
        p_telephone_contact     IN customers.telephone_contact%TYPE DEFAULT NULL,
        p_name_contact          IN customers.name_contact%TYPE DEFAULT NULL,
        p_email_contact         IN customers.email_contact%TYPE DEFAULT NULL,
        p_uuid                  IN customers.uuid%TYPE DEFAULT NULL,
        p_slug                  IN customers.slug%TYPE DEFAULT NULL,
        p_user_id               IN customers.user_id%TYPE DEFAULT NULL,
        p_created_at            IN customers.created_at%TYPE DEFAULT NULL,
        p_updated_at            IN customers.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        INSERT INTO customers(
            id                 ,
            customer_co        ,
            description        ,
            telephone_co       ,
            fax_co             ,
            email              ,
            address            ,
            k_type_customer    ,
            k_sector           ,
            k_category_co      ,
            fiscal_document_co ,
            location_id        ,
            telephone_contact  ,
            name_contact       ,
            email_contact      ,
            uuid               ,
            slug               ,
            user_id            ,
            created_at         ,
            updated_at         
        ) VALUES (
            p_id                 ,
            p_customer_co        ,
            p_description        ,
            p_telephone_co       ,
            p_fax_co             ,
            p_email              ,
            p_address            ,
            p_k_type_customer    ,
            p_k_sector           ,
            p_k_category_co      ,
            p_fiscal_document_co ,
            p_location_id        ,
            p_telephone_contact  ,
            p_name_contact       ,
            p_email_contact      ,
            p_uuid               ,
            p_slug               ,
            p_user_id            ,
            p_created_at         ,
            p_updated_at 
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins( p_rec IN OUT customers%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.updated_at    := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_k_utils.f_uuid();
        END IF;  
        --
        INSERT INTO igtp.customers VALUES p_rec;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                    IN customers.id%TYPE,
        p_customer_co           IN customers.customer_co%TYPE DEFAULT NULL,
        p_description           IN customers.description%TYPE DEFAULT NULL,
        p_telephone_co          IN customers.telephone_co%TYPE DEFAULT NULL,
        p_fax_co                IN customers.fax_co%TYPE DEFAULT NULL,
        p_email                 IN customers.email%TYPE DEFAULT NULL,
        p_address               IN customers.address%TYPE DEFAULT NULL,
        p_k_type_customer       IN customers.k_type_customer%TYPE DEFAULT NULL,
        p_k_sector              IN customers.k_sector%TYPE DEFAULT NULL,
        p_k_category_co         IN customers.k_category_co%TYPE DEFAULT NULL,
        p_fiscal_document_co    IN customers.fiscal_document_co%TYPE DEFAULT NULL,
        p_location_id           IN customers.location_id%TYPE DEFAULT NULL,
        p_telephone_contact     IN customers.telephone_contact%TYPE DEFAULT NULL,
        p_name_contact          IN customers.name_contact%TYPE DEFAULT NULL,
        p_email_contact         IN customers.email_contact%TYPE DEFAULT NULL,
        p_uuid                  IN customers.uuid%TYPE DEFAULT NULL,
        p_slug                  IN customers.slug%TYPE DEFAULT NULL,
        p_user_id               IN customers.user_id%TYPE DEFAULT NULL,
        p_created_at            IN customers.created_at%TYPE DEFAULT NULL,
        p_updated_at            IN customers.updated_at%TYPE DEFAULT NULL
    ) IS
    BEGIN
        --
        UPDATE CUSTOMERS 
        SET telephone_co = p_telephone_co
            ,name_contact = p_name_contact
            ,created_at = p_created_at
            ,k_type_customer = p_k_type_customer
            ,user_id = p_user_id
            ,email = p_email
            ,k_sector = p_k_sector
            ,slug = p_slug
            ,k_category_co = p_k_category_co
            ,description = p_description
            ,address = p_address
            ,email_contact = p_email_contact
            ,customer_co = p_customer_co
            ,location_id = p_location_id
            ,fiscal_document_co = p_fiscal_document_co
            ,updated_at = p_updated_at
            ,uuid = p_uuid
            ,telephone_contact = p_telephone_contact
            ,fax_co = p_fax_co
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT customers%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.customers 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id IN customers.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM customers
              WHERE id = p_id;
        --      
    END del;
    --
    -- TODO: desarrollar las funciones que evaluan la existencia
    -- exist customer by id
    FUNCTION exist( p_id IN customers.id%TYPE ) RETURN BOOLEAN IS
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist customer by code
    FUNCTION exist( p_customer_co IN customers.customer_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_customer_co => p_customer_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
END dsc_api_k_customer;
/

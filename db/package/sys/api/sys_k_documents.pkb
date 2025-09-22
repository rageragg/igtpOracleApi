CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY igtp.sys_k_documents IS
    --
    /*
        Purpose:      Package contains description documents 
        Remarks:      
        
        Who     Date        Description
        ------  ----------  --------------------------------
        RAGE    01.01.2021  Created
    */
    --
    g_record        documents%ROWTYPE;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN documents%ROWTYPE IS 
    BEGIN 
        --
        RETURN g_record;
        --
    END get_record;
    --
    -- get DATA RECORD BY ID
    FUNCTION get_record( p_id in documents.id%TYPE )  RETURN documents%ROWTYPE IS 
        --
        l_data documents%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.documents WHERE id = p_id;
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
    -- get DATA RECORD BY CO
    FUNCTION get_record( p_document_co IN documents.document_co%TYPE ) RETURN documents%ROWTYPE IS 
        --
        l_data documents%ROWTYPE;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.documents WHERE document_co = p_document_co;
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
    -- get DATA RETURN Array
    FUNCTION get_list RETURN documents_api_tab IS 
        --
        l_data documents_api_tab;
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.documents ORDER BY K_ORDER_LIST;
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
          FROM igtp.documents;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;    
    --
    -- insert
    PROCEDURE ins (
            p_id                IN documents.id%TYPE,
            p_document_co       IN documents.document_co%TYPE DEFAULT NULL,
            p_k_type_document   IN documents.k_type_document%TYPE DEFAULT NULL,
            p_k_format          IN documents.k_format%TYPE DEFAULT NULL,
            p_description       IN documents.description%TYPE DEFAULT NULL,
            p_cdata             IN documents.cdata%TYPE DEFAULT NULL,
            p_user_id           IN documents.user_id%TYPE DEFAULT NULL,
            p_created_at        IN documents.created_at%TYPE DEFAULT NULL,
            p_updated_at        IN documents.updated_at%TYPE DEFAULT NULL 
        ) IS
        --
    BEGIN
        --
        IF p_id IS NULL THEN 
            p_id := inc_id;
        END IF;
        --
        IF p_created_at IS NULL THEN 
            p_created_at := sysdate;
        END IF;
        --
        IF p_updated_at IS NULL THEN 
            p_updated_at := sysdate;
        END IF;
        --
        INSERT INTO igtp.documents(
            id,
            document_co,
            k_type_document,
            k_format,
            description ,
            cdata,
            user_id,
            created_at,
            updated_at        
        ) VALUES (
            p_id,
            p_document_co,
            p_k_type_document,
            p_k_format,
            p_description,
            p_cdata,
            p_user_id,
            p_created_at,
            p_updated_at       
        );
        --
    END ins;
    --
    -- insert
    PROCEDURE ins (
            p_id                IN documents.id%TYPE,
            p_document_co       IN documents.document_co%TYPE DEFAULT NULL,
            p_k_type_document   IN documents.k_type_document%TYPE DEFAULT NULL,
            p_k_format          IN documents.k_format%TYPE DEFAULT NULL,
            p_description       IN documents.description%TYPE DEFAULT NULL,
            p_bdata             IN documents.bdata%TYPE DEFAULT NULL,
            p_user_id           IN documents.user_id%TYPE DEFAULT NULL,
            p_created_at        IN documents.created_at%TYPE DEFAULT NULL,
            p_updated_at        IN documents.updated_at%TYPE DEFAULT NULL 
        ) IS
        --
    BEGIN
        --
        IF p_id IS NULL THEN 
            p_id := inc_id;
        END IF;
        --
        IF p_created_at IS NULL THEN 
            p_created_at := sysdate;
        END IF;
        --
        IF p_updated_at IS NULL THEN 
            p_updated_at := sysdate;
        END IF;
        --
        INSERT INTO igtp.documents(
            id,
            document_co,
            k_type_document,
            k_format,
            description ,
            bdata,
            user_id,
            created_at,
            updated_at        
        ) VALUES (
            p_id,
            p_document_co,
            p_k_type_document,
            p_k_format,
            p_description,
            p_bdata,
            p_user_id,
            p_created_at,
            p_updated_at       
        );
        --
    END ins;
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT documents%ROWTYPE ) IS
    BEGIN
        --
        IF p_rec.created_at IS NULL THEN 
            p_rec.created_at := sysdate;
        END IF;
        --
        IF p_rec.updated_at IS NULL THEN 
            p_rec.updated_at := sysdate;
        END IF;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.documents 
             VALUES p_rec
           RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;         
    --
    -- update
    PROCEDURE upd (
            p_id                IN documents.ID%TYPE,
            p_document_co           IN documents.document_co%TYPE DEFAULT NULL, 
            p_description       IN documents.description%TYPE DEFAULT NULL,
            p_telephone_co      IN documents.telephone_co%TYPE DEFAULT NULL, 
            p_postal_co         IN documents.postal_co%TYPE DEFAULT NULL, 
            p_municipality_id   IN documents.municipality_id%TYPE DEFAULT NULL,
            p_population        IN documents.population%TYPE DEFAULT NULL,
            p_uuid              IN OUT documents.uuid%TYPE,
            p_slug              IN documents.slug%TYPE DEFAULT NULL,
            p_user_id           IN documents.user_id%TYPE DEFAULT NULL,
            p_created_at        IN OUT documents.created_at%TYPE, 
            p_updated_at        IN OUT documents.updated_at%TYPE
        ) IS
    BEGIN
        --
        IF p_uuid IS NULL THEN 
            p_uuid := sys_k_utils.f_uuid();
        END IF;   
        --
        IF p_created_at IS NULL THEN 
            p_created_at := sysdate;
        END IF;
        --
        IF p_updated_at IS NULL THEN 
            p_updated_at := sysdate;
        END IF;        
        --
        UPDATE igtp.documents 
        SET document_co     = p_document_co,
            description     = p_description,
            telephone_co    = p_telephone_co,
            postal_co       = p_postal_co,
            municipality_id = p_municipality_id,
            population      = p_population,
            uuid            = p_uuid,
            slug            = p_slug,
            user_id         = p_user_id,
            created_at      = p_created_at,
            updated_at      = p_updated_at
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT documents%ROWTYPE ) IS
    BEGIN 
        --
        IF p_rec.uuid IS NULL THEN 
            p_rec.uuid := sys_k_utils.f_uuid();
        END IF;   
        --
        p_rec.updated_at        := sysdate;
        --
        UPDATE igtp.documents 
           SET ROW = p_rec
         WHERE id = p_rec.id
         RETURNING updated_at INTO p_rec.updated_at;
        --
    END upd;       
    --
    -- del
    PROCEDURE del ( p_id in documents.id%TYPE ) IS
    BEGIN
        --
        DELETE FROM igtp.documents 
            WHERE id = p_id;
        --
    END del;
    --
    -- exist
    FUNCTION exist( p_id IN documents.id%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_id => p_id );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
    -- exist
    FUNCTION exist( p_document_co IN documents.document_co%TYPE ) RETURN BOOLEAN IS 
    BEGIN 
        --
        g_record := get_record( p_document_co => p_document_co );
        --
        RETURN g_record.id IS NOT NULL;
        --
    END exist;
    --
END sys_k_documents;
/

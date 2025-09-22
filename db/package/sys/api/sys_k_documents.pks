CREATE OR REPLACE PACKAGE sys_k_documents IS
    --
    /*
        Purpose:      Package contains description documents 
        Remarks:      
        
        Who     Date        Description
        ------  ----------  --------------------------------
        RAGE    01.01.2021  Created
    */
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'DOCUMENTS';
    --
    TYPE documents_api_tab IS TABLE OF igtp.documents%ROWTYPE INDEX BY PLS_INTEGER;
    --
    -- get DATA RETURN RECORD by PRELOAD with function exist
    FUNCTION get_record RETURN igtp.documents%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( 
        p_id IN igtp.documents.id%TYPE 
    ) RETURN igtp.documents%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( 
        p_document_co       IN documents.document_co%TYPE
    ) RETURN igtp.documents%ROWTYPE;
    --
    -- insert proccess
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
    );
    --
    -- insert proccess
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
    );
    --
    -- insert docuements
    PROCEDURE ins (
        p_rec   IN OUT igtp.documents%ROWTYPE 
    );
    --
    -- update docuements
    PROCEDURE upd (
        p_id                IN documents.id%TYPE,
        p_document_co       IN documents.document_co%TYPE DEFAULT NULL,
        p_k_type_document   IN documents.k_type_document%TYPE DEFAULT NULL,
        p_k_format          IN documents.k_format%TYPE DEFAULT NULL,
        p_description       IN documents.description%TYPE DEFAULT NULL,
        p_cdata             IN documents.cdata%TYPE DEFAULT NULL,
        p_user_id           IN documents.user_id%TYPE DEFAULT NULL,
        p_created_at        IN documents.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN documents.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- update docuements
    PROCEDURE upd (
        p_id                IN documents.id%TYPE,
        p_document_co       IN documents.document_co%TYPE DEFAULT NULL,
        p_k_type_document   IN documents.k_type_document%TYPE DEFAULT NULL,
        p_k_format          IN documents.k_format%TYPE DEFAULT NULL,
        p_description       IN documents.description%TYPE DEFAULT NULL,
        p_bdata             IN documents.bdata%TYPE DEFAULT NULL,
        p_user_id           IN documents.user_id%TYPE DEFAULT NULL,
        p_created_at        IN documents.created_at%TYPE DEFAULT NULL,
        p_updated_at        IN documents.updated_at%TYPE DEFAULT NULL 
    );
    --
    -- insert docuements
    PROCEDURE upd (
        p_rec   IN OUT igtp.documents%ROWTYPE 
    );
    --
    -- delete
    PROCEDURE del (
        p_id IN documents.id%TYPE
    );
    --
    -- exist
    FUNCTION exist( p_id IN documents.id%TYPE ) RETURN BOOLEAN;
    --
    -- exist
    FUNCTION exist( 
        p_document_co       IN documents.document_co%TYPE
    ) RETURN BOOLEAN;
    --
END sys_k_documents;
/
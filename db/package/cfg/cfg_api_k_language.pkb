CREATE OR REPLACE PACKAGE BODY cfg_api_k_language IS
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN igtp.languages.id%TYPE ) RETURN igtp.languages%ROWTYPE IS 
        --
        l_rec languages%ROWTYPE;
        --
    BEGIN 
        --
        SELECT *
          INTO l_rec
          FROM igtp.languages 
         WHERE id = p_id;
        --
        RETURN l_rec;
        --
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                RETURN NULL;  
        --
    END get_record;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_language_co IN languages.language_co%TYPE ) RETURN languages%ROWTYPE IS 
            --
        l_data languages%ROWTYPE;
        --
        --
        CURSOR c_data IS 
            SELECT * FROM igtp.languages WHERE language_co = p_language_co;
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
    -- create incremental id
    FUNCTION inc_id RETURN NUMBER IS 
        --
        mx  NUMBER(8);
        --
    BEGIN
        --
        SELECT max(id)
          INTO mx
          FROM igtp.languages;
        --
        mx := nvl(mx,0) + 1;
        --
        RETURN mx;  
        --
    END inc_id;    
    --
    -- insert
    PROCEDURE ins (
        p_id              languages.id%TYPE,
        p_language_co     languages.language_co%TYPE,
        p_description     languages.description%TYPE,
        p_diccionary      languages.diccionary%TYPE,
        p_updated_at      languages.updated_at%TYPE,
        p_created_at      languages.created_at%TYPE
    ) IS
    BEGIN
        --
        INSERT INTO languages(
            id,
            language_co,
            description,
            diccionary,
            created_at,
            updated_at
        ) 
        VALUES (
            p_id,
            p_language_co,
            p_description,
            p_diccionary,
            p_created_at,
            p_updated_at
        );
        --
    END ins;
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT igtp.languages%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        IF p_rec.id IS NULL THEN 
            p_rec.id := inc_id;
        END IF; 
        --
        INSERT INTO igtp.languages 
             VALUES p_rec
             RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id              languages.id%TYPE,
        p_language_co     languages.language_co%TYPE,
        p_description     languages.description%TYPE,
        p_diccionary      languages.diccionary%TYPE,
        p_updated_at      languages.updated_at%TYPE,
        p_created_at      languages.created_at%TYPE
    ) IS
    BEGIN
        --
        UPDATE languages 
           SET language_co = p_language_co,
               description = p_description,
               diccionary  = p_diccionary,
               created_at  = p_created_at,
               updated_at  = p_updated_at
         WHERE id = p_id;
        -- 
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT igtp.languages%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.languages 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del (
        p_id    languages.id%TYPE
    ) IS
    BEGIN
        --
        DELETE FROM LANGUAGES
         WHERE id = p_id;
        --
    END del;
    --
end cfg_api_k_language;
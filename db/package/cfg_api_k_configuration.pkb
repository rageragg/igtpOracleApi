--------------------------------------------------------
--  DDL for Package Body configuration_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY cfg_api_k_configuration IS
    --
    -- get record
    FUNCTION get_record( p_id IN igtp.configurations.id%TYPE ) RETURN igtp.configurations%ROWTYPE IS 
        --
        l_rec configurations%ROWTYPE;
        --
    BEGIN 
        --
        SELECT *
          INTO l_rec
          FROM igtp.configurations 
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
    -- insert
    PROCEDURE ins (
        p_id                            IN configurations.id%TYPE,
        p_local_currency_co             IN configurations.local_currency_co%TYPE DEFAULT NULL,
        p_foreign_currency_co           IN configurations.foreign_currency_co%TYPE DEFAULT NULL,
        p_last_foreign_currency_q_value IN configurations.last_foreign_currency_q_value%TYPE DEFAULT NULL, 
        p_last_foreign_currency_q_date  IN configurations.last_foreign_currency_q_date%TYPE DEFAULT NULL, 
        p_country_co                    IN configurations.country_co%TYPE DEFAULT NULL, 
        p_company_description           IN configurations.company_description%TYPE DEFAULT NULL, 
        p_company_address               IN configurations.company_address%TYPE DEFAULT NULL, 
        p_company_telephone_co          IN configurations.company_telephone_co%TYPE DEFAULT NULL,
        p_company_fax_co                IN configurations.company_fax_co%TYPE DEFAULT NULL, 
        p_company_email                 IN configurations.company_email%TYPE DEFAULT NULL, 
        p_company_fiscal_document_co    IN configurations.company_fiscal_document_co%TYPE DEFAULT NULL, 
        p_company_logo                  IN configurations.company_logo%TYPE DEFAULT NULL,
        p_days_per_year                 IN configurations.days_per_year%TYPE DEFAULT NULL, 
        p_weeks_per_year                IN configurations.weeks_per_year%TYPE DEFAULT NULL,
        p_months_per_year               IN configurations.months_per_year%TYPE DEFAULT NULL,
        p_days_per_month                IN configurations.days_per_month%TYPE DEFAULT NULL, 
        p_days_per_week                 IN configurations.days_per_week%TYPE DEFAULT NULL,
        p_hours_per_day                 IN configurations.hours_per_day%TYPE DEFAULT NULL,
        p_language_co                   IN configurations.language_co%TYPE DEFAULT 'ES',
        p_updated_at                    IN configurations.updated_at%TYPE DEFAULT NULL, 
        p_created_at                    IN configurations.created_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        INSERT INTO igtp.configurations(
            id,
            local_currency_co,
            foreign_currency_co,
            last_foreign_currency_q_value,
            last_foreign_currency_q_date,
            country_co,
            company_description,
            company_address,
            company_telephone_co,
            company_fax_co,
            company_email,
            company_fiscal_document_co,
            company_logo,
            days_per_year,
            weeks_per_year,
            months_per_year,
            days_per_month,
            days_per_week,
            hours_per_day,
            language_co,
            created_at,
            updated_at
        ) 
        VALUES (
            p_id,
            p_local_currency_co,
            p_foreign_currency_co,
            p_last_foreign_currency_q_value,
            p_last_foreign_currency_q_date,
            p_country_co,
            p_company_description,
            p_company_address,
            p_company_telephone_co,
            p_company_fax_co,
            p_company_email,
            p_company_fiscal_document_co,
            p_company_logo,
            p_days_per_year,
            p_weeks_per_year,
            p_months_per_year,
            p_days_per_month,
            p_days_per_week,
            p_hours_per_day,
            p_language_co,
            p_updated_at,
            p_created_at
        );
        --
    END ins;
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT igtp.configurations%ROWTYPE ) IS 
    BEGIN 
        --
        p_rec.created_at := sysdate;
        --
        INSERT INTO igtp.configurations 
             VALUES p_rec
             RETURNING id, created_at INTO p_rec.id, p_rec.created_at;
        --
    END ins;
    --
    -- update
    PROCEDURE upd (
        p_id                            IN configurations.id%TYPE,
        p_local_currency_co             IN configurations.local_currency_co%TYPE DEFAULT NULL,
        p_foreign_currency_co           IN configurations.foreign_currency_co%TYPE DEFAULT NULL,
        p_last_foreign_currency_q_value IN configurations.last_foreign_currency_q_value%TYPE DEFAULT NULL, 
        p_last_foreign_currency_q_date  IN configurations.last_foreign_currency_q_date%TYPE DEFAULT NULL, 
        p_country_co                    IN configurations.country_co%TYPE DEFAULT NULL, 
        p_company_description           IN configurations.company_description%TYPE DEFAULT NULL, 
        p_company_address               IN configurations.company_address%TYPE DEFAULT NULL, 
        p_company_telephone_co          IN configurations.company_telephone_co%TYPE DEFAULT NULL,
        p_company_fax_co                IN configurations.company_fax_co%TYPE DEFAULT NULL, 
        p_company_email                 IN configurations.company_email%TYPE DEFAULT NULL, 
        p_company_fiscal_document_co    IN configurations.company_fiscal_document_co%TYPE DEFAULT NULL, 
        p_company_logo                  IN configurations.company_logo%TYPE DEFAULT NULL,
        p_days_per_year                 IN configurations.days_per_year%TYPE DEFAULT NULL, 
        p_weeks_per_year                IN configurations.weeks_per_year%TYPE DEFAULT NULL,
        p_months_per_year               IN configurations.months_per_year%TYPE DEFAULT NULL,
        p_days_per_month                IN configurations.days_per_month%TYPE DEFAULT NULL, 
        p_days_per_week                 IN configurations.days_per_week%TYPE DEFAULT NULL,
        p_hours_per_day                 IN configurations.hours_per_day%TYPE DEFAULT NULL,
        p_language_co                   IN configurations.language_co%TYPE DEFAULT 'ES',
        p_updated_at                    IN configurations.updated_at%TYPE DEFAULT NULL, 
        p_created_at                    IN configurations.created_at%TYPE DEFAULT NULL 
    ) IS
    BEGIN
        --
        UPDATE igtp.configurations SET
            local_currency_co             = p_local_currency_co,
            foreign_currency_co           = p_foreign_currency_co,
            last_foreign_currency_q_value = p_last_foreign_currency_q_value,
            last_foreign_currency_q_date  = p_last_foreign_currency_q_date,
            country_co                    = p_country_co,
            company_description           = p_company_description,
            company_address               = p_company_address,
            company_telephone_co          = p_company_telephone_co,
            company_fax_co                = p_company_fax_co,
            company_email                 = p_company_email,
            company_fiscal_document_co    = p_company_fiscal_document_co,
            company_logo                  = p_company_logo,
            days_per_year                 = p_days_per_year,
            weeks_per_year                = p_weeks_per_year,
            months_per_year               = p_months_per_year,
            days_per_month                = p_days_per_month,
            days_per_week                 = p_days_per_week,
            hours_per_day                 = p_hours_per_day,
            language_co                   = p_language_co,                
            updated_at                    = p_updated_at,
            created_at                    = p_created_at
        WHERE id = p_id;
        --
    END upd;
    --
    -- update RECORD
    PROCEDURE upd( p_rec IN OUT igtp.configurations%ROWTYPE ) IS 
    BEGIN
        --
        p_rec.updated_at    := sysdate;
        --
        UPDATE igtp.configurations 
           SET ROW = p_rec
         WHERE id = p_rec.id;
        --
    END upd;
    --
    -- del
    PROCEDURE del ( p_id IN igtp.configurations.id%TYPE
    ) IS
    BEGIN
        --
        DELETE FROM igtp.configurations
              WHERE id = p_id;
        --
    END del;
    --
END cfg_api_k_configuration;
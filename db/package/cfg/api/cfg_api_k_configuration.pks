--------------------------------------------------------
--  DDL for Package Body CONFIGURATIONS_API
--------------------------------------------------------

CREATE OR REPLACE PACKAGE cfg_api_k_configuration IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'CONFIGURATIONS';
    --
    TYPE configurations_api_tab IS TABLE OF igtp.configurations%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN igtp.configurations.id%TYPE ) RETURN igtp.configurations%ROWTYPE;
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
    );
    --
    -- insert by records
    PROCEDURE ins ( p_rec IN OUT igtp.configurations%ROWTYPE ); 
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
    );
    --
    -- update
    PROCEDURE upd ( p_rec IN OUT igtp.configurations%ROWTYPE );
    --
    -- delete
    PROCEDURE del ( p_id IN igtp.configurations.id%TYPE );
    --
    -- inicia las globales declaradas
    PROCEDURE set_global_configuration( p_id IN igtp.configurations.id%TYPE );
    --
END cfg_api_k_configuration;

--------------------------------------------------------
--  DDL for View V_CONFIGURATIONS
--------------------------------------------------------

CREATE OR REPLACE FORCE NONEDITIONABLE VIEW "IGTP"."V_CONFIGURATIONS" (
	"LOCAL_CURRENCY_CO", "FOREIGN_CURRENCY_CO", "LAST_FOREIGN_CURRENCY_Q_DATE",
	"LAST_FOREIGN_CURRENCY_Q_VALUE", "COUNTRY_CO", "COMPANY_DESCRIPTION", 
	"COMPANY_TELEPHONE_CO", "COMPANY_EMAIL", "DAYS_PER_YEAR", 
	"WEEKS_PER_YEAR", "MONTHS_PER_YEAR", "DAYS_PER_MONTH", 
	"DAYS_PER_WEEK", "HOURS_PER_DAY", "HOURS_PER_WEEK", 
	"HOURS_PER_MONTH"
) AS 
SELECT 	local_currency_co,
		foreign_currency_co,
		last_foreign_currency_q_date,
		last_foreign_currency_q_value,
		country_co,
		company_description,
		company_telephone_co,
		company_email,
		days_per_year,
		weeks_per_year,
		months_per_year,
		days_per_month,
		days_per_week,
		hours_per_day,
		(hours_per_day*days_per_week) hours_per_week,
		(hours_per_day*days_per_month) hours_per_month
FROM configurations
;

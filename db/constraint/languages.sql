
--------------------------------------------------------
--  Constraints for Table LANGUAGES
--------------------------------------------------------

ALTER TABLE "IGTP"."LANGUAGES" 
    ADD CONSTRAINT "LANGUAGE_JSON_CHK" CHECK (DICCIONARY IS JSON);
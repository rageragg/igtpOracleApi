
--------------------------------------------------------
--  Constraints for Table LANGUAGES
--------------------------------------------------------

ALTER TABLE "IGTP"."LANGUAGES" 
    ADD CONSTRAINT "LANGUAGE_JSON_CHK" CHECK (DICCIONARY IS JSON);

ALTER TABLE "IGTP"."LANGUAGES" 
    ADD CONSTRAINT "LANGUAGES_PK" 
    PRIMARY KEY ("ID")
    USING INDEX "IGTP"."LANGUAGES_PK"  ENABLE;
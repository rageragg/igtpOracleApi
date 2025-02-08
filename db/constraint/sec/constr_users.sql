--------------------------------------------------------
--  Constraints for Table USERS
--------------------------------------------------------

  ALTER TABLE "IGTP"."USERS" 
    ADD CONSTRAINT "USERS_PK" 
    PRIMARY KEY ("ID")
    USING INDEX "IGTP"."USERS_PK"  
    ENABLE;

  ALTER TABLE "IGTP"."USERS" 
    ADD CONSTRAINT "VALID_CHK" 
    CHECK ( k_valid IN ('Y','N' ) ) 
    ENABLE;

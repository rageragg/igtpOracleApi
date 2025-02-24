--------------------------------------------------------
--  Constraints for Table USERS
--------------------------------------------------------

  ALTER TABLE "IGTP"."PROCCESSES" 
    ADD CONSTRAINT "PROCCESSES_PK" 
    PRIMARY KEY ("ID")
    USING INDEX "IGTP"."PROCCESSES_PK"  
    ENABLE;
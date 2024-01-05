--------------------------------------------------------
--  Constraints for Table EMPLOYEES
--------------------------------------------------------

ALTER TABLE "IGTP"."EMPLOYEES" 
  MODIFY ("ID" NOT NULL ENABLE);
ALTER TABLE "IGTP"."EMPLOYEES" 
  ADD CONSTRAINT "EMPLOYEES_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."EMPLOYEES_PK"  ENABLE;

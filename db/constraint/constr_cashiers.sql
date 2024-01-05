--------------------------------------------------------
--  Constraints for Table CASHIERS
--------------------------------------------------------

ALTER TABLE "IGTP"."CASHIERS" 
  MODIFY ("ID" NOT NULL ENABLE);
ALTER TABLE "IGTP"."CASHIERS" 
  ADD CONSTRAINT "CASHIERS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."CASHIERS_PK"  ENABLE;

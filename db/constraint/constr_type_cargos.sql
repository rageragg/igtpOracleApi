--------------------------------------------------------
--  Constraints for Table TYPE_CARGOS
--------------------------------------------------------

ALTER TABLE "IGTP"."TYPE_CARGOS" MODIFY ("ID" NOT NULL ENABLE);
  
ALTER TABLE "IGTP"."TYPE_CARGOS" 
  ADD CONSTRAINT "TYPE_CARGOS_PK" PRIMARY KEY ("ID")
  USING INDEX "IGTP"."TYPE_CARGOS_PK"  ENABLE;

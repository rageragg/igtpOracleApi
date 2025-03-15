CREATE TABLE test.documents(	
  id            NUMBER(8,0) NOT NULL ENABLE, 
  document_co   VARCHAR2(20 BYTE) NOT NULL ENABLE, 
  descriptions  VARCHAR2(80 BYTE) NOT NULL ENABLE,
  num_version   VARCHAR2(20 BYTE) NOT NULL ENABLE, 
  type_document VARCHAR2(20 BYTE) NOT NULL ENABLE,
  date_loaded   TIMESTAMP (6) WITH TIME ZONE, 
  document      CLOB
);
--  
INSERT INTO test.documents (
  id, document_co, num_version, 
  descriptions, type_document, date_loaded, 
  document
) 
VALUES ( 
  1, '42001235658', 'XX.0', 
  "DOCUMENTO VIGENTE", 'POLIZA-R-200', SYSTIMESTAMP, 
  'This is a sample document.'
);

-- general-purpose SQL types


CREATE TYPE t_str_array AS TABLE OF VARCHAR2(4000);
/

CREATE TYPE t_date_array AS TABLE OF DATE;
/

CREATE TYPE t_num_array AS TABLE OF NUMBER;
/


CREATE TYPE t_name_value_pair AS object (
  name          VARCHAR2(255),
  value_string  VARCHAR2(4000),
  value_number  NUMBER,
  value_date    DATE
);
/

CREATE TYPE t_dictionary AS TABLE OF t_name_value_pair;
/

-- types for CSV parsing

CREATE TYPE t_csv_line AS object (
  line_number  NUMBER,
  line_raw     VARCHAR2(4000),
  c001         VARCHAR2(4000),
  c002         VARCHAR2(4000),
  c003         VARCHAR2(4000),
  c004         VARCHAR2(4000),
  c005         VARCHAR2(4000),
  c006         VARCHAR2(4000),
  c007         VARCHAR2(4000),
  c008         VARCHAR2(4000),
  c009         VARCHAR2(4000),
  c010         VARCHAR2(4000),
  c011         VARCHAR2(4000),
  c012         VARCHAR2(4000),
  c013         VARCHAR2(4000),
  c014         VARCHAR2(4000),
  c015         VARCHAR2(4000),
  c016         VARCHAR2(4000),
  c017         VARCHAR2(4000),
  c018         VARCHAR2(4000),
  c019         VARCHAR2(4000),
  c020         VARCHAR2(4000)
);
/

CREATE TYPE t_csv_tab AS TABLE OF t_csv_line;
/


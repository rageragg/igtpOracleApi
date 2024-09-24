CREATE OR REPLACE PACKAGE utl_k_gen_xls IS
  /*
    Fecha    : 2020-02-03
    Objetivo : Generacion de archivo excel desde PL/SQL
    Requerimiento minimo: Excel version 2003 con soporte formato XML.
  */
  /*
    -- ! Ejemplo de uso de utl_k_gen_xls:
    --
  BEGIN
      --
      -- ! se crea el archivo fisico (libro), en el directorio
      utl_k_gen_xls.create_excel(
          p_directory => 'APP_OUTDIR',
          p_file_name => 'reporte.xls'
      );
      --
      -- ! se agregan estilos para las celdas
      utl_k_gen_xls.create_style(
          p_style_name  => 'Estilo1',
          p_fontname    => 'Arial',
          p_fontcolor   => 'White',
          p_fontsize    => 10,
          p_bold        => True,
          p_italic      => True,
          p_underline   => 'False',
          p_backcolor   => 'Gray'
      );
      --
      utl_k_gen_xls.create_style(
        p_style_name  => 'Normal_Right',
        p_fontsize    => 10,
        p_h_alignment => 'Right'
      );
      --
      utl_k_gen_xls.create_style(
        p_style_name  => 'Normal_Left',
        p_fontsize    => 10,
        p_h_alignment => 'Left'
      );
      --
      -- se crea una hoja en el libro
      utl_k_gen_xls.create_worksheet(
          p_worksheet_name => 'datos'
      );
      --
      -- ! se establece el ancho de columna
      utl_k_gen_xls.set_column_width(
          p_column    => 1, 
          p_width     => 200, 
          p_worksheet => 'datos'
      );
      --
      -- ! TITULOS DEL REPORTE
      utl_k_gen_xls.write_cell_char(
        p_row            => 1,
        p_column         => 1,
        p_worksheet_name => 'datos',
        p_value          => 'TITULO REPORTE',
        p_style          => 'Estilo1'
      );
      --
      -- ! ENCABEZADOS DE COLUMNA
      utl_k_gen_xls.write_cell_char(
        p_row            => 2,
        p_column         => 1,
        p_worksheet_name => 'datos',
        p_value          => 'BOLETOS',
        p_style          => 'Estilo1'
      );
      --
      utl_k_gen_xls.write_cell_char(
        p_row            => 2,
        p_column         => 2,
        p_worksheet_name => 'datos',
        p_value          => 'PESO',
        p_style          => 'Estilo1'
      );    
      -- 
      -- ! DETALLES DEL REPORTE
      utl_k_gen_xls.write_cell_char(
        p_row            => 3,
        p_column         => 1,
        p_worksheet_name => 'datos',
        p_value          => '12523-2255',
        p_style          => 'Normal_Left'
      );
      -- 
      utl_k_gen_xls.write_cell_num(
        p_row            => 3,
        p_column         => 2,
        p_worksheet_name => 'datos',
        p_value          => 750.70,
        p_style          => 'Normal_Right'
      );
      --
      utl_k_gen_xls.write_cell_char(
        p_row            => 4,
        p_column         => 1,
        p_worksheet_name => 'datos',
        p_value          => '2532-2555',
        p_style          => 'Normal_Left'
      );
      --
      utl_k_gen_xls.write_cell_num(
        p_row            => 4,
        p_column         => 2,
        p_worksheet_name => 'datos',
        p_value          => 685.50,
        p_style          => 'Normal_Right'
      );    
      --
      utl_k_gen_xls.close_file;
      --
  END;
  --
  -- ! SALIDA
  ------------------------------
  | TITULO REPORTE             |	
  ------------------------------
  | BOLETOS	        |     PESO |
  ------------------------------ 
  | 12523-2255	    | 7,507.00 |
  | 2532-2555	      | 6,855.00 |
  ------------------------------
*/

  debug_flag BOOLEAN := FALSE  ;
  --
  t_ENTERO         CONSTANT PLS_INTEGER:= 1;
  t_NUMERICO       CONSTANT PLS_INTEGER:= 2;
  t_MONEDA         CONSTANT PLS_INTEGER:= 3;
  t_ALFANUMERICO   CONSTANT PLS_INTEGER:= 4;
  t_FECHA          CONSTANT PLS_INTEGER:= 5;
  t_FORMULA        CONSTANT PLS_INTEGER:= 6;
  t_NUM_MASCARA    CONSTANT PLS_INTEGER:= 7;
  --
  SUBTYPE tipoCelda IS PLS_INTEGER Range 1..7;
  --
  PROCEDURE create_excel( 
    p_directory IN VARCHAR2 DEFAULT NULL,  
    p_file_name IN VARCHAR2 DEFAULT NULL 
  );
  --
  PROCEDURE create_excel_apps ;
  --
  PROCEDURE create_style( 
    p_style_name IN VARCHAR2
    , p_fontname IN VARCHAR2 DEFAULT NULL
    , p_fontcolor IN VARCHAR2 DEFAULT 'Black'
    , p_fontsize IN NUMBER DEFAULT null
    , p_bold IN BOOLEAN DEFAULT FALSE
    , p_italic IN BOOLEAN DEFAULT FALSE
    , p_underline IN VARCHAR2 DEFAULT NULL
    , p_backcolor IN VARCHAR2 DEFAULT NULL
    , p_v_alignment in varchar2 default null
    , p_h_alignment in varchar2 default null
  );
  --
  PROCEDURE write_cell_formula(
    p_row NUMBER ,
    p_column NUMBER,
    p_worksheet_name IN VARCHAR2,
    p_value IN VARCHAR2
  );
  --
  PROCEDURE write_cell(
    p_row NUMBER,
    p_column NUMBER,
    p_worksheet_name IN VARCHAR2,
    p_value IN VARCHAR2,
    p_tipo_celda tipoCelda,
    p_style IN VARCHAR2 DEFAULT NULL
  );
  --
  PROCEDURE close_file ;
  --
  PROCEDURE create_worksheet( p_worksheet_name IN VARCHAR2 ) ;
  PROCEDURE write_cell_num(p_row NUMBER ,  p_column NUMBER, p_worksheet_name IN VARCHAR2,  p_value IN NUMBER , p_style IN VARCHAR2 DEFAULT NULL);
  PROCEDURE write_cell_char(p_row NUMBER, p_column NUMBER, p_worksheet_name IN VARCHAR2,  p_value IN VARCHAR2, p_style IN VARCHAR2 DEFAULT NULL ,p_merge IN pls_integer default 1 );
  PROCEDURE write_cell_null(p_row NUMBER ,  p_column NUMBER , p_worksheet_name IN VARCHAR2, p_style IN VARCHAR2);
  --
  PROCEDURE set_row_height( p_row IN NUMBER , p_height IN NUMBER, p_worksheet IN VARCHAR2  ) ;
  PROCEDURE set_column_width( p_column IN NUMBER , p_width IN NUMBER , p_worksheet IN VARCHAR2  ) ;
  --
END utl_k_gen_xls;
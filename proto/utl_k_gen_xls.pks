CREATE OR REPLACE PACKAGE utl_k_gen_xls IS
  /*
    Fecha    : 2020-02-03
    Objetivo : Generacion de archivo excel desde PL/SQL
    Requerimiento minimo: Excel version 2003 con soporte formato XML.
  */
  /*
    -- ! Ejemplo de uso de utl_k_gen_xls:
    -----------------------------------------------------------------
    Flujo
      1.- Crear el documento
      2.- Agregar estilos (opcional)
      3.- Crear la hoja del documento
      4.- Crear contenido del documento
      5.- Cerrar el documento
    --
    BEGIN
      --
      -- ! se crea el archivo fisico (libro), en el directorio
      utl_k_gen_xls.create_excel(
          p_directory => 'APP_OUTDIR',
          p_file_name => 'reporte-boletos.xls'
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
  DEBUG_FLAG     BOOLEAN := FALSE;
  --
  T_INTEGER      CONSTANT PLS_INTEGER:= 1;
  T_NUMERIC      CONSTANT PLS_INTEGER:= 2;
  T_CURRENCY     CONSTANT PLS_INTEGER:= 3;
  T_ALFANUMERIC  CONSTANT PLS_INTEGER:= 4;
  T_DATE         CONSTANT PLS_INTEGER:= 5;
  T_FORMULA      CONSTANT PLS_INTEGER:= 6;
  T_NUM_MASK     CONSTANT PLS_INTEGER:= 7;
  --
  SUBTYPE typecell IS PLS_INTEGER RANGE 1..7;
  --
  /*
    Crea un documento en el sistema de archivo
    Parametros:
      p_directory   : Alias del directorio donde se
                      creara el documento
        p_file_nane : Nombre del documento
      )
  */
  PROCEDURE create_excel(
    p_directory IN VARCHAR2 DEFAULT NULL,
    p_file_name IN VARCHAR2 DEFAULT NULL
  );
  --
  /*
    Inicializa el proceso para crear el documento XLS
  */
  PROCEDURE create_excel_apps;
  --
  /*
    Agrega a la configuracion del documento un estilo de celda
      Parametros:
        p_style_name    : Nombre del estilo
        p_fontname      : Nombre de la fuente de letra a aplicar
        p_fontcolor     : Color de las letras de la celda, Por defecto 'Black' (Negro)
        p_fontsize      : Tamanio de la letras de la celda
        p_bold          : Si se resalta la letra con NEGRILLA de la celda, Por defecto no aplica
        p_italic        : Si la letra es cursiva de la celda, Por defecto no aplica
        p_underline     : Si la letra esta subrayada en la celda
        p_backcolor     : Color de fondo de la celda
        p_v_alignment   : Alineacion vertical de la celda ("Top", "Center", "Bottom") => (Arriba, Centro, Abajo)
        p_h_alignment   : alineacion horizontal de la celda ("Right", "Center", "Left") => (Derecha, Centro, Izquierda)
  */
  PROCEDURE create_style(
    p_style_name  IN VARCHAR2,
    p_fontname    IN VARCHAR2 DEFAULT NULL,
    p_fontcolor   IN VARCHAR2 DEFAULT 'Black',
    p_fontsize    IN NUMBER DEFAULT NULL,
    p_bold        IN BOOLEAN DEFAULT FALSE,
    p_italic      IN BOOLEAN DEFAULT FALSE,
    p_underline   IN VARCHAR2 DEFAULT NULL,
    p_backcolor   IN VARCHAR2 DEFAULT NULL,
    p_v_alignment IN VARCHAR2 DEFAULT NULL,
    p_h_alignment IN VARCHAR2 DEFAULT NULL
  );
  --
  /*
    Establece una formula en la celda
      Parametros:
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
        p_value           : formula que se establece
  */
  PROCEDURE write_cell_formula(
    p_row             IN NUMBER,
    p_column          IN NUMBER,
    p_worksheet_name  IN VARCHAR2,
    p_value           IN VARCHAR2
  );
  --
  /*
    Establece el valor en la celda, segun el tipo de datos
      Parametros:
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
        p_value           : valor que se establece
        p_type_cell      : Entre 1..7
                              ENTERO       (1)
                              NUMERICO     (2)
                              MONEDA       (3)
                              ALFANUMERICO (4)
                              FECHA        (5)
                              FORMULA      (6)
                              NUM_MASCARA  (7)
        p_style           : Estilo de la celda                              
  */
  PROCEDURE write_cell(
    p_row             IN NUMBER,
    p_column          IN NUMBER,
    p_worksheet_name  IN VARCHAR2,
    p_value           IN VARCHAR2,
    p_type_cell       IN typecell,
    p_style           IN VARCHAR2 DEFAULT NULL
  );
  --
  /*
    Cierra el documento y libera recursos
  */
  PROCEDURE close_file;
  --
  /*
    Crea una hoja de calculo dentro del documento
  */
  PROCEDURE create_worksheet(
    p_worksheet_name IN VARCHAR2
  );
  --
  /*
    Escribe un valor numerico en la celda
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
        p_value           : valor que se establece
        p_style           : nombre del estilo a aplicar   
  */
  PROCEDURE write_cell_num(
    p_row             IN NUMBER,
    p_column          IN NUMBER,
    p_worksheet_name  IN VARCHAR2,
    p_value           IN NUMBER,
    p_style           IN VARCHAR2 DEFAULT NULL
  );
  --
    /*
    Escribe un valor caracteres en la celda
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
        p_value           : valor que se establece
        p_style           : nombre del estilo a aplicar   
  */
  PROCEDURE write_cell_char(
    p_row             IN NUMBER,
    p_column          IN NUMBER,
    p_worksheet_name  IN VARCHAR2,
    p_value           IN VARCHAR2,
    p_style           IN VARCHAR2 DEFAULT NULL,
    p_merge           IN PLS_INTEGER DEFAULT 1
  );
  --
  /*
    Escribe un valor nulo (vacio) en la celda
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
        p_style           : nombre del estilo a aplicar   
  */
  PROCEDURE write_cell_null(
    p_row             IN NUMBER,
    p_column          IN NUMBER,
    p_worksheet_name  IN VARCHAR2,
    p_style           IN VARCHAR2
  );
  --
  /*
    Escribe la altura de la celda
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
  */
  PROCEDURE set_row_height(
    p_row       IN NUMBER,
    p_height    IN NUMBER,
    p_worksheet IN VARCHAR2
  );
  --
  /*
    Escribe el ancho de la celda
        p_row             : Fila en la hoja del documento
        p_column          : Columna en la hoja del documento
        p_worksheet_name  : Nombre de la hoja del documento
  */
  PROCEDURE set_column_width(
    p_column    IN NUMBER,
    p_width     IN NUMBER,
    p_worksheet IN VARCHAR2
  );
  --
END utl_k_gen_xls;
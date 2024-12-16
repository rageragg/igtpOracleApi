CREATE OR REPLACE PACKAGE SYS_K_PDF_BUILDER
AS
    ---------------------------------------------------------------------------
    --  DDL:        for Package PDF (API)
    --  PURPOSE:    Package to generate PDF files
    --  REFERENCES
    --  NOMBRE                          TIPO
    --  =============================== =======================================
    --
    --  MODIFICATIONS
    --  DATE        AUTOR               DESCRIPTIONS
    --  =========== =================== =======================================
    --  20-10-2010  Anton Scheffer      Actualizacion de metodos de procesos
    --                                  administrativos de creacion de tiendas
    --  see http://technology.amis.nl/blog/8650/as_pdf-generating-a-pdf-document-with-some-plsql
    ---------------------------------------------------------------------------
    --
    TYPE tp_settings IS RECORD( 
        page_width          NUMBER,
        page_height         NUMBER,
        margin_left         NUMBER,
        margin_right        NUMBER,
        margin_top          NUMBER,
        margin_bottom       NUMBER,
        encoding            VARCHAR2(100),
        current_font        PLS_INTEGER,
        current_fontsizePt  PLS_INTEGER,
        x                   NUMBER,
        y                   NUMBER,
        page_nr             PLS_INTEGER
    );
  --
  PROCEDURE init;
  --
  FUNCTION get_pdf return blob;
  --
  PROCEDURE save_pdf( 
      p_dir       IN VARCHAR2 := 'APP_OUTDIR',
      p_filename  IN VARCHAR2 := 'my.pdf'
  );
  --
  PROCEDURE show_pdf;
  --
  FUNCTION conv2user_units( 
      p_value IN NUMBER, 
      p_unit  IN VARCHAR2 
  ) RETURN NUMBER;
--
  procedure set_format
    ( p_format IN VARCHAR2 := 'A4'
    , p_orientation IN VARCHAR2 := 'PORTRAIT'
    );
--
  procedure set_pagesize
    ( p_width IN NUMBER
    , p_height IN NUMBER
    , p_unit IN VARCHAR2 := 'cm'
    );
--
  procedure set_margins
    ( p_top IN NUMBER := 3
    , p_left IN NUMBER := 1
    , p_bottom IN NUMBER := 4
    , p_right IN NUMBER := 1
    , p_unit IN VARCHAR2 := 'cm'
    );
--
  function get_settings
  return tp_settings;
--
  procedure new_page;
--
  procedure set_font
    ( p_family IN VARCHAR2
    , p_style  IN VARCHAR2 := 'N'
    , p_fontsizePt IN PLS_INTEGER := null
    , p_encoding IN VARCHAR2 := 'WINDOWS-1252'
    );
--
  procedure add2page( p_txt IN nclob );
--
  procedure put_txt( p_x IN NUMBER, p_y IN NUMBER, p_txt IN nclob );
--
  function string_width( p_txt IN nclob )
  return NUMBER;
--
  procedure write
    ( p_txt IN nclob
    , p_x IN NUMBER := null 
    , p_y IN NUMBER := null
    , p_line_height IN NUMBER := null
    , p_start IN NUMBER := null  -- left side of the available text box
    , p_width IN NUMBER := null  -- width of the available text box
    , p_alignment IN VARCHAR2 := null
    );
--
  procedure set_color( p_rgb IN VARCHAR2 := '000000' );
--
  procedure set_color
    ( p_red IN NUMBER := 0
    , p_green IN NUMBER := 0
    , p_blue IN NUMBER := 0 
    );
--
  procedure set_bk_color( p_rgb IN VARCHAR2 := 'ffffff' );
--
  procedure set_bk_color
    ( p_red IN NUMBER := 255
    , p_green IN NUMBER := 255
    , p_blue IN NUMBER := 255 
    );
--
  procedure horizontal_line
    ( p_x IN NUMBER
    , p_y IN NUMBER
    , p_width IN NUMBER
    , p_line_width IN NUMBER := 0.5
    , p_line_color IN VARCHAR2 := '000000'
    );
--
  procedure vertical_line
    ( p_x IN NUMBER
    , p_y IN NUMBER
    , p_height IN NUMBER
    , p_line_width IN NUMBER := 0.5
    , p_line_color IN VARCHAR2 := '000000'
    );
--
  procedure rect
    ( p_x IN NUMBER
    , p_y IN NUMBER
    , p_width IN NUMBER
    , p_height IN NUMBER
    , p_line_color IN VARCHAR2 := null
    , p_fill_color IN VARCHAR2 := null
    , p_line_width IN NUMBER := 0.5
    );
--
  procedure put_image
     ( p_dir IN VARCHAR2
     , p_file_name IN VARCHAR2
     , p_x IN NUMBER
     , p_y IN NUMBER
     , p_width IN NUMBER := null
     , p_height IN NUMBER := null
     );
--
  procedure put_image
     ( p_url IN VARCHAR2
     , p_x IN NUMBER
     , p_y IN NUMBER
     , p_width IN NUMBER := null
     , p_height IN NUMBER := null
     );
--
  procedure put_image
     ( p_img IN blob
     , p_x IN NUMBER
     , p_y IN NUMBER
     , p_width IN NUMBER := null
     , p_height IN NUMBER := null
     );
--

end sys_k_pdf_builder;
/


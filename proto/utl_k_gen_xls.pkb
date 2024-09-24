create or replace package body gc_k_gen_xls_mrd is

-------------------------------------------------------------------
-- hiaquin 23-jul-2012 v1.00
-- adaptacion de package de creacion del excel para tronweb.
-- genera archivos excel xml.
-------------------------------------------------------------------
-- worksheets must be created before it could be passed AS parameter TO the write cell procedures
/*----------------Modificaciones---------------------------
|| V. 1.01  HJAM  01/07/2013
|| Modificacion para dar formato a las celdas deacuerdo al tipo seleccionado...
||------------------------------------------------------------------
|| V. 1.02  HJAM  02/09/2013
|| Se comenta la funcion cell_used, ya que el control esta en la c
|| reacion del archivo, y esto sumaba bastante al proceso.
--------------------------------------------------------------------
||------------------------------------------------------------------
|| V. 1.03  HJAM-jumgonzalez  11/12/2014
|| se modifico para agregar el paramentro de alineacion en columna.
--------------------------------------------------------------------
-------------------------------------------------------------------
-- v1.04
-- jumgonzalez 17-09-2022
-- se modifica para agregar el encoding="ISO-8859-1" a la version del xml que se genera
-- esto con el objetivo de que pueda leer los caracteres extraños.
*/

l_file  utl_FILE.file_type ;

g_apps_env VARCHAR2(1) := 'U' ; -- unset at the start

TYPE tbl_excel_data IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER ;
g_excel_data tbl_excel_data ;
g_null_data tbl_excel_data ;
g_data_count NUMBER ;


TYPE rec_styles IS record ( s VARCHAR2(30) , def VARCHAR2(2000) );
TYPE tbl_style IS TABLE OF rec_styles  INDEX BY BINARY_INTEGER ;
g_styles tbl_style ;
g_null_styles tbl_style ;
g_style_count NUMBER := 0;

TYPE rec_worksheets IS record ( w VARCHAR2(30) , whdr VARCHAR2(300), wftr VARCHAR2(2000) );
TYPE tbl_worksheets IS TABLE OF rec_worksheets  INDEX BY BINARY_INTEGER ;
g_worksheets tbl_worksheets ;
g_null_worksheets tbl_worksheets ;
g_worksheets_count NUMBER := 0;

TYPE rec_cell_data IS record  ( r NUMBER , c NUMBER , v VARCHAR2(2000) ,s VARCHAR2(30) , w VARCHAR2(100), dt tipoCelda, merg pls_integer );
TYPE tbl_cell_data IS TABLE OF rec_cell_data INDEX BY binary_INTEGER ;
g_cells tbl_cell_data ;
g_null_cells tbl_cell_data ;
g_cell_count NUMBER := 0 ;

TYPE rec_columns_data IS record( c NUMBER, wd NUMBER, w VARCHAR2(30)  ) ;
TYPE tbl_columns_data IS TABLE OF rec_columns_data Index BY BINARY_INTEGER ;
g_columns tbl_columns_data ;
g_null_columns tbl_columns_data ;
g_column_count NUMBER ;


TYPE rec_rows_data IS record( r NUMBER, ht NUMBER , w VARCHAR2(30) ) ;
TYPE tbl_rows_data IS TABLE OF rec_rows_data Index BY BINARY_INTEGER ;
g_rows tbl_ROWS_data ;
g_null_rows tbl_rows_data ;
g_ROW_count NUMBER ;
--

PROCEDURE p ( p_string IN VARCHAR2) is
begin
        IF debug_flag = TRUE THEN
          DBMS_OUTPUT.put_line( p_string) ;
        END IF;
END ;

FUNCTION style_defined ( p_style IN VARCHAR2 ) RETURN BOOLEAN IS
BEGIN
    FOR i IN 1..g_style_count LOOP
        IF g_styles(i).s = p_style THEN
            RETURN TRUE ;
        END IF;
    END LOOP ;
        RETURN FALSE ;
END ;
-------------------------------------------------------------------------------------------------------------
-- Function : cell_used   returns : BOOLEAN
--  Description : Cell_used FUNCTION returns TRUE IF that cell IS already used
--  Called BY : write_Cell_char, write_cell_num
--  ??? right now it IS NOT called BY write_Cell_null , this needs TO be evaluated
-------------------------------------------------------------------------------------------------------------
FUNCTION cell_used ( p_r IN NUMBER , p_c IN number , p_w IN VARCHAR2  ) RETURN BOOLEAN IS
BEGIN
  ----V. 1.02
/*    FOR i IN 1..g_cell_count LOOP
        IF ( g_cells(i).r = p_r AND g_cells(i).c = p_c AND g_cells(i).w = p_w )  THEN
            RETURN TRUE ;
        END IF;
    END LOOP ;*/
----FIN V. 1.02
    RETURN FALSE ;
END ;

PROCEDURE initialize_collections IS
    --- following lines resets the cell data and the cell count as it was
    -- observed that the data is retained across the two runs within same seseion.
BEGIN
    g_cells := g_null_cells ;
    g_Cell_count := 0 ;

    g_styles := g_null_styles ;
    g_style_count := 0 ;

    g_rows := g_null_rows ;
    g_ROW_count := 0 ;

    g_columns := g_null_columns ;
    g_column_count :=  0 ;

    g_excel_data := g_null_data ;
    g_data_count := 0 ;

    g_apps_env := 'U';

    g_worksheets := g_null_worksheets ;
    g_worksheets_count := 0;

END ;

PROCEDURE create_excel_apps is
BEGIN
    -- CHECK the env value
    IF g_apps_env = 'N' THEN
        raise_application_error( -20001 , 'You have already called create_excel ( Non Apps ) procedure, Can not set env to create_excel_apps.');
    END IF ;
    initialize_collections ;
    g_apps_env := 'Y' ;
END ;

PROCEDURE create_excel( p_directory IN VARCHAR2 DEFAULT NULL ,  p_file_name IN VARCHAR2 DEFAULT NULL )
IS
--
BEGIN
    -- CHECK the env value
    IF g_apps_env = 'Y' THEN
        raise_application_error( -20001 , 'You have already called procedure create_excel_apps , Can not set env to Non-Apps create_excel.');
    END IF ;
    initialize_collections ;
    g_apps_env := 'N' ;
    IF ( p_directory IS NULL OR p_file_name IS NULL ) THEN
        raise_application_error( -20001 , 'Directorio y/o Nombre de Archivo no deben ser Nulos');
    END IF ;

    BEGIN
        -------------------------------------------
        -- Open the FILE IN the specified directory
        -- -----------------------------------------
        If Not UTL_FILE.IS_OPEN (l_file) Then       --V 1.01
           l_file :=   utl_file.fopen( p_directory, p_file_name , 'w') ;
        End If;

    EXCEPTION
    WHEN utl_file.write_error THEN
        raise_application_error( -20101 , 'UTL_FILE - Error de Escritura. Verifique si el archivo ya esta abierto o los permisos al directorio');
    WHEN utl_file.INVALID_OPERATION THEN
        raise_application_error( -20101 , 'UTL_FILE - No pudo abrir archivo u operar en el. Verifique si el archivo ya esta abierto');
    WHEN utl_file.invalid_path THEN
        raise_application_error( -20101 , 'UTL_FILE - Ruta invalida. Verifique que el directorio es valido y que tiene acceso');
    WHEN others THEN
        raise_application_error( -20101 , 'UTL_FILE - Error Generico.');
    END ;

    p( 'Archivo '||p_file_name ||' creado satisfactoriamente.');

END ;


PROCEDURE create_style( p_style_name IN VARCHAR2
                      , p_fontname IN VARCHAR2 DEFAULT NULL
                      , p_fontcolor IN VARCHAR2 DEFAULT 'Black'
                      , p_fontsize IN NUMBER DEFAULT null
                      , p_bold IN BOOLEAN DEFAULT FALSE
                      , p_italic IN BOOLEAN DEFAULT FALSE
                      , p_underline IN VARCHAR2 DEFAULT NULL
                      , p_backcolor IN VARCHAR2 DEFAULT NULL
                      ---HJAM - 03/11/2014
                      , p_v_alignment in varchar2 default null
                      , p_h_alignment in varchar2 default null
                      ---Fin HJAM
                      ) is

--l_style VARCHAR2(2000)  ;
l_font               VARCHAR2(1200);
---HJAM
l_alignment          VARCHAR2(1200);
  /*
    Parametro para configurar la alineacion vertical y horizontal del valor de la celda.
    Los valores posibles son:
        p_v_alignment => alineacion vertical ("Top", "Center", "Bottom") => (Arriba, Centro, Abajo)
        p_h_alignment => alineacion horizontal ("Right", "Center", "Left") => (Derecha, Centro, Izquierda)
  */
---Fin HJAM
BEGIN
    --------------------------------------------------------------------
    --- CHECK IF this style IS already defined AND RAISE   ERROR IF yes
    --------------------------------------------------------------------
    IF style_defined( p_style_name ) THEN
        RAISE_application_error( -20001 , 'Style "'||p_style_name ||'" is already defined.');
    END IF;


    g_style_count := g_style_count + 1;
    ---- ??? pass ANY value OF underline AND it will only use single underlines
    -- ??? pattern IS NOT handleed
    IF upper(p_style_name) = 'DEFAULT' THEN
       RAISE_application_error( -20001 , 'Style name DEFAULT is not allowed ');
    END IF ;

    IF upper(p_style_name) IS NULL  THEN
       RAISE_application_error( -20001 , 'Style name can not be null ');
    END IF ;

    g_styles(g_style_count).s := p_style_name ;
    g_styles(g_style_count).def := ' <Style ss:ID="'||  p_style_name    ||'"> ' ;

    l_font := ' <Font ' ;

    IF p_fontname IS NOT NULL THEN
        l_font :=l_font || 'ss:FontName="'|| p_fontname ||'" ';
    end if ;

    IF p_fontsize is not null then
        l_font := l_font ||' ss:Size="'|| p_fontsize  ||'" ';
    end if ;

    IF p_fontcolor is not null then
        l_font := l_font ||' ss:Color="'|| p_fontcolor  ||'" ';
    ELSE
        l_font := l_font ||' ss:Color="Black" ';
    end if ;

    IF p_bold = TRUE THEN
        l_font := l_font ||' ss:Bold="1" ' ;
    END IF;

    IF p_italic = TRUE THEN
        l_font := l_font ||' ss:Italic="1" ' ;
    END IF;

    IF p_underline IS NOT NULL THEN
        l_font := l_font ||' ss:Underline="Single" ' ;
    END IF ;
--        p( l_font );
     g_styles(g_style_count).def :=  g_styles(g_style_count).def || l_font || '/>' ;

    IF p_backcolor IS NOT NULL THEN
      g_styles(g_style_count).def :=  g_styles(g_style_count).def || ' <Interior ss:Color="'||p_backcolor ||'" ss:Pattern="Solid"/>' ;
    ELSE
        g_styles(g_style_count).def :=  g_styles(g_style_count).def || ' <Interior/>';
    END IF ;
    ----HJAM - 03/11/2014
    IF p_v_alignment is not null or p_h_alignment is not null THEN
      l_alignment:= '<Alignment ';
      if p_v_alignment is not null then
        if upper(p_v_alignment) not in ('TOP','CENTER','BOTTOM') then
          Raise_Application_Error(-20001, 'EL VALOR DE ALINEACION VERTICAL ES INCORRECTO ("TOP","CENTER","BOTTOM")');
        end if;
        l_alignment:= l_alignment || 'ss:Vertical="' || p_v_alignment||'" ';
      end if;
      if p_h_alignment is not null then
        if upper(p_h_alignment) not in ('LEFT','CENTER','RIGHT') then
          Raise_Application_Error(-20001, 'EL VALOR DE ALINEACION HORIZONTAL ES INCORRECTO ("LEFT","CENTER","RIGHT")');
        end if;
        l_alignment:= l_alignment || 'ss:Horizontal="' || p_h_alignment||'" ';
      end if;
      l_alignment:= l_alignment || '/>';
      g_styles(g_style_count).def :=  g_styles(g_style_count).def || l_alignment;
    END IF;
    ----Fin HJAM
     g_styles(g_style_count).def :=  g_styles(g_style_count).def || ' </Style>' ;

---  ??? IN font there IS SOME family which IS NOT considered

END ;

PROCEDURE close_file  IS

l_last_row NUMBER := 0 ;
--l_dt CHAR ; -- ??? Variable TO store the datatype ;  this IS NOT used at this time but may be needed IF the memory
            -- issue IS there FOR example IF there IS big array
l_style VARCHAR2(140) ;
l_row_change VARCHAR2(100) ;
---V 1.01
  ---HJAM - 03/11/2014
  --l_margen varchar2(20):= ' ss:MergeAcross="';
  l_margen varchar2(40):= ' ss:MergeAcross="';
  ---Fin HJAM
---FIN V 1.01

l_file_header VARCHAR2(2000) := '<?xml version="1.0"  encoding="ISO-8859-1"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
  <LastAuthor>a</LastAuthor>
  <Created>1996-10-14T23:33:28Z</Created>
  <LastSaved>2007-05-10T04:00:57Z</LastSaved>
  <Version>11.5606</Version>
 </DocumentProperties>
 <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>9300</WindowHeight>
  <WindowWidth>15135</WindowWidth>
  <WindowTopX>120</WindowTopX>
  <WindowTopY>120</WindowTopY>
  <AcceptLabelsInFormulas/>
  <ProtectStructure>False</ProtectStructure>
  <ProtectWindows>False</ProtectWindows>
 </ExcelWorkbook>
  <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
   <Borders/>
   <Font/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>
  <Style ss:ID="s999" ss:Name="Moneda">
   <NumberFormat ss:Format="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* \(#,##0.00\);_(&quot;$&quot;* &quot;-&quot;??_);_(@_)"/>
  </Style>
  <Style ss:ID="s99" ss:Parent="s999">
   <Font ss:FontName="Arial"/>
  </Style>
  <Style ss:ID="s98">
   <NumberFormat ss:Format="Short Date"/>
  </Style>
  <Style ss:ID="s97">
   <NumberFormat ss:Format="#,##0.00"/>
  </Style>';

BEGIN
    IF gc_k_gen_xls_mrd.g_Cell_count = 0 THEN
        raise_application_error( -20007 , 'No cells have been written, this version of gen_xl_xml needs at least one cell to be written');
    END IF;
    IF gc_k_gen_xls_mrd.g_worksheets_count = 0 THEN
        raise_application_error( -20008 , 'No worksheets have been created, this version does not support automatic worksheet creation');
    END IF;
p( gc_k_gen_xls_mrd.g_Cell_count) ;
    -----------------------------------------
    -- Write the header xml part IN the FILE.
    ------------------------------------------
    g_data_count := g_data_count + 1 ;
    g_excel_data( g_data_count ) :=  l_file_header ;
    p( 'Headers written');


    FOR i IN 1..g_style_count LOOP
        p( ' writing style number : '||i);
        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) := g_styles(i).def ;
    END LOOP ;
    -- CLOSE the styles tag
    g_data_count := g_data_count + 1 ;
    g_excel_data( g_data_count ) := ' </Styles>' ;
 p( 'worksheet count '|| g_worksheets_count );
    FOR j IN 1..g_worksheets_count LOOP
        l_last_row := 0  ; --- FOR every worksheet we need TO CREATE START OF the row
            p( '()()------------------------------------------------------------ last row '||l_last_row );
        --- write the header first
        -- write the COLUMN widhts first
        -- write the cells
        -- write the worksheet footer
        l_row_change := NULL ;
        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) := ' <Worksheet ss:Name="'|| g_worksheets( j).w ||'"> ' ;
        p( '-------------------------------------------------------------');
        p( '****************.Generated sheet '|| g_worksheets( j).w);
        p( '-------------------------------------------------------------');

        -- write the TABLE structure ??? change the LINE here TO include tha maxrow AND cell
        g_data_count := g_data_count + 1 ;
        --V 1.01
        --g_excel_data( g_data_count ) := '<Table ss:ExpandedColumnCount="16" ss:ExpandedRowCount="44315" x:FullColumns="1"  x:FullRows="1">' ;
        g_excel_data( g_data_count ) := '<Table x:FullColumns="1"  x:FullRows="1">' ;
        --FIN V 1.01

        FOR i IN 1..g_column_count LOOP
            IF g_columns(i).w =  g_worksheets( j).w THEN
                g_data_count := g_data_count + 1 ;
                g_excel_data( g_data_count ) :=  ' <Column ss:Index="'||g_columns(i).c||'" ss:AutoFitWidth="0" ss:Width="'||g_columns(i).wd ||'"/> ' ;
            END IF;
        END LOOP ;
        ---------------------------------------------
        -- write the cells data
        ---------------------------------------------

        FOR i IN 1..g_cell_count LOOP ------  LOOP OF g_cell_count
         p( '()()()()()()()()()()()()  '|| i);
            --- we will write only IF the cells belongs TO the worksheet that we are writing.
            IF  g_cells(i).w <> g_worksheets(j).w  THEN
                p( '........................Cell : W :'|| g_worksheets( j).w ||'=> r='|| g_cells(i).r ||',c ='|| g_cells(i).c||',w='|| g_cells(i).w );
                p( '...Not in this worksheet ');
--                l_last_row := l_last_row -1 ;
            ELSE


            p( '........................Cell : W :'|| g_worksheets( j).w ||'=> r='|| g_cells(i).r ||',c ='|| g_cells(i).c||',w='|| g_cells(i).w );
            IF g_cells(i).s IS NOT NULL AND NOT style_defined( g_cells(i).s ) THEN
--                p(g_cells(i).s) ;
                raise_application_error( -20001 , 'Style "'||g_cells(i).s ||'" is not defined, Note : Styles are case sensative and check spaces used while passing style');
            END IF;
            p( '()()------------------------------------------------------------ last row '||l_last_row );
            IF l_last_row = 0 THEN

--
                FOR t IN 1..g_row_count LOOP
                    p( '...Height check => Row =' ||g_rows(t).r ||', w='||g_rows(t).w);
                    IF g_rows(t).r = g_cells(i).r AND  g_rows(t).w = g_worksheets(j).w THEN
                        p( '...Changing height') ;
                        l_row_change := ' ss:AutoFitHeight="0" ss:Height="'|| g_rows(t).ht||'" '     ;
                        g_data_count := g_data_count + 1 ;
                        g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                        l_last_row := g_cells(i).r ;
                        EXIT   ;
                    ELSE
                        p( '...NO change height') ;
                        l_row_change := NULL ;
                    END IF ;

                END loop  ;

                IF l_ROW_CHANGE IS NULL THEN
                    g_data_count := g_data_count + 1 ;
                    p( '...Creating new row ');
                    g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                    l_last_row := g_cells(i).r ;
                END IF;
            END IF;


            IF g_cells(i).s IS NOT NULL THEN
                p( '...Adding style ');
                l_style := ' ss:StyleID="'||g_cells(i).s||'"' ;
            ELSE
                p( '...No style for this cell ');
                l_style := NULL ;
            END IF;

            p( '()()------------------------------------------------------------ last row '||l_last_row );
            IF g_cells(i).r <> l_last_row THEN

                p('...closing the row.'||g_cells(i).r);
                g_data_count := g_data_count + 1 ;
                g_excel_data( g_data_count ) := '  </Row>' ;

                p( 'ROWCOUNT : '||g_row_count );
                FOR t IN 1..g_ROW_count LOOP
                    p( '.....Height check => Row =' ||g_rows(t).r ||', w='||g_rows(t).w);
                    IF g_rows(t).r = g_cells(i).r AND  g_rows(t).w = g_worksheets(j).w THEN
                        p( '.....Changing height') ;
                        l_row_change := ' ss:AutoFitHeight="0" ss:Height="'|| g_rows(t).ht||'" '     ;
                            g_data_count := g_data_count + 1 ;
                            g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                        EXIT   ;
                    ELSE
                        p( '.....NO change height') ;
                        l_row_change := NULL ;
                    END IF ;

                END loop  ;
--                  P( 'Row :'||g_cells(i).r ||'->'|| l_ROW_CHANGE);
                    IF l_row_change IS NULL THEN
                        g_data_count := g_data_count + 1 ;
                        g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                    END IF;

                  IF g_cells(i).v IS NULL THEN
                      g_data_count := g_data_count + 1 ;
                      g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style ||' ></Cell>';
                  ELSE
                      g_data_count := g_data_count + 1 ;
                      ---V 1.01  Damos el formato a la celda, deacuerdo al tipo seleccionado
                      ---Estilos en comentario para moneda, fecha y numerico. Habia duplicidad de estilo.  Hay que investigar...
                      Case g_cells(i).dt
                        When t_FORMULA Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style || 'ss:Formula="'|| g_cells(i).v ||'"' ||' ></Cell>';
                        When t_MONEDA Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s99"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                        When t_FECHA Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s98"><Data ss:Type="DateTime">'||g_cells(i).v||'</Data></Cell>';
                        When t_NUMERICO Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s97"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                        When t_ALFANUMERICO Then
                          if g_cells(i).merg > 1 then
                            l_margen:= ' ss:MergeAcross="' || g_cells(i).merg ||'" ';
                          else
                            l_margen := ' ';
                          end if;
                          g_excel_data( g_data_count ) := '<Cell'||l_margen||' ss:Index="'||g_cells(i).c||'"' || l_style ||' ><Data ss:Type="String">'||g_cells(i).v||'</Data></Cell>';
                        Else
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style ||' ><Data ss:Type="String">'||g_cells(i).v||'</Data></Cell>';
                      End Case;
                  END IF;
                l_last_row :=g_cells(i).r ;
            ELSE
                IF g_cells(i).v IS NULL THEN
                    g_data_count := g_data_count + 1 ;
                    g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style ||' > </Cell>';
                ELSE
                    g_data_count := g_data_count + 1 ;
                    --Estilos en comentario para moneda, fecha y numerico. Habia duplicidad de estilo.  Hay que investigar...
                      Case g_cells(i).dt
                        When t_FORMULA Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style || 'ss:Formula="'|| g_cells(i).v ||'"' ||' ></Cell>';
                        When t_MONEDA Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s99"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                        When t_FECHA Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s98"><Data ss:Type="DateTime">'||g_cells(i).v||'</Data></Cell>';
                        When t_NUMERICO Then
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s97"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                        When t_ALFANUMERICO Then
                          if g_cells(i).merg > 1 then
                            l_margen:= ' ss:MergeAcross="' || g_cells(i).merg ||'" ';
                          else
                            l_margen := ' ';
                          end if;
                          g_excel_data( g_data_count ) := '<Cell'||l_margen||'ss:Index="'||g_cells(i).c||'"' || l_style ||' ><Data ss:Type="String">'||g_cells(i).v||'</Data></Cell>';
                        Else
                          g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style ||' ><Data ss:Type="String">'||g_cells(i).v||'</Data></Cell>';
                      End Case;
                END IF ;
            END IF ;

               END IF ;
            NULL ;
        END LOOP ; -- LOOP OF g_cells_count

            p('...closing the row.');
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := '  </Row>' ;

        -- ??? does following COMMENT will have sheet NAME FOR debugging
        p( '-------------------------------------------------------------');
        p( '....End of writing cell data, closing table tag');
        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) := '  </Table>' ;

        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) := g_worksheets(j).wftr ;
        p( '..Closed the worksheet '|| g_worksheets( j).w );
        END LOOP ;
    g_data_count := g_data_count + 1 ;
    g_excel_data( g_data_count ) := '</Workbook>' ;
        p( 'Closed the workbook tag');

    IF g_apps_env = 'N' THEN
        FOR i IN 1..g_data_count LOOP
            utl_FILE.put_line( l_file, g_excel_data(i ));
        END LOOP ;
        utl_file.fclose( l_file );
        p( 'File closed ');
    ELSIF g_apps_env = 'Y' THEN
        /*FOR i IN 1..g_data_count LOOP
            fnd_file.put_line( fnd_file.output , g_excel_data(i));
            fnd_file.put_line( fnd_file.log , g_excel_data(i));
        END LOOP ;*/
        Null;
    ELSE
        raise_application_error( -20001 , 'Env not set, ( Apps or not Apps ) Contact Support.' );
    END IF;


END ;

PROCEDURE create_worksheet ( p_worksheet_name IN VARCHAR2 ) IS
BEGIN
    g_worksheets_count := g_worksheets_count + 1 ;

    g_worksheets(g_worksheets_count).w := p_worksheet_name ;
    g_worksheets(g_worksheets_count).whdr :=  '<Worksheet ss:Name=" ' || p_worksheet_name  ||' ">' ;

    g_worksheets(g_worksheets_count).wftr := '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
       <ProtectObjects>False</ProtectObjects>
       <ProtectScenarios>False</ProtectScenarios>
      </WorksheetOptions>
     </Worksheet>' ;

END ;

---
PROCEDURE write_cell(p_row NUMBER,
                     p_column NUMBER,
                     p_worksheet_name IN VARCHAR2,
                     p_value IN VARCHAR2,
                     p_tipo_celda tipoCelda,
                     p_style IN VARCHAR2 DEFAULT NULL) IS
BEGIN

    -- CHECK IF this cell has been used previously.
    IF cell_used( p_row , p_column , p_worksheet_name ) THEN
        RAISE_application_error( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used.Check if you have missed to increment row number in your code. ');
    END IF;

    g_cell_count := g_cell_count + 1 ;
    g_cells( g_cell_count  ).r := p_row ;
    g_cells( g_cell_count  ).c := p_column ;
    g_cells( g_cell_count  ).v := p_value ;
    g_cells( g_cell_count  ).w := p_worksheet_name ;
    g_cells( g_cell_count  ).dt:= p_tipo_celda ;
    g_cells( g_cell_count  ).s := p_style ;
    g_cells (g_cell_count  ).merg:= 1;

END ;
---

PROCEDURE write_cell_char(p_row NUMBER, p_column NUMBER, p_worksheet_name IN VARCHAR2,  p_value IN VARCHAR2, p_style IN VARCHAR2 DEFAULT NULL, p_merge pls_integer default 1) IS
--l_ws_exist BOOLEAN ;
--l_worksheet VARCHAR2(2000) ;
BEGIN

    -- CHECK IF this cell has been used previously.
    IF cell_used( p_row , p_column , p_worksheet_name ) THEN
        RAISE_application_error( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used.Check if you have missed to increment row number in your code. ');
    END IF;

-- IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet A ; N ; D ; C ; F
-- this PROCEDURE just adds the data INTO the g_cells TABLE
    g_cell_count := g_cell_count + 1 ;
    g_cells( g_cell_count  ).r := p_row ;
    g_cells( g_cell_count  ).c := p_column ;
    g_cells( g_cell_count  ).v := p_value ;
    g_cells( g_cell_count  ).w := p_worksheet_name ;
    g_cells( g_cell_count  ).s := p_style ;
    --g_cells( g_cell_count  ).dt := 'String' ;
    g_cells( g_cell_count  ).dt := t_ALFANUMERICO ;
    g_cells (g_cell_count  ).merg:= p_merge;

END ;

PROCEDURE write_cell_num(p_row NUMBER ,  p_column NUMBER, p_worksheet_name IN VARCHAR2, p_value IN NUMBER , p_style IN VARCHAR2 DEFAULT NULL) IS
--l_ws_exist BOOLEAN ;
--l_worksheet VARCHAR2(2000) ;
BEGIN
--  ???  IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet
-- this PROCEDURE just adds the data INTO the g_cells TABLE
---
    -- CHECK IF this cell has been used previously.
    IF cell_used( p_row , p_column , p_worksheet_name ) THEN
        RAISE_application_error( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used. Check if you have missed to increment row number in your code.');
    END IF;

    g_cell_count := g_cell_count + 1 ;
    g_cells( g_cell_count  ).r := p_row ;
    g_cells( g_cell_count  ).c := p_column ;
    g_cells( g_cell_count  ).v := p_value ;
    g_cells( g_cell_count  ).w := p_worksheet_name ;
    g_cells( g_cell_count  ).s := p_style ;
    --g_cells( g_cell_count  ).dt := 'Number' ;
    g_cells( g_cell_count  ).dt := t_NUMERICO ;
    g_cells (g_cell_count  ).merg:= 1;

END ;
---V 1.01
PROCEDURE write_cell_formula(p_row NUMBER ,
                             p_column NUMBER,
                             p_worksheet_name IN VARCHAR2,
                             p_value IN VARCHAR2) IS
--l_ws_exist BOOLEAN ;
--l_worksheet VARCHAR2(2000) ;
BEGIN
--  ???  IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet
-- this PROCEDURE just adds the data INTO the g_cells TABLE
---
    -- CHECK IF this cell has been used previously.
    IF cell_used( p_row , p_column , p_worksheet_name ) THEN
        RAISE_application_error( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used. Check if you have missed to increment row number in your code.');
    END IF;

    g_cell_count := g_cell_count + 1 ;
    g_cells( g_cell_count  ).r := p_row ;
    g_cells( g_cell_count  ).c := p_column ;
    g_cells( g_cell_count  ).v := p_value ;
    g_cells( g_cell_count  ).w := p_worksheet_name ;
    g_cells( g_cell_count  ).dt := t_FORMULA ;

END ;
---FIN V 1.01

PROCEDURE write_cell_null(p_row NUMBER ,  p_column NUMBER , p_worksheet_name IN VARCHAR2, p_style IN VARCHAR2 ) IS
BEGIN
-- ????    NULL IS allowed here FOR time being. one OPTION IS TO warn USER that NULL IS passed but otherwise
-- the excel generates without error
    g_cell_count := g_cell_count + 1 ;
    g_cells( g_cell_count  ).r := p_row ;
    g_cells( g_cell_count  ).c := p_column ;
    g_cells( g_cell_count  ).v := null ;
    g_cells( g_cell_count  ).w := p_worksheet_name ;
    g_cells( g_cell_count  ).s := p_style ;
    g_cells( g_cell_count  ).dt := NULL ;
END ;

PROCEDURE set_row_height( p_row IN NUMBER , p_height IN NUMBER, p_worksheet IN VARCHAR2 ) IS
BEGIN
    g_ROW_count := g_ROW_count + 1 ;
    g_rows( g_row_count ).r := p_row ;
    g_rows( g_row_count ).ht := p_height ;
    g_rows( g_row_count ).w := p_worksheet ;
END ;

PROCEDURE set_column_width( p_column IN NUMBER , p_width IN NUMBER, p_worksheet IN VARCHAR2  ) IS
BEGIN
    g_column_count := g_column_count + 1 ;
    g_columns( g_column_count ).c := p_column ;
    g_columns( g_column_count ).wd := p_width ;
    g_columns( g_column_count ).w := p_worksheet ;

END ;

END gc_k_gen_xls_mrd;
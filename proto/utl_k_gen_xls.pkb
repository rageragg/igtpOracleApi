CREATE OR REPLACE PACKAGE BODY utl_k_gen_xls IS
    /*
    Fecha    : 2020-02-03
    Objetivo : Generacion de archivo excel desde PL/SQL
    Requerimiento minimo: Excel version 2003 con soporte formato XML.
    */
    --
    g_file  utl_FILE.file_type ;
    --
    g_apps_env VARCHAR2(1) := 'U' ; -- unset at the start
    --
    -- contenido de la hoja de calculo
    TYPE tbl_excel_data IS TABLE OF VARCHAR2(4096) INDEX BY BINARY_INTEGER ;
    g_excel_data    tbl_excel_data ;
    g_null_data     tbl_excel_data ;
    g_data_count    NUMBER ;
    --
    -- tipo de registro de estilos para las celdas
    TYPE rec_styles IS RECORD (
        s   VARCHAR2(30) , 
        def VARCHAR2(2000) 
    );
    --
    -- tabla de estilos
    TYPE tbl_style IS TABLE OF rec_styles  INDEX BY BINARY_INTEGER ;
    g_styles        tbl_style ;
    g_null_styles   tbl_style ;
    g_style_count   NUMBER := 0;
    --
    -- tipo hoja de trabajo
    TYPE rec_worksheets IS RECORD ( 
        w       VARCHAR2(30),   -- nombre de la hoja 
        whdr    VARCHAR2(300),  -- etiqueta de inicio de hoja
        wftr    VARCHAR2(2000)  -- etiqueta opciones de la hoja y cierre
    );
    --
    TYPE tbl_worksheets IS TABLE OF rec_worksheets  INDEX BY BINARY_INTEGER ;
    g_worksheets        tbl_worksheets ;
    g_null_worksheets   tbl_worksheets ;
    g_worksheets_count  NUMBER := 0;
    --
    -- tipo de celda
    TYPE rec_cell_data IS RECORD  ( 
        r       NUMBER ,            -- fila
        c       NUMBER ,            -- columna
        v       VARCHAR2(2000) ,    -- valor
        s       VARCHAR2(30) ,      -- estilo
        w       VARCHAR2(100),      -- hoja de trabajo
        dt      typecell,           -- tipo de dato 
        merg    pls_integer         -- cantidad de celdas a unir
    );
    --
    TYPE tbl_cell_data IS TABLE OF rec_cell_data INDEX BY binary_INTEGER ;
    g_cells         tbl_cell_data ;
    g_null_cells    tbl_cell_data ;
    g_cell_count    NUMBER := 0 ;
    --
    -- tipo de columna
    TYPE rec_columns_data IS RECORD( 
        c   NUMBER,         -- indice de columna
        wd  NUMBER,         -- ancho de columna
        w   VARCHAR2(30)    -- hoja de trabajo    
    ) ;
    --
    TYPE tbl_columns_data IS TABLE OF rec_columns_data Index BY BINARY_INTEGER ;
    g_columns       tbl_columns_data ;
    g_null_columns  tbl_columns_data ;
    g_column_count  NUMBER ;
    --
    -- tipo de fila
    TYPE rec_rows_data IS RECORD( 
        r   NUMBER,         -- indice de fila
        ht  NUMBER ,        -- altura de fila
        w   VARCHAR2(30)    -- hoja de trabajo
    ) ;
    --
    TYPE tbl_rows_data IS TABLE OF rec_rows_data Index BY BINARY_INTEGER ;
    g_rows      tbl_ROWS_data ;
    g_null_rows tbl_rows_data ;
    g_row_count NUMBER ;
    --
    /*
        Procedimiento para depuracion
    */
    PROCEDURE p( 
            p_string IN VARCHAR2
        ) IS
    BEGIN
        --
        IF debug_flag = TRUE THEN
            --
            dbms_output.put_line( p_string) ;
            --
        END IF;
        --
    END p;
    /*
        VerIFica si el estilo esta definido
    */
    FUNCTION style_defined ( 
            p_style IN VARCHAR2 
        ) RETURN BOOLEAN IS
    BEGIN
        --
        FOR i IN 1..g_style_count LOOP
            --
            IF g_styles(i).s = p_style THEN
                --
                RETURN TRUE ;
                --
            END IF;
            --
        END LOOP ;
        --
        RETURN FALSE ;
        --
    END style_defined;
    --
    /*
        VerIFica si la celda esta usada
        NOTA: Solo con proposito de ser expandida la funcion
    */
    FUNCTION cell_used ( 
            p_r IN NUMBER , 
            p_c IN NUMBER , 
            p_w IN VARCHAR2  
        ) RETURN BOOLEAN IS
    BEGIN
        --
        RETURN FALSE ;
        --
    END cell_used;
    --
    /*
        Proceso que restablecen los datos de la celda y el 
        recuento de celdas como estaba.
        Los datos se conservan en las dos ejecuciones dentro de la msisma sesión
    */
    PROCEDURE initialize_collections IS
    BEGIN
        --
        g_Cell_count        := 0;
        g_style_count       := 0;
        g_row_count         := 0;
        g_column_count      := 0;
        g_data_count        := 0;
        g_worksheets_count  := 0;
        --
        g_cells         := g_null_cells;
        g_styles        := g_null_styles ;
        g_rows          := g_null_rows ;
        g_columns       := g_null_columns ;
        g_excel_data    := g_null_data ;
        g_apps_env      := 'U';
        --
        g_worksheets := g_null_worksheets ;
        --
    END initialize_collections;
    --
    /*
        VerIFica el entorno, e inicializa las colecciones
    */
    PROCEDURE create_excel_apps is
    BEGIN
        --
        IF g_apps_env = 'N' THEN
            --
            RAISE_APPLICATION_ERROR( 
                -20001 , 
                'Ya ha llamado al procedimiento create_excel (No aplicaciones). No se puede configurar env para create_excel_apps.'
            );
            --
        END IF ;
        --
        initialize_collections ;
        --
        g_apps_env := 'Y' ;
        --
    END create_excel_apps;
    --
    /*
        Crea el documento excel en el sistema de archivos
    */
    PROCEDURE create_excel( 
            p_directory IN VARCHAR2 DEFAULT NULL,  
            p_file_name IN VARCHAR2 DEFAULT NULL 
        ) IS
        --
    BEGIN
        -- CHECK the env value
        IF g_apps_env = 'Y' THEN
            --
            RAISE_APPLICATION_ERROR( 
                -20001 , 
                'Ya ha llamado al procedimiento create_excel_apps. No se puede configurar env en create_excel que no sea de aplicaciones.'
            );
            --
        END IF ;
        --
        initialize_collections ;
        --
        g_apps_env := 'N' ;
        --
        IF ( p_directory IS NULL OR p_file_name IS NULL ) THEN
            --
            RAISE_APPLICATION_ERROR( 
                -20001 , 
                'Directorio y/o Nombre de Archivo no deben ser Nulos'
            );
            --
        END IF ;
        --
        -- control interno de archivo 
        BEGIN
            --
            -- verificamos que el archivo no este abierto
            IF NOT utl_file.is_open(g_file) THEN       
                --
                g_file := utl_file.fopen( p_directory, p_file_name , 'w', 16384) ;
                --
            END IF;
            --
            EXCEPTION
                WHEN utl_file.WRITE_ERROR THEN
                    RAISE_APPLICATION_ERROR( 
                        -20101 , 
                        'UTL_FILE - Error de Escritura. VerIFique si el archivo ya esta abierto o los permisos al directorio'
                    );
                WHEN utl_file.INVALID_OPERATION THEN
                    RAISE_APPLICATION_ERROR( 
                        -20101 , 
                        'UTL_FILE - No pudo abrir archivo u operar en el. VerIFique si el archivo ya esta abierto'
                    );
                WHEN utl_file.INVALID_PATH THEN
                    RAISE_APPLICATION_ERROR( 
                        -20101 , 
                        'UTL_FILE - Ruta invalida. VerIFique que el directorio es valido y que tiene acceso'
                    );
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR( 
                        -20101 , 
                        'UTL_FILE - Error Generico.'
                    );
        END;
        --
        -- traza de depuracion
        p( 'Archivo '||p_file_name ||' creado satisfactoriamente.');
        --
    END create_excel;
    --
    /*
        Agrega a la configuracion del documento un estilo de celda
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
        ) IS
        --
        l_font               VARCHAR2(1200);
        l_alignment          VARCHAR2(1200);
        --
    BEGIN
        /*
            Ejemplo de resultado:
            <Style ss:ID="Default" ss:Name="Normal">
                <Alignment ss:Vertical="Bottom"/>
                <Borders/>
                <Font/>
                <Interior/>
                <NumberFormat/>
                <Protection/>
            </Style>
        */
        --
        -- se verIFica que el estilo este definido
        IF style_defined( p_style_name ) THEN
            --
            RAISE_APPLICATION_ERROR( 
                -20001 , 
                'Ya el estilo '||p_style_name||' fue definido'
            );
            --
        END IF;
        --
        IF upper(p_style_name) = 'DEFAULT' THEN
            --
            RAISE_APPLICATION_ERROR( 
                -20001 , 
                'El estilo DEFAULT no es permitido definirlo nuevamente'
            );
            --
        END IF ;
        --
        IF upper(p_style_name) IS NULL  THEN
            --
            RAISE_APPLICATION_ERROR( 
                -20001 , 
                'Nombre de estilo NO PUEDE SER NULO'
            );
            --
        END IF ;
        --
        g_style_count := g_style_count + 1;
        --
        g_styles(g_style_count).s := p_style_name ;
        g_styles(g_style_count).def := ' <Style ss:ID="'||  p_style_name    ||'"> ' ;
        --
        l_font := ' <Font ' ;
        --
        IF p_fontname IS NOT NULL THEN
            l_font :=l_font || 'ss:FontName="'|| p_fontname ||'" ';
        END IF ;
        --
        IF p_fontsize IS NOT NULL THEN
            l_font := l_font ||' ss:Size="'|| p_fontsize  ||'" ';
        END IF ;
        --
        IF p_fontcolor IS NOT NULL THEN
            l_font := l_font ||' ss:Color="'|| p_fontcolor  ||'" ';
        ELSE
            l_font := l_font ||' ss:Color="Black" ';
        END IF ;
        --
        IF p_bold = TRUE THEN
            l_font := l_font ||' ss:Bold="1" ' ;
        END IF;
        --
        IF p_italic = TRUE THEN
            l_font := l_font ||' ss:Italic="1" ' ;
        END IF;
        --
        IF p_underline IS NOT NULL THEN
            l_font := l_font ||' ss:Underline="Single" ' ;
        END IF ;
        --
        g_styles(g_style_count).def :=  g_styles(g_style_count).def || l_font || '/>' ;
        --
        IF p_backcolor IS NOT NULL THEN
            g_styles(g_style_count).def :=  g_styles(g_style_count).def || ' <Interior ss:Color="'||p_backcolor ||'" ss:Pattern="Solid"/>' ;
        ELSE
            g_styles(g_style_count).def :=  g_styles(g_style_count).def || ' <Interior/>';
        END IF ;
        --
        IF p_v_alignment IS NOT NULL OR p_h_alignment IS NOT NULL THEN
            --
            l_alignment:= '<Alignment ';
            --
            IF p_v_alignment IS NOT NULL THEN
                --
                IF upper(p_v_alignment) NOT IN ('TOP','CENTER','BOTTOM') THEN
                    RAISE_APPLICATION_ERROR(
                        -20001, 
                        'El valor de alineacion vertical es incorrecto, valores correctos son: ("TOP","CENTER","BOTTOM")'
                    );
                    --
                END IF;
                --
                l_alignment:= l_alignment || 'ss:Vertical="' || p_v_alignment||'" ';
                --
            END IF;
            --
            IF p_h_alignment IS NOT NULL THEN
                --
                IF upper(p_h_alignment) not in ('LEFT','CENTER','RIGHT') THEN
                    RAISE_APPLICATION_ERROR(
                        -20001, 
                        'El valor de alineacion horizontal es incorrecto, valores correctos son: ("LEFT","CENTER","RIGHT")'
                    );
                END IF;
                --
                l_alignment:= l_alignment || 'ss:Horizontal="' || p_h_alignment||'" ';
                --
            END IF;
            --
            l_alignment:= l_alignment || '/>';
            g_styles(g_style_count).def :=  g_styles(g_style_count).def || l_alignment;
            --
        END IF;
        --
        g_styles(g_style_count).def :=  g_styles(g_style_count).def || ' </Style>' ;
        --
        p( 'Estilo '||p_style_name ||' creado satisfactoriamente.');
        --
    END create_style;
    --
    FUNCTION header_string RETURN VARCHAR2 IS 
    BEGIN
        --
        RETURN '<?xml version="1.0" encoding="ISO-8859-1"?>'||
               '<?mso-application progid="Excel.Sheet"?>'||
               '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'||
               'xmlns:o="urn:schemas-microsoft-com:office:office"'||
               'xmlns:x="urn:schemas-microsoft-com:office:excel"'||
               'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'||
               'xmlns:html="http://www.w3.org/TR/REC-html40">'||
               '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'||
               '<LastAuthor>a</LastAuthor>'||
               '<Created>1996-10-14T23:33:28Z</Created>'||
               '<LastSaved>2007-05-10T04:00:57Z</LastSaved>'||
               '<Version>11.5606</Version>'||
               '</DocumentProperties>'||
               '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'||
               '<WindowHeight>9300</WindowHeight>'||
               '<WindowWidth>15135</WindowWidth>'||
               '<WindowTopX>120</WindowTopX>'||
               '<WindowTopY>120</WindowTopY>'||
               '<AcceptLabelsInFormulas/>'||
               '<ProtectStructure>False</ProtectStructure>'||
               '<ProtectWindows>False</ProtectWindows>'||
               '</ExcelWorkbook>'||
               '<Styles>'||
               '<Style ss:ID="Default" ss:Name="Normal">'||
               ' <Alignment ss:Vertical="Bottom"/>'||
               ' <Borders/>'||
               ' <Font/>'||
               ' <Interior/>'||
               ' <NumberFormat/>'||
               ' <Protection/>'||
               '</Style>'||
               '<Style ss:ID="s999" ss:Name="Moneda">'||
               ' <NumberFormat ss:Format="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* \(#,##0.00\);_(&quot;$&quot;* &quot;-&quot;??_);_(@_)"/>'||
               '</Style>'||
               '<Style ss:ID="s99" ss:Parent="s999">'||
               ' <Font ss:FontName="Arial"/>'||
               '</Style>'||
               '<Style ss:ID="s98">'||
               ' <NumberFormat ss:Format="Short Date"/>'||
               '</Style>'||
               '<Style ss:ID="s97">'||
               ' <NumberFormat ss:Format="#,##0.00"/>'||
               '</Style>';
        --
    END header_string;
    --
    -- Cierra el documento y libera recursos
    PROCEDURE close_file  IS
        --
        l_last_row      NUMBER := 0 ;
        l_style         VARCHAR2(140) ;
        l_row_change    VARCHAR2(100) ;
        l_margen varchar2(40):= ' ss:MergeAcross="';
        --
        l_file_header VARCHAR2(2000) := 
            '<?xml version="1.0"  encoding="ISO-8859-1"?><?mso-application progid="Excel.Sheet"?>
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
        --
    BEGIN
        --
        IF g_Cell_count = 0 THEN
            --
            RAISE_APPLICATION_ERROR( -20007 , 'No cells have been written, this version of gen_xl_xml needs at least one cell to be written');
            --
        END IF;
        --
        IF g_worksheets_count = 0 THEN
            --
            RAISE_APPLICATION_ERROR( -20008 , 'No worksheets have been created, this version does not support automatic worksheet creation');
            --
        END IF;
        --
        p( 'Cabeceras');
        --
        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) :=  l_file_header ;
        --
        FOR i IN 1..g_style_count LOOP
            --
            p( ' Estilo : '||i);
            --
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := g_styles(i).def ;
            --
        END LOOP ;
        -- 
        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) := ' </Styles>' ;
        --
        p( 'Cant. Hojas de Trabajo '|| g_worksheets_count );
        --
        FOR j IN 1..g_worksheets_count LOOP
            --
            l_last_row := 0;
            --
            p( '()()------------------------------------------------------------ last row '||l_last_row );
            --
            l_row_change := NULL ;
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := ' <Worksheet ss:Name="'|| g_worksheets(j).w ||'"> ' ;

            p( '-------------------------------------------------------------');
            p( '****************.Generando Hoja '|| g_worksheets( j).w);
            p( '-------------------------------------------------------------');
            --
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := '<Table x:FullColumns="1"  x:FullRows="1">' ;
            --
            FOR i IN 1..g_column_count LOOP
                --
                IF g_columns(i).w =  g_worksheets( j).w THEN
                    --
                    g_data_count := g_data_count + 1 ;
                    g_excel_data( g_data_count ) :=  ' <Column ss:Index="'||g_columns(i).c||'" ss:AutoFitWidth="0" ss:Width="'||g_columns(i).wd ||'"/> ' ;
                    --
                END IF;
                --
            END LOOP ;
            ---------------------------------------------
            -- datos de las celdas
            ---------------------------------------------
            FOR i IN 1..g_cell_count LOOP
                --
                p( '()()()()()()()()()()()()  '|| i);
                --
                IF  g_cells(i).w <> g_worksheets(j).w  THEN
                    p( '........................Cell : W :'|| g_worksheets( j).w ||'=> r='|| g_cells(i).r ||',c ='|| g_cells(i).c||',w='|| g_cells(i).w );
                    p( '...No es de este hoja ');
                    --
                ELSE
                    --
                    p( '........................Cell : W :'|| g_worksheets( j).w ||'=> r='|| g_cells(i).r ||',c ='|| g_cells(i).c||',w='|| g_cells(i).w );
                    --
                    IF g_cells(i).s IS NOT NULL AND NOT style_defined( g_cells(i).s ) THEN
                        --
                        RAISE_APPLICATION_ERROR( -20001 , 'Style "'||g_cells(i).s ||'" is not defined, Note : Styles are case sensative and check spaces used while passing style');
                        --
                    END IF;
                    --
                    p( '()()------------------------------------------------------------ Ultima fila '||l_last_row );
                    --
                    IF l_last_row = 0 THEN
                        --
                        FOR t IN 1..g_row_count LOOP
                            --
                            p( '...chequenado altura => Row =' ||g_rows(t).r ||', w='||g_rows(t).w);
                            --
                            IF g_rows(t).r = g_cells(i).r AND  g_rows(t).w = g_worksheets(j).w THEN
                                --
                                p( '...Cambiando Altura') ;
                                --
                                l_row_change := ' ss:AutoFitHeight="0" ss:Height="'|| g_rows(t).ht||'" '     ;
                                g_data_count := g_data_count + 1 ;
                                g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                                l_last_row := g_cells(i).r ;
                                --
                                EXIT;
                                --
                            ELSE
                                --
                                p( '...NO cambia altura') ;
                                l_row_change := NULL ;
                                --
                            END IF ;
                            --
                        END LOOP;
                        --
                        IF l_ROW_CHANGE IS NULL THEN
                            --
                            g_data_count := g_data_count + 1 ;
                            --
                            p( '...Creando nueva fila');
                            --
                            g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                            l_last_row := g_cells(i).r ;
                            --
                        END IF;
                        --
                    END IF;
                    --
                    IF g_cells(i).s IS NOT NULL THEN
                        p( '...Agregando Estilo');
                        l_style := ' ss:StyleID="'||g_cells(i).s||'"' ;
                    ELSE
                        p( '...Celda sin estilo');
                        l_style := NULL ;
                    END IF;
                    --
                    p( '()()------------------------------------------------------------ Ultima Fila '||l_last_row );
                    --
                    IF g_cells(i).r <> l_last_row THEN
                        --
                        p('...closing the row.'||g_cells(i).r);
                        g_data_count := g_data_count + 1 ;
                        g_excel_data( g_data_count ) := '  </Row>' ;
                        --
                        p( 'ROWCOUNT : '||g_row_count );
                        --
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

                        END LOOP  ;
                        --
                        IF l_row_change IS NULL THEN
                            g_data_count := g_data_count + 1 ;
                            g_excel_data( g_data_count ) := ' <Row ss:Index="'||g_cells(i).r||'"'|| l_row_change  ||'>' ;
                        END IF;
                        --
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
                                When T_CURRENCY Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s99"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                                When T_DATE Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s98"><Data ss:Type="DateTime">'||g_cells(i).v||'</Data></Cell>';
                                When T_NUMERIC Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s97"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                                When T_ALFANUMERIC Then
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
                        --
                        l_last_row :=g_cells(i).r ;
                        --
                    ELSE
                        --
                        IF g_cells(i).v IS NULL THEN
                            g_data_count := g_data_count + 1 ;
                            g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style ||' > </Cell>';
                        ELSE
                            g_data_count := g_data_count + 1 ;
                            --Estilos en comentario para moneda, fecha y numerico. Habia duplicidad de estilo.  Hay que investigar...
                            Case g_cells(i).dt
                                When t_FORMULA Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'"' || l_style || 'ss:Formula="'|| g_cells(i).v ||'"' ||' ></Cell>';
                                When T_CURRENCY Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s99"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                                When T_DATE Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s98"><Data ss:Type="DateTime">'||g_cells(i).v||'</Data></Cell>';
                                When T_NUMERIC Then
                                g_excel_data( g_data_count ) := '<Cell ss:Index="'||g_cells(i).c||'" ss:StyleID="s97"><Data ss:Type="Number">'||g_cells(i).v||'</Data></Cell>';
                                When T_ALFANUMERIC Then
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
                        --
                    END IF ;

                END IF ;
                --
            END LOOP ; -- LOOP OF g_cells_count

            p('...closing the row.');
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := '  </Row>' ;
            --
            -- ??? does following COMMENT will have sheet NAME FOR debugging
            p( '-------------------------------------------------------------');
            p( '....End of writing cell data, closing table tag');
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := '  </Table>' ;
            --
            g_data_count := g_data_count + 1 ;
            g_excel_data( g_data_count ) := g_worksheets(j).wftr ;
            p( '..Closed the worksheet '|| g_worksheets( j).w );
            --
        END LOOP ;
        --
        g_data_count := g_data_count + 1 ;
        g_excel_data( g_data_count ) := '</Workbook>' ;
        --
        p( 'Closed the workbook tag');
        --
        IF g_apps_env = 'N' THEN
            --
            FOR i IN 1..g_data_count LOOP
                utl_FILE.put_line( g_file, g_excel_data(i ));
            END LOOP ;
            --
            utl_file.fclose( g_file );
            --
            p( 'File closed ');
            --
        ELSIF g_apps_env = 'Y' THEN
            --
            NULL;
            --
        ELSE
            RAISE_APPLICATION_ERROR( -20001 , 'Env not set, ( Apps or not Apps ) Contact Support.' );
        END IF;
        --
    END close_file;
    /*
        Crea una hoja de trabajo
    */
    PROCEDURE create_worksheet ( p_worksheet_name IN VARCHAR2 ) IS
    BEGIN
        -- 
        -- contador de hojas en el libro
        g_worksheets_count := g_worksheets_count + 1 ;
        --
        -- se establece el nombre del archivo
        g_worksheets(g_worksheets_count).w := p_worksheet_name ;
        --
        -- se crea la primera etiqueta XML, descripcion de la hoja
        g_worksheets(g_worksheets_count).whdr :=  '<Worksheet ss:Name=" ' || p_worksheet_name  ||' ">' ;
        --
        -- cierre de etiqueta 
        g_worksheets(g_worksheets_count).wftr := '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' ||
                                                 '<ProtectObjects>False</ProtectObjects>' ||
                                                 '<ProtectScenarios>False</ProtectScenarios>' ||
                                                 '</WorksheetOptions>' ||
                                                 '</Worksheet>' ;
        --
    END create_worksheet;
    --
    -- Se escribe una celda
    PROCEDURE write_cell(
            p_row               IN NUMBER,
            p_column            IN NUMBER,
            p_worksheet_name    IN VARCHAR2,
            p_value             IN VARCHAR2,
            p_type_cell         IN typecell,
            p_style             IN VARCHAR2 DEFAULT NULL
        ) IS
    BEGIN
        --
        -- se verifica si la celda es usada
        IF cell_used( p_row , p_column , p_worksheet_name ) THEN
            RAISE_APPLICATION_ERROR( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used.Check IF you have missed to increment row NUMBER in your code. ');
        END IF;
        --
        g_cell_count := g_cell_count + 1 ;
        g_cells( g_cell_count  ).r := p_row ;
        g_cells( g_cell_count  ).c := p_column ;
        g_cells( g_cell_count  ).v := p_value ;
        g_cells( g_cell_count  ).w := p_worksheet_name ;
        g_cells( g_cell_count  ).dt:= p_type_cell ;
        g_cells( g_cell_count  ).s := p_style ;
        g_cells (g_cell_count  ).merg:= 1;
        --
    END write_cell;
    --
    -- Se escribe una celda de tipo caracter
    PROCEDURE write_cell_char(
            p_row               IN NUMBER, 
            p_column            IN NUMBER, 
            p_worksheet_name    IN VARCHAR2,  
            p_value             IN VARCHAR2, 
            p_style             IN VARCHAR2 DEFAULT NULL, 
            p_merge             IN PLS_INTEGER DEFAULT 1
        ) IS
    BEGIN
        --
        -- Se verifica que no sea usada
        IF cell_used( p_row , p_column , p_worksheet_name ) THEN
            RAISE_APPLICATION_ERROR( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used.Check IF you have missed to increment row NUMBER in your code. ');
        END IF;
        --
        g_cell_count := g_cell_count + 1 ;
        g_cells( g_cell_count  ).r := p_row ;
        g_cells( g_cell_count  ).c := p_column ;
        g_cells( g_cell_count  ).v := p_value ;
        g_cells( g_cell_count  ).w := p_worksheet_name ;
        g_cells( g_cell_count  ).s := p_style ;
        g_cells( g_cell_count  ).dt := T_ALFANUMERIC ;
        g_cells (g_cell_count  ).merg:= p_merge;
        --
    END write_cell_char;
    --
    PROCEDURE write_cell_num(
            p_row            IN NUMBER,  
            p_column         IN NUMBER, 
            p_worksheet_name IN VARCHAR2, 
            p_value          IN NUMBER, 
            p_style          IN VARCHAR2 DEFAULT NULL
        ) IS
        --l_ws_exist BOOLEAN ;
        --l_worksheet VARCHAR2(2000) ;
    BEGIN
        -- ???  IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet
        -- this PROCEDURE just adds the data INTO the g_cells TABLE
        --
        -- CHECK IF this cell has been used previously.
        IF cell_used( p_row , p_column , p_worksheet_name ) THEN
            RAISE_APPLICATION_ERROR( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used. Check IF you have missed to increment row NUMBER in your code.');
        END IF;

        g_cell_count := g_cell_count + 1 ;
        g_cells( g_cell_count  ).r := p_row ;
        g_cells( g_cell_count  ).c := p_column ;
        g_cells( g_cell_count  ).v := p_value ;
        g_cells( g_cell_count  ).w := p_worksheet_name ;
        g_cells( g_cell_count  ).s := p_style ;
        g_cells( g_cell_count  ).dt := T_NUMERIC ;
        g_cells (g_cell_count  ).merg:= 1;

    END write_cell_num;
    --
    ---V 1.01
    PROCEDURE write_cell_formula(
            p_row               IN NUMBER ,
            p_column            IN NUMBER,
            p_worksheet_name    IN VARCHAR2,
            p_value             IN VARCHAR2
        ) IS
        --l_ws_exist BOOLEAN ;
        --l_worksheet VARCHAR2(2000) ;
    BEGIN
        -- ???  IF worksheet NAME IS NOT passed THEN use first USER created sheet ELSE use DEFAULT sheet
        -- this PROCEDURE just adds the data INTO the g_cells TABLE
        --
        -- CHECK IF this cell has been used previously.
        IF cell_used( p_row , p_column , p_worksheet_name ) THEN
            RAISE_APPLICATION_ERROR( -20001 , 'The cell ( Row: '||p_row ||' Column:'||p_column ||' Worksheet:'||p_worksheet_name ||') is already used. Check IF you have missed to increment row NUMBER in your code.');
        END IF;
        --
        g_cell_count := g_cell_count + 1 ;
        g_cells( g_cell_count  ).r := p_row ;
        g_cells( g_cell_count  ).c := p_column ;
        g_cells( g_cell_count  ).v := p_value ;
        g_cells( g_cell_count  ).w := p_worksheet_name ;
        g_cells( g_cell_count  ).dt := t_FORMULA ;
        --
    END write_cell_formula;
    --
    PROCEDURE write_cell_null(
            p_row               IN NUMBER ,  
            p_column            IN NUMBER , 
            p_worksheet_name    IN VARCHAR2, 
            p_style             IN VARCHAR2 
        ) IS
    BEGIN
        -- 
        g_cell_count := g_cell_count + 1 ;
        g_cells( g_cell_count  ).r := p_row ;
        g_cells( g_cell_count  ).c := p_column ;
        g_cells( g_cell_count  ).v := NULL ;
        g_cells( g_cell_count  ).w := p_worksheet_name ;
        g_cells( g_cell_count  ).s := p_style ;
        g_cells( g_cell_count  ).dt := NULL ;
        --
    END write_cell_null;
    --
    PROCEDURE set_row_height( 
            p_row       IN NUMBER , 
            p_height    IN NUMBER, 
            p_worksheet IN VARCHAR2 
        ) IS
    BEGIN
        --
        g_row_count := g_row_count + 1 ;
        g_rows( g_row_count ).r := p_row ;
        g_rows( g_row_count ).ht := p_height ;
        g_rows( g_row_count ).w := p_worksheet ;
        --
    END set_row_height;
    --
    PROCEDURE set_column_width( 
            p_column    IN NUMBER, 
            p_width     IN NUMBER, 
            p_worksheet IN VARCHAR2
        ) IS
    BEGIN
        --
        g_column_count := g_column_count + 1 ;
        g_columns( g_column_count ).c := p_column ;
        g_columns( g_column_count ).wd := p_width ;
        g_columns( g_column_count ).w := p_worksheet ;
        --
    END set_column_width;
    --
END utl_k_gen_xls;
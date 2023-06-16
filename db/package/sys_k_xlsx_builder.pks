CREATE OR REPLACE PACKAGE sys_k_xlsx_builder AUTHID CURRENT_USER AS
    /*
        ******************************************************************************
        **
        ** Author: Anton Scheffer
        ** Date: 19-02-2011
        ** Website: http://technology.amis.nl/blog
        ** See also: http://technology.amis.nl/blog/?p=10995
        ** See also: https://technology.amis.nl/2011/02/19/create-an-excel-file-with-plsql/
        **
        ** Changelog:
        **   Date: 21-02-2011   Added Aligment, horizontal, vertical, wrapText
        **   Date: 06-03-2011   Added Comments, MergeCells, fixed bug for dependency on NLS-settings
        **   Date: 16-03-2011   Added bold and italic fonts
        **   Date: 22-03-2011   Fixed issue with timezone's set to a region(name) instead of a offset
        **   Date: 08-04-2011   Fixed issue with XML-escaping from text
        **   Date: 27-05-2011   Added MIT-license
        **   Date: 11-08-2011   Fixed NLS-issue with column width
        **   Date: 29-09-2011   Added font color
        **   Date: 16-10-2011   fixed bug in add_string
        **   Date: 26-04-2012   Fixed set_autofilter (only one autofilter per sheet, added _xlnm._FilterDatabase)
                                Added list_validation = drop-down 
        **   Date: 27-08-2013   Added freeze_pane
        **
        ******************************************************************************
        Copyright (C) 2011, 2012 by Anton Scheffer

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in
        all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
        THE SOFTWARE.
        ******************************************************************************
    */
    --
    TYPE tp_alignment IS RECORD( 
        vertical    VARCHAR2(11), 
        horizontal  VARCHAR2(16), 
        wrapText    BOOLEAN
    );
    --
    PROCEDURE clear_workbook;
    --
    PROCEDURE new_sheet( p_sheetname VARCHAR2 := NULL );
    --
    FUNCTION OraFmt2Excel( p_format VARCHAR2 := NULL ) RETURN VARCHAR2;
    --
    FUNCTION get_numFmt( p_format VARCHAR2 := NULL ) RETURN PLS_INTEGER;
    --
    FUNCTION get_font( p_name       VARCHAR2,
                       p_family     PLS_INTEGER := 2,
                       p_fontsize   NUMBER := 11,
                       p_theme      PLS_INTEGER := 1,
                       p_underline  BOOLEAN := FALSE,
                       p_italic     BOOLEAN := FALSE,
                       p_bold       BOOLEAN := FALSE,
                       p_rgb        VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
                     ) RETURN PLS_INTEGER;
    --
    FUNCTION get_fill( p_patternType VARCHAR2, 
                       p_fgRGB       VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
                     ) RETURN PLS_INTEGER;
    --
    /*  Valores para: get_border
        none
        thin
        medium
        dashed
        dotted
        thick
        double
        hair
        mediumDashed
        dashDot
        mediumDashDot
        dashDotDot
        mediumDashDotDot
        slantDashDot
    */
    FUNCTION get_border( p_top      VARCHAR2 := 'thin', 
                         p_bottom   VARCHAR2 := 'thin', 
                         p_left     VARCHAR2 := 'thin', 
                         p_right    VARCHAR2 := 'thin'
                       ) RETURN PLS_INTEGER;
    --
    /*  Valores: get_alignment
        horizontal
        center
        centerContinuous
        distributed
        fill
        general
        justify
        left
        right
    */
    /*  vertical
        bottom
        center
        distributed
        justify
        top
    */
    FUNCTION get_alignment( p_vertical      VARCHAR2 := NULL, 
                            p_horizontal    VARCHAR2 := NULL, 
                            p_wrapText      BOOLEAN  := NULL
                          ) RETURN tp_alignment;
    --
    PROCEDURE cell( p_col           PLS_INTEGER, 
                    p_row           PLS_INTEGER, 
                    p_value         NUMBER, 
                    p_numFmtId      PLS_INTEGER := NULL, 
                    p_fontId        PLS_INTEGER := NULL, 
                    p_fillId        PLS_INTEGER := NULL, 
                    p_borderId      PLS_INTEGER := NULL, 
                    p_alignment     tp_alignment := NULL, 
                    p_sheet         PLS_INTEGER := NULL
                 );
    --
    PROCEDURE cell( p_col       PLS_INTEGER, 
                    p_row       PLS_INTEGER, 
                    p_value     VARCHAR2, 
                    p_numFmtId  PLS_INTEGER := NULL, 
                    p_fontId    PLS_INTEGER := NULL, 
                    p_fillId    PLS_INTEGER := NULL, 
                    p_borderId  PLS_INTEGER := NULL, 
                    p_alignment tp_alignment := NULL, 
                    p_sheet     PLS_INTEGER := NULL
                  );
    --
    PROCEDURE cell
        ( p_col PLS_INTEGER
        , p_row PLS_INTEGER
        , p_value date
        , p_numFmtId PLS_INTEGER := NULL
        , p_fontId PLS_INTEGER := NULL
        , p_fillId PLS_INTEGER := NULL
        , p_borderId PLS_INTEGER := NULL
        , p_alignment tp_alignment := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE hyperlink
        ( p_col PLS_INTEGER
        , p_row PLS_INTEGER
        , p_url VARCHAR2
        , p_value VARCHAR2 := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE comment
        ( p_col PLS_INTEGER
        , p_row PLS_INTEGER
        , p_text VARCHAR2
        , p_author VARCHAR2 := NULL
        , p_width PLS_INTEGER := 150  -- pixels
        , p_height PLS_INTEGER := 100  -- pixels
        , p_sheet PLS_INTEGER := NULL
        );
--
  PROCEDURE mergecells
    ( p_tl_col PLS_INTEGER -- top left
    , p_tl_row PLS_INTEGER
    , p_br_col PLS_INTEGER -- bottom right
    , p_br_row PLS_INTEGER
    , p_sheet PLS_INTEGER := NULL
    );
    --
    PROCEDURE list_validation
        ( p_sqref_col PLS_INTEGER
        , p_sqref_row PLS_INTEGER
        , p_tl_col PLS_INTEGER -- top left
        , p_tl_row PLS_INTEGER
        , p_br_col PLS_INTEGER -- bottom right
        , p_br_row PLS_INTEGER
        , p_style VARCHAR2 := 'stop' -- stop, warning, information
        , p_title VARCHAR2 := NULL
        , p_prompt varchar := NULL
        , p_show_error BOOLEAN := FALSE
        , p_error_title VARCHAR2 := NULL
        , p_error_txt VARCHAR2 := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE list_validation
        ( p_sqref_col PLS_INTEGER
        , p_sqref_row PLS_INTEGER
        , p_defined_name VARCHAR2
        , p_style VARCHAR2 := 'stop' -- stop, warning, information
        , p_title VARCHAR2 := NULL
        , p_prompt varchar := NULL
        , p_show_error BOOLEAN := FALSE
        , p_error_title VARCHAR2 := NULL
        , p_error_txt VARCHAR2 := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE defined_name
        ( p_tl_col PLS_INTEGER -- top left
        , p_tl_row PLS_INTEGER
        , p_br_col PLS_INTEGER -- bottom right
        , p_br_row PLS_INTEGER
        , p_name VARCHAR2
        , p_sheet PLS_INTEGER := NULL
        , p_localsheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE set_column_width
        ( p_col PLS_INTEGER
        , p_width NUMBER
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE set_column
        ( p_col PLS_INTEGER
        , p_numFmtId PLS_INTEGER := NULL
        , p_fontId PLS_INTEGER := NULL
        , p_fillId PLS_INTEGER := NULL
        , p_borderId PLS_INTEGER := NULL
        , p_alignment tp_alignment := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE set_row
        ( p_row PLS_INTEGER
        , p_numFmtId PLS_INTEGER := NULL
        , p_fontId PLS_INTEGER := NULL
        , p_fillId PLS_INTEGER := NULL
        , p_borderId PLS_INTEGER := NULL
        , p_alignment tp_alignment := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
  PROCEDURE freeze_rows
    ( p_nr_rows PLS_INTEGER := 1
    , p_sheet PLS_INTEGER := NULL
    );
    --
    PROCEDURE freeze_cols
        ( p_nr_cols PLS_INTEGER := 1
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE freeze_pane
        ( p_col PLS_INTEGER
        , p_row PLS_INTEGER
        , p_sheet PLS_INTEGER := NULL
        );
    --
    PROCEDURE set_autofilter
        ( p_column_start PLS_INTEGER := NULL
        , p_column_end PLS_INTEGER := NULL
        , p_row_start PLS_INTEGER := NULL
        , p_row_end PLS_INTEGER := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --
    FUNCTION finish RETURN blob;
    --
    PROCEDURE save
        ( p_directory VARCHAR2
        , p_filename VARCHAR2
        );
    --
    PROCEDURE query2sheet
        ( p_sql VARCHAR2
        , p_column_headers BOOLEAN := true
        , p_directory VARCHAR2 := NULL
        , p_filename VARCHAR2 := NULL
        , p_sheet PLS_INTEGER := NULL
        );
    --    
END sys_k_xlsx_builder;
/

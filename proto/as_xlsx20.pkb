CREATE OR REPLACE PACKAGE BODY as_xlsx IS
    --
    C_VERSION constant VARCHAR2(20) := 'as_xlsx20';
    --
    C_LOCAL_FILE_HEADER        CONSTANT RAW(4) := hextoraw( '504B0304' ); -- Local file header signature
    c_END_OF_CENTRAL_DIRECTORY CONSTANT RAW(4) := hextoraw( '504B0506' ); -- End of central directory signature
    --
    SUBTYPE tp_author IS VARCHAR2(32767 CHAR);
    --
    TYPE tp_XF_fmt IS RECORD( 
      numFmtId  PLS_INTEGER,
      fontId    PLS_INTEGER,
      fillId    PLS_INTEGER,
      borderId  PLS_INTEGER,
      alignment tp_alignment,
      height    NUMBER
    );
    --
    TYPE tp_col_fmts  IS TABLE OF tp_XF_fmt INDEX BY PLS_INTEGER;
    TYPE tp_row_fmts  IS TABLE OF tp_XF_fmt INDEX BY PLS_INTEGER;
    TYPE tp_widths    IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    --
    TYPE tp_cell IS RECORD( 
      value       NUMBER,
      style       VARCHAR2(50),
      formula_idx PLS_INTEGER
    );
    --
    TYPE tp_cells IS TABLE OF tp_cell INDEX BY PLS_INTEGER;
    TYPE tp_rows  IS TABLE OF tp_cells INDEX BY PLS_INTEGER;
    --
    TYPE tp_autofilter IS RECORD( 
      column_start  PLS_INTEGER,
      column_end    PLS_INTEGER,
      row_start     PLS_INTEGER,
      row_end       PLS_INTEGER
    );
    --
    TYPE tp_autofilters IS TABLE OF tp_autofilter INDEX BY PLS_INTEGER;
    TYPE tp_hyperlink IS RECORD( 
      cell VARCHAR2(10),
      url  VARCHAR2(1000)
    );
    --
  TYPE tp_hyperlinks  IS TABLE OF tp_hyperlink INDEX BY PLS_INTEGER;
  TYPE tp_authors     IS TABLE OF PLS_INTEGER INDEX BY tp_author;
  TYPE tp_formulas    IS TABLE OF VARCHAR2(32767) INDEX BY PLS_INTEGER;
  --
  authors tp_authors;
  --
  TYPE tp_comment IS RECORD( 
    text    VARCHAR2(32767 char),
    author  tp_author,
    row     PLS_INTEGER,
    column  PLS_INTEGER,
    width   PLS_INTEGER,
    height  PLS_INTEGER
  );
    --
  TYPE tp_comments    IS TABLE OF tp_comment INDEX BY PLS_INTEGER;
  TYPE tp_mergecells  IS TABLE OF VARCHAR2(21) INDEX BY PLS_INTEGER;
  --
  TYPE tp_validation IS RECORD
    ( TYPE VARCHAR2(10)
    , errorstyle VARCHAR2(32)
    , showinputmessage boolean
    , prompt VARCHAR2(32767 char)
    , title VARCHAR2(32767 char)
    , error_title VARCHAR2(32767 char)
    , error_txt VARCHAR2(32767 char)
    , showerrormessage boolean
    , formula1 VARCHAR2(32767 char)
    , formula2 VARCHAR2(32767 char)
    , allowBlank boolean
    , sqref VARCHAR2(32767 char)
    );
  TYPE tp_validations IS TABLE OF tp_validation INDEX BY PLS_INTEGER;
  TYPE tp_sheet IS RECORD
    ( rows tp_rows
    , widths tp_widths
    , name VARCHAR2(100)
    , freeze_rows PLS_INTEGER
    , freeze_cols PLS_INTEGER
    , autofilters tp_autofilters
    , hyperlinks tp_hyperlinks
    , col_fmts tp_col_fmts
    , row_fmts tp_row_fmts
    , comments tp_comments
    , mergecells tp_mergecells
    , validations tp_validations
    , tabcolor VARCHAR2(8)
    , fontid PLS_INTEGER
    );
  TYPE tp_sheets IS TABLE OF tp_sheet INDEX BY PLS_INTEGER;
  TYPE tp_numFmt IS RECORD
    ( numFmtId PLS_INTEGER
    , formatCode VARCHAR2(100)
    );
  TYPE tp_numFmts IS TABLE OF tp_numFmt INDEX BY PLS_INTEGER;
  TYPE tp_fill IS RECORD
    ( patternTYPE VARCHAR2(30)
    , fgRGB VARCHAR2(8)
    , bgRGB VARCHAR2(8)
    );
  TYPE tp_fills IS TABLE OF tp_fill INDEX BY PLS_INTEGER;
  TYPE tp_cellXfs IS TABLE OF tp_xf_fmt INDEX BY PLS_INTEGER;
  TYPE tp_font IS RECORD
    ( name VARCHAR2(100)
    , family PLS_INTEGER
    , fontsize NUMBER
    , theme PLS_INTEGER
    , RGB VARCHAR2(8)
    , underline boolean
    , italic boolean
    , bold boolean
    );
  TYPE tp_fonts IS TABLE OF tp_font INDEX BY PLS_INTEGER;
  TYPE tp_border IS RECORD
    ( top VARCHAR2(17)
    , bottom VARCHAR2(17)
    , left VARCHAR2(17)
    , right VARCHAR2(17)
    );
  TYPE tp_borders IS TABLE OF tp_border INDEX BY PLS_INTEGER;
  TYPE tp_numFmtIndexes IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  TYPE tp_strings IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(32767 char);
  TYPE tp_str_ind IS TABLE OF VARCHAR2(32767 char) INDEX BY PLS_INTEGER;
  TYPE tp_defined_name IS RECORD
    ( name VARCHAR2(32767 char)
    , ref VARCHAR2(32767 char)
    , sheet PLS_INTEGER
    );
  TYPE tp_defined_names IS TABLE OF tp_defined_name INDEX BY PLS_INTEGER;
  TYPE tp_book IS RECORD
    ( sheets tp_sheets
    , strings tp_strings
    , str_ind tp_str_ind
    , str_cnt PLS_INTEGER := 0
    , fonts tp_fonts
    , fills tp_fills
    , borders tp_borders
    , numFmts tp_numFmts
    , cellXfs tp_cellXfs
    , numFmtIndexes tp_numFmtIndexes
    , defined_names tp_defined_names
    , formulas tp_formulas
    , fontid PLS_INTEGER
    );
  workbook tp_book;
  --
  g_useXf boolean := TRUE;
  --
  g_addtxt2utf8blob_tmp VARCHAR2(32767);
  --
  PROCEDURE addtxt2utf8blob_init( p_blob IN OUT NOCOPY BLOB ) IS
  BEGIN
    --
    g_addtxt2utf8blob_tmp := NULL;
    dbms_lob.createtemporary( p_blob, TRUE );
    --
  END addtxt2utf8blob_init;
  --
  PROCEDURE addtxt2utf8blob_finish( p_blob IN OUT NOCOPY BLOB ) IS
    t_raw raw(32767);
  BEGIN
    --
    t_raw := utl_i18n.string_to_raw( g_addtxt2utf8blob_tmp, 'AL32UTF8' );
    dbms_lob.writeappend( p_blob, utl_raw.length( t_raw ), t_raw );
    --
  EXCEPTION
    WHEN VALUE_ERROR THEN
        --
        t_raw := utl_i18n.string_to_raw( substr( g_addtxt2utf8blob_tmp, 1, 16381 ), 'AL32UTF8' );
        dbms_lob.writeappend( p_blob, utl_raw.length( t_raw ), t_raw );
        t_raw := utl_i18n.string_to_raw( substr( g_addtxt2utf8blob_tmp, 16382 ), 'AL32UTF8' );
        dbms_lob.writeappend( p_blob, utl_raw.length( t_raw ), t_raw );
        --
  END addtxt2utf8blob_finish;
  --
  PROCEDURE addtxt2utf8blob( p_txt VARCHAR2, p_blob IN OUT NOCOPY BLOB ) IS
  BEGIN
    g_addtxt2utf8blob_tmp := g_addtxt2utf8blob_tmp || p_txt;
  EXCEPTION
    WHEN VALUE_ERROR
    then
      addtxt2utf8blob_finish( p_blob );
      g_addtxt2utf8blob_tmp := p_txt;
  end;
  --
  PROCEDURE blob2file( 
      p_blob        BLOB
      p_directory   VARCHAR2 := 'MY_DIR'
      p_filename    VARCHAR2 := 'my.xlsx'
    ) IS
    --
    t_fh    utl_file.file_type;
    t_len   PLS_INTEGER := 32767;
    --
  BEGIN
    --
    t_fh := utl_file.fopen( 
      p_directory,
      p_filename,
      'wb'
    );
    --
    FOR i in 0 .. trunc( ( dbms_lob.getlength( p_blob ) - 1 ) / t_len ) LOOP
      --
      utl_file.put_raw( 
        t_fh
        dbms_lob.substr( 
          p_blob,
          t_len,
          i * t_len + 1,
        )
      );
      --
    END LOOP;
    --
    utl_file.fclose( t_fh );
    --
  END blob2file;
--
  function raw2num( p_raw raw, p_len integer, p_pos integer )
  return NUMBER
  is
  BEGIN
    return utl_raw.cast_to_binary_integer( utl_raw.substr( p_raw, p_pos, p_len ), utl_raw.little_endian );
  end;
--
  function little_endian( p_big NUMBER, p_bytes PLS_INTEGER := 4 )
  return raw
  is
  BEGIN
    return utl_raw.substr( utl_raw.cast_from_binary_integer( p_big, utl_raw.little_endian ), 1, p_bytes );
  end;
--
  function blob2num( p_blob blob, p_len integer, p_pos integer )
  return NUMBER
  is
  BEGIN
    return utl_raw.cast_to_binary_integer( dbms_lob.substr( p_blob, p_len, p_pos ), utl_raw.little_endian );
  end;
--
  PROCEDURE add1file
    ( p_zipped_blob in out blob
    , p_name VARCHAR2
    , p_content blob
    )
  is
    t_now date;
    t_blob blob;
    t_len integer;
    t_clen integer;
    t_crc32 raw(4) := hextoraw( '00000000' );
    t_compressed boolean := false;
    t_name raw(32767);
  BEGIN
    t_now := sysdate;
    t_len := nvl( dbms_lob.getlength( p_content ), 0 );
    if t_len > 0
    then
      t_blob := utl_compress.lz_compress( p_content );
      t_clen := dbms_lob.getlength( t_blob ) - 18;
      t_compressed := t_clen < t_len;
      t_crc32 := dbms_lob.substr( t_blob, 4, t_clen + 11 );
    end if;
    if not t_compressed
    then
      t_clen := t_len;
      t_blob := p_content;
    end if;
    if p_zipped_blob is NULL
    then
      dbms_lob.createtemporary( p_zipped_blob, TRUE );
    end if;
    t_name := utl_i18n.string_to_raw( p_name, 'AL32UTF8' );
    dbms_lob.append( p_zipped_blob
                   , utl_raw.concat( C_LOCAL_FILE_HEADER -- Local file header signature
                                   , hextoraw( '1400' )  -- version 2.0
                                   , case when t_name = utl_i18n.string_to_raw( p_name, 'US8PC437' )
                                       then hextoraw( '0000' ) -- no General purpose bits
                                       else hextoraw( '0008' ) -- set Language encoding flag (EFS)
                                     end
                                   , case when t_compressed
                                        then hextoraw( '0800' ) -- deflate
                                        else hextoraw( '0000' ) -- stored
                                     end
                                   , little_endian( to_number( to_char( t_now, 'ss' ) ) / 2
                                                  + to_number( to_char( t_now, 'mi' ) ) * 32
                                                  + to_number( to_char( t_now, 'hh24' ) ) * 2048
                                                  , 2
                                                  ) -- File last modification time
                                   , little_endian( to_number( to_char( t_now, 'dd' ) )
                                                  + to_number( to_char( t_now, 'mm' ) ) * 32
                                                  + ( to_number( to_char( t_now, 'yyyy' ) ) - 1980 ) * 512
                                                  , 2
                                                  ) -- File last modification date
                                   , t_crc32 -- CRC-32
                                   , little_endian( t_clen )                      -- compressed size
                                   , little_endian( t_len )                       -- uncompressed size
                                   , little_endian( utl_raw.length( t_name ), 2 ) -- File name length
                                   , hextoraw( '0000' )                           -- Extra field length
                                   , t_name                                       -- File name
                                   )
                   );
    if t_compressed
    then
      dbms_lob.copy( p_zipped_blob, t_blob, t_clen, dbms_lob.getlength( p_zipped_blob ) + 1, 11 ); -- compressed content
    elsif t_clen > 0
    then
      dbms_lob.copy( p_zipped_blob, t_blob, t_clen, dbms_lob.getlength( p_zipped_blob ) + 1, 1 ); --  content
    end if;
    if dbms_lob.istemporary( t_blob ) = 1
    then
      dbms_lob.freetemporary( t_blob );
    end if;
  end;
--
  PROCEDURE finish_zip( p_zipped_blob in out blob )
  is
    t_cnt PLS_INTEGER := 0;
    t_offs integer;
    t_offs_dir_header integer;
    t_offs_end_header integer;
    t_comment raw(200) := utl_raw.cast_to_raw( 'Implementation by Anton Scheffer, ' || C_VERSION );
  BEGIN
    t_offs_dir_header := dbms_lob.getlength( p_zipped_blob );
    t_offs := 1;
    while dbms_lob.substr( p_zipped_blob, utl_raw.length( C_LOCAL_FILE_HEADER ), t_offs ) = C_LOCAL_FILE_HEADER
    loop
      t_cnt := t_cnt + 1;
      dbms_lob.append( p_zipped_blob
                     , utl_raw.concat( hextoraw( '504B0102' )      -- Central directory file header signature
                                     , hextoraw( '1400' )          -- version 2.0
                                     , dbms_lob.substr( p_zipped_blob, 26, t_offs + 4 )
                                     , hextoraw( '0000' )          -- File comment length
                                     , hextoraw( '0000' )          -- Disk NUMBER where file starts
                                     , hextoraw( '0000' )          -- Internal file attributes =>
                                                                   --     0000 binary file
                                                                   --     0100 (ascii)text file
                                     , case
                                         when dbms_lob.substr( p_zipped_blob
                                                             , 1
                                                             , t_offs + 30 + blob2num( p_zipped_blob, 2, t_offs + 26 ) - 1
                                                             ) in ( hextoraw( '2F' ) -- /
                                                                  , hextoraw( '5C' ) -- \
                                                                  )
                                         then hextoraw( '10000000' ) -- a directory/folder
                                         else hextoraw( '2000B681' ) -- a file
                                       end                         -- External file attributes
                                     , little_endian( t_offs - 1 ) -- Relative offset of local file header
                                     , dbms_lob.substr( p_zipped_blob
                                                      , blob2num( p_zipped_blob, 2, t_offs + 26 )
                                                      , t_offs + 30
                                                      )            -- File name
                                     )
                     );
      t_offs := t_offs + 30 + blob2num( p_zipped_blob, 4, t_offs + 18 )  -- compressed size
                            + blob2num( p_zipped_blob, 2, t_offs + 26 )  -- File name length
                            + blob2num( p_zipped_blob, 2, t_offs + 28 ); -- Extra field length
    end loop;
    t_offs_end_header := dbms_lob.getlength( p_zipped_blob );
    dbms_lob.append( p_zipped_blob
                   , utl_raw.concat( c_END_OF_CENTRAL_DIRECTORY                                -- End of central directory signature
                                   , hextoraw( '0000' )                                        -- NUMBER of this disk
                                   , hextoraw( '0000' )                                        -- Disk where central directory starts
                                   , little_endian( t_cnt, 2 )                                 -- NUMBER of central directory records on this disk
                                   , little_endian( t_cnt, 2 )                                 -- Total NUMBER of central directory records
                                   , little_endian( t_offs_end_header - t_offs_dir_header )    -- Size of central directory
                                   , little_endian( t_offs_dir_header )                        -- Offset of start of central directory, relative to start of archive
                                   , little_endian( nvl( utl_raw.length( t_comment ), 0 ), 2 ) -- ZIP file comment length
                                   , t_comment
                                   )
                   );
  end;
--
  function alfan_col( p_col PLS_INTEGER )
  return VARCHAR2
  is
  BEGIN
    return case
             when p_col > 702 then chr( 64 + trunc( ( p_col - 27 ) / 676 ) ) || chr( 65 + mod( trunc( ( p_col - 1 ) / 26 ) - 1, 26 ) ) || chr( 65 + mod( p_col - 1, 26 ) )
             when p_col > 26  then chr( 64 + trunc( ( p_col - 1 ) / 26 ) ) || chr( 65 + mod( p_col - 1, 26 ) )
             else chr( 64 + p_col )
           end;
  end;
--
  function col_alfan( p_col VARCHAR2 )
  return PLS_INTEGER
  is
  BEGIN
    return ascii( substr( p_col, -1 ) ) - 64
         + nvl( ( ascii( substr( p_col, -2, 1 ) ) - 64 ) * 26, 0 )
         + nvl( ( ascii( substr( p_col, -3, 1 ) ) - 64 ) * 676, 0 );
  end;
--
  PROCEDURE clear_workbook
  is
    s PLS_INTEGER;
    t_row_ind PLS_INTEGER;
  BEGIN
    s := workbook.sheets.first;
    while s is not NULL
    loop
      t_row_ind := workbook.sheets( s ).rows.first();
      while t_row_ind is not NULL
      loop
        workbook.sheets( s ).rows( t_row_ind ).delete();
        t_row_ind := workbook.sheets( s ).rows.next( t_row_ind );
      end loop;
      workbook.sheets( s ).rows.delete();
      workbook.sheets( s ).widths.delete();
      workbook.sheets( s ).autofilters.delete();
      workbook.sheets( s ).hyperlinks.delete();
      workbook.sheets( s ).col_fmts.delete();
      workbook.sheets( s ).row_fmts.delete();
      workbook.sheets( s ).comments.delete();
      workbook.sheets( s ).mergecells.delete();
      workbook.sheets( s ).validations.delete();
      s := workbook.sheets.next( s );
    end loop;
    workbook.strings.delete();
    workbook.str_ind.delete();
    workbook.fonts.delete();
    workbook.fills.delete();
    workbook.borders.delete();
    workbook.numFmts.delete();
    workbook.cellXfs.delete();
    workbook.defined_names.delete();
    workbook.formulas.delete();
    workbook := NULL;
  end;
--
  PROCEDURE set_tabcolor
    ( p_tabcolor VARCHAR2 -- this is a hex ALPHA Red Green Blue value
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).tabcolor := substr( p_tabcolor, 1, 8 );
  end;
--
  PROCEDURE new_sheet
    ( p_sheetname VARCHAR2 := NULL
    , p_tabcolor VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
    )
  is
    t_nr PLS_INTEGER := workbook.sheets.count() + 1;
    t_ind PLS_INTEGER;
  BEGIN
    workbook.sheets( t_nr ).name := nvl( dbms_xmlgen.convert( translate( p_sheetname, 'a/\[]*:?', 'a' ) ), 'Sheet' || t_nr );
    if workbook.strings.count() = 0
    then
     workbook.str_cnt := 0;
    end if;
    if workbook.fonts.count() = 0
    then
      workbook.fontid := get_font( 'Calibri' );
    end if;
    if workbook.fills.count() = 0
    then
      t_ind := get_fill( 'none' );
      t_ind := get_fill( 'gray125' );
    end if;
    if workbook.borders.count() = 0
    then
      t_ind := get_border( '', '', '', '' );
    end if;
    set_tabcolor( p_tabcolor, t_nr );
    workbook.sheets( t_nr ).fontid := workbook.fontid;
  end;
--
  PROCEDURE set_col_width
    ( p_sheet PLS_INTEGER
    , p_col PLS_INTEGER
    , p_format VARCHAR2
    )
  is
    t_width NUMBER;
    t_nr_chr PLS_INTEGER;
  BEGIN
    if p_format is NULL
    then
      return;
    end if;
    if instr( p_format, ';' ) > 0
    then
      t_nr_chr := length( translate( substr( p_format, 1, instr( p_format, ';' ) - 1 ), 'a\"', 'a' ) );
    else
      t_nr_chr := length( translate( p_format, 'a\"', 'a' ) );
    end if;
    t_width := trunc( ( t_nr_chr * 7 + 5 ) / 7 * 256 ) / 256; -- assume default 11 point Calibri
    if workbook.sheets( p_sheet ).widths.exists( p_col )
    then
      workbook.sheets( p_sheet ).widths( p_col ) :=
        greatest( workbook.sheets( p_sheet ).widths( p_col )
                , t_width
                );
    else
      workbook.sheets( p_sheet ).widths( p_col ) := greatest( t_width, 8.43 );
    end if;
  end;
--
  function OraFmt2Excel( p_format VARCHAR2 := NULL )
  return VARCHAR2
  is
    t_format VARCHAR2(1000) := substr( p_format, 1, 1000 );
  BEGIN
    t_format := replace( replace( t_format, 'hh24', 'hh' ), 'hh12', 'hh' );
    t_format := replace( t_format, 'mi', 'mm' );
    t_format := replace( replace( replace( t_format, 'AM', '~~' ), 'PM', '~~' ), '~~', 'AM/PM' );
    t_format := replace( replace( replace( t_format, 'am', '~~' ), 'pm', '~~' ), '~~', 'AM/PM' );
    t_format := replace( replace( t_format, 'day', 'DAY' ), 'DAY', 'dddd' );
    t_format := replace( replace( t_format, 'dy', 'DY' ), 'DAY', 'ddd' );
    t_format := replace( replace( t_format, 'RR', 'RR' ), 'RR', 'YY' );
    t_format := replace( replace( t_format, 'month', 'MONTH' ), 'MONTH', 'mmmm' );
    t_format := replace( replace( t_format, 'mon', 'MON' ), 'MON', 'mmm' );
    t_format := replace( t_format, '9', '#' );
    t_format := replace( t_format, 'D', '.' );
    t_format := replace( t_format, 'G', ',' );
    return t_format;
  end;
--
  function get_numFmt( p_format VARCHAR2 := NULL )
  return PLS_INTEGER
  is
    t_cnt PLS_INTEGER;
    t_numFmtId PLS_INTEGER;
  BEGIN
    if p_format is NULL
    then
      return 0;
    end if;
    t_cnt := workbook.numFmts.count();
    for i in 1 .. t_cnt
    loop
      if workbook.numFmts( i ).formatCode = p_format
      then
        t_numFmtId := workbook.numFmts( i ).numFmtId;
        exit;
      end if;
    end loop;
    if t_numFmtId is NULL
    then
      t_numFmtId := case when t_cnt = 0 then 164 else workbook.numFmts( t_cnt ).numFmtId + 1 end;
      t_cnt := t_cnt + 1;
      workbook.numFmts( t_cnt ).numFmtId := t_numFmtId;
      workbook.numFmts( t_cnt ).formatCode := p_format;
      workbook.numFmtIndexes( t_numFmtId ) := t_cnt;
    end if;
    return t_numFmtId;
  end;
--
  PROCEDURE set_font
    ( p_name VARCHAR2
    , p_sheet PLS_INTEGER := NULL
    , p_family PLS_INTEGER := 2
    , p_fontsize NUMBER := 11
    , p_theme PLS_INTEGER := 1
    , p_underline boolean := false
    , p_italic boolean := false
    , p_bold boolean := false
    , p_rgb VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
    )
  is
    t_ind PLS_INTEGER := get_font( p_name, p_family, p_fontsize, p_theme, p_underline, p_italic, p_bold, p_rgb );
  BEGIN
    if p_sheet is NULL
    then
      workbook.fontid := t_ind;
    else
      workbook.sheets( p_sheet ).fontid := t_ind;
    end if;
  end;
--
  function get_font
    ( p_name VARCHAR2
    , p_family PLS_INTEGER := 2
    , p_fontsize NUMBER := 11
    , p_theme PLS_INTEGER := 1
    , p_underline boolean := false
    , p_italic boolean := false
    , p_bold boolean := false
    , p_rgb VARCHAR2 := NULL -- this is a hex ALPHA Red Green Blue value
    )
  return PLS_INTEGER
  is
    t_ind PLS_INTEGER;
  BEGIN
    if workbook.fonts.count() > 0
    then
      for f in 0 .. workbook.fonts.count() - 1
      loop
        if (   workbook.fonts( f ).name = p_name
           and workbook.fonts( f ).family = p_family
           and workbook.fonts( f ).fontsize = p_fontsize
           and workbook.fonts( f ).theme = p_theme
           and workbook.fonts( f ).underline = p_underline
           and workbook.fonts( f ).italic = p_italic
           and workbook.fonts( f ).bold = p_bold
           and ( workbook.fonts( f ).rgb = p_rgb
               or ( workbook.fonts( f ).rgb is NULL and p_rgb is NULL )
               )
           )
        then
          return f;
        end if;
      end loop;
    end if;
    t_ind := workbook.fonts.count();
    workbook.fonts( t_ind ).name := p_name;
    workbook.fonts( t_ind ).family := p_family;
    workbook.fonts( t_ind ).fontsize := p_fontsize;
    workbook.fonts( t_ind ).theme := p_theme;
    workbook.fonts( t_ind ).underline := p_underline;
    workbook.fonts( t_ind ).italic := p_italic;
    workbook.fonts( t_ind ).bold := p_bold;
    workbook.fonts( t_ind ).rgb := p_rgb;
    return t_ind;
  end;
--
  function get_fill
    ( p_patternTYPE VARCHAR2
    , p_fgRGB VARCHAR2 := NULL
    , p_bgRGB VARCHAR2 := NULL
    )
  return PLS_INTEGER
  is
    t_ind PLS_INTEGER;
  BEGIN
    if workbook.fills.count() > 0
    then
      for f in 0 .. workbook.fills.count() - 1
      loop
        if (   workbook.fills( f ).patternTYPE = p_patternType
           and nvl( workbook.fills( f ).fgRGB, 'x' ) = nvl( upper( p_fgRGB ), 'x' )
           and nvl( workbook.fills( f ).bgRGB, 'x' ) = nvl( upper( p_bgRGB ), 'x' )
           )
        then
          return f;
        end if;
      end loop;
    end if;
    t_ind := workbook.fills.count();
    workbook.fills( t_ind ).patternTYPE := p_patternType;
    workbook.fills( t_ind ).fgRGB := upper( p_fgRGB );
    workbook.fills( t_ind ).bgRGB := upper( p_bgRGB );
    return t_ind;
  end;
--
  function get_border
    ( p_top VARCHAR2 := 'thin'
    , p_bottom VARCHAR2 := 'thin'
    , p_left VARCHAR2 := 'thin'
    , p_right VARCHAR2 := 'thin'
    )
  return PLS_INTEGER
  is
    t_ind PLS_INTEGER;
  BEGIN
    if workbook.borders.count() > 0
    then
      for b in 0 .. workbook.borders.count() - 1
      loop
        if (   nvl( workbook.borders( b ).top, 'x' ) = nvl( p_top, 'x' )
           and nvl( workbook.borders( b ).bottom, 'x' ) = nvl( p_bottom, 'x' )
           and nvl( workbook.borders( b ).left, 'x' ) = nvl( p_left, 'x' )
           and nvl( workbook.borders( b ).right, 'x' ) = nvl( p_right, 'x' )
           )
        then
          return b;
        end if;
      end loop;
    end if;
    t_ind := workbook.borders.count();
    workbook.borders( t_ind ).top := p_top;
    workbook.borders( t_ind ).bottom := p_bottom;
    workbook.borders( t_ind ).left := p_left;
    workbook.borders( t_ind ).right := p_right;
    return t_ind;
  end;
--
  function get_alignment
    ( p_vertical VARCHAR2 := NULL
    , p_horizontal VARCHAR2 := NULL
    , p_wrapText boolean := NULL
    )
  return tp_alignment
  is
    t_rv tp_alignment;
  BEGIN
    t_rv.vertical := p_vertical;
    t_rv.horizontal := p_horizontal;
    t_rv.wrapText := p_wrapText;
    return t_rv;
  end;
--
  function get_XfId
    ( p_sheet PLS_INTEGER
    , p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    )
  return VARCHAR2
  is
    t_cnt PLS_INTEGER;
    t_XfId PLS_INTEGER;
    t_XF tp_XF_fmt;
    t_col_XF tp_XF_fmt;
    t_row_XF tp_XF_fmt;
  BEGIN
    if not g_useXf
    then
      return '';
    end if;
    if workbook.sheets( p_sheet ).col_fmts.exists( p_col )
    then
      t_col_XF := workbook.sheets( p_sheet ).col_fmts( p_col );
    end if;
    if workbook.sheets( p_sheet ).row_fmts.exists( p_row )
    then
      t_row_XF := workbook.sheets( p_sheet ).row_fmts( p_row );
    end if;
    t_XF.numFmtId := coalesce( p_numFmtId, t_col_XF.numFmtId, t_row_XF.numFmtId, workbook.sheets( p_sheet ).fontid, workbook.fontid );
    t_XF.fontId := coalesce( p_fontId, t_col_XF.fontId, t_row_XF.fontId, 0 );
    t_XF.fillId := coalesce( p_fillId, t_col_XF.fillId, t_row_XF.fillId, 0 );
    t_XF.borderId := coalesce( p_borderId, t_col_XF.borderId, t_row_XF.borderId, 0 );
    t_XF.alignment := get_alignment
                        ( coalesce( p_alignment.vertical, t_col_XF.alignment.vertical, t_row_XF.alignment.vertical )
                        , coalesce( p_alignment.horizontal, t_col_XF.alignment.horizontal, t_row_XF.alignment.horizontal )
                        , coalesce( p_alignment.wrapText, t_col_XF.alignment.wrapText, t_row_XF.alignment.wrapText )
                        );
    if (   t_XF.numFmtId + t_XF.fontId + t_XF.fillId + t_XF.borderId = 0
       and t_XF.alignment.vertical is NULL
       and t_XF.alignment.horizontal is NULL
       and not nvl( t_XF.alignment.wrapText, false )
       )
    then
      return '';
    end if;
    if t_XF.numFmtId > 0
    then
      set_col_width( p_sheet, p_col, workbook.numFmts( workbook.numFmtIndexes( t_XF.numFmtId ) ).formatCode );
    end if;
    t_cnt := workbook.cellXfs.count();
    for i in 1 .. t_cnt
    loop
      if (   workbook.cellXfs( i ).numFmtId = t_XF.numFmtId
         and workbook.cellXfs( i ).fontId = t_XF.fontId
         and workbook.cellXfs( i ).fillId = t_XF.fillId
         and workbook.cellXfs( i ).borderId = t_XF.borderId
         and nvl( workbook.cellXfs( i ).alignment.vertical, 'x' ) = nvl( t_XF.alignment.vertical, 'x' )
         and nvl( workbook.cellXfs( i ).alignment.horizontal, 'x' ) = nvl( t_XF.alignment.horizontal, 'x' )
         and nvl( workbook.cellXfs( i ).alignment.wrapText, false ) = nvl( t_XF.alignment.wrapText, false )
         )
      then
        t_XfId := i;
        exit;
      end if;
    end loop;
    if t_XfId is NULL
    then
      t_cnt := t_cnt + 1;
      t_XfId := t_cnt;
      workbook.cellXfs( t_cnt ) := t_XF;
    end if;
    return 's="' || t_XfId || '"';
  end;
--
  PROCEDURE cell
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_value NUMBER
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).value := p_value;
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).style := NULL;
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).style := get_XfId( t_sheet, p_col, p_row, p_numFmtId, p_fontId, p_fillId, p_borderId, p_alignment );
  end;
--
  function add_string( p_string VARCHAR2 )
  return PLS_INTEGER
  is
    t_cnt PLS_INTEGER;
  BEGIN
    if workbook.strings.exists( nvl( p_string, '' ) )
    then
      t_cnt := workbook.strings( nvl( p_string, '' ) );
    else
      t_cnt := workbook.strings.count();
      workbook.str_ind( t_cnt ) := p_string;
      workbook.strings( nvl( p_string, '' ) ) := t_cnt;
    end if;
    workbook.str_cnt := workbook.str_cnt + 1;
    return t_cnt;
  end;
--
  PROCEDURE cell
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_value VARCHAR2
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
    t_alignment tp_alignment := p_alignment;
  BEGIN
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).value := add_string( p_value );
    if t_alignment.wrapText is NULL and instr( p_value, chr(13) ) > 0
    then
      t_alignment.wrapText := TRUE;
    end if;
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).style := 't="s" ' || get_XfId( t_sheet, p_col, p_row, p_numFmtId, p_fontId, p_fillId, p_borderId, t_alignment );
  end;
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
    )
  is
    t_numFmtId PLS_INTEGER := p_numFmtId;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).value := ( p_value - date '1900-03-01' ) + 61;
    if t_numFmtId is NULL
       and not (   workbook.sheets( t_sheet ).col_fmts.exists( p_col )
               and workbook.sheets( t_sheet ).col_fmts( p_col ).numFmtId is not NULL
               )
       and not (   workbook.sheets( t_sheet ).row_fmts.exists( p_row )
               and workbook.sheets( t_sheet ).row_fmts( p_row ).numFmtId is not NULL
               )
    then
      t_numFmtId := get_numFmt( 'dd/mm/yyyy' );
    end if;
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).style := get_XfId( t_sheet, p_col, p_row, t_numFmtId, p_fontId, p_fillId, p_borderId, p_alignment );
  end;
--
  PROCEDURE query_date_cell
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_value date
    , p_sheet PLS_INTEGER := NULL
    , p_XfId VARCHAR2
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    cell( p_col, p_row, p_value, 0, p_sheet => t_sheet ); 
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).style := p_XfId;
  end;
--
  PROCEDURE hyperlink
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_url VARCHAR2
    , p_value VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).value := add_string( nvl( p_value, p_url ) );
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).style := 't="s" ' || get_XfId( t_sheet, p_col, p_row, '', get_font( 'Calibri', p_theme => 10, p_underline => TRUE ) );
    t_ind := workbook.sheets( t_sheet ).hyperlinks.count() + 1;
    workbook.sheets( t_sheet ).hyperlinks( t_ind ).cell := alfan_col( p_col ) || p_row;
    workbook.sheets( t_sheet ).hyperlinks( t_ind ).url := p_url;
  end;
--
  PROCEDURE comment
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_text VARCHAR2
    , p_author VARCHAR2 := NULL
    , p_width PLS_INTEGER := 150
    , p_height PLS_INTEGER := 100
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    t_ind := workbook.sheets( t_sheet ).comments.count() + 1;
    workbook.sheets( t_sheet ).comments( t_ind ).row := p_row;
    workbook.sheets( t_sheet ).comments( t_ind ).column := p_col;
    workbook.sheets( t_sheet ).comments( t_ind ).text := dbms_xmlgen.convert( p_text );
    workbook.sheets( t_sheet ).comments( t_ind ).author := dbms_xmlgen.convert( p_author );
    workbook.sheets( t_sheet ).comments( t_ind ).width := p_width;
    workbook.sheets( t_sheet ).comments( t_ind ).height := p_height;
  end;
--
  PROCEDURE num_formula
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_formula VARCHAR2
    , p_default_value NUMBER := NULL
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER := workbook.formulas.count;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.formulas( t_ind ) := p_formula;
    cell( p_col, p_row, p_default_value, p_numFmtId, p_fontId, p_fillId, p_borderId, p_alignment, t_sheet );
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).formula_idx := t_ind;
  end;
--
  PROCEDURE str_formula
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_formula VARCHAR2
    , p_default_value VARCHAR2 := NULL
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER := workbook.formulas.count;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.formulas( t_ind ) := p_formula;
    cell( p_col, p_row, p_default_value, p_numFmtId, p_fontId, p_fillId, p_borderId, p_alignment, t_sheet );
    workbook.sheets( t_sheet ).rows( p_row )( p_col ).formula_idx := t_ind;
  end;
--
  PROCEDURE mergecells
    ( p_tl_col PLS_INTEGER -- top left
    , p_tl_row PLS_INTEGER
    , p_br_col PLS_INTEGER -- bottom right
    , p_br_row PLS_INTEGER
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    t_ind := workbook.sheets( t_sheet ).mergecells.count() + 1;
    workbook.sheets( t_sheet ).mergecells( t_ind ) := alfan_col( p_tl_col ) || p_tl_row || ':' || alfan_col( p_br_col ) || p_br_row;
  end;
--
  PROCEDURE add_validation
    ( p_TYPE VARCHAR2
    , p_sqref VARCHAR2
    , p_style VARCHAR2 := 'stop' -- stop, warning, information
    , p_formula1 VARCHAR2 := NULL
    , p_formula2 VARCHAR2 := NULL
    , p_title VARCHAR2 := NULL
    , p_prompt varchar := NULL
    , p_show_error boolean := false
    , p_error_title VARCHAR2 := NULL
    , p_error_txt VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    t_ind := workbook.sheets( t_sheet ).validations.count() + 1;
    workbook.sheets( t_sheet ).validations( t_ind ).TYPE := p_type;
    workbook.sheets( t_sheet ).validations( t_ind ).errorstyle := p_style;
    workbook.sheets( t_sheet ).validations( t_ind ).sqref := p_sqref;
    workbook.sheets( t_sheet ).validations( t_ind ).formula1 := p_formula1;
    workbook.sheets( t_sheet ).validations( t_ind ).error_title := p_error_title;
    workbook.sheets( t_sheet ).validations( t_ind ).error_txt := p_error_txt;
    workbook.sheets( t_sheet ).validations( t_ind ).title := p_title;
    workbook.sheets( t_sheet ).validations( t_ind ).prompt := p_prompt;
    workbook.sheets( t_sheet ).validations( t_ind ).showerrormessage := p_show_error;
  end;
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
    , p_show_error boolean := false
    , p_error_title VARCHAR2 := NULL
    , p_error_txt VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
  BEGIN
    add_validation( 'list'
                  , alfan_col( p_sqref_col ) || p_sqref_row
                  , p_style => lower( p_style )
                  , p_formula1 => '$' || alfan_col( p_tl_col ) || '$' ||  p_tl_row || ':$' || alfan_col( p_br_col ) || '$' || p_br_row
                  , p_title => p_title
                  , p_prompt => p_prompt
                  , p_show_error => p_show_error
                  , p_error_title => p_error_title
                  , p_error_txt => p_error_txt
                  , p_sheet => p_sheet
                  );
  end;
--
  PROCEDURE list_validation
    ( p_sqref_col PLS_INTEGER
    , p_sqref_row PLS_INTEGER
    , p_defined_name VARCHAR2
    , p_style VARCHAR2 := 'stop' -- stop, warning, information
    , p_title VARCHAR2 := NULL
    , p_prompt varchar := NULL
    , p_show_error boolean := false
    , p_error_title VARCHAR2 := NULL
    , p_error_txt VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
  BEGIN
    add_validation( 'list'
                  , alfan_col( p_sqref_col ) || p_sqref_row
                  , p_style => lower( p_style )
                  , p_formula1 => p_defined_name
                  , p_title => p_title
                  , p_prompt => p_prompt
                  , p_show_error => p_show_error
                  , p_error_title => p_error_title
                  , p_error_txt => p_error_txt
                  , p_sheet => p_sheet
                  );
  end;
--
  PROCEDURE defined_name
    ( p_tl_col PLS_INTEGER -- top left
    , p_tl_row PLS_INTEGER
    , p_br_col PLS_INTEGER -- bottom right
    , p_br_row PLS_INTEGER
    , p_name VARCHAR2
    , p_sheet PLS_INTEGER := NULL
    , p_localsheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    t_ind := workbook.defined_names.count() + 1;
    workbook.defined_names( t_ind ).name := p_name;
    workbook.defined_names( t_ind ).ref := 'Sheet' || t_sheet || '!$' || alfan_col( p_tl_col ) || '$' ||  p_tl_row || ':$' || alfan_col( p_br_col ) || '$' || p_br_row;
    workbook.defined_names( t_ind ).sheet := p_localsheet;
  end;
--
  PROCEDURE set_column_width
    ( p_col PLS_INTEGER
    , p_width NUMBER
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_width NUMBER;
  BEGIN
    t_width := trunc( round( p_width * 7 ) * 256 / 7 ) / 256;
    workbook.sheets( nvl( p_sheet, workbook.sheets.count() ) ).widths( p_col ) := t_width;
  end;
--
  PROCEDURE set_column
    ( p_col PLS_INTEGER
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).col_fmts( p_col ).numFmtId := p_numFmtId;
    workbook.sheets( t_sheet ).col_fmts( p_col ).fontId := p_fontId;
    workbook.sheets( t_sheet ).col_fmts( p_col ).fillId := p_fillId;
    workbook.sheets( t_sheet ).col_fmts( p_col ).borderId := p_borderId;
    workbook.sheets( t_sheet ).col_fmts( p_col ).alignment := p_alignment;
  end;
--
  PROCEDURE set_row
    ( p_row PLS_INTEGER
    , p_numFmtId PLS_INTEGER := NULL
    , p_fontId PLS_INTEGER := NULL
    , p_fillId PLS_INTEGER := NULL
    , p_borderId PLS_INTEGER := NULL
    , p_alignment tp_alignment := NULL
    , p_sheet PLS_INTEGER := NULL
    , p_height NUMBER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
    t_cells tp_cells;
  BEGIN
    workbook.sheets( t_sheet ).row_fmts( p_row ).numFmtId := p_numFmtId;
    workbook.sheets( t_sheet ).row_fmts( p_row ).fontId := p_fontId;
    workbook.sheets( t_sheet ).row_fmts( p_row ).fillId := p_fillId;
    workbook.sheets( t_sheet ).row_fmts( p_row ).borderId := p_borderId;
    workbook.sheets( t_sheet ).row_fmts( p_row ).alignment := p_alignment;
    workbook.sheets( t_sheet ).row_fmts( p_row ).height := trunc( p_height * 4 / 3 ) * 3 / 4;
    if not workbook.sheets( t_sheet ).rows.exists( p_row )
    then
      workbook.sheets( t_sheet ).rows( p_row ) := t_cells;
    end if;
  end;
--
  PROCEDURE freeze_rows
    ( p_nr_rows PLS_INTEGER := 1
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).freeze_cols := NULL;
    workbook.sheets( t_sheet ).freeze_rows := p_nr_rows;
  end;
--
  PROCEDURE freeze_cols
    ( p_nr_cols PLS_INTEGER := 1
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).freeze_rows := NULL;
    workbook.sheets( t_sheet ).freeze_cols := p_nr_cols;
  end;
--
  PROCEDURE freeze_pane
    ( p_col PLS_INTEGER
    , p_row PLS_INTEGER
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    workbook.sheets( t_sheet ).freeze_rows := p_row;
    workbook.sheets( t_sheet ).freeze_cols := p_col;
  end;
--
  PROCEDURE set_autofilter
    ( p_column_start PLS_INTEGER := NULL
    , p_column_end PLS_INTEGER := NULL
    , p_row_start PLS_INTEGER := NULL
    , p_row_end PLS_INTEGER := NULL
    , p_sheet PLS_INTEGER := NULL
    )
  is
    t_ind PLS_INTEGER;
    t_sheet PLS_INTEGER := nvl( p_sheet, workbook.sheets.count() );
  BEGIN
    t_ind := 1;
    workbook.sheets( t_sheet ).autofilters( t_ind ).column_start := p_column_start;
    workbook.sheets( t_sheet ).autofilters( t_ind ).column_end := p_column_end;
    workbook.sheets( t_sheet ).autofilters( t_ind ).row_start := p_row_start;
    workbook.sheets( t_sheet ).autofilters( t_ind ).row_end := p_row_end;
    defined_name
      ( p_column_start
      , p_row_start
      , p_column_end
      , p_row_end
      , '_xlnm._FilterDatabase'
      , t_sheet
      , t_sheet - 1
      );
  end;
--
/*
  PROCEDURE add1xml
    ( p_excel IN OUT NOCOPY BLOB
    , p_filename VARCHAR2
    , p_xml clob
    )
  is
    t_tmp blob;
    c_step constant NUMBER := 24396;
  BEGIN
    dbms_lob.createtemporary( t_tmp, TRUE );
    for i in 0 .. trunc( length( p_xml ) / c_step )
    loop
      dbms_lob.append( t_tmp, utl_i18n.string_to_raw( substr( p_xml, i * c_step + 1, c_step ), 'AL32UTF8' ) );
    end loop;
    add1file( p_excel, p_filename, t_tmp );
    dbms_lob.freetemporary( t_tmp );
  end;
*/
--
  PROCEDURE add1xml
    ( p_excel IN OUT NOCOPY BLOB
    , p_filename VARCHAR2
    , p_xml clob
    )
  is
    t_tmp blob;
    dest_offset integer := 1;
    src_offset integer := 1;
    lang_context integer;
    warning integer;
  BEGIN
    lang_context := dbms_lob.DEFAULT_LANG_CTX;
    dbms_lob.createtemporary( t_tmp, TRUE );
    dbms_lob.converttoblob
      ( t_tmp
      , p_xml
      , dbms_lob.lobmaxsize
      , dest_offset
      , src_offset
      ,  nls_charset_id( 'AL32UTF8'  )
      , lang_context
      , warning
      );
    add1file( p_excel, p_filename, t_tmp );
    dbms_lob.freetemporary( t_tmp );
  end;
--
  function finish
  return blob
  is
    t_excel blob;
    t_yyy blob;
    t_xxx clob;
    t_tmp VARCHAR2(32767 char);
    t_str VARCHAR2(32767 char);
    t_c NUMBER;
    t_h NUMBER;
    t_w NUMBER;
    t_cw NUMBER;
    s PLS_INTEGER;
    t_row_ind PLS_INTEGER;
    t_col_min PLS_INTEGER;
    t_col_max PLS_INTEGER;
    t_col_ind PLS_INTEGER;
    t_len PLS_INTEGER;
  BEGIN
    dbms_lob.createtemporary( t_excel, TRUE );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Default Extension="vml" ContentType="application/vnd.openxmlformats-officedocument.vmlDrawing"/>
<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>';
    s := workbook.sheets.first;
    while s is not NULL
    loop
      t_xxx := t_xxx || ( '
<Override PartName="/xl/worksheets/sheet' || s || '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' );
      s := workbook.sheets.next( s );
    end loop;
    t_xxx := t_xxx || '
<Override PartName="/xl/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>';
    s := workbook.sheets.first;
    while s is not NULL
    loop
      if workbook.sheets( s ).comments.count() > 0
      then
        t_xxx := t_xxx || ( '
<Override PartName="/xl/comments' || s || '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml"/>' );
      end if;
      s := workbook.sheets.next( s );
    end loop;
    t_xxx := t_xxx || '
</Types>';
    add1xml( t_excel, '[Content_Types].xml', t_xxx );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<dc:creator>' || sys_context( 'userenv', 'os_user' ) || '</dc:creator>
<dc:description>Build by version:' || C_VERSION || '</dc:description>
<cp:lastModifiedBy>' || sys_context( 'userenv', 'os_user' ) || '</cp:lastModifiedBy>
<dcterms:created xsi:type="dcterms:W3CDTF">' || to_char( current_timestamp, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM' ) || '</dcterms:created>
<dcterms:modified xsi:type="dcterms:W3CDTF">' || to_char( current_timestamp, 'yyyy-mm-dd"T"hh24:mi:ssTZH:TZM' ) || '</dcterms:modified>
</cp:coreProperties>';
    add1xml( t_excel, 'docProps/core.xml', t_xxx );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
<Application>Microsoft Excel</Application>
<DocSecurity>0</DocSecurity>
<ScaleCrop>false</ScaleCrop>
<HeadingPairs>
<vt:vector size="2" baseType="variant">
<vt:variant>
<vt:lpstr>Worksheets</vt:lpstr>
</vt:variant>
<vt:variant>
<vt:i4>' || workbook.sheets.count() || '</vt:i4>
</vt:variant>
</vt:vector>
</HeadingPairs>
<TitlesOfParts>
<vt:vector size="' || workbook.sheets.count() || '" baseType="lpstr">';
    s := workbook.sheets.first;
    while s is not NULL
    loop
      t_xxx := t_xxx || ( '
<vt:lpstr>' || workbook.sheets( s ).name || '</vt:lpstr>' );
      s := workbook.sheets.next( s );
    end loop;
    t_xxx := t_xxx || '</vt:vector>
</TitlesOfParts>
<LinksUpToDate>false</LinksUpToDate>
<SharedDoc>false</SharedDoc>
<HyperlinksChanged>false</HyperlinksChanged>
<AppVersion>14.0300</AppVersion>
</Properties>';
    add1xml( t_excel, 'docProps/app.xml', t_xxx );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>';
    add1xml( t_excel, '_rels/.rels', t_xxx );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">';
    if workbook.numFmts.count() > 0
    then
      t_xxx := t_xxx || ( '<numFmts count="' || workbook.numFmts.count() || '">' );
      for n in 1 .. workbook.numFmts.count()
      loop
        t_xxx := t_xxx || ( '<numFmt numFmtId="' || workbook.numFmts( n ).numFmtId || '" formatCode="' || workbook.numFmts( n ).formatCode || '"/>' );
      end loop;
      t_xxx := t_xxx || '</numFmts>';
    end if;
    t_xxx := t_xxx || ( '<fonts count="' || workbook.fonts.count() || '" x14ac:knownFonts="1">' );
    for f in 0 .. workbook.fonts.count() - 1
    loop
      t_xxx := t_xxx || ( '<font>' ||
        case when workbook.fonts( f ).bold then '<b/>' end ||
        case when workbook.fonts( f ).italic then '<i/>' end ||
        case when workbook.fonts( f ).underline then '<u/>' end ||
'<sz val="' || to_char( workbook.fonts( f ).fontsize, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,' )  || '"/>
<color ' || case when workbook.fonts( f ).rgb is not NULL
              then 'rgb="' || workbook.fonts( f ).rgb
              else 'theme="' || workbook.fonts( f ).theme
            end || '"/>
<name val="' || workbook.fonts( f ).name || '"/>
<family val="' || workbook.fonts( f ).family || '"/>
<scheme val="none"/>
</font>' );
    end loop;
    t_xxx := t_xxx || ( '</fonts>
<fills count="' || workbook.fills.count() || '">' );
    for f in 0 .. workbook.fills.count() - 1
    loop
      t_xxx := t_xxx || ( '<fill><patternFill patternType="' || workbook.fills( f ).patternTYPE || '">' ||
         case when workbook.fills( f ).fgRGB is not NULL then '<fgColor rgb="' || workbook.fills( f ).fgRGB || '"/>' end ||
         case when workbook.fills( f ).bgRGB is not NULL then '<bgColor rgb="' || workbook.fills( f ).bgRGB || '"/>' end ||
         '</patternFill></fill>' );
    end loop;
    t_xxx := t_xxx || ( '</fills>
<borders count="' || workbook.borders.count() || '">' );
    for b in 0 .. workbook.borders.count() - 1
    loop
      t_xxx := t_xxx || ( '<border>' ||
         case when workbook.borders( b ).left   is NULL then '<left/>'   else '<left style="'   || workbook.borders( b ).left   || '"/>' end ||
         case when workbook.borders( b ).right  is NULL then '<right/>'  else '<right style="'  || workbook.borders( b ).right  || '"/>' end ||
         case when workbook.borders( b ).top    is NULL then '<top/>'    else '<top style="'    || workbook.borders( b ).top    || '"/>' end ||
         case when workbook.borders( b ).bottom is NULL then '<bottom/>' else '<bottom style="' || workbook.borders( b ).bottom || '"/>' end ||
         '</border>' );
    end loop;
    t_xxx := t_xxx || ( '</borders>
<cellStyleXfs count="1">
<xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>
</cellStyleXfs>
<cellXfs count="' || ( workbook.cellXfs.count() + 1 ) || '">
<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>' );
    for x in 1 .. workbook.cellXfs.count()
    loop
      t_xxx := t_xxx || ( '<xf numFmtId="' || workbook.cellXfs( x ).numFmtId || '" fontId="' || workbook.cellXfs( x ).fontId || '" fillId="' || workbook.cellXfs( x ).fillId || '" borderId="' || workbook.cellXfs( x ).borderId || '">' );
      if (  workbook.cellXfs( x ).alignment.horizontal is not NULL
         or workbook.cellXfs( x ).alignment.vertical is not NULL
         or workbook.cellXfs( x ).alignment.wrapText
         )
      then
        t_xxx := t_xxx || ( '<alignment' ||
          case when workbook.cellXfs( x ).alignment.horizontal is not NULL then ' horizontal="' || workbook.cellXfs( x ).alignment.horizontal || '"' end ||
          case when workbook.cellXfs( x ).alignment.vertical is not NULL then ' vertical="' || workbook.cellXfs( x ).alignment.vertical || '"' end ||
          case when workbook.cellXfs( x ).alignment.wrapText then ' wrapText="TRUE"' end || '/>' );
      end if;
      t_xxx := t_xxx || '</xf>';
    end loop;
    t_xxx := t_xxx || ( '</cellXfs>
<cellStyles count="1">
<cellStyle name="Normal" xfId="0" builtinId="0"/>
</cellStyles>
<dxfs count="0"/>
<tableStyles count="0" defaultTableStyle="TableStyleMedium2" defaultPivotStyle="PivotStyleLight16"/>
<extLst>
<ext uri="{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main">
<x14:slicerStyles defaultSlicerStyle="SlicerStyleLight1"/>
</ext>
</extLst>
</styleSheet>' );
    add1xml( t_excel, 'xl/styles.xml', t_xxx );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<fileVersion appName="xl" lastEdited="5" lowestEdited="5" rupBuild="9302"/>
<workbookPr date1904="false" defaultThemeVersion="124226"/>
<bookViews>
<workbookView xWindow="120" yWindow="45" windowWidth="19155" windowHeight="4935"/>
</bookViews>
<sheets>';
    s := workbook.sheets.first;
    while s is not NULL
    loop
      t_xxx := t_xxx || ( '
<sheet name="' || workbook.sheets( s ).name || '" sheetId="' || s || '" r:id="rId' || ( 9 + s ) || '"/>' );
      s := workbook.sheets.next( s );
    end loop;
    t_xxx := t_xxx || '</sheets>';
    if workbook.defined_names.count() > 0
    then
      t_xxx := t_xxx || '<definedNames>';
      for s in 1 .. workbook.defined_names.count()
      loop
        t_xxx := t_xxx || ( '
<definedName name="' || workbook.defined_names( s ).name || '"' ||
            case when workbook.defined_names( s ).sheet is not NULL then ' localSheetId="' || to_char( workbook.defined_names( s ).sheet ) || '"' end ||
            '>' || workbook.defined_names( s ).ref || '</definedName>' );
      end loop;
      t_xxx := t_xxx || '</definedNames>';
    end if;
    t_xxx := t_xxx || '<calcPr calcId="144525"/></workbook>';
    add1xml( t_excel, 'xl/workbook.xml', t_xxx );
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme">
<a:themeElements>
<a:clrScheme name="Office">
<a:dk1>
<a:sysClr val="windowText" lastClr="000000"/>
</a:dk1>
<a:lt1>
<a:sysClr val="window" lastClr="FFFFFF"/>
</a:lt1>
<a:dk2>
<a:srgbClr val="1F497D"/>
</a:dk2>
<a:lt2>
<a:srgbClr val="EEECE1"/>
</a:lt2>
<a:accent1>
<a:srgbClr val="4F81BD"/>
</a:accent1>
<a:accent2>
<a:srgbClr val="C0504D"/>
</a:accent2>
<a:accent3>
<a:srgbClr val="9BBB59"/>
</a:accent3>
<a:accent4>
<a:srgbClr val="8064A2"/>
</a:accent4>
<a:accent5>
<a:srgbClr val="4BACC6"/>
</a:accent5>
<a:accent6>
<a:srgbClr val="F79646"/>
</a:accent6>
<a:hlink>
<a:srgbClr val="0000FF"/>
</a:hlink>
<a:folHlink>
<a:srgbClr val="800080"/>
</a:folHlink>
</a:clrScheme>
<a:fontScheme name="Office">
<a:majorFont>
<a:latin typeface="Cambria"/>
<a:ea typeface=""/>
<a:cs typeface=""/>
<a:font script="Jpan" typeface="MS P????"/>
<a:font script="Hang" typeface="?? ??"/>
<a:font script="Hans" typeface="??"/>
<a:font script="Hant" typeface="????"/>
<a:font script="Arab" typeface="Times New Roman"/>
<a:font script="Hebr" typeface="Times New Roman"/>
<a:font script="Thai" typeface="Tahoma"/>
<a:font script="Ethi" typeface="Nyala"/>
<a:font script="Beng" typeface="Vrinda"/>
<a:font script="Gujr" typeface="Shruti"/>
<a:font script="Khmr" typeface="MoolBoran"/>
<a:font script="Knda" typeface="Tunga"/>
<a:font script="Guru" typeface="Raavi"/>
<a:font script="Cans" typeface="Euphemia"/>
<a:font script="Cher" typeface="Plantagenet Cherokee"/>
<a:font script="Yiii" typeface="Microsoft Yi Baiti"/>
<a:font script="Tibt" typeface="Microsoft Himalaya"/>
<a:font script="Thaa" typeface="MV Boli"/>
<a:font script="Deva" typeface="Mangal"/>
<a:font script="Telu" typeface="Gautami"/>
<a:font script="Taml" typeface="Latha"/>
<a:font script="Syrc" typeface="Estrangelo Edessa"/>
<a:font script="Orya" typeface="Kalinga"/>
<a:font script="Mlym" typeface="Kartika"/>
<a:font script="Laoo" typeface="DokChampa"/>
<a:font script="Sinh" typeface="Iskoola Pota"/>
<a:font script="Mong" typeface="Mongolian Baiti"/>
<a:font script="Viet" typeface="Times New Roman"/>
<a:font script="Uigh" typeface="Microsoft Uighur"/>
<a:font script="Geor" typeface="Sylfaen"/>
</a:majorFont>
<a:minorFont>
<a:latin typeface="Calibri"/>
<a:ea typeface=""/>
<a:cs typeface=""/>
<a:font script="Jpan" typeface="MS P????"/>
<a:font script="Hang" typeface="?? ??"/>
<a:font script="Hans" typeface="??"/>
<a:font script="Hant" typeface="????"/>
<a:font script="Arab" typeface="Arial"/>
<a:font script="Hebr" typeface="Arial"/>
<a:font script="Thai" typeface="Tahoma"/>
<a:font script="Ethi" typeface="Nyala"/>
<a:font script="Beng" typeface="Vrinda"/>
<a:font script="Gujr" typeface="Shruti"/>
<a:font script="Khmr" typeface="DaunPenh"/>
<a:font script="Knda" typeface="Tunga"/>
<a:font script="Guru" typeface="Raavi"/>
<a:font script="Cans" typeface="Euphemia"/>
<a:font script="Cher" typeface="Plantagenet Cherokee"/>
<a:font script="Yiii" typeface="Microsoft Yi Baiti"/>
<a:font script="Tibt" typeface="Microsoft Himalaya"/>
<a:font script="Thaa" typeface="MV Boli"/>
<a:font script="Deva" typeface="Mangal"/>
<a:font script="Telu" typeface="Gautami"/>
<a:font script="Taml" typeface="Latha"/>
<a:font script="Syrc" typeface="Estrangelo Edessa"/>
<a:font script="Orya" typeface="Kalinga"/>
<a:font script="Mlym" typeface="Kartika"/>
<a:font script="Laoo" typeface="DokChampa"/>
<a:font script="Sinh" typeface="Iskoola Pota"/>
<a:font script="Mong" typeface="Mongolian Baiti"/>
<a:font script="Viet" typeface="Arial"/>
<a:font script="Uigh" typeface="Microsoft Uighur"/>
<a:font script="Geor" typeface="Sylfaen"/>
</a:minorFont>
</a:fontScheme>
<a:fmtScheme name="Office">
<a:fillStyleLst>
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:tint val="50000"/>
<a:satMod val="300000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="35000">
<a:schemeClr val="phClr">
<a:tint val="37000"/>
<a:satMod val="300000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:tint val="15000"/>
<a:satMod val="350000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:lin ang="16200000" scaled="1"/>
</a:gradFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:shade val="51000"/>
<a:satMod val="130000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="80000">
<a:schemeClr val="phClr">
<a:shade val="93000"/>
<a:satMod val="130000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:shade val="94000"/>
<a:satMod val="135000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:lin ang="16200000" scaled="0"/>
</a:gradFill>
</a:fillStyleLst>
<a:lnStyleLst>
<a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">
<a:solidFill>
<a:schemeClr val="phClr">
<a:shade val="95000"/>
<a:satMod val="105000"/>
</a:schemeClr>
</a:solidFill>
<a:prstDash val="solid"/>
</a:ln>
<a:ln w="25400" cap="flat" cmpd="sng" algn="ctr">
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:prstDash val="solid"/>
</a:ln>
<a:ln w="38100" cap="flat" cmpd="sng" algn="ctr">
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:prstDash val="solid"/>
</a:ln>
</a:lnStyleLst>
<a:effectStyleLst>
<a:effectStyle>
<a:effectLst>
<a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0">
<a:srgbClr val="000000">
<a:alpha val="38000"/>
</a:srgbClr>
</a:outerShdw>
</a:effectLst>
</a:effectStyle>
<a:effectStyle>
<a:effectLst>
<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">
<a:srgbClr val="000000">
<a:alpha val="35000"/>
</a:srgbClr>
</a:outerShdw>
</a:effectLst>
</a:effectStyle>
<a:effectStyle>
<a:effectLst>
<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">
<a:srgbClr val="000000">
<a:alpha val="35000"/>
</a:srgbClr>
</a:outerShdw>
</a:effectLst>
<a:scene3d>
<a:camera prst="orthographicFront">
<a:rot lat="0" lon="0" rev="0"/>
</a:camera>
<a:lightRig rig="threePt" dir="t">
<a:rot lat="0" lon="0" rev="1200000"/>
</a:lightRig>
</a:scene3d>
<a:sp3d>
<a:bevelT w="63500" h="25400"/>
</a:sp3d>
</a:effectStyle>
</a:effectStyleLst>
<a:bgFillStyleLst>
<a:solidFill>
<a:schemeClr val="phClr"/>
</a:solidFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:tint val="40000"/>
<a:satMod val="350000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="40000">
<a:schemeClr val="phClr">
<a:tint val="45000"/>
<a:shade val="99000"/>
<a:satMod val="350000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:shade val="20000"/>
<a:satMod val="255000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:path path="circle">
<a:fillToRect l="50000" t="-80000" r="50000" b="180000"/>
</a:path>
</a:gradFill>
<a:gradFill rotWithShape="1">
<a:gsLst>
<a:gs pos="0">
<a:schemeClr val="phClr">
<a:tint val="80000"/>
<a:satMod val="300000"/>
</a:schemeClr>
</a:gs>
<a:gs pos="100000">
<a:schemeClr val="phClr">
<a:shade val="30000"/>
<a:satMod val="200000"/>
</a:schemeClr>
</a:gs>
</a:gsLst>
<a:path path="circle">
<a:fillToRect l="50000" t="50000" r="50000" b="50000"/>
</a:path>
</a:gradFill>
</a:bgFillStyleLst>
</a:fmtScheme>
</a:themeElements>
<a:objectDefaults/>
<a:extraClrSchemeLst/>
</a:theme>';
    add1xml( t_excel, 'xl/theme/theme1.xml', t_xxx );
    s := workbook.sheets.first;
    while s is not NULL
    loop
      t_col_min := 16384;
      t_col_max := 1;
      t_row_ind := workbook.sheets( s ).rows.first();
      while t_row_ind is not NULL
      loop
        t_col_min := least( t_col_min, workbook.sheets( s ).rows( t_row_ind ).first() );
        t_col_max := greatest( t_col_max, workbook.sheets( s ).rows( t_row_ind ).last() );
        t_row_ind := workbook.sheets( s ).rows.next( t_row_ind );
      end loop;
      addtxt2utf8blob_init( t_yyy );
      addtxt2utf8blob( '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" xmlns:x14="http://schemas.microsoft.com/office/spreadsheetml/2009/9/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">' ||
case when workbook.sheets( s ).tabcolor is not NULL then '<sheetPr><tabColor rgb="' || workbook.sheets( s ).tabcolor || '"/></sheetPr>' end ||
'<dimension ref="' || alfan_col( t_col_min ) || workbook.sheets( s ).rows.first() || ':' || alfan_col( t_col_max ) || workbook.sheets( s ).rows.last() || '"/>
<sheetViews>
<sheetView' || case when s = 1 then ' tabSelected="1"' end || ' workbookViewId="0">'
                     , t_yyy
                     );
      if workbook.sheets( s ).freeze_rows > 0 and workbook.sheets( s ).freeze_cols > 0
      then
        addtxt2utf8blob( '<pane xSplit="' || workbook.sheets( s ).freeze_cols || '" '
                          || 'ySplit="' || workbook.sheets( s ).freeze_rows || '" '
                          || 'topLeftCell="' || alfan_col( workbook.sheets( s ).freeze_cols + 1 ) || ( workbook.sheets( s ).freeze_rows + 1 ) || '" '
                          || 'activePane="bottomLeft" state="frozen"/>'
                       , t_yyy
                       );
      else
        if workbook.sheets( s ).freeze_rows > 0
        then
          addtxt2utf8blob( '<pane ySplit="' || workbook.sheets( s ).freeze_rows || '" topLeftCell="A' || ( workbook.sheets( s ).freeze_rows + 1 ) || '" activePane="bottomLeft" state="frozen"/>'
                         , t_yyy
                         );
        end if;
        if workbook.sheets( s ).freeze_cols > 0
        then
          addtxt2utf8blob( '<pane xSplit="' || workbook.sheets( s ).freeze_cols || '" topLeftCell="' || alfan_col( workbook.sheets( s ).freeze_cols + 1 ) || '1" activePane="bottomLeft" state="frozen"/>'
                         , t_yyy
                         );
        end if;
      end if;
      addtxt2utf8blob( '</sheetView>
</sheetViews>
<sheetFormatPr defaultRowHeight="15" x14ac:dyDescent="0.25"/>'
                     , t_yyy
                     );
      if workbook.sheets( s ).widths.count() > 0
      then
        addtxt2utf8blob( '<cols>', t_yyy );
        t_col_ind := workbook.sheets( s ).widths.first();
        while t_col_ind is not NULL
        loop
          addtxt2utf8blob( '<col min="' || t_col_ind || '" max="' || t_col_ind || '" width="' || to_char( workbook.sheets( s ).widths( t_col_ind ), 'TM9', 'NLS_NUMERIC_CHARACTERS=.,' ) || '" customWidth="1"/>', t_yyy );
          t_col_ind := workbook.sheets( s ).widths.next( t_col_ind );
        end loop;
        addtxt2utf8blob( '</cols>', t_yyy );
      end if;
      addtxt2utf8blob( '<sheetData>', t_yyy );
      t_row_ind := workbook.sheets( s ).rows.first();
      while t_row_ind is not NULL
      loop
        if workbook.sheets( s ).row_fmts.exists( t_row_ind ) and workbook.sheets( s ).row_fmts( t_row_ind ).height is not NULL
        then
          addtxt2utf8blob( '<row r="' || t_row_ind || '" spans="' || t_col_min || ':' || t_col_max || '" customHeight="1" ht="'
                         || to_char( workbook.sheets( s ).row_fmts( t_row_ind ).height, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,' ) || '" >', t_yyy );
        else
          addtxt2utf8blob( '<row r="' || t_row_ind || '" spans="' || t_col_min || ':' || t_col_max || '">', t_yyy );
        end if;
        t_col_ind := workbook.sheets( s ).rows( t_row_ind ).first();
        while t_col_ind is not NULL
        loop
          if workbook.sheets( s ).rows( t_row_ind )( t_col_ind ).formula_idx is NULL
          then
            t_tmp := NULL;
          else
            t_tmp := '<f>' || workbook.formulas( workbook.sheets( s ).rows( t_row_ind )( t_col_ind ).formula_idx ) || '</f>';
          end if;
          addtxt2utf8blob( '<c r="' || alfan_col( t_col_ind ) || t_row_ind || '"'
                 || ' ' || workbook.sheets( s ).rows( t_row_ind )( t_col_ind ).style
                 || '>' || t_tmp || '<v>'
                 || to_char( workbook.sheets( s ).rows( t_row_ind )( t_col_ind ).value, 'TM9', 'NLS_NUMERIC_CHARACTERS=.,' )
                 || '</v></c>', t_yyy );
          t_col_ind := workbook.sheets( s ).rows( t_row_ind ).next( t_col_ind );
        end loop;
        addtxt2utf8blob( '</row>', t_yyy );
        t_row_ind := workbook.sheets( s ).rows.next( t_row_ind );
      end loop;
      addtxt2utf8blob( '</sheetData>', t_yyy );
      for a in 1 ..  workbook.sheets( s ).autofilters.count()
      loop
        addtxt2utf8blob( '<autoFilter ref="' ||
            alfan_col( nvl( workbook.sheets( s ).autofilters( a ).column_start, t_col_min ) ) ||
            nvl( workbook.sheets( s ).autofilters( a ).row_start, workbook.sheets( s ).rows.first() ) || ':' ||
            alfan_col( coalesce( workbook.sheets( s ).autofilters( a ).column_end, workbook.sheets( s ).autofilters( a ).column_start, t_col_max ) ) ||
            nvl( workbook.sheets( s ).autofilters( a ).row_end, workbook.sheets( s ).rows.last() ) || '"/>', t_yyy );
      end loop;
      if workbook.sheets( s ).mergecells.count() > 0
      then
        addtxt2utf8blob( '<mergeCells count="' || to_char( workbook.sheets( s ).mergecells.count() ) || '">', t_yyy );
        for m in 1 ..  workbook.sheets( s ).mergecells.count()
        loop
          addtxt2utf8blob( '<mergeCell ref="' || workbook.sheets( s ).mergecells( m ) || '"/>', t_yyy );
        end loop;
        addtxt2utf8blob( '</mergeCells>', t_yyy );
      end if;
--
      if workbook.sheets( s ).validations.count() > 0
      then
        addtxt2utf8blob( '<dataValidations count="' || to_char( workbook.sheets( s ).validations.count() ) || '">', t_yyy );
        for m in 1 ..  workbook.sheets( s ).validations.count()
        loop
          addtxt2utf8blob( '<dataValidation' ||
              ' type="' || workbook.sheets( s ).validations( m ).TYPE || '"' ||
              ' errorStyle="' || workbook.sheets( s ).validations( m ).errorstyle || '"' ||
              ' allowBlank="' || case when nvl( workbook.sheets( s ).validations( m ).allowBlank, TRUE ) then '1' else '0' end || '"' ||
              ' sqref="' || workbook.sheets( s ).validations( m ).sqref || '"', t_yyy );
          if workbook.sheets( s ).validations( m ).prompt is not NULL
          then
            addtxt2utf8blob( ' showInputMessage="1" prompt="' || workbook.sheets( s ).validations( m ).prompt || '"', t_yyy );
            if workbook.sheets( s ).validations( m ).title is not NULL
            then
              addtxt2utf8blob( ' promptTitle="' || workbook.sheets( s ).validations( m ).title || '"', t_yyy );
            end if;
          end if;
          if workbook.sheets( s ).validations( m ).showerrormessage
          then
            addtxt2utf8blob( ' showErrorMessage="1"', t_yyy );
            if workbook.sheets( s ).validations( m ).error_title is not NULL
            then
              addtxt2utf8blob( ' errorTitle="' || workbook.sheets( s ).validations( m ).error_title || '"', t_yyy );
            end if;
            if workbook.sheets( s ).validations( m ).error_txt is not NULL
            then
              addtxt2utf8blob( ' error="' || workbook.sheets( s ).validations( m ).error_txt || '"', t_yyy );
            end if;
          end if;
          addtxt2utf8blob( '>', t_yyy );
          if workbook.sheets( s ).validations( m ).formula1 is not NULL
          then
            addtxt2utf8blob( '<formula1>' || workbook.sheets( s ).validations( m ).formula1 || '</formula1>', t_yyy );
          end if;
          if workbook.sheets( s ).validations( m ).formula2 is not NULL
          then
            addtxt2utf8blob( '<formula2>' || workbook.sheets( s ).validations( m ).formula2 || '</formula2>', t_yyy );
          end if;
          addtxt2utf8blob( '</dataValidation>', t_yyy );
        end loop;
        addtxt2utf8blob( '</dataValidations>', t_yyy );
      end if;
--
      if workbook.sheets( s ).hyperlinks.count() > 0
      then
        addtxt2utf8blob( '<hyperlinks>', t_yyy );
        for h in 1 ..  workbook.sheets( s ).hyperlinks.count()
        loop
          addtxt2utf8blob( '<hyperlink ref="' || workbook.sheets( s ).hyperlinks( h ).cell || '" r:id="rId' || h || '"/>', t_yyy );
        end loop;
        addtxt2utf8blob( '</hyperlinks>', t_yyy );
      end if;
      addtxt2utf8blob( '<pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>', t_yyy );
      if workbook.sheets( s ).comments.count() > 0
      then
        addtxt2utf8blob( '<legacyDrawing r:id="rId' || ( workbook.sheets( s ).hyperlinks.count() + 1 ) || '"/>', t_yyy );
      end if;
--
      addtxt2utf8blob( '</worksheet>', t_yyy );
      addtxt2utf8blob_finish( t_yyy );
      add1file( t_excel, 'xl/worksheets/sheet' || s || '.xml', t_yyy );
      if workbook.sheets( s ).hyperlinks.count() > 0 or workbook.sheets( s ).comments.count() > 0
      then
        t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';
        if workbook.sheets( s ).comments.count() > 0
        then
          t_xxx := t_xxx || ( '<Relationship Id="rId' || ( workbook.sheets( s ).hyperlinks.count() + 2 ) || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments" Target="../comments' || s || '.xml"/>' );
          t_xxx := t_xxx || ( '<Relationship Id="rId' || ( workbook.sheets( s ).hyperlinks.count() + 1 ) || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing" Target="../drawings/vmlDrawing' || s || '.vml"/>' );
        end if;
        for h in 1 ..  workbook.sheets( s ).hyperlinks.count()
        loop
          t_xxx := t_xxx || ( '<Relationship Id="rId' || h || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="' || workbook.sheets( s ).hyperlinks( h ).url || '" TargetMode="External"/>' );
        end loop;
        t_xxx := t_xxx || '</Relationships>';
        add1xml( t_excel, 'xl/worksheets/_rels/sheet' || s || '.xml.rels', t_xxx );
      end if;
--
      if workbook.sheets( s ).comments.count() > 0
      then
        declare
          cnt PLS_INTEGER;
          author_ind tp_author;
--          t_col_ind := workbook.sheets( s ).widths.next( t_col_ind );
        BEGIN
          authors.delete();
          for c in 1 .. workbook.sheets( s ).comments.count()
          loop
            authors( workbook.sheets( s ).comments( c ).author ) := 0;
          end loop;
          t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<comments xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
<authors>';
          cnt := 0;
          author_ind := authors.first();
          while author_ind is not NULL or authors.next( author_ind ) is not NULL
          loop
            authors( author_ind ) := cnt;
            t_xxx := t_xxx || ( '<author>' || author_ind || '</author>' );
            cnt := cnt + 1;
            author_ind := authors.next( author_ind );
          end loop;
        end;
        t_xxx := t_xxx || '</authors><commentList>';
        for c in 1 .. workbook.sheets( s ).comments.count()
        loop
          t_xxx := t_xxx || ( '<comment ref="' || alfan_col( workbook.sheets( s ).comments( c ).column ) ||
             to_char( workbook.sheets( s ).comments( c ).row || '" authorId="' || authors( workbook.sheets( s ).comments( c ).author ) ) || '">
<text>' );
          if workbook.sheets( s ).comments( c ).author is not NULL
          then
            t_xxx := t_xxx || ( '<r><rPr><b/><sz val="9"/><color indexed="81"/><rFont val="Tahoma"/><charset val="1"/></rPr><t xml:space="preserve">' ||
               workbook.sheets( s ).comments( c ).author || ':</t></r>' );
          end if;
          t_xxx := t_xxx || ( '<r><rPr><sz val="9"/><color indexed="81"/><rFont val="Tahoma"/><charset val="1"/></rPr><t xml:space="preserve">' ||
             case when workbook.sheets( s ).comments( c ).author is not NULL then '
' end || workbook.sheets( s ).comments( c ).text || '</t></r></text></comment>' );
        end loop;
        t_xxx := t_xxx || '</commentList></comments>';
        add1xml( t_excel, 'xl/comments' || s || '.xml', t_xxx );
        t_xxx := '<xml xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">
<o:shapelayout v:ext="edit"><o:idmap v:ext="edit" data="2"/></o:shapelayout>
<v:shapeTYPE id="_x0000_t202" coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/></v:shapetype>';
        for c in 1 .. workbook.sheets( s ).comments.count()
        loop
          t_xxx := t_xxx || ( '<v:shape id="_x0000_s' || to_char( c ) || '" type="#_x0000_t202"
style="position:absolute;margin-left:35.25pt;margin-top:3pt;z-index:' || to_char( c ) || ';visibility:hidden;" fillcolor="#ffffe1" o:insetmode="auto">
<v:fill color2="#ffffe1"/><v:shadow on="t" color="black" obscured="t"/><v:path o:connecttype="none"/>
<v:textbox style="mso-direction-alt:auto"><div style="text-align:left"></div></v:textbox>
<x:ClientData ObjectType="Note"><x:MoveWithCells/><x:SizeWithCells/>' );
          t_w := workbook.sheets( s ).comments( c ).width;
          t_c := 1;
          loop
            if workbook.sheets( s ).widths.exists( workbook.sheets( s ).comments( c ).column + t_c )
            then
              t_cw := 256 * workbook.sheets( s ).widths( workbook.sheets( s ).comments( c ).column + t_c );
              t_cw := trunc( ( t_cw + 18 ) / 256 * 7); -- assume default 11 point Calibri
            else
              t_cw := 64;
            end if;
            exit when t_w < t_cw;
            t_c := t_c + 1;
            t_w := t_w - t_cw;
          end loop;
          t_h := workbook.sheets( s ).comments( c ).height;
          t_xxx := t_xxx || ( '<x:Anchor>' || workbook.sheets( s ).comments( c ).column || ',15,' ||
                     workbook.sheets( s ).comments( c ).row || ',30,' ||
                     ( workbook.sheets( s ).comments( c ).column + t_c - 1 ) || ',' || round( t_w ) || ',' ||
                     ( workbook.sheets( s ).comments( c ).row + 1 + trunc( t_h / 20 ) ) || ',' || mod( t_h, 20 ) || '</x:Anchor>' );
          t_xxx := t_xxx || ( '<x:AutoFill>False</x:AutoFill><x:Row>' ||
            ( workbook.sheets( s ).comments( c ).row - 1 ) || '</x:Row><x:Column>' ||
            ( workbook.sheets( s ).comments( c ).column - 1 ) || '</x:Column></x:ClientData></v:shape>' );
        end loop;
        t_xxx := t_xxx || '</xml>';
        add1xml( t_excel, 'xl/drawings/vmlDrawing' || s || '.vml', t_xxx );
      end if;
--
      s := workbook.sheets.next( s );
    end loop;
    t_xxx := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>';
    s := workbook.sheets.first;
    while s is not NULL
    loop
      t_xxx := t_xxx || ( '
<Relationship Id="rId' || ( 9 + s ) || '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet' || s || '.xml"/>' );
      s := workbook.sheets.next( s );
    end loop;
    t_xxx := t_xxx || '</Relationships>';
    add1xml( t_excel, 'xl/_rels/workbook.xml.rels', t_xxx );
    addtxt2utf8blob_init( t_yyy );
    addtxt2utf8blob( '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="' || workbook.str_cnt || '" uniqueCount="' || workbook.strings.count() || '">'
                  , t_yyy
                  );
    for i in 0 .. workbook.str_ind.count() - 1
    loop
      addtxt2utf8blob( '<si><t xml:space="preserve">' || dbms_xmlgen.convert( substr( workbook.str_ind( i ), 1, 32000 ) ) || '</t></si>', t_yyy );
    end loop;
    addtxt2utf8blob( '</sst>', t_yyy );
    addtxt2utf8blob_finish( t_yyy );
    add1file( t_excel, 'xl/sharedStrings.xml', t_yyy );
    finish_zip( t_excel );
    clear_workbook;
    return t_excel;
  end;
--
  PROCEDURE save
    ( p_directory VARCHAR2
    , p_filename VARCHAR2
    )
  is
  BEGIN
    blob2file( finish, p_directory, p_filename );
  end;
--
  PROCEDURE query2sheet
    ( p_c in out integer
    , p_column_headers boolean := TRUE
    , p_directory VARCHAR2 := NULL
    , p_filename VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    , p_UseXf boolean := false
    )
  is
    t_sheet PLS_INTEGER;
    t_col_cnt integer;
    t_desc_tab dbms_sql.desc_tab2;
    d_tab dbms_sql.date_table;
    n_tab dbms_sql.number_table;
    v_tab dbms_sql.varchar2_table;
    t_bulk_size PLS_INTEGER := 200;
    t_r integer;
    t_cur_row PLS_INTEGER;
    t_useXf boolean := g_useXf;
    TYPE tp_XfIds IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    t_XfIds tp_XfIds;
  BEGIN
    if p_sheet is NULL
    then
      new_sheet;
    end if;
    t_sheet := coalesce( p_sheet, workbook.sheets.count() );
    setUseXf( TRUE );
    dbms_sql.describe_columns2( p_c, t_col_cnt, t_desc_tab );
    for c in 1 .. t_col_cnt
    loop
      if p_column_headers
      then
        cell( c, 1, t_desc_tab( c ).col_name, p_sheet => t_sheet );
      end if;
      case
        when t_desc_tab( c ).col_TYPE in ( 2, 100, 101 )
        then
          dbms_sql.define_array( p_c, c, n_tab, t_bulk_size, 1 );
        when t_desc_tab( c ).col_TYPE in ( 12, 178, 179, 180, 181, 231 )
        then
          dbms_sql.define_array( p_c, c, d_tab, t_bulk_size, 1 );
          t_XfIds(c) := get_XfId( t_sheet, c, NULL, get_numFmt( 'dd/mm/yyyy' ) );
        when t_desc_tab( c ).col_TYPE in ( 1, 8, 9, 96, 112 )
        then
          dbms_sql.define_array( p_c, c, v_tab, t_bulk_size, 1 );
        else
          NULL;
      end case;
    end loop;
--
    setUseXf( p_UseXf );
    t_cur_row := case when p_column_headers then 2 else 1 end;
--
    loop
      t_r := dbms_sql.fetch_rows( p_c );
      if t_r > 0
      then
        for c in 1 .. t_col_cnt
        loop
          case
            when t_desc_tab( c ).col_TYPE in ( 2, 100, 101 )
            then
              dbms_sql.column_value( p_c, c, n_tab );
              for i in 0 .. t_r - 1
              loop
                if n_tab( i + n_tab.first() ) is not NULL
                then
                  cell( c, t_cur_row + i, n_tab( i + n_tab.first() ), p_sheet => t_sheet );
                end if;
              end loop;
              n_tab.delete;
            when t_desc_tab( c ).col_TYPE in ( 12, 178, 179, 180, 181, 231 )
            then
              dbms_sql.column_value( p_c, c, d_tab );
              for i in 0 .. t_r - 1
              loop
                if d_tab( i + d_tab.first() ) is not NULL
                then
                  if g_useXf
                  then
                    cell( c, t_cur_row + i, d_tab( i + d_tab.first() ), p_sheet => t_sheet );
                  else
                    query_date_cell( c, t_cur_row + i, d_tab( i + d_tab.first() ), t_sheet, t_XfIds(c) );
                  end if;
                end if;
              end loop;
              d_tab.delete;
            when t_desc_tab( c ).col_TYPE in ( 1, 8, 9, 96, 112 )
            then
              dbms_sql.column_value( p_c, c, v_tab );
              for i in 0 .. t_r - 1
              loop
                if v_tab( i + v_tab.first() ) is not NULL
                then
                  cell( c, t_cur_row + i, v_tab( i + v_tab.first() ), p_sheet => t_sheet );
                end if;
              end loop;
              v_tab.delete;
            else
              NULL;
          end case;
        end loop;
      end if;
      exit when t_r != t_bulk_size;
      t_cur_row := t_cur_row + t_r;
    end loop;
    dbms_sql.close_cursor( p_c );
    if ( p_directory is not NULL and  p_filename is not NULL )
    then
      save( p_directory, p_filename );
    end if;
    setUseXf( t_useXf );
  EXCEPTION
    when others
    then
      if dbms_sql.is_open( p_c )
      then
        dbms_sql.close_cursor( p_c );
      end if;
      setUseXf( t_useXf );
  end;
--
  PROCEDURE query2sheet
    ( p_sql VARCHAR2
    , p_column_headers boolean := TRUE
    , p_directory VARCHAR2 := NULL
    , p_filename VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    , p_UseXf boolean := false
    )
  is
    t_c integer;
    t_r integer;
  BEGIN
    t_c := dbms_sql.open_cursor;
    dbms_sql.parse( t_c, p_sql, dbms_sql.native );
    t_r := dbms_sql.execute( t_c );
    query2sheet
      ( p_c => t_c
      , p_column_headers => p_column_headers
      , p_directory => p_directory
      , p_filename => p_filename
      , p_sheet => p_sheet
      , p_UseXf => p_UseXf
      );
  end;
--
  PROCEDURE query2sheet
    ( p_rc in out sys_refcursor
    , p_column_headers boolean := TRUE
    , p_directory VARCHAR2 := NULL
    , p_filename VARCHAR2 := NULL
    , p_sheet PLS_INTEGER := NULL
    , p_UseXf boolean := false
    )
  is
    t_c integer;
    t_r integer;
  BEGIN
    t_c := dbms_sql.to_cursor_number( p_rc );
    query2sheet
      ( p_c => t_c
      , p_column_headers => p_column_headers
      , p_directory => p_directory
      , p_filename => p_filename
      , p_sheet => p_sheet
      , p_UseXf => p_UseXf
      );
  end;
--
  PROCEDURE setUseXf( p_val boolean := TRUE )
  is
  BEGIN
    g_useXf := p_val;
  end;
--
end;
/

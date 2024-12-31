CREATE OR REPLACE PACKAGE BODY sys_k_pdf_builder AS
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
  --                                  administrativos de creacion archivos PDF
  --  see http://technology.amis.nl/blog/8650/as_pdf-generating-a-pdf-document-with-some-plsql
  ---------------------------------------------------------------------------
  --
  TYPE tp_objects_tab IS TABLE OF NUMBER(10) INDEX BY PLS_INTEGER;
  TYPE tp_pages_tab IS TABLE OF BLOB INDEX BY PLS_INTEGER;
  TYPE tp_char_width_tab IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  --
  TYPE tp_font IS RECORD( 
    char_width_tab  tp_char_width_tab, 
    standard        BOOLEAN, 
    family          VARCHAR2(100), 
    style           VARCHAR2(2), -- N Normal, I Italic, B Bold, BI Bold Italic
    subtype         VARCHAR2(15) := 'Type1',
    name            VARCHAR2(100),
    encoding        VARCHAR2(100) := 'WINDOWS-1252'
  );
  --
  TYPE tp_font_tab IS TABLE OF tp_font INDEX BY PLS_INTEGER;
  TYPE tp_pls_tab IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  --
  TYPE tp_img is record( 
    adler32     VARCHAR2(8)
    , width     PLS_INTEGER
    , height    PLS_INTEGER
    , color_res PLS_INTEGER
    , color_tab RAW(768)
    , greyscale BOOLEAN
    , pixels    BLOB
    , TYPE      VARCHAR2(5)
    , nr_colors PLS_INTEGER
  );
  --
  TYPE tp_img_tab IS TABLE OF tp_img  INDEX BY  PLS_INTEGER;
  --
  -- pacakges globals
  pdf_doc       BLOB; -- the blob containing the build PDF document
  objects_tab   tp_objects_tab;
  pages_tab     tp_pages_tab;
  settings      tp_settings;
  fonts         tp_font_tab;
  used_fonts    tp_pls_tab;
  images        tp_img_tab;
  t_ncharset    VARCHAR2(1000);
  t_lan_ter     VARCHAR2(1000);
  --
  PROCEDURE init_core_fonts IS
    --
    FUNCTION init_standard_withs( 
        p_compressed_tab IN VARCHAR2 
      ) RETURN tp_char_width_tab IS
      --
      t_rv    tp_char_width_tab;
      t_tmp   RAW(32767);
      --
    BEGIN
      --
      t_tmp := utl_compress.lz_uncompress( 
        utl_encode.base64_decode( utl_raw.cast_to_raw( p_compressed_tab ) ) 
      );
      --
      FOR i IN 0 .. 255 LOOP
        t_rv( i ) := utl_raw.cast_to_binary_integer( utl_raw.substr( t_tmp, i * 4 + 1, 4 ) );
      END LOOP;
      --
      RETURN t_rv;
      --
    END init_standard_withs;
    --
  BEGIN
    --
    fonts( 1 ).family   := 'helvetica';
    fonts( 1 ).style    := 'N'; -- Normal
    fonts( 1 ).name     := 'Helvetica';
    fonts( 1 ).standard := TRUE;
    --
    fonts( 1 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC81Tuw3CMBC94FQMgMQOLAGVGzNCGtc0dAxAT+8lsgE7RKJFomOA' ||
      'SLT4frHjBEFJ8XSX87372C8A1Qr+Ax5gsWGYU7QBAK4x7gTnGLOS6xJPOd8w5NsM' ||
      '2OvFvQidAP04j1nyN3F7iSNny3E6DylPeeqbNqvti31vMpfLZuzH86oPdwaeo6X+' ||
      '5X6Oz5VHtTqJKfYRNVu6y0ZyG66rdcxzXJe+Q/KJ59kql+bTt5K6lKucXvxWeHKf' ||
      '+p6Tfersfh7RHuXMZjHsdUkxBeWtM60gDjLTLoHeKsyDdu6m8VK3qhnUQAmca9BG' ||
      'Dq3nP+sV/4FcD6WOf9K/ne+hdav+DTuNLeYABAAA'
    );
    --
    fonts( 2 ).family   := 'helvetica';
    fonts( 2 ).style    := 'I'; -- Italic
    fonts( 2 ).name     := 'Helvetica-Oblique';
    fonts( 2 ).standard := TRUE;
    --
    fonts( 2 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC81Tuw3CMBC94FQMgMQOLAGVGzNCGtc0dAxAT+8lsgE7RKJFomOA' || 
      'SLT4frHjBEFJ8XSX87372C8A1Qr+Ax5gsWGYU7QBAK4x7gTnGLOS6xJPOd8w5NsM' || 
      '2OvFvQidAP04j1nyN3F7iSNny3E6DylPeeqbNqvti31vMpfLZuzH86oPdwaeo6X+' || 
      '5X6Oz5VHtTqJKfYRNVu6y0ZyG66rdcxzXJe+Q/KJ59kql+bTt5K6lKucXvxWeHKf' || 
      '+p6Tfersfh7RHuXMZjHsdUkxBeWtM60gDjLTLoHeKsyDdu6m8VK3qhnUQAmca9BG' || 
      'Dq3nP+sV/4FcD6WOf9K/ne+hdav+DTuNLeYABAAA'
    );
    --
    fonts( 3 ).family   := 'helvetica';
    fonts( 3 ).style    := 'B'; -- Bold
    fonts( 3 ).name     := 'Helvetica-Bold';
    fonts( 3 ).standard := TRUE;
    --
    fonts( 3 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC8VSsRHCMAx0SJcBcgyRJaBKkxXSqKahYwB6+iyRTbhLSUdHRZUB' || 
      'sOWXLF8SKCn+ZL/0kizZuaJ2/0fn8XBu10SUF28n59wbvoCr51oTD61ofkHyhBwK' || 
      '8rXusVaGAb4q3rXOBP4Qz+wfUpzo5FyO4MBr39IH+uLclFvmCTrz1mB5PpSD52N1' || 
      'DfqS988xptibWfbw9Sa/jytf+dz4PqQz6wi63uxxBpCXY7uUj88jNDNy1mYGdl97' || 
      '856nt2f4WsOFed4SpzumNCvlT+jpmKC7WgH3PJn9DaZfA42vlgh96d+wkHy0/V95' || 
      'xyv8oj59QbvBN2I/iAuqEAAEAAA='
    );
    --
    fonts( 4 ).family   := 'helvetica';
    fonts( 4 ).style    := 'BI'; -- Bold Italic
    fonts( 4 ).name     := 'Helvetica-BoldOblique';
    fonts( 4 ).standard := TRUE;
    --
    fonts( 4 ).char_width_tab := init_standard_withs ( 
      'H4sIAAAAAAAAC8VSsRHCMAx0SJcBcgyRJaBKkxXSqKahYwB6+iyRTbhLSUdHRZUB' || 
      'sOWXLF8SKCn+ZL/0kizZuaJ2/0fn8XBu10SUF28n59wbvoCr51oTD61ofkHyhBwK' || 
      '8rXusVaGAb4q3rXOBP4Qz+wfUpzo5FyO4MBr39IH+uLclFvmCTrz1mB5PpSD52N1' || 
      'DfqS988xptibWfbw9Sa/jytf+dz4PqQz6wi63uxxBpCXY7uUj88jNDNy1mYGdl97' || 
      '856nt2f4WsOFed4SpzumNCvlT+jpmKC7WgH3PJn9DaZfA42vlgh96d+wkHy0/V95' || 
      'xyv8oj59QbvBN2I/iAuqEAAEAAA='
    );
    --
    fonts( 5 ).family   := 'times';
    fonts( 5 ).style    := 'N'; -- Normal
    fonts( 5 ).name     := 'Times-Roman';
    fonts( 5 ).standard := TRUE;
    --
    fonts( 5 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC8WSKxLCQAyG+3Bopo4bVHbwHGCvUNNT9AB4JEwvgUBimUF3wCNR' || 
      'qAoGRZL9twlQikR8kzTvZBtF0SP6O7Ej1kTnSRfEhHw7+Jy3J4XGi8w05yeZh2sE' || 
      '4j312ZDeEg1gvSJy6C36L9WX1urr4xrolfrSrYmrUCeDPGMu5+cQ3Ur3OXvQ+TYf' || 
      '+2FGexOZvTM1L3S3o5fJjGQJX2n68U2ur3X5m3cTvfbxsk9pcsMee60rdTjnhNkc' || 
      'Zip9HOv9+7/tI3Oif3InOdV/oLdx3gq2HIRaB1Ob7XPk35QwwxDyxg3e09Dv6nSf' || 
      'rxQjvty8ywDce9CXvdF9R+4y4o+7J1P/I9sABAAA'
    );
    --
    fonts( 6 ).family   := 'times';
    fonts( 6 ).style    := 'I'; -- Italic
    fonts( 6 ).name     := 'Times-Italic';
    fonts( 6 ).standard := TRUE;
    --
    fonts( 6 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC8WSPQ6CQBCFF+i01NB5g63tPcBegYZTeAB6SxNLjLUH4BTEeAYr' || 
      'Kwpj5ezsW2YgoKXFl2Hnb9+wY4x5m7+TOOJMdIFsRywodkfMBX9aSz7bXGp+gj6+' || 
      'R4TvOtJ3CU5Eq85tgGsbxG3QN8iFZY1WzpxXwkckFTR7e1G6osZGWT1bDuBnTeP5' || 
      'KtW/E71c0yB2IFbBphuyBXIL9Y/9fPvhf8se6vsa8nmeQtU6NSf6ch9fc8P9DpqK' || 
      'cPa5/I7VxDwruTN9kV3LDvQ+h1m8z4I4x9LIbnn/Fv6nwOdyGq+d33jk7/cxztyq' || 
      'XRhTz/it7Mscg7fT5CO+9ahnYk20Hww5IrwABAAA'
    );
    --
    fonts( 7 ).family   := 'times';
    fonts( 7 ).style    := 'B'; -- Bold
    fonts( 7 ).name     := 'Times-Bold';
    fonts( 7 ).standard := TRUE;
    --
    fonts( 7 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC8VSuw3CQAy9XBqUAVKxAZkgHQUNEiukySxpqOjTMQEDZIrUDICE' || 
      'RHUVVfy9c0IQJcWTfbafv+ece7u/Izs553cgAyN/APagl+wjgN3XKZ5kmTg/IXkw' || 
      'h4JqXUEfAb1I1VvwFYysk9iCffmN4+gtccSr5nlwDpuTepCZ/MH0FZibDUnO7MoR' || 
      'HXdDuvgjpzNxgevG+dF/hr3dWfoNyEZ8Taqn+7d7ozmqpGM8zdMYruFrXopVjvY2' || 
      'in9gXe+5vBf1KfX9E6TOVBsb8i5iqwQyv9+a3Gg/Cv+VoDtaQ7xdPwfNYRDji09g' || 
      'X/FvLNGmO62B9jSsoFwgfM+jf1z/SPwrkTMBOkCTBQAEAAA='
    );
    --
    fonts( 8 ).family   := 'times';
    fonts( 8 ).style    := 'BI'; -- Bold Italic
    fonts( 8 ).name     := 'Times-BoldItalic';
    fonts( 8 ).standard := TRUE;
    --
    fonts( 8 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC8WSuw2DMBCGHegYwEuECajIAGwQ0TBFBnCfPktkAKagzgCRIqWi' || 
      'oso9fr+Qo5RB+nT2ve+wMWYzf+fgjKmOJFelPhENnS0xANJXHfwHSBtjfoI8nMMj' || 
      'tXo63xKW/Cx9ONRn3US6C/wWvYeYNr+LH2IY6cHGPkJfvsc5kX7mFjF+Vqs9iT6d' || 
      'zwEL26y1Qz62nWlvD5VSf4R9zPuon/ne+C45+XxXf5lnTGLTOZCXPx8v9Qfdjdid' || 
      '5vD/f/+/pE/Ur14kG+xjTHRc84pZWsC2Hjk2+Hgbx78j4Z8W4DlL+rBnEN5Bie6L' || 
      'fsL+1u/InuYCdsdaeAs+RxftKfGdfQDlDF/kAAQAAA=='
    );
    --
    fonts( 9 ).family   := 'courier';
    fonts( 9 ).style    := 'N'; -- Normal
    fonts( 9 ).name     := 'Courier';
    fonts( 9 ).standard := TRUE;
    --
    FOR i IN 0 .. 255 LOOP
      --
      fonts( 9 ).char_width_tab( i ) := 600;
      --
    END LOOP;
    --
    fonts( 10 ).family          := 'courier';
    fonts( 10 ).style           := 'I'; -- Italic
    fonts( 10 ).name            := 'Courier-Oblique';
    fonts( 10 ).standard        := TRUE;
    fonts( 10 ).char_width_tab  := fonts( 9 ).char_width_tab;
    --
    fonts( 11 ).family          := 'courier';
    fonts( 11 ).style           := 'BI'; -- Bold
    fonts( 11 ).name            := 'Courier-Bold';
    fonts( 11 ).standard        := TRUE;
    fonts( 11 ).char_width_tab  := fonts( 9 ).char_width_tab;
    --
    fonts( 12 ).family          := 'courier';
    fonts( 12 ).style           := 'BI'; -- Bold Italic
    fonts( 12 ).name            := 'Courier-BoldOblique';
    fonts( 12 ).standard        := TRUE;
    fonts( 12 ).char_width_tab  := fonts( 9 ).char_width_tab;
    --
    fonts( 13 ).family    := 'symbol';
    fonts( 13 ).style     := 'N'; -- Normal
    fonts( 13 ).name      := 'Symbol';
    fonts( 13 ).standard  := TRUE;
    --
    fonts( 13 ).char_width_tab := init_standard_withs( 
      'H4sIAAAAAAAAC82SIU8DQRCFZ28xIE+cqcbha4tENKk/gQCJJ6AweIK9H1CHqKnp' || 
      'D2gTFBaDIcFwCQkJSTG83fem7SU0qYNLvry5nZ25t7NnZkv7c8LQrFhAP6GHZvEY' || 
      'HOB9ylxGubTfNVRc34mKpFonzBQ/gUZ6Ds7AN6i5lv1dKv8Ab1eKQYSV4hUcgZFq' || 
      'J/Sec7fQHtdTn3iqfvdrb7m3e2pZW+xDG3oIJ/Li3gfMr949rlU74DyT1/AuTX1f' || 
      'YGhOzTP8B0/RggsEX/I03vgXPrrslZjfM8/pGu40t2ZjHgud97F7337mXP/GO4h9' || 
      '3WmPPaOJ/jrOs9yC52MlrtUzfWupfTX51X/L+13Vl/J/s4W2S3pSfSh5DmeXerMf' || 
      '+LXhWQAEAAA='
    );
    --
    fonts( 14 ).family    := 'zapfdingbats';
    fonts( 14 ).style     := 'N'; -- Normal
    fonts( 14 ).name      := 'ZapfDingbats';
    fonts( 14 ).standard  := TRUE;
    --
    fonts( 14 ).char_width_tab := init_standard_withs
      ( 'H4sIAAAAAAAAC83ROy9EQRjG8TkzjdJl163SSHR0EpdsVkSi2UahFhUljUKUIgoq' || 
        'CrvJCtFQyG6EbSSERGxhC0ofQAQFxbIi8T/7PoUPIOEkvzxzzsycdy7O/fUTtToX' || 
        'bnCuvHPOV8gk4r423ovkGQ5od5OTWMeesmBz/RuZIWv4wCAY4z/xjipeqflC9qAD' || 
        'aRwxrxkJievSFzrRh36tZ1zttL6nkGX+A27xrLnttE/IBji9x7UvcIl9nPJ9AL36' || 
        'd1L9hyihoDW10L62cwhNyhntryZVExYl3kMj+zym+CrJv6M8VozPmfr5L8uwJORL' || 
        'tox7NFHG/Obj79FlwhqZ1X292xn6CbAXP/fjjv6rJYyBtUdl1vxEO6fcRB7bMmJ3' || 
        'GYZsTN0GdrDL/Ao5j1GZNr5kwqydX5z1syoiYEq5gCtlSrXi+mVbi3PfVAuhoQAE' || 
        'AAA='
      );
    --
  END init_core_fonts;
  --
  FUNCTION pdf_string( 
      p_txt IN BLOB 
    ) RETURN BLOB IS
    --
    t_rv    BLOB;
    t_ind   INTEGER;
    --
    TYPE tp_tab_raw IS TABLE OF raw(1);
    --
    tab_raw tp_tab_raw := tp_tab_raw( 
      utl_raw.cast_to_raw( '\' ), 
      utl_raw.cast_to_raw( '(' ), 
      utl_raw.cast_to_raw( ')' )
    );
    --
  BEGIN
    --
    t_rv := p_txt;
    --
    FOR i IN tab_raw.FIRST .. tab_raw.LAST LOOP 
      --
      t_ind := -1;
      --
      LOOP
        --
        t_ind := dbms_lob.instr( t_rv, tab_raw( i ), t_ind + 2 );
        --
        EXIT WHEN t_ind <= 0;
        --
        dbms_lob.copy( t_rv, t_rv, dbms_lob.lobmaxsize, t_ind + 1, t_ind );
        dbms_lob.copy( t_rv, tab_raw( 1 ), 1, t_ind, 1 );
        --
      END LOOP;
      --
    END LOOP;
    --
    RETURN t_rv;
    --
  END pdf_string;
  --
  FUNCTION raw2num( 
      p_value IN RAW 
    ) RETURN NUMBER IS
  BEGIN -- note: FFFFFFFF => -1
    --
    RETURN utl_raw.cast_to_binary_integer( p_value );
    --
  END raw2num;
  --
  FUNCTION to_char_round( 
      p_value     IN NUMBER, 
      p_precision IN PLS_INTEGER := 2 
    ) RETURN VARCHAR2 IS
  BEGIN
    --
    RETURN rtrim( rtrim( to_char( p_value, rpad( '9999999990D'
                                               , 11 + p_precision
                                               , '0'
                                               )
                                , 'NLS_NUMERIC_CHARACTERS = ''.,''' ), '0' )
                , '.'
                );
    --
  END to_char_round;
  --
  FUNCTION file2blob( 
      p_dir       IN VARCHAR2, 
      p_file_name IN VARCHAR2 
    ) RETURN BLOB IS
    --
    file_lob  BFILE;
    file_blob BLOB;
    --
  BEGIN
    --
    file_lob := bfilename( p_dir, p_file_name );
    --
    dbms_lob.open( file_lob, dbms_lob.file_readonly );
    dbms_lob.createtemporary( file_blob, TRUE );
    dbms_lob.loadfromfile( file_blob, file_lob, dbms_lob.lobmaxsize );
    dbms_lob.close( file_lob );
    --
    RETURN file_blob;
    --
    EXCEPTION
      WHEN OTHERS THEN
        --
        IF dbms_lob.isopen( file_lob ) = 1 THEN
          --
          dbms_lob.close( file_lob );
          --
        END IF;
        --
        IF dbms_lob.istemporary( file_blob ) = 1 THEN
          --
          dbms_lob.freetemporary( file_blob );
          --
        END IF;
        --
        RAISE;
        --
  END file2blob;
--
  PROCEDURE raw2pdfDoc( 
      p_txt IN BLOB 
    ) IS
  BEGIN
    --
    dbms_lob.append( 
      pdf_doc, 
      p_txt 
    );
    --
  END raw2pdfDoc;
  --
  PROCEDURE add2pdfDoc( 
      p_txt IN VARCHAR2 
    ) IS
  BEGIN
    --
    raw2pdfDoc( 
      utl_raw.concat( 
        utl_raw.cast_to_raw( p_txt ), 
        hextoraw( '0D0A' ) 
      ) 
    );
    --
  END add2pdfDoc;
  --
  FUNCTION add_object2pdfDoc( 
      p_txt IN VARCHAR2 := null 
    ) RETURN NUMBER IS
    --
    t_self NUMBER(10);
    --
  BEGIN
    --
    t_self := objects_tab.COUNT();
    --
    objects_tab( t_self ) := dbms_lob.getlength( pdf_doc );
    add2pdfDoc( t_self || ' 0 obj' );
    --
    IF p_txt IS NOT NULL THEN
      --
      add2pdfDoc( '<<' || p_txt || '>>' || chr(13) || chr(10) || 'endobj' );
      --
    END IF;
    --
    RETURN t_self;
    --
  END add_object2pdfDoc;
  --
  PROCEDURE add_object2pdfDoc( 
      p_txt IN VARCHAR2 := null 
    ) IS
    --
    t_self NUMBER(10);
    --
  BEGIN
    --
    t_self := add_object2pdfDoc( p_txt );
    --
  END add_object2pdfDoc;
  --
  FUNCTION adler32( 
      p_src IN BLOB 
    ) RETURN VARCHAR2 IS
    --
    s1 PLS_INTEGER := 1;
    s2 PLS_INTEGER := 0;
    --
  BEGIN
    --
    FOR i in 1 .. dbms_lob.getlength( p_src ) LOOP
      --
      s1 := mod( 
                s1 + utl_raw.cast_to_binary_integer( 
                  dbms_lob.substr( p_src, 1, i ) 
                ), 
                65521 
      );
      --
      s2 := mod( 
                  s2 + s1, 
                  65521
               );
      --
    END LOOP;
    --
    RETURN to_char( s2, 'fm0XXX' ) || to_char( s1, 'fm0XXX' );
    --
  END adler32;
  --
  FUNCTION flate_encode( 
      p_val IN BLOB 
    ) RETURN BLOB IS
    --
    t_cpr blob;
    t_blob blob;
    --
  BEGIN
    --
    t_cpr := utl_compress.lz_compress( p_val );
    t_blob := hextoraw( '789C' );
    dbms_lob.copy( t_blob, t_cpr, dbms_lob.getlength( t_cpr ) - 10 - 8, 3, 11 );
    dbms_lob.append( t_blob, hextoraw( adler32( p_val ) ) );
    dbms_lob.freetemporary( t_cpr );
    --
    RETURN t_blob;
    --
  END flate_encode;
  --
  PROCEDURE put_stream( 
      p_stream    IN BLOB, 
      p_compress  IN BOOLEAN := TRUE, 
      p_extra     IN VARCHAR2 := '' 
    ) IS
    --
    t_blob BLOB;
    --
  BEGIN
    --
    IF p_compress THEN
      --
      t_blob := Flate_encode( p_stream );
      put_stream( t_blob, false, '/Filter /FlateDecode ' || p_extra );
      dbms_lob.freetemporary( t_blob );
      --
    ELSE
      --
      add2pdfDoc( '/Length ' || dbms_lob.getlength( p_stream ) || p_extra || ' >>' );
      add2pdfDoc( 'stream' );
      raw2pdfDoc( p_stream );
      add2pdfDoc( 'endstream' );
      --
    END IF;
    --
  END put_stream;
  --
  FUNCTION add_stream( 
      p_stream    IN BLOB, 
      p_extra     IN VARCHAR2 := '', 
      p_compress  IN BOOLEAN := TRUE 
    ) RETURN NUMBER IS
      --
      t_self NUMBER(10);
      --
  BEGIN
    --
    t_self := add_object2pdfDoc;
    --
    add2pdfDoc( '<<' );
    put_stream( p_stream, p_compress, p_extra );
    add2pdfDoc( 'endobj' );
    --
    RETURN t_self;
    --
  END add_stream;
  --
  FUNCTION add_info RETURN NUMBER IS
    --
    t_banner varchar2(1000);
    --
  BEGIN
    --
    BEGIN
      --
      SELECT 'running on ' || replace( replace( replace( substr( banner, 1, 950), '\', '\\' ), '(', '\(' ), ')', '\)' )
        INTO t_banner
        FROM v$version
       WHERE instr( upper( banner ), 'DATABASE' ) > 0;
      --
      t_banner := '/Producer (' || t_banner || ')';
      --
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
    END;
    --
    RETURN add_object2pdfDoc(  
      '/CreationDate (D:' || to_char( sysdate, 'YYYYMMDDhh24miss' ) || ')'|| 
      '/Creator (AS-PDF mini 0.2.0 by Anton Scheffer)'|| 
      t_banner
    );
    --
  END add_info;
  --
  FUNCTION add_font( 
      p_index IN PLS_INTEGER 
    ) RETURN NUMBER IS
    --
  BEGIN
    --
    RETURN add_object2pdfDoc(  
      '/TYPE/Font' || 
      '/Subtype/' || 
      fonts( p_index ).subtype || 
      '/BaseFont/' || 
      fonts( p_index ).name || 
      '/Encoding/WinAnsiEncoding' -- code page 1252
    );
    --
  END add_font;
  --
  PROCEDURE add_image( 
      p_img IN tp_img 
    ) IS
    --
    t_self    NUMBER(10);
    t_pallet  NUMBER(10);
    --
  BEGIN
    --
    IF p_img.color_tab IS NOT NULL THEN
      --
      t_pallet := add_stream( p_img.color_tab );
      --
    ELSE
      --
      t_pallet := add_object2pdfDoc; -- add an empty object
      add2pdfDoc( 'endobj' );
      --
    END IF;
    --
    t_self := add_object2pdfDoc;
    --
    add2pdfDoc( '<</TYPE /XObject /Subtype /Image' );
    add2pdfDoc( ' /Width ' || to_char( p_img.width ) || ' /Height ' || to_char( p_img.height ) );
    add2pdfDoc( '/BitsPerComponent ' || to_char( p_img.color_res ) );
    --
    IF p_img.color_tab IS NULL THEN
      --
      IF p_img.greyscale THEN
        --
        add2pdfDoc( '/ColorSpace /DeviceGray' );
        --
      ELSE
        --
        add2pdfDoc( '/ColorSpace /DeviceRGB' );
        --
      END IF;
      --
    ELSE
      --
      add2pdfDoc( '/ColorSpace [/Indexed /DeviceRGB ' || to_char( utl_raw.length( p_img.color_tab ) / 3 - 1 ) || ' ' || to_char( t_pallet ) || ' 0 R]' );
      --
    END IF;
    --
    IF p_img.TYPE = 'jpg' THEN
      --
      put_stream( 
        p_img.pixels, 
        false, 
        '/Filter /DCTDecode' 
      );
      --
    ELSIF p_img.TYPE = 'png' THEN
      --
      put_stream( 
        p_img.pixels, 
        false, 
        ' /Filter /FlateDecode /DecodeParms <</Predictor 15 /Colors ' || 
        p_img.nr_colors || 
        '/BitsPerComponent ' || 
        p_img.color_res || 
        ' /Columns ' || 
        p_img.width || 
        ' >>' 
      );
      --
    ELSE
      --
      put_stream( p_img.pixels );
      --
    END IF;
    --
    add2pdfDoc( 'endobj' );
    --
  END add_image;
  --
  FUNCTION add_resources RETURN NUMBER IS
    --
    t_ind     PLS_INTEGER;
    t_self    NUMBER(10);
    t_fonts   tp_objects_tab;
    --
  BEGIN
    --
    t_ind := used_fonts.FIRST;
    --
    WHILE t_ind IS NOT NULL LOOP
      --
      t_fonts( t_ind )  := add_font( t_ind );
      t_ind             := used_fonts.next( t_ind );
      --
    END LOOP;
    --
    t_self := add_object2pdfDoc;
    --
    add2pdfDoc( '<</ProcSet [/PDF /Text]' );
    add2pdfDoc( '/Font' );
    add2pdfDoc( '  <<' );
    --
    t_ind := used_fonts.FIRST;
    --
    WHILE t_ind IS NOT NULL LOOP
      --
      add2pdfDoc( '    /F' || to_char( t_ind ) || ' ' || to_char( t_fonts( t_ind ) ) || ' 0 R' );
      t_ind := used_fonts.next( t_ind );
      --
    END LOOP;
    --
    add2pdfDoc( '  >>' );
    --
    IF images.count() > 0 THEN
      --
      add2pdfDoc( '/XObject <<' );
      --
      FOR i in images.FIRST .. images.LAST LOOP
        --
        add2pdfDoc( '    /I' || to_char( i ) || ' ' || to_char( t_self + 2 * i ) || ' 0 R' );
        --
      END LOOP;
      --
      add2pdfDoc( '>>' );
      --
    END IF;
    --
    add2pdfDoc( '>>' );
    add2pdfDoc( 'endobj' );
    --
    IF images.count() > 0 THEN
      --
      FOR i IN images.FIRST .. images.LAST LOOP
        --
        add_image( images( i ) );
        --
      END LOOP;
      --
    END IF;
    --
    RETURN t_self;
    --
  END add_resources;
  --
  PROCEDURE add_page( 
      p_page_nr     IN PLS_INTEGER,
      p_parent      IN NUMBER,
      p_resources   IN NUMBER
    ) IS
    --
    t_content NUMBER(10);
    --
  BEGIN
    --
    t_content := add_stream( pages_tab( p_page_nr ) );
    add_object2pdfDoc;
    --
    add2pdfDoc( '<< /TYPE /Page' );
    add2pdfDoc( '/Parent ' || to_char( p_parent ) || ' 0 R' );
    add2pdfDoc( '/Contents ' || to_char( t_content ) || ' 0 R' );
    add2pdfDoc( '/Resources ' || to_char( p_resources ) || ' 0 R' );
    add2pdfDoc( '>>' );
    add2pdfDoc( 'endobj' );
    --
  END add_page;
  --
  FUNCTION add_pages RETURN NUMBER IS
    --
    t_self        NUMBER(10);
    t_resources   NUMBER(10);
    --
  BEGIN
    --
    t_resources := add_resources;
    t_self      := add_object2pdfDoc;
    --
    add2pdfDoc( '<</TYPE/Pages/Kids [' );
    --
    FOR i IN pages_tab.FIRST .. pages_tab.LAST LOOP
      --
      add2pdfDoc( to_char( t_self + i * 2 + 2 ) || ' 0 R' );
      --
    END LOOP;
    --
    add2pdfDoc( ']' );
    add2pdfDoc( '/Count ' || pages_tab.count() );
    add2pdfDoc( '/MediaBox [0 0 ' || to_char_round( settings.page_width, 0 ) || ' ' || to_char_round( settings.page_height, 0 ) || ']' );
    add2pdfDoc( '>>' );
    add2pdfDoc( 'endobj' );
    --
    FOR i IN pages_tab.FIRST .. pages_tab.LAST LOOP
      --
      add_page( i, t_self, t_resources );
      --
    END LOOP;
    --
    RETURN t_self;
    --
  END add_pages;
  --
  FUNCTION add_catalogue RETURN NUMBER IS
  BEGIN
    --
    RETURN add_object2pdfDoc(  
      '/TYPE/Catalog' || 
      '/Pages ' || 
      to_char( add_pages ) || ' 0 R' || 
      '/OpenAction [0 /XYZ null null 1]'
    );
    --
  END add_catalogue;
  --
  PROCEDURE finish_pdf IS
    --
    t_xref      NUMBER(10);
    t_info      NUMBER(10);
    t_catalogue NUMBER(10);
    --
  BEGIN
    --
    add2pdfDoc( '%PDF-1.3' );
    --
    raw2pdfDoc( hextoraw( '25E2E3CFD30D0A' ) ); -- add a hex comment
    --
    t_info      := add_info;
    t_catalogue := add_catalogue;
    t_xref      := dbms_lob.getlength( pdf_doc );
    --
    add2pdfDoc( 'xref' );
    add2pdfDoc( '0 ' || to_char( objects_tab.count() ) );
    add2pdfDoc( '0000000000 65535 f ' );
    --
    FOR i in 1 .. objects_tab.count() - 1 LOOP
      --
      add2pdfDoc( to_char( objects_tab( i ), 'fm0000000000' ) || ' 00000 n' );  -- this line should be exactly 20 bytes, including EOL
      --
    END LOOP;
    --
    add2pdfDoc( 'trailer' );
    add2pdfDoc( '<< /Root ' || to_char( t_catalogue ) || ' 0 R' );
    add2pdfDoc( '/Info ' || to_char( t_info ) || ' 0 R' );
    add2pdfDoc( '/Size ' || to_char( objects_tab.count()  ) );
    add2pdfDoc( '>>' );
    add2pdfDoc( 'startxref' );
    add2pdfDoc( to_char( t_xref ) );
    add2pdfDoc( '%%EOF' );
    --
    objects_tab.delete;
    FOR i IN pages_tab.FIRST .. pages_tab.LAST LOOP
      --
      dbms_lob.freetemporary( pages_tab( i ) );
      --
    END LOOP;
    --
    pages_tab.delete;
    fonts.delete;
    used_fonts.delete;
    --
    IF images.count() > 0 THEN
      --
      FOR i IN images.FIRST .. images.LAST LOOP
        --
        IF dbms_lob.istemporary( images( i ).pixels ) = 1 THEN
          --
          dbms_lob.freetemporary( images( i ).pixels );
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    images.delete;
    settings := null;
    --
  END finish_pdf;
  --
  FUNCTION get_settings RETURN tp_settings IS
  BEGIN
    --
    RETURN settings;
    --
  END get_settings;
--
  procedure new_page
  is
  begin
    pages_tab( pages_tab.count() ) := null;
    dbms_lob.createtemporary( pages_tab( pages_tab.count() - 1 ), TRUE );
--
    settings.x := settings.margin_left;
    settings.y := settings.page_height - settings.margin_top - nvl( settings.current_fontsizePt, 12 );
    settings.page_nr := pages_tab.count();
--
    IF settings.current_font IS NOT NULL
    THEN
      add2page( 'BT /F' || settings.current_font || ' ' ||
                to_char_round( settings.current_fontsizePt ) || ' Tf ET'
              );
    END IF;
  END;
--
  FUNCTION parse_png( p_img_blob in blob )
  RETURN tp_img
  is
    t_img tp_img;
    buf raw(32767);
    len integer;
    ind integer;
    color_type PLS_INTEGER;
  begin
    IF rawtohex( dbms_lob.substr( p_img_blob, 8, 1 ) ) != '89504E470D0A1A0A'
    THEN -- not the right signature
      RETURN null;
    END IF;
    dbms_lob.createtemporary( t_img.pixels, TRUE );
    ind := 9;
    LOOP
      len := raw2num( dbms_lob.substr( p_img_blob, 4, ind ) ); -- length
      exit WHEN len is null or ind > dbms_lob.getlength( p_img_blob );
      case utl_raw.cast_to_varchar2( dbms_lob.substr( p_img_blob, 4, ind + 4 ) ) -- Chunk TYPE
      WHEN 'IHDR'
      THEN
        t_img.width := raw2num( dbms_lob.substr( p_img_blob, 4, ind + 8 ) );
        t_img.height := raw2num( dbms_lob.substr( p_img_blob, 4, ind + 12 ) );
        t_img.color_res := raw2num( dbms_lob.substr( p_img_blob, 1, ind + 16 ) );
        color_type := raw2num( dbms_lob.substr( p_img_blob, 1, ind + 17 ) );
        t_img.greyscale := color_type in ( 0, 4 );
        WHEN 'PLTE'
        THEN
          t_img.color_tab := dbms_lob.substr( p_img_blob, len, ind + 8 );
        WHEN 'IDAT'
        THEN
          dbms_lob.append( t_img.pixels, dbms_lob.substr( p_img_blob, len, ind + 8 ) );
        WHEN 'IEND'
        THEN
          exit;
        ELSE
          null;
      END case;
      ind := ind + 4 + 4 + len + 4; -- Length + Chunk TYPE + Chunk data + CRC
    END LOOP;
--
    t_img.TYPE := 'png';
    t_img.nr_colors := case color_type WHEN 0 THEN 1 WHEN 2 THEN 3 WHEN 3 THEN 1 WHEN 4 THEN 2 ELSE 4 END;
--
    RETURN t_img;
  END;
--
  FUNCTION parse_jpg( p_img_blob in blob )
  RETURN tp_img
  is
    buf raw(4);
    t_img tp_img;
    t_ind integer;
  begin
    IF (  dbms_lob.substr( p_img_blob, 2, 1 ) != hextoraw( 'FFD8' )  -- SOI Start of Image
       or dbms_lob.substr( p_img_blob, 2, dbms_lob.getlength( p_img_blob ) - 1 )  != hextoraw( 'FFD9' )  -- EOI END of Image
       )
    THEN -- this is not a jpg I can handle
      RETURN null;
    END IF;
--
    t_img.pixels := p_img_blob;
    t_img.TYPE := 'jpg';
    IF dbms_lob.substr( t_img.pixels, 2, 3 ) in ( hextoraw( 'FFE0' ) -- a APP0 jpg
                                                , hextoraw( 'FFE1' ) -- a APP1 jpg
                                                )
    THEN
      t_img.color_res := 8;
      t_img.height := 1;
      t_img.width := 1;
--
      t_ind := 3;
      t_ind := t_ind + 2 + raw2num( dbms_lob.substr( t_img.pixels, 2, t_ind + 2 ) );
      LOOP
        buf := dbms_lob.substr( t_img.pixels, 2, t_ind );
        exit WHEN buf = hextoraw( 'FFDA' ); -- SOS Start of Scan
        exit WHEN buf = hextoraw( 'FFD9' ); -- EOI END Of Image
        exit WHEN substr( rawtohex( buf ), 1, 2 ) != 'FF';
        IF rawtohex( buf ) in ( 'FFD0' -- RSTn
                              , 'FFD1'
                              , 'FFD2'
                              , 'FFD3'
                              , 'FFD4'
                              , 'FFD5'
                              , 'FFD6'
                              , 'FFD7'
                              , 'FF01' -- TEM
                              )
        THEN
          t_ind := t_ind + 2;
        ELSE
          IF buf = hextoraw( 'FFC0' ) -- SOF0 (Start Of Frame 0) marker
          THEN
            t_img.color_res := raw2num( dbms_lob.substr( t_img.pixels, 1, t_ind + 4 ) );
            t_img.height := raw2num( dbms_lob.substr( t_img.pixels, 2, t_ind + 5 ) );
            t_img.width := raw2num( dbms_lob.substr( t_img.pixels, 2, t_ind + 7 ) );
          END IF;
          t_ind := t_ind + 2 + raw2num( dbms_lob.substr( t_img.pixels, 2, t_ind + 2 ) );
        END IF;
      END LOOP;
    END IF;
--
    RETURN t_img;
  END;
  --
  FUNCTION parse_img( 
      p_blob    IN BLOB, 
      p_type    IN VARCHAR2 := null, 
      p_adler32 IN VARCHAR2 := null 
    ) RETURN tp_img IS
    --
    img tp_img;
    t_type varchar2(5) := p_type;
    --
  BEGIN
    --
    IF t_type IS NULL THEN
      --
      IF rawtohex( dbms_lob.substr( p_blob, 8, 1 ) ) = '89504E470D0A1A0A' THEN
        --
        t_type := 'png';
        --
      ELSE
        --
        t_type := 'jpg';
        --
      END IF;
      --
    END IF;
    --
    img :=  CASE lower( t_type )
              WHEN 'png' THEN parse_png( p_blob )
              WHEN 'jpg' THEN parse_jpg( p_blob )
            END;
    --
    IF img.width IS NOT NULL THEN
      --
      img.adler32 := nvl( p_adler32, adler32( p_blob ) );
      --
    END IF;
    --
    RETURN img;
    --
  END parse_img;
  --
  PROCEDURE init IS
  BEGIN
    --
    t_ncharset := nls_charset_name( 
      nls_charset_id( 'NCHAR_CS' ) 
    );
    --
    t_lan_ter  := substr( 
      sys_context( 'userenv', 'LANGUAGE' ), 
      1, 
      instr( sys_context( 'userenv', 'LANGUAGE' ), '.' ) 
    );
    --      
    dbms_lob.createtemporary( 
      lob_loc => pdf_doc, 
      cache   => TRUE 
    );
    --
    settings := null;
    --
    objects_tab.DELETE;
    pages_tab.DELETE;
    fonts.DELETE;
    used_fonts.DELETE;
    images.DELETE;
    --
    objects_tab( 0 ) := 0;
    --
    init_core_fonts;
    set_format;
    set_margins;
    new_page;
    set_font( 'helvetica' );
    --
  END init;
--
  FUNCTION get_pdf
  RETURN blob
  is
  begin
    finish_pdf;
    RETURN pdf_doc;
  END;
  --
  PROCEDURE save_pdf( 
        p_dir       IN VARCHAR2 := 'APP_OUTDIR',
        p_filename  IN VARCHAR2 := 'my.pdf'
    ) IS
      --
      t_fh utl_file.file_type;
      t_len PLS_INTEGER := 32767;
      --
  BEGIN
    --
    t_fh := utl_file.fopen( p_dir, p_filename, 'wb' );
    --
    finish_pdf;
    --
    FOR i in 0 .. trunc( ( dbms_lob.getlength( pdf_doc ) - 1 ) / t_len ) LOOP
      --
      utl_file.put_raw( t_fh, dbms_lob.substr( pdf_doc, t_len, i * t_len + 1 ) );
      --
    END LOOP;
    --
    utl_file.fclose( t_fh );
    --
    dbms_lob.freetemporary( pdf_doc );
    --
  END save_pdf;
  --
  PROCEDURE show_pdf IS
  BEGIN
    --
    finish_pdf;
    --
    owa_util.mime_header( 'application/pdf', false );
    --
    htp.print( 'Content-Length: ' || dbms_lob.getlength( pdf_doc ) );
    htp.print( 'Content-disposition: inline' );
    htp.print( 'Content-Description: Generated by as_xslfo2pdf' );
    --
    owa_util.http_header_close;
    wpg_docload.download_file( pdf_doc );
    dbms_lob.freetemporary( pdf_doc );
    --
  END show_pdf;
  --
  FUNCTION conv2user_units( 
      p_value IN NUMBER, 
      p_unit  IN VARCHAR2 
    ) RETURN NUMBER IS
  BEGIN
    --
    RETURN CASE lower( p_unit )
             WHEN 'mm'    THEN p_value * 72 / 25.4
             WHEN 'cm'    THEN p_value * 72 / 2.54
             WHEN 'pt'    THEN p_value -- also point
             WHEN 'point' THEN p_value
             WHEN 'inch'  THEN p_value * 72
             WHEN 'in'    THEN p_value * 72 -- also inch
             WHEN 'pica'  THEN p_value * 12
             WHEN 'p'     THEN p_value * 12 -- also pica
             WHEN 'pc'    THEN p_value * 12 -- also pica
             WHEN 'em'    THEN p_value * 12 -- also pica
             WHEN 'px'    THEN p_value-- pixel voorlopig op point zetten
             WHEN 'px'    THEN p_value * 0.8 -- pixel
             ELSE null
           END;
    --
  END conv2user_units;
--
  procedure set_format
    ( p_format IN VARCHAR2 := 'A4'
    , p_orientation IN VARCHAR2 := 'PORTRAIT'
    )
  is
    t_tmp NUMBER;
  begin
    case upper( p_format )
      WHEN 'A3'
      THEN
        settings.page_height := conv2user_units( 420, 'mm' );
        settings.page_width  := conv2user_units( 297, 'mm' );
      WHEN 'A4'
      THEN
        settings.page_height := conv2user_units( 297, 'mm' );
        settings.page_width  := conv2user_units( 210, 'mm' );
      WHEN 'A5'
      THEN
        settings.page_height := conv2user_units( 210, 'mm' );
        settings.page_width  := conv2user_units( 148, 'mm' );
      WHEN 'A6'
      THEN
        settings.page_height := conv2user_units( 148, 'mm' );
        settings.page_width  := conv2user_units( 105, 'mm' );
      WHEN 'LEGAL'
      THEN
        settings.page_height := conv2user_units( 356, 'mm' );
        settings.page_width  := conv2user_units( 216, 'mm' );
      WHEN 'LETTER'
      THEN
        settings.page_height := conv2user_units( 279, 'mm' );
        settings.page_width  := conv2user_units( 216, 'mm' );
      ELSE
        null;
    END case;
--
    case
      WHEN upper( p_orientation ) in ( 'L', 'LANDSCAPE' )
      THEN
        IF settings.page_height > settings.page_width
        THEN
          t_tmp := settings.page_height;
          settings.page_height := settings.page_width;
          settings.page_width := t_tmp;
        END IF;
      WHEN upper( p_orientation ) in ( 'P', 'PORTRAIT' )
      THEN
        IF settings.page_height < settings.page_width
        THEN
          t_tmp := settings.page_height;
          settings.page_height := settings.page_width;
          settings.page_width := t_tmp;
        END IF;
      ELSE
        null;
    END case;
  END;
--
  procedure set_pagesize
    ( p_width IN NUMBER
    , p_height IN NUMBER
    , p_unit IN VARCHAR2 := 'cm'
    )
  is
  begin
    settings.page_width  := conv2user_units( p_width, p_unit );
    settings.page_height := conv2user_units( p_height, p_unit );
  END;
--
  procedure set_margins
    ( p_top IN NUMBER := 3
    , p_left IN NUMBER := 1
    , p_bottom IN NUMBER := 4
    , p_right IN NUMBER := 1
    , p_unit IN VARCHAR2 := 'cm'
    )
  is
  begin
    settings.margin_left   := conv2user_units( p_left, p_unit );
    settings.margin_right  := conv2user_units( p_right, p_unit );
    settings.margin_top    := conv2user_units( p_top, p_unit );
    settings.margin_bottom := conv2user_units( p_bottom, p_unit );
  END;
--
  procedure set_font
    ( p_family IN VARCHAR2
    , p_style  IN VARCHAR2 := 'N'
    , p_fontsizePt in PLS_INTEGER := null
    , p_encoding IN VARCHAR2 := 'WINDOWS-1252'
    )
  is
    t_style varchar2(100);
    t_family varchar2(100);
  begin
    IF (   p_family is null
       and p_style is null
       and p_fontsizePt is null
       )
    THEN
      RETURN;
    END IF;
    t_style := replace(
               replace(
               replace(
               replace(
               replace( upper( p_style )
                      , 'NORMAL', 'N' )
                      , 'REGULAR', 'N' )
                      , 'BOLD', 'B' )
                      , 'ITALIC', 'I' )
                      , 'OBLIQUE', 'I' );
    t_style := nvl( t_style, case WHEN settings.current_font is null THEN 'N' ELSE fonts( settings.current_font ).style END );
    t_family := nvl( lower( p_family ), case WHEN settings.current_font is null THEN 'helvetica' ELSE fonts( settings.current_font ).family END );
    for i in fonts.FIRST .. fonts.LAST
    LOOP
      IF (   fonts( i ).family = t_family
         and fonts( i ).style = t_style
         and lower( fonts( i ).encoding ) = lower( p_encoding )
         )
      THEN
        settings.current_font := i;
        settings.current_fontsizePt := coalesce( p_fontsizePt, settings.current_fontsizePt, 12 );
        settings.encoding := nvl( utl_i18n.map_charset( p_encoding, utl_i18n.generic_context, utl_i18n.iana_to_oracle )
                                , settings.encoding
                                );
        used_fonts( i ) := 0;
        IF pages_tab.count() > 0
        THEN
          add2page( 'BT /F' || i || ' '
                  || to_char_round( settings.current_fontsizePt ) || ' Tf ET'
                  );
        END IF;
        exit;
      END IF;
    END LOOP;
  END;
--
  FUNCTION nclob2blob( p_txt in nclob )
  RETURN blob
  is
  begin
    IF p_txt is null or p_txt = ''
    THEN
      RETURN null;
    END IF;
    RETURN utl_raw.convert( utl_raw.cast_to_raw( p_txt )
                          , t_lan_ter || settings.encoding
                          , t_lan_ter || t_ncharset
                          );
  END;
--
  procedure add2page( p_txt in blob )
  is
  begin
    dbms_lob.append( pages_tab( pages_tab.count() - 1 )
                   , p_txt
                   );
    dbms_lob.append( pages_tab( pages_tab.count() - 1 )
                   , hextoraw( '0D0A' )
                   );
  END;
--
  procedure add2page( p_txt in nclob )
  is
  begin
    add2page( nclob2blob( p_txt ) );
  END;
--
  procedure put_txt( p_x IN NUMBER, p_y IN NUMBER, p_txt in blob )
  is
  begin
    add2page( utl_raw.concat( utl_raw.cast_to_raw( 'BT ' )
                            , utl_raw.cast_to_raw( to_char_round( p_x ) || ' ' || to_char_round( p_y ) )
                            , utl_raw.cast_to_raw( ' Td (' )
                            , pdf_string( p_txt )
                            , utl_raw.cast_to_raw( ') Tj ET' )
                            )
            );
  END;
--
  procedure put_txt( p_x IN NUMBER, p_y IN NUMBER, p_txt in nclob )
  is
  begin
    IF p_txt IS NOT NULL
    THEN
      put_txt( p_x, p_y, nclob2blob( p_txt ) );
    END IF;
  END;
--
  FUNCTION string_width( p_txt in nclob )
  RETURN NUMBER
  is
    t_tmp blob;
    t_width NUMBER;
    t_char PLS_INTEGER;
  begin
    IF p_txt is null
    THEN
      RETURN 0;
    END IF;
--
    t_width := 0;
    t_tmp := nclob2blob( p_txt );
    for i in 1 .. dbms_lob.getlength( t_tmp )
    LOOP
      t_char := utl_raw.cast_to_binary_integer( dbms_lob.substr( t_tmp, 1, i ) );
      t_width := t_width
               + fonts( settings.current_font ).char_width_tab( t_char )
               * ( settings.current_fontsizePt / 1000 );
    END LOOP;
    RETURN t_width;
  END;
--
  procedure write
    ( p_txt in nclob
    , p_x IN NUMBER := null
    , p_y IN NUMBER := null
    , p_line_height IN NUMBER := null
    , p_start IN NUMBER := null  -- left side of the available text box
    , p_width IN NUMBER := null  -- width of the available text box
    , p_alignment IN VARCHAR2 := null
    )
  is
    t_x NUMBER := nvl( p_x, settings.x );
    t_y NUMBER := nvl( p_y, settings.y );
    t_line_height NUMBER := nvl( p_line_height, settings.current_fontsizePt );
    t_start NUMBER := nvl( p_start, settings.margin_right );
    t_width NUMBER := nvl( p_width
                         , settings.page_width - settings.margin_right
                         - settings.margin_left
                         );
    t_len NUMBER;
    t_cnt PLS_INTEGER;
    t_ind PLS_INTEGER;
  begin
    IF p_txt is null
    THEN
      RETURN;
    END IF;
--
    t_ind := instrc( p_txt, chr(10) );
    IF t_ind > 0
    THEN
      write( rtrim( substrc( p_txt, 1, t_ind - 1 ), chr(13) ), t_x, t_y, t_line_height, t_start, t_width, p_alignment );
      write( substrc( p_txt, t_ind + 1 ), t_start, t_y - t_line_height, t_line_height, t_start, t_width, p_alignment );
      RETURN;
    END IF;
    t_x := case WHEN t_x < 0 THEN t_start ELSE t_x END;
    t_y := case WHEN t_y < 0 THEN settings.y - t_line_height ELSE t_y END;
    t_len := string_width( p_txt );
    IF t_len > t_width - t_x + t_start
    THEN
      t_cnt := 0;
      WHILE (   instrc( p_txt, ' ', 1, t_cnt + 1 ) > 0
            and string_width( substrc( p_txt, 1, instrc( p_txt, ' ', 1, t_cnt + 1 ) - 1 ) ) <= t_width - t_x + t_start
            )
      LOOP
        t_cnt := t_cnt + 1;
      END LOOP;
      IF t_cnt > 0
      THEN
        write( substrc( p_txt, 1, instrc( p_txt, ' ', 1, t_cnt ) - 1 ), t_x, t_y, t_line_height, t_start, t_width, p_alignment );
        write( substrc( p_txt, instrc( p_txt, ' ', 1, t_cnt ) + 1 ), null, null, t_line_height, t_start, t_width, p_alignment );
      ELSE
        IF t_x > t_start
        THEN
          write( p_txt, t_start, t_y - t_line_height, t_line_height, t_start, t_width, p_alignment );
        ELSE
          t_ind := trunc( length( p_txt ) / 2 );
          write( substrc( p_txt, 1, t_ind ), t_x, t_y, t_line_height, t_start, t_width, p_alignment );
          write( substrc( p_txt, t_ind + 1 ), null, null, t_line_height, t_start, t_width, p_alignment );
        END IF;
      END IF;
    ELSE
      IF instr( p_alignment, 'right' ) > 0 or instr( p_alignment, 'END' ) > 0
      THEN
        t_x := t_start + t_width - t_len;
      ELSIF instr( p_alignment, 'center' ) > 0
      THEN
        t_x := ( t_width + t_x + t_start - string_width( p_txt ) ) / 2;
      END IF;
      put_txt( t_x, t_y, p_txt );
      settings.x := t_x + t_len + string_width( ' ' );
      settings.y := t_y ;
    END IF;
  END;
--
  FUNCTION rgb( p_hex_rgb IN VARCHAR2 )
  RETURN VARCHAR2
  is
  begin
    RETURN to_char_round( nvl( to_number( substr( ltrim( p_hex_rgb, '#' ), 1, 2 ), 'xx' ) / 255, 0 ), 5 ) || ' ' ||
           to_char_round( nvl( to_number( substr( ltrim( p_hex_rgb, '#' ), 3, 2 ), 'xx' ) / 255, 0 ), 5 ) || ' ' ||
           to_char_round( nvl( to_number( substr( ltrim( p_hex_rgb, '#' ), 5, 2 ), 'xx' ) / 255, 0 ), 5 ) || ' ';
  END;
--
  procedure set_color
    ( p_rgb IN VARCHAR2 := '000000'
    , p_backgr in boolean
    )
  is
  begin
    add2page( rgb( p_rgb ) || case WHEN p_backgr THEN 'RG' ELSE 'rg' END );
  END;
--
  procedure set_color( p_rgb IN VARCHAR2 := '000000' )
  is
  begin
    set_color( p_rgb, false );
  END;
--
  procedure set_color
    ( p_red IN NUMBER := 0
    , p_green IN NUMBER := 0
    , p_blue IN NUMBER := 0
    )
  is
  begin
    IF (   p_red between 0 and 255
       and p_blue between 0 and 255
       and p_green between 0 and 255
       )
    THEN
      set_color(  to_char( p_red, 'fm0x' )
               || to_char( p_green, 'fm0x' )
               || to_char( p_blue, 'fm0x' )
               , false
               );
    END IF;
  END;
--
  procedure set_bk_color( p_rgb IN VARCHAR2 := 'ffffff' )
  is
  begin
    set_color( p_rgb, TRUE );
  END;
--
  procedure set_bk_color
    ( p_red IN NUMBER := 255
    , p_green IN NUMBER := 255
    , p_blue IN NUMBER := 255
    )
  is
  begin
    IF (   p_red between 0 and 255
       and p_blue between 0 and 255
       and p_green between 0 and 255
       )
    THEN
      set_color(  to_char( p_red, 'fm0x' )
               || to_char( p_green, 'fm0x' )
               || to_char( p_blue, 'fm0x' )
               , TRUE
               );
    END IF;
  END;
--
  procedure horizontal_line
    ( p_x IN NUMBER
    , p_y IN NUMBER
    , p_width IN NUMBER
    , p_line_width IN NUMBER := 0.5
    , p_line_color IN VARCHAR2 := '000000'
    )
  is
    t_use_color boolean;
  begin
    add2page( 'q' );
    t_use_color := substr( p_line_color, -6 ) != '000000';
    IF t_use_color
    THEN
      set_color( p_line_color );
      set_bk_color( p_line_color );
    ELSE
      add2page( '0 g' );
    END IF;
    add2page(  to_char_round( p_x, 5 ) || ' '
            || to_char_round( p_y, 5 ) || ' '
            || to_char_round( p_width, 5 ) || ' '
            || to_char_round( p_line_width, 5 ) || ' re '
            || case WHEN t_use_color THEN 'b' ELSE 'f' END
            );
    add2page( 'Q' );
  END;
--
  procedure vertical_line
    ( p_x IN NUMBER
    , p_y IN NUMBER
    , p_height IN NUMBER
    , p_line_width IN NUMBER := 0.5
    , p_line_color IN VARCHAR2 := '000000'
    )
  is
  begin
    horizontal_line( p_x, p_y, p_line_width, p_height, p_line_color );
  END;
--
  procedure rect
    ( p_x IN NUMBER
    , p_y IN NUMBER
    , p_width IN NUMBER
    , p_height IN NUMBER
    , p_line_color IN VARCHAR2 := null
    , p_fill_color IN VARCHAR2 := null
    , p_line_width IN NUMBER := 0.5
    )
  is
  begin
    add2page( 'q' );
    IF substr( p_line_color, -6 ) != substr( p_fill_color, -6 )
    THEN
      add2page( to_char_round( p_line_width, 5 ) || ' w' );
    END IF;
    IF substr( p_line_color, -6 ) != '000000'
    THEN
      set_bk_color( p_line_color );
    ELSE
      add2page( '0 g' );
    END IF;
    IF p_fill_color IS NOT NULL
    THEN
      set_color( p_fill_color );
    END IF;
    add2page(  to_char_round( p_x, 5 ) || ' '
            || to_char_round( p_y, 5 ) || ' '
            || to_char_round( p_width, 5 ) || ' '
            || to_char_round( p_height, 5 ) || ' re '
            || case WHEN p_fill_color is null THEN 'S' ELSE 'b' END
            );
    add2page( 'Q' );
  END;
--
  procedure put_image
     ( p_dir IN VARCHAR2
     , p_file_name IN VARCHAR2
     , p_x IN NUMBER
     , p_y IN NUMBER
     , p_width IN NUMBER := null
     , p_height IN NUMBER := null
     )
  is
    t_blob blob;
  begin
    t_blob := file2blob( p_dir, p_file_name );
    put_image( t_blob, p_x, p_y, p_width, p_height );
    dbms_lob.freetemporary( t_blob );
  END;
--
  procedure put_image
     ( p_url IN VARCHAR2
     , p_x IN NUMBER
     , p_y IN NUMBER
     , p_width IN NUMBER := null
     , p_height IN NUMBER := null
     )
  is
    t_blob blob;
  begin
    t_blob := httpuritype( p_url ).getblob();
    put_image( t_blob, p_x, p_y, p_width, p_height );
    dbms_lob.freetemporary( t_blob );
  END;
--
  procedure put_image
     ( p_img in blob
     , p_x IN NUMBER
     , p_y IN NUMBER
     , p_width IN NUMBER := null
     , p_height IN NUMBER := null
     )
  is
    t_ind PLS_INTEGER;
    t_adler32 varchar2(8);
  begin
    IF p_img is null
    THEN
      RETURN;
    END IF;
    t_adler32 := adler32( p_img );
    t_ind := images.FIRST;
    WHILE t_ind IS NOT NULL
    LOOP
      exit WHEN images( t_ind ).adler32 = t_adler32;
      t_ind := images.next( t_ind );
    END LOOP;
--
    IF t_ind is null
    THEN
      t_ind := images.count() + 1;
      images( t_ind ) := parse_img( p_img, p_adler32 => t_adler32 );
    END IF;
--
    IF images( t_ind ).adler32 is null
    THEN
      images.delete( t_ind );
    ELSE
      add2page( 'q ' || to_char_round( nvl( p_width, images( t_ind ).width ) ) || ' 0 0 '
              || to_char_round( nvl( p_height, images( t_ind ).height ) ) || ' '
              || to_char_round( case WHEN p_x > 0 THEN p_x ELSE - p_x - images( t_ind ).width / 2 END ) || ' '
              || to_char_round( case WHEN p_y > 0 THEN p_y ELSE - p_y + images( t_ind ).height / 2 END ) || ' '
              || ' cm /I' || to_char( t_ind ) || ' Do Q'
              );
    END IF;
  END;
--
END sys_k_pdf_builder;
/


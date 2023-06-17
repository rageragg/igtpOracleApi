--------------------------------------------------------
--  DDL for Package Body SYS_K_ZIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "IGTP"."SYS_K_ZIP_UTIL" IS
    /*  
        Purpose:    Package handles zipping and unzipping of files
        
        Remarks:    by Anton Scheffer, see http://forums.oracle.com/forums/thread.jspa?messageID=9289744#9289744
                    for unzipping, see http://technology.amis.nl/blog/8090/parsing-a-microsoft-word-docx-and-unzip-zipfiles-with-plsql
                    for zipping, see http://forums.oracle.com/forums/thread.jspa?threadID=1115748&tstart=0
        Who     DATE        Description
        ------  ----------  --------------------------------
        MBR     09.01.2011  Created
        MBR     21.05.2012  Fixed a bug related to use of dbms_lob.substr IN 
                            get_file (use dbms_lob.copy instead)
    */
    --
    FUNCTION raw2num( p_value IN RAW ) RETURN NUMBER IS
    BEGIN                             
        --                  
        RETURN utl_raw.cast_to_binary_integer( p_value, utl_raw.little_endian );
        --
    END raw2num;
    --
    FUNCTION file2blob( p_dir       IN VARCHAR2,
                        p_file_name IN VARCHAR2
                      ) RETURN BLOB IS
        --              
        file_lob    bfile;
        file_blob   BLOB;
        --
    BEGIN
        --
        file_lob := bfilename( p_dir, p_file_name );
        --
        dbms_lob.open( file_lob, dbms_lob.file_readonly );
        dbms_lob.createtemporary( file_blob, true );
        dbms_lob.loadfromfile( file_blob, file_lob, dbms_lob.lobmaxsize );
        dbms_lob.close( file_lob );
        --
        RETURN file_blob;
        --
        EXCEPTION
            WHEN OTHERS THEN
                --
                IF dbms_lob.isopen( file_lob ) = 1 THEN
                    dbms_lob.close( file_lob );
                END IF;
                --
                IF dbms_lob.istemporary( file_blob ) = 1 THEN
                    dbms_lob.freetemporary( file_blob );
                END IF;
                --
                RAISE;
        --
    END file2blob;
    --
    FUNCTION raw2varchar2( p_raw IN RAW, 
                            p_encoding IN VARCHAR2 
                        ) RETURN VARCHAR2 IS
    BEGIN
        --
        RETURN nvl
                ( utl_i18n.raw_to_char( p_raw, p_encoding ), 
                  utl_i18n.raw_to_char( p_raw, 
                        utl_i18n.map_charset( p_encoding, 
                                              utl_i18n.generic_context, 
                                              utl_i18n.iana_to_oracle
                                            )
                  )
                );
        --        
    END raw2varchar2;
    --
    FUNCTION get_file_list( p_dir       IN VARCHAR2, 
                            p_zip_file  IN VARCHAR2, 
                            p_encoding  IN VARCHAR2 := NULL
                          ) RETURN t_file_list IS
    BEGIN
        --
        RETURN get_file_list( 
                    file2blob( p_dir, p_zip_file ), 
                    p_encoding
               );
        --
    END get_file_list;
    --
    FUNCTION get_file_list( p_zipped_blob   IN BLOB, 
                            p_encoding      IN VARCHAR2 := NULL
                          ) RETURN t_file_list IS
        --
        t_ind       INTEGER;
        t_hd_ind    INTEGER;
        t_rv        t_file_list;
        --
    BEGIN
        --
        t_ind := dbms_lob.getlength( p_zipped_blob ) - 21;
        --
        LOOP
            EXIT WHEN dbms_lob.substr( p_zipped_blob, 4, t_ind) = hextoraw( '504B0506' ) OR t_ind < 1;
            t_ind := t_ind - 1;
        END LOOP;
        --
        IF t_ind <= 0 THEN
            RETURN NULL;
        END if;
        --
        t_hd_ind := raw2num( dbms_lob.substr( p_zipped_blob, 4, t_ind + 16 ) ) + 1;
        t_rv := t_file_list();
        t_rv.extend( raw2num( dbms_lob.substr( p_zipped_blob, 2, t_ind + 10 ) ) );
        --
        FOR i IN 1 .. raw2num( dbms_lob.substr( p_zipped_blob, 2, t_ind + 8 ) ) LOOP
            --
            t_rv( i ) :=
                raw2varchar2
                    ( dbms_lob.substr( p_zipped_blob
                                    , raw2num( dbms_lob.substr( p_zipped_blob
                                                                , 2
                                                                , t_hd_ind + 28
                                                                ) )
                                    , t_hd_ind + 46
                                    )
                    , p_encoding
                    );
            
            t_hd_ind :=
                t_hd_ind
                + 46
                + raw2num( dbms_lob.substr( p_zipped_blob
                                        , 2
                                        , t_hd_ind + 28
                                        ) )
                + raw2num( dbms_lob.substr( p_zipped_blob
                                        , 2
                                        , t_hd_ind + 30
                                        ) )
                + raw2num( dbms_lob.substr( p_zipped_blob
                                        , 2
                                        , t_hd_ind + 32
                                        ) );
            --
        END LOOP;
        --
        RETURN t_rv;
        --
    END get_file_list;
    --
    FUNCTION get_file( p_dir        IN VARCHAR2, 
                       p_zip_file   IN VARCHAR2, 
                       p_file_name  IN VARCHAR2, 
                       p_encoding   IN VARCHAR2 := NULL
                     ) RETURN BLOB IS
    BEGIN
        --
        RETURN get_file( file2blob( p_dir, p_zip_file ), p_file_name, p_encoding );
        --
    END get_file;
    --
    FUNCTION get_file( p_zipped_blob    IN BLOB, 
                       p_file_name      IN VARCHAR2, 
                       p_encoding       IN VARCHAR2 := NULL
                     ) RETURN BLOB IS
        --
        t_tmp       BLOB;
        t_ind       INTEGER;
        t_hd_ind    INTEGER;
        t_fl_ind    INTEGER;
        --
    BEGIN
        --
        t_ind := dbms_lob.getlength( p_zipped_blob ) - 21;
        --
        LOOP
            EXIT WHEN dbms_lob.substr( p_zipped_blob, 4, t_ind ) = hextoraw( '504B0506' ) OR t_ind < 1;
            t_ind := t_ind - 1;
        END LOOP;
        --
        IF t_ind <= 0 THEN
            RETURN NULL;
        END if;
        --
        t_hd_ind := raw2num( dbms_lob.substr( p_zipped_blob
                                            , 4
                                            , t_ind + 16
                                            ) ) + 1;
        --
        FOR i IN 1 .. raw2num( dbms_lob.substr( p_zipped_blob, 2, t_ind + 8 ) ) LOOP
            --
            IF p_file_name =
                raw2varchar2
                    ( dbms_lob.substr( p_zipped_blob
                                    , raw2num( dbms_lob.substr( p_zipped_blob
                                                                , 2
                                                                , t_hd_ind + 28
                                                                ) )
                                    , t_hd_ind + 46
                                    )
                    , p_encoding
                    )
            THEN
                --
                IF dbms_lob.substr( p_zipped_blob, 2, t_hd_ind + 10 ) = hextoraw( '0800' ) THEN
                    --
                    t_fl_ind := raw2num( dbms_lob.substr( p_zipped_blob, 4, t_hd_ind + 42 ) );
                    -- gzip header
                    t_tmp := hextoraw( '1F8B0800000000000003' );  
                    --        
                    dbms_lob.copy( t_tmp
                                , p_zipped_blob
                                , raw2num( dbms_lob.substr( p_zipped_blob
                                                            , 4
                                                            , t_fl_ind + 19
                                                            ) )
                                , 11
                                ,   t_fl_ind
                                    + 31
                                    + raw2num( dbms_lob.substr( p_zipped_blob
                                                            , 2
                                                            , t_fl_ind + 27
                                                            ) )
                                    + raw2num( dbms_lob.substr( p_zipped_blob
                                                            , 2
                                                            , t_fl_ind + 29
                                                            ) )
                                );
                    --
                    dbms_lob.append( t_tmp
                                    , dbms_lob.substr( p_zipped_blob
                                                    , 4
                                                    , t_fl_ind + 15
                                                    )
                                    );
                    --
                    dbms_lob.append( t_tmp
                                    , dbms_lob.substr( p_zipped_blob, 4, t_fl_ind + 23 )
                                    );
                    --
                    RETURN utl_compress.lz_uncompress( t_tmp );
                    --
                END if;
                --
                IF dbms_lob.substr( p_zipped_blob
                                , 2
                                , t_hd_ind + 10
                                ) =
                            hextoraw( '0000' )
                                                -- The file IS stored (no compression)
                THEN
                t_fl_ind :=
                        raw2num( dbms_lob.substr( p_zipped_blob
                                                , 4
                                                , t_hd_ind + 42
                                                ) );

                dbms_lob.createtemporary(t_tmp, cache => true);
                
                dbms_lob.copy(dest_lob => t_tmp,
                                src_lob => p_zipped_blob,
                                amount => raw2num( dbms_lob.substr( p_zipped_blob, 4, t_fl_ind + 19)),
                                dest_offset => 1,
                                src_offset => t_fl_ind + 31 + raw2num(dbms_lob.substr(p_zipped_blob, 2, t_fl_ind + 27)) + raw2num(dbms_lob.substr( p_zipped_blob, 2, t_fl_ind + 29))
                            );
                            
                RETURN t_tmp;
                                                
                END if;
                
            END IF;
            --
            t_hd_ind :=
                t_hd_ind
                + 46
                + raw2num( dbms_lob.substr( p_zipped_blob
                                        , 2
                                        , t_hd_ind + 28
                                        ) )
                + raw2num( dbms_lob.substr( p_zipped_blob
                                        , 2
                                        , t_hd_ind + 30
                                        ) )
                + raw2num( dbms_lob.substr( p_zipped_blob
                                        , 2
                                        , t_hd_ind + 32
                                        ) );
            --
        END LOOP;
        --
        RETURN NULL;
        --
    END get_file;
    --
    FUNCTION little_endian( p_big IN NUMBER, p_bytes IN PLS_INTEGER := 4 ) RETURN RAW IS
    BEGIN
        --
        RETURN utl_raw.substr( 
                    utl_raw.cast_from_binary_integer( p_big, utl_raw.little_endian)
                    , 1
                    , p_bytes
        );
        --
    END little_endian;
    --
    PROCEDURE add_file( p_zipped_blob IN OUT BLOB, 
                        p_name IN VARCHAR2, 
                        p_content IN BLOB
                      ) IS
        --
        t_now   DATE;
        t_blob  BLOB;
        t_clen  INTEGER;
        --
    BEGIN
        --
        t_now := sysdate;
        t_blob := utl_compress.lz_compress( p_content );
        t_clen := dbms_lob.getlength( t_blob );
        --
        IF p_zipped_blob IS NULL THEN
            --
            dbms_lob.createtemporary( p_zipped_blob, true );
            --
        END if;
        --
        dbms_lob.append( 
                p_zipped_blob, 
                utl_raw.concat( 
                    hextoraw( '504B0304' )              -- Local file header signature
                    , hextoraw( '1400' )                  -- version 2.0
                    , hextoraw( '0000' )                  -- no General purpose bits
                    , hextoraw( '0800' )                  -- deflate
                    , little_endian(   
                        to_number( to_char( t_now
                                            , 'ss'
                                          ) ) / 2
                        + to_number( to_char( t_now
                                            , 'mi'
                                            ) ) * 32
                        + to_number( to_char( t_now
                                            , 'hh24'
                                            ) ) * 2048
                        , 2
                     )                                 -- File last modification time
                    , little_endian(   
                        to_number( to_char( t_now
                                            , 'dd'
                                            ) )
                        + to_number( to_char( t_now
                                            , 'mm'
                                            ) ) * 32
                        + ( to_number( to_char( t_now
                                            , 'yyyy'
                                            ) ) - 1980 ) * 512
                        , 2
                    )                                 -- File last modification DATE
                    , dbms_lob.substr( t_blob, 4, t_clen - 7 )                                         -- CRC-32
                    , little_endian( t_clen - 18 )                     -- compressed size
                    , little_endian( dbms_lob.getlength( p_content ) ) -- uncompressed size
                    , little_endian( length( p_name ), 2 )             -- File name length
                    , hextoraw( '0000' )                               -- Extra field length
                    , utl_raw.cast_to_raw( p_name )                    -- File name
                )
        );
        --
        dbms_lob.copy( p_zipped_blob
                    , t_blob
                    , t_clen - 18
                    , dbms_lob.getlength( p_zipped_blob ) + 1
                    , 11
        ); -- compressed content
        --
        dbms_lob.freetemporary( t_blob );
        --
    END add_file;
    --
    PROCEDURE finish_zip(
        p_zipped_blob IN OUT BLOB
    ) IS
        --
        t_cnt               PLS_INTEGER := 0;
        t_offs              INTEGER;
        t_offs_dir_header   INTEGER;
        t_offs_end_header   INTEGER;
        t_comment           RAW( 32767 ) := utl_raw.cast_to_raw( 'Implementation by Anton Scheffer' );
        --
    BEGIN
        --
        t_offs_dir_header := dbms_lob.getlength( p_zipped_blob );
        t_offs := dbms_lob.instr( p_zipped_blob, hextoraw( '504B0304' ), 1 );
        --
        WHILE t_offs > 0 LOOP
            --
            t_cnt := t_cnt + 1;
            --
            dbms_lob.append( 
                p_zipped_blob, 
                utl_raw.concat( 
                    hextoraw( '504B0102' ), -- Central directory file header signature
                    hextoraw( '1400' ),     -- version 2.0
                    dbms_lob.substr( p_zipped_blob, 26, t_offs + 4 ),
                    hextoraw( '0000' ),              -- File comment length
                    hextoraw( '0000' ),              -- Disk NUMBER where file starts
                    hextoraw( '0100' ),              -- Internal file attributes
                    hextoraw( '2000B681' ),          -- External file attributes
                    little_endian( t_offs - 1 ),     -- Relative offset of local file header
                    dbms_lob.substr( 
                        p_zipped_blob, 
                        utl_raw.cast_to_binary_integer( 
                            dbms_lob.substr( p_zipped_blob, 2, t_offs + 26 ), 
                            utl_raw.little_endian
                        ),
                        t_offs + 30
                    )                                                 -- File name
                )
            );
            --
            t_offs := dbms_lob.instr( p_zipped_blob, hextoraw( '504B0304' ), t_offs + 32 );
            --
        END LOOP;
        --
        t_offs_end_header := dbms_lob.getlength( p_zipped_blob );
        --
        dbms_lob.append( 
            p_zipped_blob
            , utl_raw.concat( 
                hextoraw( '504B0506' )       -- END of central directory signature
                , hextoraw( '0000' )                          -- NUMBER of this disk
                , hextoraw( '0000' )             -- Disk where central directory starts
                , little_endian( t_cnt, 2 )      -- NUMBER of central directory records on this disk
                , little_endian( t_cnt, 2 )      -- Total NUMBER of central directory records
                , little_endian( t_offs_end_header - t_offs_dir_header ) -- Size of central directory
                , little_endian( t_offs_dir_header ) -- Relative offset of local file header
                , little_endian( 
                    nvl( utl_raw.length( t_comment ), 0 )
                    , 2
                )  -- ZIP file comment length
                , t_comment
            )
        );
        --
    END finish_zip;
    --
    PROCEDURE save_zip( p_zipped_blob IN BLOB, 
                        p_dir IN VARCHAR2, 
                        p_filename IN VARCHAR2
                      ) IS
        --
        t_fh    utl_file.file_type;
        t_len   PLS_INTEGER := 32767;
        --
    BEGIN
        --
        t_fh := utl_file.fopen( p_dir, p_filename, 'wb' );
        --
        FOR i IN 0 .. trunc(  ( dbms_lob.getlength( p_zipped_blob ) - 1 ) / t_len ) LOOP
            --
            utl_file.put_raw( t_fh
                            , dbms_lob.substr( p_zipped_blob
                                            , t_len
                                            , i * t_len + 1
                                            )
            );
            --
        END LOOP;
        --
        utl_file.fclose( t_fh );
        --
    END;
    --
END sys_k_zip_util;

/

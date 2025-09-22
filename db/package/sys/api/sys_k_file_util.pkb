CREATE OR REPLACE PACKAGE BODY sys_k_file_util IS
    /*
        Purpose:      Package contains file utilities 
        Remarks:      
        
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     01.01.2005  Created
        MBR     18.01.2011  Added BLOB/CLOB operations
    */
    --
    FUNCTION resolve_filename (
            p_dir IN VARCHAR2,
            p_file_name IN VARCHAR2,
            p_os IN VARCHAR2 := g_os_windows
        ) RETURN VARCHAR2 IS 
        --
        l_returnvalue t_file_name;
        --
    BEGIN
        --
        IF lower(p_os) = g_os_windows THEN
            --
            IF substr(p_dir,-1) = g_dir_sep_win THEN
                l_returnvalue:=p_dir || p_file_name;
            ELSE
                --
                IF p_dir IS NOT NULL THEN
                    l_returnvalue:=p_dir || g_dir_sep_win || p_file_name;
                ELSE
                    l_returnvalue:=p_file_name;
                END IF;
                --
            END IF;
            --
        ELSIF lower(p_os) = g_os_unix THEN
            --
            IF substr(p_dir,-1) = g_dir_sep_unix THEN
                l_returnvalue:=p_dir || p_file_name;
            ELSE
                --
                IF p_dir IS NOT NULL THEN
                    l_returnvalue:=p_dir || g_dir_sep_unix || p_file_name;
                ELSE
                    l_returnvalue:=p_file_name;
                END IF;
                --
            END IF;
            --
        ELSE
            --
            l_returnvalue:=null;
            --
        END IF;
        --
        RETURN l_returnvalue;

    END resolve_filename;
    --                            
    FUNCTION extract_filename (
            p_file_name IN VARCHAR2,
            p_os IN VARCHAR2 := g_os_windows
        ) RETURN VARCHAR2 IS
        --
        l_returnvalue    t_file_name;
        l_dir_sep        t_dir_sep;
        l_dir_sep_pos    PLS_INTEGER;
        --
    BEGIN
        --
        IF lower(p_os) = g_os_windows THEN
            l_dir_sep:=g_dir_sep_win;
        ELSIF lower(p_os) = g_os_unix THEN
            l_dir_sep:=g_dir_sep_unix;
        END IF;
        --
        IF lower(p_os) in (g_os_windows, g_os_unix) THEN
            --
            l_dir_sep_pos:=instr(p_file_name, l_dir_sep, -1);
            --
            IF l_dir_sep_pos = 0 THEN
                -- no directory found
                l_returnvalue:=p_file_name;
                --
            ELSE
                -- copy filename part
                l_returnvalue:=sys_k_string_util.copy_str(p_file_name, l_dir_sep_pos + 1);
                --
            END IF;
            --
        ELSE
            l_returnvalue:=null;
        END IF;
        --
        RETURN l_returnvalue;
        --
    END extract_filename;
    --
    FUNCTION get_file_ext (p_file_name IN VARCHAR2) RETURN VARCHAR2 IS
        --
        l_sep_pos     PLS_INTEGER;
        l_returnvalue t_file_name;
        --
    BEGIN
        --
        l_sep_pos:=instr(p_file_name, g_file_ext_sep, -1);
        --
        IF l_sep_pos = 0 THEN
            -- no extension found
            l_returnvalue:=null;
            --
        ELSE
            -- copy extension
            l_returnvalue:=sys_k_string_util.copy_str(p_file_name, l_sep_pos + 1);
            --
        END IF;
        --
        RETURN l_returnvalue;
        --
    END get_file_ext;
    --
    FUNCTION strip_file_ext (p_file_name IN VARCHAR2) RETURN VARCHAR2 IS
        --
        l_sep_pos      PLS_INTEGER;
        l_file_ext     t_file_name;
        l_returnvalue  t_file_name;
        --
    BEGIN
        --
        l_file_ext:=get_file_ext (p_file_name);
        --
        IF l_file_ext IS NOT NULL THEN
            --
            l_sep_pos:=instr(p_file_name, g_file_ext_sep || l_file_ext, -1);
            -- copy everything except extension
            IF l_sep_pos > 0 THEN
                l_returnvalue := sys_k_string_util.copy_str(p_file_name, 1, l_sep_pos - 1);
            ELSE
                l_returnvalue := p_file_name;
            END IF;
            --
        ELSE
            l_returnvalue := p_file_name;
        END IF;
        --
        RETURN l_returnvalue;
        --
    END strip_file_ext;
    --
    FUNCTION get_filename_str (
            p_str       IN VARCHAR2,
            p_extension IN VARCHAR2 := null
        ) RETURN VARCHAR2 IS
        --
        l_returnvalue t_file_name;
        --
    BEGIN
        --
        l_returnvalue := replace(replace(replace(replace(trim(p_str), ' ', '_'), '\', '_'), '/', '_'), ':', '');
        --
        IF p_extension IS NOT NULL THEN
            l_returnvalue := l_returnvalue || '.' || p_extension;
        END IF;
        --
        RETURN l_returnvalue;
        --
    END get_filename_str;
    --
    FUNCTION get_blob_from_file (
            p_directory_name    IN VARCHAR2,
            p_file_name         IN VARCHAR2
        ) RETURN BLOB IS
        --
        l_bfile          bfile;
        l_returnvalue    BLOB;
        --
    BEGIN
        --
        dbms_lob.createtemporary (l_returnvalue, FALSE);
        l_bfile := bfilename (p_directory_name, p_file_name);
        dbms_lob.fileopen (l_bfile, dbms_lob.file_readonly);
        dbms_lob.loadfromfile (l_returnvalue, l_bfile, dbms_lob.getlength(l_bfile));
        dbms_lob.fileclose (l_bfile);
        --
        RETURN l_returnvalue;
        --
        EXCEPTION
            WHEN others THEN
                --
                IF dbms_lob.fileisopen (l_bfile) = 1 THEN
                    dbms_lob.fileclose (l_bfile);
                END IF;
                dbms_lob.freetemporary(l_returnvalue);
                raise;
        --
    END get_blob_from_file;
    --
    FUNCTION get_clob_from_file (
            p_directory_name    IN VARCHAR2,
            p_file_name         IN VARCHAR2
        ) RETURN CLOB IS
        --
        l_bfile             BFILE;
        l_returnvalue       CLOB;
        l_dest_offset       INTEGER := 1;
        l_src_offset        INTEGER := 1;
        l_bfile_csid        NUMBER  := 0;
        l_lang_context      INTEGER := 0;
        l_warning           INTEGER := 0;
        --
    BEGIN
        --
        dbms_lob.createtemporary (l_returnvalue, FALSE);
        --
        l_bfile := bfilename (p_directory_name, p_file_name);
        --
        dbms_lob.fileopen (l_bfile, dbms_lob.file_readonly);
        --
        dbms_lob.loadclobfromfile(
            dest_lob        => l_returnvalue,
            src_bfile       => l_bfile,
            amount          => dbms_lob.lobmaxsize,
            dest_offset     => l_dest_offset,
            src_offset      => l_src_offset,
            bfile_csid      => l_bfile_csid,
            lang_context    => l_lang_context,
            warning         => l_warning
        );
        --
        dbms_lob.fileclose (l_bfile);
        --
        RETURN l_returnvalue;
        --
        EXCEPTION
            WHEN others THEN
                --
                IF dbms_lob.fileisopen (l_bfile) = 1 THEN
                    dbms_lob.fileclose (l_bfile);
                END IF;
                --
                dbms_lob.freetemporary(l_returnvalue);
                --
                RAISE;
        --
    END get_clob_from_file;
    --
    PROCEDURE save_blob_to_file (
            p_directory_name    IN VARCHAR2,
            p_file_name         IN VARCHAR2,
            p_blob              IN BLOB
        ) IS
        --
        l_file      utl_file.file_type;
        l_buffer    RAW(32767);
        l_amount    BINARY_INTEGER := 32767;
        l_pos       INTEGER := 1;
        l_blob_len  INTEGER;
        --
    BEGIN
        --
        l_blob_len := dbms_lob.getlength (p_blob);
        --
        l_file := utl_file.fopen (p_directory_name, p_file_name, g_file_mode_write_byte, 32767);
        --
        WHILE l_pos < l_blob_len LOOP
            --
            dbms_lob.read (p_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw (l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
            --
        END LOOP;
        --
        utl_file.fclose (l_file);
        --
        EXCEPTION
            WHEN others THEN
                --
                IF utl_file.is_open (l_file) THEN
                    utl_file.fclose (l_file);
                END IF;
                raise;  
        --
    END save_blob_to_file;  
    --
    PROCEDURE save_clob_to_file (
            p_directory_name    IN VARCHAR2,
            p_file_name         IN VARCHAR2,
            p_clob              IN CLOB
        ) IS
        --
        l_file      utl_file.file_type;
        l_buffer    VARCHAR2(32767);
        l_amount    BINARY_INTEGER := 8000;
        l_pos       INTEGER := 1;
        l_clob_len  INTEGER;
        --
    BEGIN
        --    
        l_clob_len := dbms_lob.getlength (p_clob); 
        l_file := utl_file.fopen (p_directory_name, p_file_name, g_file_mode_write_text, 32767);
        --
        WHILE l_pos < l_clob_len LOOP
            --
            dbms_lob.read (p_clob, l_amount, l_pos, l_buffer);
            utl_file.put (l_file, l_buffer);
            utl_file.fflush (l_file);
            l_pos := l_pos + l_amount;
            --
        END LOOP;
        --
        utl_file.fclose (l_file);
        --
        EXCEPTION
            WHEN others THEN
                --
                IF utl_file.is_open (l_file) THEN
                    utl_file.fclose (l_file);
                END IF;
                RAISE;  
        --
    END save_clob_to_file;  
    --
    PROCEDURE save_clob_to_file_raw (
            p_directory_name    IN VARCHAR2,
            p_file_name         IN VARCHAR2,
            p_clob              IN CLOB
        ) IS
        --
        l_file       utl_file.file_type;
        l_chunk_size PLS_INTEGER := 3000;
        --
    BEGIN
        --
        l_file := utl_file.fopen (p_directory_name, p_file_name, g_file_mode_write_byte, max_linesize => 32767 );
        --
        FOR i in 1 .. ceil (length( p_clob ) / l_chunk_size) LOOP
            --
            utl_file.put_raw (l_file, utl_raw.cast_to_raw (substr(p_clob, ( i - 1 ) * l_chunk_size + 1, l_chunk_size )));
            utl_file.fflush(l_file);
            --
        END LOOP; 
        --
        utl_file.fclose (l_file);
        --
        EXCEPTION
            WHEN others THEN
                --
                IF utl_file.is_open (l_file) THEN
                    utl_file.fclose (l_file);
                END IF;
                raise;  
        --
    END save_clob_to_file_raw;  
    --
    FUNCTION file_exists (
            p_directory_name    IN VARCHAR2,
            p_file_name         IN VARCHAR2
        ) RETURN BOOLEAN IS
        --
        l_length      number;
        l_block_size  number; 
        l_returnvalue BOOLEAN := FALSE;
        --
    BEGIN
        --
        utl_file.fgetattr (p_directory_name, p_file_name, l_returnvalue, l_length, l_block_size);
        --
        RETURN l_returnvalue;
        --
    END file_exists;
    --
    FUNCTION fmt_bytes (p_bytes in number) RETURN VARCHAR2 IS
        --
        l_returnvalue sys_k_string_util.t_max_db_varchar2;
        --
    BEGIN
        --    
        l_returnvalue := CASE
                            WHEN p_bytes IS NULL THEN NULL
                            WHEN p_bytes < 1024 THEN to_char(p_bytes) || ' bytes'
                            WHEN p_bytes < 1048576 THEN to_char(round(p_bytes / 1024, 1)) || ' kB'
                            WHEN p_bytes < 1073741824 THEN to_char(round(p_bytes / 1048576, 1)) || ' MB'
                            WHEN p_bytes < 1099511627776 THEN to_char(round(p_bytes / 1073741824, 1)) || ' GB'
                            ELSE to_char(round(p_bytes / 1099511627776, 1)) || ' TB'
                        END;
        --
        RETURN l_returnvalue;
        --
    END fmt_bytes;
    --
END sys_k_file_util;
/


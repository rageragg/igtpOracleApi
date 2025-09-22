CREATE OR REPLACE PACKAGE sys_k_file_util IS
    --
    /*
        Purpose:      Package contains file utilities 
        Remarks: 

        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     01.01.2005  Created
        MBR     18.01.2011  Added BLOB/CLOB operations
    */
    --
    -- operating system types
    g_os_windows                   CONSTANT VARCHAR2(1) := 'w';
    g_os_unix                      CONSTANT VARCHAR2(1) := 'u';
    g_dir_sep_win                  CONSTANT VARCHAR2(1) := '\';
    g_dir_sep_unix                 CONSTANT VARCHAR2(1) := '/';
    g_file_ext_sep                 CONSTANT VARCHAR2(1) := '.';
    --
    -- file open modes
    g_file_mode_append_text        CONSTANT VARCHAR2(1) := 'a';
    g_file_mode_append_byte        CONSTANT VARCHAR2(2) := 'ab';
    g_file_mode_read_text          CONSTANT VARCHAR2(1) := 'r';
    g_file_mode_read_byte          CONSTANT VARCHAR2(2) := 'rb';
    g_file_mode_write_text         CONSTANT VARCHAR2(1) := 'w';
    g_file_mode_write_byte         CONSTANT VARCHAR2(2) := 'wb';
    g_file_name_def                VARCHAR2(2000);
    g_file_ext_def                 VARCHAR2(50);
    g_dir_sep_def                  VARCHAR2(1);
    --
    SUBTYPE t_file_name IS g_file_name_def%TYPE;
    SUBTYPE t_file_ext  IS g_file_ext_def%TYPE;
    SUBTYPE t_dir_sep   IS g_dir_sep_def%TYPE;
    --
    -- resolve filename
    FUNCTION resolve_filename ( 
        p_dir       IN VARCHAR2,
        p_file_name IN VARCHAR2,
        p_os        IN VARCHAR2 := g_os_windows
    ) RETURN VARCHAR2;
    --                         
    -- extract filename
    FUNCTION extract_filename ( 
        p_file_name IN VARCHAR2,
        p_os        IN VARCHAR2 := g_os_windows
    ) RETURN VARCHAR2;
    --                     
    -- get file extension    
    FUNCTION get_file_ext (
        p_file_name IN VARCHAR2
    ) RETURN VARCHAR2;
    --
    -- strip file extension
    FUNCTION strip_file_ext (
        p_file_name IN VARCHAR2
    ) RETURN VARCHAR2;
    --                         
    -- get filename string (no whitespace)
    FUNCTION get_filename_str ( 
        p_str       IN VARCHAR2,
        p_extension IN VARCHAR2 := null
    ) RETURN VARCHAR2;
    --
    -- get BLOB from file
    FUNCTION get_blob_from_file (
        p_directory_name    IN VARCHAR2,
        p_file_name         IN VARCHAR2
    ) RETURN BLOB;
    --
    -- get CLOB from file
    FUNCTION get_clob_from_file (
        p_directory_name    IN VARCHAR2,
        p_file_name         IN VARCHAR2
    ) RETURN CLOB;
    --
    -- save BLOB to file
    procedure save_blob_to_file (
        p_directory_name    IN VARCHAR2,
        p_file_name         IN VARCHAR2,
        p_blob              IN BLOB
    );  
    --
    -- save CLOB to file
    PROCEDURE save_clob_to_file (
        p_directory_name    IN VARCHAR2,
        p_file_name         IN VARCHAR2,
        p_clob              IN CLOB
    );  
    --
    -- save CLOB to file (raw)
    procedure save_clob_to_file_raw (
        p_directory_name    IN VARCHAR2,
        p_file_name         IN VARCHAR2,
        p_clob              IN CLOB
    );  
    --                           
    -- does file exist?
    FUNCTION file_exists (  
        p_directory_name    IN VARCHAR2,
        p_file_name         IN VARCHAR2
    ) RETURN BOOLEAN;
    --
    -- format bytes
    FUNCTION fmt_bytes (
        p_bytes IN number
    ) RETURN VARCHAR2;
    --
END sys_k_file_util;
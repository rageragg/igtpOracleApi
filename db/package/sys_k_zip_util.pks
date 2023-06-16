--------------------------------------------------------
--  DDL for Package sys_k_zip_util
--------------------------------------------------------

CREATE OR REPLACE PACKAGE sys_k_zip_util IS
    /*
        Purpose:    Package handles zipping and unzipping of files
        Remarks:    by Anton Scheffer, see http://forums.oracle.com/forums/thread.jspa?messageID=9289744#9289744
                    for unzipping, see http://technology.amis.nl/blog/8090/parsing-a-microsoft-word-docx-and-unzip-zipfiles-with-plsql
                    for zipping, see http://forums.oracle.com/forums/thread.jspa?threadID=1115748&tstart=0
        Who     Date        Description
        ------  ----------  --------------------------------
        MBR     09.01.2011  Created
    */
    --
    TYPE t_file_list IS TABLE OF CLOB;
    --
    FUNCTION get_file_list(
        p_dir       IN VARCHAR2,
        p_zip_file  IN VARCHAR2,
        p_encoding  IN VARCHAR2 := NULL
    ) RETURN t_file_list;
    --
    -- p_encoding IN VARCHAR2 := NULL Use CP850 for zip files created with a German Winzip to see umlauts, etc */
    FUNCTION get_file_list(
        p_zipped_blob   IN BLOB,
        p_encoding      IN VARCHAR2 := NULL
    ) RETURN t_file_list;
    --
    FUNCTION get_file(
        p_dir       IN VARCHAR2,
        p_zip_file  IN VARCHAR2,
        p_file_name IN VARCHAR2,
        p_encoding  IN VARCHAR2 := NULL
    ) RETURN BLOB;
    --
    FUNCTION get_file(
        p_zipped_blob   IN BLOB,
        p_file_name     IN VARCHAR2,
        p_encoding      IN VARCHAR2 := NULL
    ) RETURN BLOB;
    --
    PROCEDURE add_file(
        p_zipped_blob   IN OUT BLOB,
        p_name          IN VARCHAR2,
        p_content       IN BLOB
    );
    --
    PROCEDURE finish_zip(
        p_zipped_blob IN OUT BLOB
    );
    --
    PROCEDURE save_zip(
        p_zipped_blob   IN BLOB,
        p_dir           IN VARCHAR2,
        p_filename      IN VARCHAR2
    );
    --
END sys_k_zip_util;
/ 

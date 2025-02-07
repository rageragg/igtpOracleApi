DECLARE
    --
BEGIN
    --
    sys_k_pdf_builder.init;
    --
    sys_k_pdf_builder.set_font( 
        'helvetica', 
        'N', 
        20 
    );
    --
    sys_k_pdf_builder.write( 
        'TITULO DEL DOCUMENTO' 
    );
    --
    sys_k_pdf_builder.set_font( 
        'helvetica', 
        'N', 
        16 
    );
    --
    sys_k_pdf_builder.write( 
        'SUBTITULO DEL DOCUMENTO', 
        -1, 
        -1 
    );
    --
    sys_k_pdf_builder.write( 
        'The quick brown fox jumps over the lazy dog. 1234567890', 
        -1, 
        700 
    );
    --
    sys_k_pdf_builder.save_pdf;
    --
END;
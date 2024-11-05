BEGIN
    --
    -- ! se crea el archivo fisico (libro), en el directorio
    gc_k_gen_xls_mrd.create_excel(
        p_directory => 'APP_OUTDIR',
        p_file_name => 'reporte.xls'
    );
    --
    -- ! se agregan estilos para las celdas
    gc_k_gen_xls_mrd.create_style(
        p_style_name  => 'Estilo1',
        p_fontname    => 'Arial',
        p_fontcolor   => 'White',
        p_fontsize    => 9,
        p_bold        => True,
        p_italic      => True,
        p_underline   => 'False',
        p_backcolor   => 'Gray'
    );
    --
    gc_k_gen_xls_mrd.create_style(
      p_style_name  =>  'Normal_Right',
      p_fontsize    => 8,
      p_h_alignment => 'Right'
    );
    --
    gc_k_gen_xls_mrd.create_style(
      p_style_name  => 'Normal_Left',
      p_fontsize    => 8,
      p_h_alignment => 'Left'
    );
    --
    -- se crea una hoja en el libro
    gc_k_gen_xls_mrd.create_worksheet(
        p_worksheet_name => 'datos'
    );
    --
    -- ! se establece el ancho de columna
    gc_k_gen_xls_mrd.set_column_width(
        p_column    => 1, 
        p_width     => 200, 
        p_worksheet => 'datos'
    );
    --
    -- ! TITULOS DEL REPORTE
    gc_k_gen_xls_mrd.write_cell_char(
       p_row            => 1,
       p_column         => 1,
       p_worksheet_name => 'datos',
       p_value          => 'TITULO REPORTE',
       p_style          => 'Estilo1'
    );
    --
    -- ENCABEZADOS DE COLUMNA
    gc_k_gen_xls_mrd.write_cell_char(
       p_row            => 2,
       p_column         => 1,
       p_worksheet_name => 'datos',
       p_value          => 'BOLETOS',
       p_style          => 'Estilo1'
    );
    --
    gc_k_gen_xls_mrd.write_cell_char(
       p_row            => 2,
       p_column         => 2,
       p_worksheet_name => 'datos',
       p_value          => 'PESO',
       p_style          => 'Estilo1'
    );    
    -- 
    -- DETALLES
    gc_k_gen_xls_mrd.write_cell_char(
       p_row            => 3,
       p_column         => 1,
       p_worksheet_name => 'datos',
       p_value          => '12523-2255',
       p_style          => 'Normal_Left'
    );
    -- 
    gc_k_gen_xls_mrd.write_cell_num(
       p_row            => 3,
       p_column         => 2,
       p_worksheet_name => 'datos',
       p_value          => 750.70,
       p_style          => 'Normal_Right'
    );
    --
    gc_k_gen_xls_mrd.write_cell_char(
       p_row            => 4,
       p_column         => 1,
       p_worksheet_name => 'datos',
       p_value          => '2532-2555',
       p_style          => 'Normal_Left'
    );
    --
    gc_k_gen_xls_mrd.write_cell_num(
       p_row            => 4,
       p_column         => 2,
       p_worksheet_name => 'datos',
       p_value          => 685.50,
       p_style          => 'Normal_Right'
    );    
    --
    gc_k_gen_xls_mrd.close_file;
    --
end;
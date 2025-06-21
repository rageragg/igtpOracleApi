CREATE OR REPLACE FUNCTION numero_a_letras(
        p_numero IN NUMBER
    ) RETURN VARCHAR2 IS
    --
    TYPE t_array IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    --
    v_unidades t_array;
    v_decenas  t_array;
    v_centenas t_array;
    --
    v_num      NUMBER           := TRUNC(p_numero);
    v_letras   VARCHAR2(1024*4) := '';
    v_millones NUMBER;
    v_miles    NUMBER;
    v_cientos  NUMBER;
    --
BEGIN
    --
    -- Inicializar los arreglos
    v_unidades(1) := 'uno';    
    v_unidades(2) := 'dos';     
    v_unidades(3) := 'tres';
    v_unidades(4) := 'cuatro'; 
    v_unidades(5) := 'cinco';   
    v_unidades(6) := 'seis';
    v_unidades(7) := 'siete'; 
    v_unidades(8) := 'ocho';    
    v_unidades(9) := 'nueve';
    v_unidades(0) := '';
    --
    v_decenas(1) := 'diez';    
    v_decenas(2) := 'veinte';   
    v_decenas(3) := 'treinta';
    v_decenas(4) := 'cuarenta';
    v_decenas(5) := 'cincuenta';
    v_decenas(6) := 'sesenta';
    v_decenas(7) := 'setenta'; 
    v_decenas(8) := 'ochenta';  
    v_decenas(9) := 'noventa';
    v_decenas(0) := '';
    --
    v_centenas(1) := 'ciento'; 
    v_centenas(2) := 'doscientos'; 
    v_centenas(3) := 'trescientos';
    v_centenas(4) := 'cuatrocientos'; 
    v_centenas(5) := 'quinientos'; 
    v_centenas(6) := 'seiscientos';
    v_centenas(7) := 'setecientos'; 
    v_centenas(8) := 'ochocientos'; 
    v_centenas(9) := 'novecientos';
    v_centenas(0) := '';

    IF v_num = 0 THEN
        RETURN 'cero';
    END IF;

    -- Millones
    v_millones := TRUNC(v_num / 1000000);
    IF v_millones > 0 THEN
        IF v_millones = 1 THEN
            v_letras := v_letras || 'un millón ';
        ELSE
            v_letras := v_letras || numero_a_letras(v_millones) || ' millones ';
        END IF;
        v_num := MOD(v_num, 1000000);
    END IF;

    -- Miles
    v_miles := TRUNC(v_num / 1000);
    IF v_miles > 0 THEN
        IF v_miles = 1 THEN
            v_letras := v_letras || 'mil ';
        ELSE
            v_letras := v_letras || numero_a_letras(v_miles) || ' mil ';
        END IF;
        v_num := MOD(v_num, 1000);
    END IF;

    -- Centenas
    v_cientos := TRUNC(v_num / 100);
    IF v_cientos > 0 THEN
        IF v_num = 100 THEN
            v_letras := v_letras || 'cien';
            RETURN TRIM(v_letras);
        ELSE
            v_letras := v_letras || v_centenas(v_cientos) || ' ';
        END IF;
        v_num := MOD(v_num, 100);
    END IF;

    -- Decenas y unidades
    IF v_num > 0 THEN
        IF v_num <= 9 THEN
            v_letras := v_letras || v_unidades(v_num);
        ELSIF v_num = 10 THEN
            v_letras := v_letras || 'diez';
        ELSIF v_num = 11 THEN
            v_letras := v_letras || 'once';
        ELSIF v_num = 12 THEN
            v_letras := v_letras || 'doce';
        ELSIF v_num = 13 THEN
            v_letras := v_letras || 'trece';
        ELSIF v_num = 14 THEN
            v_letras := v_letras || 'catorce';
        ELSIF v_num = 15 THEN
            v_letras := v_letras || 'quince';
        ELSIF v_num < 20 THEN
            v_letras := v_letras || 'dieci' || v_unidades(v_num - 10);
        ELSIF v_num = 20 THEN
            v_letras := v_letras || 'veinte';
        ELSIF v_num < 30 THEN
            v_letras := v_letras || 'veinti' || v_unidades(v_num - 20);
        ELSE
            v_letras := v_letras || v_decenas(TRUNC(v_num / 10));
            IF MOD(v_num, 10) > 0 THEN
                v_letras := v_letras || ' y ' || v_unidades(MOD(v_num, 10));
            END IF;
        END IF;
        --
    END IF;
    --
    RETURN TRIM(v_letras);
    --
END numero_a_letras;
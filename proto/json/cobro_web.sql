DECLARE
    --
    -- Variables
    l_json_data     VARCHAR2(32767);
    l_json_object   JSON_OBJECT_T;
    --
    -- tipo de datos
    -- recibo
    TYPE t_recibo IS RECORD (
        numPoliza VARCHAR2(20),
        numRecibo VARCHAR2(20),
        monto     NUMBER
    );
    --
    TYPE t_recibos IS TABLE OF t_recibo INDEX BY PLS_INTEGER;
    --
    -- pago
    TYPE t_pago IS RECORD (
        fechaPago      DATE,
        pagador        VARCHAR2(20),
        tipoPago       VARCHAR2(20),
        referenciaPago VARCHAR2(20),
        moneda         VARCHAR2(20),
        monto_total    NUMBER,
        recibos        t_recibos
    );
    --
    r_pago      t_pago;
    r_recibo    t_recibo;
    --
    -- tratamiento de registro principal
    PROCEDURE p_pago (
            p_json_object IN JSON_OBJECT_T,
            p_pago        OUT t_pago
        ) IS
        --
        l_recibos       t_recibos;
        l_recibo        t_recibo; 
        l_json_array    JSON_ARRAY_T := JSON_ARRAY_T();
        l_element       JSON_ELEMENT_T;
        l_json          JSON_OBJECT_T;
        --
        l_timestamp     TIMESTAMP WITH TIME ZONE;
        l_iso_date      VARCHAR2(50);
        --
    BEGIN
        --
        -- fechaPago
        l_iso_date          := p_json_object.get_string('fechaPago');
        l_timestamp         := to_timestamp_tz(l_iso_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM');
        p_pago.fechaPago    := cast(l_timestamp AS DATE);
        --
        -- pagador
        p_pago.pagador := p_json_object.get_string('pagador');
        --
        -- tipoPago
        p_pago.tipoPago := p_json_object.get_string('tipoPago');
        --
        -- referenciaPago
        p_pago.referenciaPago := p_json_object.get_string('referenciaPago');
        --
        -- moneda
        p_pago.moneda := p_json_object.get_string('moneda');
        --
        -- monto_total
        p_pago.monto_total := p_json_object.get_number('montoTotal');
        --
        l_json_array := p_json_object.get_array('recibos');
        --
        -- recibos
        l_recibos := t_recibos();
        --
        -- Recorrer el array de recibos
        FOR i IN 0 .. l_json_array.get_size - 1 LOOP
            --
            l_element           := l_json_array.get(i);
            l_json              := JSON_OBJECT_T.parse(l_element.stringify);
            --
            -- Asignar valores a la estructura de recibo
            l_recibo.numPoliza  := l_json.get_string('numPoliza');
            l_recibo.numRecibo  := l_json.get_string('numRecibo');
            l_recibo.monto      := l_json.get_number('monto');
            --
            l_recibos(i+1)      := l_recibo;
            --
        END LOOP;
        --
        p_pago.recibos := l_recibos;
        --
    END p_pago;

BEGIN 
    --
    -- JSON data
    l_json_data := '{
        "guid": "595330",
        "canal": "ALI",
        "fechaPago": "2025-05-05T17:15:50+00:00",
        "tipoPagador": "A",
        "pagador": "179",
        "tipoPago": "TC",
        "referenciaPago": "903502",
        "montoTotal": 30000.96,
        "moneda": "CRC",
        "direccionIP": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36",
        "huellaNavegador": null,
        "cuenta": "HSBC1",
        "tarjeta": {
            "bin": "",
            "terminacion": "1111",
            "nombre": "EZQUELY YAGUARITAGUA",
            "mesExpira": "",
            "annioExpira": "",
            "marcaTarjeta": "Visa"
        },
        "recibos": [
                {
                    "numPoliza": "3022210116024",
                    "numRecibo": "5754239",
                    "tipoPago": "",
                    "monto": 15000.00
                },
                {
                    "numPoliza": "3022210116024",
                    "numRecibo": "5754240",
                    "tipoPago": "",
                    "monto": 15000.00
                }
            ]
        }';

    --
    -- Insert JSON data into a table
    l_json_object := JSON_OBJECT_T.parse(l_json_data);
    --
    -- Convert JSON object to PLSQL object
    p_pago (
        p_json_object => l_json_object,
        p_pago        => r_pago
    );
    --
    dbms_output.put_line( 'Fecha de Pago     : ' || r_pago.fechaPago );
    dbms_output.put_line( 'Pagador           : ' || r_pago.pagador );  
    dbms_output.put_line( 'Tipo de Pago      : ' || r_pago.tipoPago );
    dbms_output.put_line( 'Referencia de Pago: ' || r_pago.referenciaPago );
    dbms_output.put_line( 'Moneda            : ' || r_pago.moneda );    
    dbms_output.put_line( 'Monto Total       : ' || r_pago.monto_total );
    --
    IF r_pago.recibos.COUNT > 0 THEN 
        --
        FOR i IN 1 .. r_pago.recibos.COUNT LOOP
            --
            IF r_pago.recibos.EXISTS(i) THEN 
                --
                r_recibo := r_pago.recibos(i);
                --
                dbms_output.put_line( 
                    'Poliza: ' || r_recibo.numPoliza || chr(13) ||
                    'Recibo: ' || r_recibo.numRecibo || chr(13) ||
                    'Monto : ' || r_recibo.monto
                );
                --
            END IF;
            --
        END LOOP;
        --
    END IF;
    --
END;
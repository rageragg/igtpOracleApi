DECLARE
    --
    -- Variables
    l_json_data     VARCHAR2(32767);
    l_json_object   JSON_OBJECT_T;
    --
    -- tipo de datos
    -- recibo
    TYPE t_recibo IS RECORD (
        numPoliza   VARCHAR2(20),
        numRecibo   VARCHAR2(20),
        monto       NUMBER,
        valido      BOOLEAN   DEFAULT FALSE,
        observacion VARCHAR2(2000)
    );
    --
    TYPE t_recibos IS TABLE OF t_recibo INDEX BY PLS_INTEGER;
    --
    -- pago
    TYPE t_pago IS RECORD (
        guid            VARCHAR2(20),
        fechaPago       DATE,
        pagador         VARCHAR2(20),
        tipoPago        VARCHAR2(20),
        referenciaPago  VARCHAR2(20),
        moneda          VARCHAR2(20),
        cuenta          VARCHAR2(20),
        monto_total     NUMBER,
        recibos         t_recibos,
        valido          BOOLEAN   DEFAULT FALSE,
        observacion     VARCHAR2(2000)
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
        -- Inicializar la estructura de pago
        -- identificador unico de la transaccion
        p_pago.guid             := p_json_object.get_string('guid');
        --
        -- fechaPago
        l_iso_date              := p_json_object.get_string('fechaPago');
        l_timestamp             := to_timestamp_tz(l_iso_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM');
        --
        p_pago.fechaPago        := cast(l_timestamp AS DATE);
        p_pago.pagador          := p_json_object.get_string('pagador');
        p_pago.tipoPago         := p_json_object.get_string('tipoPago');
        p_pago.referenciaPago   := p_json_object.get_string('referenciaPago');
        p_pago.moneda           := p_json_object.get_string('moneda');
        p_pago.cuenta           := p_json_object.get_string('cuenta');
        p_pago.monto_total      := p_json_object.get_number('montoTotal');
        --
        -- recibos
        l_recibos := t_recibos();
        --
        -- verificar si recibos existe
        IF p_json_object.has('recibos') THEN
            --
            -- si existe, se toma el arreglo de recibos en formato JSON
            l_json_array            := p_json_object.get_array('recibos');
            --
            -- Recorrer el array de recibos
            FOR i IN 0 .. l_json_array.get_size - 1 LOOP
                --
                -- tomamos el elemento y lo sometemos a verificacion JSON como un Objeto
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
        END IF;   
        --    
    END p_pago;
    --
    -- validacion de datos
    PROCEDURE p_validador (
            p_pago        IN OUT t_pago
        ) IS
        --
        -- Validar el recibo
        PROCEDURE p_validador_recibo( 
            p_recibo IN OUT t_recibo
        ) IS
            --
            l_num_recibo   VARCHAR2(20);
            l_num_poliza   VARCHAR2(20);
            l_monto        NUMBER;
            --
        BEGIN 
            --
            -- Validar el recibo
            l_num_recibo   := p_recibo.numRecibo;
            l_num_poliza   := p_recibo.numPoliza;
            l_monto        := p_recibo.monto;
            --
            -- TODO: Validar que el recibo exista
            -- TODO: Que este en situacion de EP o RE
            -- TODO: Validar que el monto total coincida con la suma de lo pagado
            --
        END p_validador_recibo;
        --
    BEGIN 
        --
        -- TODO: Validar los datos
        -- 1. Validar cada recibo, que exista y asociado a la poliza, que este en EP o Remesado
        -- 2. Validar el monto total de los recibos
        --
        IF p_pago.recibos.COUNT > 0 THEN 
            --
            FOR i IN 1 .. p_pago.recibos.COUNT LOOP
                --
                IF p_pago.recibos.EXISTS(i) THEN 
                    --
                    p_validador_recibo( 
                        p_recibo => p_pago.recibos(i)
                    );
                    --
                END IF;
                --
            END LOOP;
            --
        END IF;
        --
    END p_validador;
    --
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
        "montoTotal": 45000.00,
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
                },
                {
                    "numPoliza": "3022210116024",
                    "numRecibo": "5754241",
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
    -- analisis de los datos:
    -- TODO: Validar cada recibo exista y asociado a la poliza
    p_validador (
        p_pago  => r_pago
    );
    --
    dbms_output.put_line( 
        'GUID              : ' || r_pago.guid || chr(13) ||
        'Fecha de Pago     : ' || r_pago.fechaPago || chr(13) ||
        'Cuenta            : ' || r_pago.cuenta || chr(13) ||
        'Pagador           : ' || r_pago.pagador || chr(13) ||
        'Tipo de Pago      : ' || r_pago.tipoPago || chr(13) ||
        'Referencia de Pago: ' || r_pago.referenciaPago || chr(13) ||
        'Moneda            : ' || r_pago.moneda || chr(13) ||
        'Monto Total       : ' || r_pago.monto_total || chr(13)
    );
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
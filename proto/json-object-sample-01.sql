declare 
    l_json      VARCHAR2(32000);
    l_obj       JSON_OBJECT_T;
    l_key_list  json_key_list; 
    l_lst       VARCHAR2(32000);
begin 
    --
    -- TODO: Se debe identificar el tipo de documento JSON es, para determinar que proceso lo va a tratar
    l_json := '{
        "num_policy": "42001235658",
        "policyholder": {
            "typ_document": "CED",
            "cod_document": "10075340",
            "surnames": "GUERRA ESTE",
            "names": "RONALD ALFONSO",
            "type_beneficiary": 1,
            "phone": "983-555-6509",
            "address": {
                "street": "200 Sporting Green",
                "city": "South San Francisco",
                "state": "CA",
                "zipCode": 99236,
                "country": "United States of America"
            }
        },
        "fec_emision": "01012025",
        "fec_efec_poliza": "01012025",
        "fec_vcto_poliza": "01012026",
        "num_renewal": 0,
        "last_spto": 0,
        "risks": [
            {
                "num_risk": 1,
                "policy_beneficiary": {
                    "typ_document": "CED",
                    "cod_document": "10075340",
                    "surnames": "GUERRA ESTE",
                    "names": "RONALD ALFONSO",
                    "type_beneficiary": 2,
                    "phone": "983-555-6509",
                    "address": {
                        "street": "200 Sporting Green",
                        "city": "South San Francisco",
                        "state": "CA",
                        "zipCode": 99236,
                        "country": "United States of America"
                    }
                },
                "risk_data": {
                    "typ_risk": "HOUSE",
                    "sum insured": 2000,
                    "address": {
                        "street": "200 Sporting Green",
                        "city": "South San Francisco",
                        "state": "CA",
                        "zipCode": 99236,
                        "country": "United States of America"
                    }
                }
            }
        ]
    }';
    --
    l_obj  := json_object_t.parse(l_json);
    --
    l_key_list := l_obj.get_keys; 
    --
    -- TODO: A cada clave se tiene que procesar por su tipo.
    -- TODO: Se debe identificar el tipo de clave y determinar como procesarlo, como un documento JSON 
    FOR counter IN 1 .. l_key_list.COUNT 
    LOOP 
        --
        DBMS_OUTPUT.put_line ( 
             counter || ' ' || l_key_list (counter) 
        );
        --
        IF counter = 1 THEN
            --
            l_lst := l_key_list (counter);
            --
        ELSE
            --
            IF counter <= l_key_list.COUNT THEN 
                --
                l_lst := l_lst ||';'|| l_key_list (counter);
                --
            END IF;
            --
        END IF;
        --
    END LOOP; 
    --
    DBMS_OUTPUT.put_line ( 'Lista: ' || l_lst );
    --
end;
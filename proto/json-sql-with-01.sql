WITH
    --
    FUNCTION updatePrice(
            jsonTxt in VARCHAR2 
        ) RETURN VARCHAR2 IS
        --
        jo          JSON_OBJECT_T;
        oldPrice    NUMBER;
        --
    BEGIN
        --
        jo := new JSON_OBJECT_T(jsonTxt);
        oldPrice := jo.get_number('price');
        jo.put('price', oldPrice * 1.1);
        --
        RETURN jo.to_string();
        --
    END;
SELECT updatePrice('{ price: 15 }')
FROM   dual;
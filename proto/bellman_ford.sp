CREATE OR REPLACE PROCEDURE bellman_ford (
    origen          VARCHAR2,
    grafo           SYS.DBMS_DEBUG_VC2COLL,
    distancias      OUT SYS.DBMS_DEBUG_VC2COLL,
    predecesores    OUT SYS.DBMS_DEBUG_VC2COLL
) AS
    num_vertices NUMBER;
    num_aristas NUMBER;
    i NUMBER;
    j NUMBER;
    u VARCHAR2(100);
    v VARCHAR2(100);
    peso NUMBER;
    arista VARCHAR2(200);
    ciclo_negativo BOOLEAN := FALSE;
BEGIN
    -- Inicialización
    num_vertices := grafo.COUNT / 3; -- Asumiendo que el grafo se pasa como (u,v,peso)
    distancias := SYS.DBMS_DEBUG_VC2COLL();
    predecesores := SYS.DBMS_DEBUG_VC2COLL();

    FOR i IN 1..num_vertices LOOP
        distancias.EXTEND;
        predecesores.EXTEND;
        distancias(i) := CASE WHEN SUBSTR(grafo((i-1)*3+1), 1, 100) = origen THEN 0 ELSE 99999 END; -- Infinito (99999) como valor grande
        predecesores(i) := NULL;
    END LOOP;

    -- Relajación de aristas
    FOR i IN 1..num_vertices-1 LOOP
        FOR j IN 1..num_vertices/2 LOOP
            u := SUBSTR(grafo((j-1)*3+1), 1, 100);
            v := SUBSTR(grafo((j-1)*3+2), 1, 100);
            peso := TO_NUMBER(grafo((j-1)*3+3));

            IF distancias(CASE WHEN SUBSTR(grafo((j-1)*3+1), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+1), 1, 100)) END) + peso < distancias(CASE WHEN SUBSTR(grafo((j-1)*3+2), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+2), 1, 100)) END) THEN

                distancias(CASE WHEN SUBSTR(grafo((j-1)*3+2), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+2), 1, 100)) END) := distancias(CASE WHEN SUBSTR(grafo((j-1)*3+1), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+1), 1, 100)) END) + peso;
                predecesores(CASE WHEN SUBSTR(grafo((j-1)*3+2), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+2), 1, 100)) END) := SUBSTR(grafo((j-1)*3+1), 1, 100);
            END IF;
        END LOOP;
    END LOOP;

    -- Detección de ciclos negativos
    FOR j IN 1..num_vertices/2 LOOP
        u := SUBSTR(grafo((j-1)*3+1), 1, 100);
        v := SUBSTR(grafo((j-1)*3+2), 1, 100);
        peso := TO_NUMBER(grafo((j-1)*3+3));

        IF distancias(CASE WHEN SUBSTR(grafo((j-1)*3+1), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+1), 1, 100)) END) + peso < distancias(CASE WHEN SUBSTR(grafo((j-1)*3+2), 1, 100) = origen THEN 1 ELSE (SELECT ROWNUM FROM (SELECT DISTINCT SUBSTR(value,1,100) as value from table(grafo)) where value = SUBSTR(grafo((j-1)*3+2), 1, 100)) END) THEN
            ciclo_negativo := TRUE;
            EXIT;
        END IF;
    END LOOP;

    IF ciclo_negativo THEN
        DBMS_OUTPUT.PUT_LINE('El grafo contiene un ciclo negativo.');
    END IF;
END;
/

-- Ejemplo de uso
DECLARE
    --
    grafo           SYS.DBMS_DEBUG_VC2COLL := SYS.DBMS_DEBUG_VC2COLL(
        'A', 'B', '-1', 
        'A', 'C', '4', 
        'B', 'C', '3', 
        'B', 'D', '2', 
        'B', 'E', '2', 
        'E', 'D', '-3', 
        'D', 'B', '1', 
        'C', 'E', '5'
    );
    --
    distancias      SYS.DBMS_DEBUG_VC2COLL;
    predecesores    SYS.DBMS_DEBUG_VC2COLL;
    --
BEGIN
    --
    bellman_ford(
        'A', 
        grafo, 
        distancias, 
        predecesores
    );
    --
    DBMS_OUTPUT.PUT_LINE('Distancias desde A:');
    FOR i IN 1..distancias.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Nodo ' || (SELECT DISTINCT SUBSTR(value,1,100) from table(grafo) where ROWNUM = i) || ': ' || distancias(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Predecesores:');
    FOR i IN 1..predecesores.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Nodo ' || (SELECT DISTINCT SUBSTR(value,1,100) from table(grafo) where ROWNUM = i) || ': ' || predecesores(i));
    END LOOP;
END;

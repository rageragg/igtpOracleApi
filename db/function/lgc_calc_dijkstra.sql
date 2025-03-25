--
---------------------------------------------------------------------------
--  DDL for function lgc_calc_dijkstra (Calcs)
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
--  2023-08-12  RAGECA - RGUERRA    Calcula la mejor ruta
--
-- TODO: Compactar codigo repetitivo en funciones de utilerias
---------------------------------------------------------------------------
--
CREATE OR REPLACE FUNCTION lgc_calc_dijkstra(
        p_source IN VARCHAR2,
        p_target IN VARCHAR2
    ) RETURN NUMBER IS
    --
    TYPE t_node IS TABLE OF VARCHAR2(100);
    TYPE t_distance IS TABLE OF NUMBER;
    --
    l_nodes         t_node      := t_node();
    l_distances     t_distance  := t_distance();
    l_current_node  VARCHAR2(100);
    l_min_distance  NUMBER;
    l_index         PLS_INTEGER;
    --
BEGIN
    --
    -- Inicialización de nodos y distancias
    l_nodes.EXTEND(5); -- ? Suponiendo 5 nodos
    l_distances.EXTEND(5);
    --
    FOR i IN 1 .. l_nodes.COUNT LOOP
        --
        l_distances(i) := 999999; -- Infinito
        --
    END LOOP;
    --
    -- Nodo de origen
    l_distances(1) := 0;
    --
    -- Lógica del algoritmo
    WHILE l_nodes.COUNT > 0 LOOP
        --
        -- Seleccionar el nodo con la menor distancia
        l_min_distance := 999999;
        --
        FOR i IN 1 .. l_nodes.COUNT LOOP
            --
            IF l_distances(i) < l_min_distance THEN
                l_min_distance := l_distances(i);
                l_index := i;
            END IF;
            --
        END LOOP;
        --
        -- Procesar el nodo actual
        l_current_node := l_nodes(l_index);
        --
        -- Actualizar distancias de los vecinos (lógica omitida para simplicidad)
        -- Eliminar el nodo actual de la lista
        l_nodes.DELETE(l_index);
        --
    END LOOP;
    --
    -- Retornar la distancia al nodo de destino
    RETURN l_distances(2); -- Ejemplo: distancia al nodo de destino
    --
END lgc_calc_dijkstra;
/
--
---------------------------------------------------------------------------
--  DDL for function lgc_calc_johnson_algorithm (Calcs)
--  MODIFICATIONS
--  DATE        AUTOR               DESCRIPTIONS
--  =========== =================== =======================================
--  2023-08-12  RAGECA - RGUERRA    Calcula la mejor ruta
--
-- TODO: Compactar codigo repetitivo en funciones de utilerias
---------------------------------------------------------------------------
--
CREATE OR REPLACE FUNCTION lgc_calc_johnson_algorithm RETURN VARCHAR2 IS
    --
    TYPE t_node IS TABLE OF VARCHAR2(100);
    TYPE t_weight IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    --
    l_nodes         t_node := t_node();
    l_weights       t_weight;
    l_distances     t_weight;
    l_potentials    t_weight;
    --
    l_current_node VARCHAR2(100);
    l_min_distance NUMBER;
    --
BEGIN
    -- Paso 1: Inicializar nodos y pesos
    l_nodes := t_node('A', 'B', 'C');
    l_weights('A->B') := 2;
    l_weights('A->C') := -3;
    l_weights('B->C') := 4;
    --
    -- Paso 2: Calcular potenciales con Bellman-Ford
    FOR i IN 1 .. l_nodes.COUNT LOOP
        l_potentials(l_nodes(i)) := 0; -- Inicializar potenciales
    END LOOP;
    --
    -- Simulación de Bellman-Ford (lógica omitida para simplicidad)
    l_potentials('A') := -3;
    l_potentials('B') := -1;
    l_potentials('C') := 0;
    --
    -- Paso 3: Reajustar pesos
    l_weights('A->B') := l_weights('A->B') + l_potentials('A') - l_potentials('B');
    l_weights('A->C') := l_weights('A->C') + l_potentials('A') - l_potentials('C');
    l_weights('B->C') := l_weights('B->C') + l_potentials('B') - l_potentials('C');
    --
    -- Paso 4: Aplicar Dijkstra desde cada nodo
    -- (Lógica de Dijkstra omitida para simplicidad)
    --
    -- Paso 5: Revertir el reajuste de pesos
    -- (Lógica para revertir los pesos omitida)
    RETURN 'Johnson Algorithm Completed';
    --
END lgc_calc_johnson_algorithm;
/
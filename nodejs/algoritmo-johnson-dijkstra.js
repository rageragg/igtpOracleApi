class Graph {
  constructor(vertices) {
    this.V = vertices;
    this.edges = []; // Aristas: [origen, destino, peso]
  }

  // Añadir una arista
  addEdge(u, v, weight) {
    this.edges.push([u, v, weight]);
  }

  // Algoritmo de Bellman-Ford
  bellmanFord(src) {
    const dist = Array(this.V).fill(Infinity);
    dist[src] = 0;

    for (let i = 0; i < this.V - 1; i++) {
      for (const [u, v, weight] of this.edges) {
        if (dist[u] !== Infinity && dist[u] + weight < dist[v]) {
          dist[v] = dist[u] + weight;
        }
      }
    }

    // Comprobar ciclos negativos
    for (const [u, v, weight] of this.edges) {
      if (dist[u] !== Infinity && dist[u] + weight < dist[v]) {
        throw new Error("El grafo contiene un ciclo negativo");
      }
    }

    return dist;
  }

  // Algoritmo de Johnson
  johnson() {
    // Agregar un nodo ficticio con peso 0 a todos los nodos existentes
    const newGraph = new Graph(this.V + 1);
    for (const [u, v, weight] of this.edges) {
      newGraph.addEdge(u, v, weight);
    }
    for (let i = 0; i < this.V; i++) {
      newGraph.addEdge(this.V, i, 0);
    }

    // Obtener h[v] con Bellman-Ford
    const h = newGraph.bellmanFord(this.V);

    // Ajustar pesos usando h[v]
    const adjustedEdges = this.edges.map(([u, v, weight]) => {
      return [u, v, weight + h[u] - h[v]];
    });

    // Usar Dijkstra para cada nodo
    const distances = [];
    for (let i = 0; i < this.V; i++) {
      distances.push(this.dijkstra(i, adjustedEdges));
    }

    return distances;
  }

  // Algoritmo de Dijkstra
  dijkstra(src, edges) {
    const dist = Array(this.V).fill(Infinity);
    dist[src] = 0;

    const visited = new Set();
    while (visited.size < this.V) {
      let u = -1;

      // Encontrar el nodo con la menor distancia no visitado
      for (let i = 0; i < this.V; i++) {
        if (!visited.has(i) && (u === -1 || dist[i] < dist[u])) {
          u = i;
        }
      }

      if (dist[u] === Infinity) break; // Nodos inalcanzables
      visited.add(u);

      for (const [from, to, weight] of edges) {
        if (from === u && !visited.has(to) && dist[u] + weight < dist[to]) {
          dist[to] = dist[u] + weight;
        }
      }
    }

    return dist;
  }
}
# Orbits.m - Directed Graph Orbit Analysis

**Author:** Thiago Santos  
**Date:** 14/03/2025  

This MATLAB function analyzes a directed graph represented by a vector and labels its orbits, calculates the order of nodes within those orbits, computes the pseudo-inverse of the graph, and assigns the degree (cyclic or non-cyclic) for each node. It also detects connected components and classifies them based on whether they contain cycles. The function utilizes Depth First Search (DFS) to traverse the graph and Floyd's Cycle Detection algorithm (Tortoise and Hare) to identify cycles.

## Features

- **Orbit Labeling:** Identifies the orbit (connected component) each node belongs to.
- **Order within Orbits:** Assigns an order to each node within its respective orbit.
- **Pseudo-inverse Calculation:** Calculates the pseudo-inverse for each node in the directed graph.
- **Degree Assignment:** Labels nodes with degree `-1` for cyclic and `0` for non-cyclic.
- **Cycle Detection:** Uses Tortoise and Hare algorithm to detect cycles in the graph.
- **Component Classification:** Classifies connected components as cyclic or non-cyclic.

## Inputs

- `phi`: A vector (1-based indexing) where each element points to the next node, representing a directed graph. It contains a permutation of nodes.
  - **Size:** `n x 1` (where `n` is the number of nodes in the graph)

## Outputs

- `orb`: Orbit label for each node indicating the connected component it belongs to.
- `ord`: Order of the node within its orbit.
- `psi`: Pseudo-inverse of `phi` for each node.
- `deg`: Degree of each node:
  - `-1` for cyclic nodes
  - `0` for non-cyclic nodes
- `init`: List of nodes that do not appear as targets in `phi` (starting points).
- `term`, `prin`, `conn`: Outputs for termination, principal node, and connected components (currently unused in this implementation).

## Function Workflow

1. **Input Validation:** Ensures `phi` contains valid node indices between `1` and `n`.
2. **DFS Traversal:** For each unvisited node, a Depth First Search (DFS) is performed to trace the chain of nodes.
3. **Cycle Detection:** The Tortoise and Hare algorithm is used to detect cycles in the graph.
4. **Component Labeling:** Each connected component is labeled, and nodes are assigned to their respective components based on the presence of cycles.
5. **Results:** The function outputs the orbit labels, order within orbits, pseudo-inverses, and the degree of each node (cyclic or non-cyclic).

## Research Context

This function was implemented as part of my work for the **Discrete Mathematics course**, where I combined innovative algorithmic approaches to solve problems related to graph theory. The implementation was developed as a research project for the professors in the course, focusing on graph traversal, cycle detection, and component classification.

## Example Usage

```matlab
phi = [2, 3, 4, 1];  % Example directed graph
[orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
``` 
This would return the orbit labels, orders within the orbits, pseudo-inverses, degrees, and initial nodes for the directed graph.
Requirements

    MATLAB

License

This project is licensed under the MIT License - see the LICENSE file for details.

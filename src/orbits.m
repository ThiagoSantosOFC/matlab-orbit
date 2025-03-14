% orbits.m
% Thiago Santos - 14/03/2025
% This function analyzes a directed graph of nodes and labels its orbits, 
% orders within those orbits, calculates the pseudo-inverse, and assigns 
% the degree (cyclic or non-cyclic) for each node. Additionally, it detects 
% the connected components and classifies them based on whether they contain 
% cycles or not. The function uses Depth First Search (DFS) to traverse the graph, 
% and the Floyd's Cycle Detection (Tortoise and Hare) algorithm to identify cycles.

% INPUT:
%   phi - a vector where each element points to the next node (1-based indexing)
%         representing a directed graph. It contains the permutation of nodes.
%         Size: n x 1 (where n is the number of nodes)

% OUTPUT:
%   orb - orbit label for each node, indicating which connected component it belongs to
%   ord - the order within the orbit for each node
%   psi - the pseudo-inverse of phi for each node
%   deg - degree of each node (-1 for cyclic, 0 for non-cyclic)
%   init - list of nodes that don't appear as a target in phi (starting points)
%   term - output for termination of connected components (not used in this example)
%   prin - output for principal node (not used in this example)
%   conn - output for connected components (not used in this example)

function [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi)
    % Convert phi to a column vector to ensure it is processed as a column
    phi = phi(:);
    
    % Number of nodes in the graph (length of phi)
    n = numel(phi);
    
    % Validate input - ensure phi contains valid indices
    if any(phi < 1) || any(phi > n)
        error('Invalid input: phi must contain indices between 1 and n');
    end
    
    % Initialize variables to store the results
    orb = zeros(n, 1);        % Orbit label for each node
    ord = zeros(n, 1);        % Order of the node within the orbit
    psi = zeros(n, 1);        % Pseudo-inverse of phi (reversed path)
    deg = zeros(n, 1);        % Degree of each node (0 for non-cyclic, -1 for cyclic)
    visited = false(n, 1);    % Keeps track of visited nodes
    
    % Determine which nodes are not present in phi (starting points)
    present = false(n, 1);    % Indicator for nodes present in phi
    present(phi) = true;
    init = find(~present)';   % Nodes without a pre-image (starting points)
    
    % Edge case: Empty input or single element
    if n == 0
        term = [];
        prin = [];
        conn = [];
        return;
    elseif n == 1
        orb(1) = 1;
        ord(1) = 1;
        psi(1) = phi(1);
        if phi(1) == 1
            deg(1) = -1;  % Self-loop is cyclic
        else
            deg(1) = 0;   % Non-cyclic
        end
        term = [];
        prin = [];
        conn = [];
        return;
    end
    
    m = numel(init);          % Number of initial (starting) nodes
    term = zeros(1, m);       % Placeholder for terminal nodes
    prin = zeros(1, m);       % Placeholder for principal nodes
    conn = zeros(1, m);       % Placeholder for connected nodes
    
    % Component label initialization
    compLabel = 0;  % Label for the connected components
    
    % Iterate over each node in phi
    for i = 1:n
        if ~visited(i)
            % Initialize DFS (Depth First Search) to explore the chain starting from node i
            stack = i;    % Start DFS from node i
            path = [];    % Path to track nodes in the current chain
            
            % Traverse the chain using DFS
            while ~isempty(stack)
                current = stack(end);
                stack(end) = []; % Pop the last element
                if visited(current)
                    continue;
                end
                visited(current) = true;
                path(end+1) = current;  % Add node to the path
                
                % Push next node in the chain onto the stack
                next = phi(current);
                if ~visited(next)
                    stack(end+1) = next;
                end
            end
            
            % Edge case: handle empty path (shouldn't happen with proper input)
            if isempty(path)
                continue;
            end
            
            % Detect cycles in the current path using the Tortoise and Hare algorithm
            [cycleFound, cycleStartIdx] = detectCycleInPath(phi, path);
            compLabel = compLabel + 1;  % Increment the component label
            
            if cycleFound
                % If cycle detected, label the nodes leading to the cycle
                for k = 1:(cycleStartIdx - 1)
                    node = path(k);
                    orb(node) = compLabel;
                    ord(node) = k;
                    if k == 1
                        psi(node) = node;  % Self-loop for first node
                    else
                        psi(node) = path(k-1);  % Previous node in the path
                    end
                    deg(node) = 0;        % Degree for non-cyclic nodes
                end
                
                % Label the cycle nodes
                cycleNodes = path(cycleStartIdx:end);
                cycleLength = numel(cycleNodes);
                for k = 1:cycleLength
                    node = cycleNodes(k);
                    orb(node) = compLabel;
                    ord(node) = cycleStartIdx + k - 1;
                    if cycleLength == 1
                        psi(node) = node;  % Self-loop for single node cycle
                    else
                        psi(node) = cycleNodes(mod(k-2+cycleLength, cycleLength) + 1);
                    end
                    deg(node) = -1;  % Degree for cycle nodes (-1 for cyclic)
                end
            else
                % If no cycle, label all nodes as part of a non-cyclic component
                for k = 1:numel(path)
                    node = path(k);
                    orb(node) = compLabel;
                    ord(node) = k;
                    if k == 1
                        psi(node) = node;  % Self-loop for first node
                    else
                        psi(node) = path(k-1);  % Previous node in the path
                    end
                    deg(node) = 0;  % Degree for non-cyclic nodes
                end
            end
        end
    end 
end

% Function to detect cycles in a path using the Tortoise and Hare algorithm
function [cycleFound, cycleStartIdx] = detectCycleInPath(phi, path)
    % Edge case: handle empty path or single-node path
    if isempty(path)
        cycleFound = false;
        cycleStartIdx = [];
        return;
    elseif numel(path) == 1
        % Check if it's a self-loop
        if phi(path(1)) == path(1)
            cycleFound = true;
            cycleStartIdx = 1;
        else
            cycleFound = false;
            cycleStartIdx = [];
        end
        return;
    end
    
    % Initialize pointers for Tortoise and Hare
    t = path(1);
    h = path(1);
    cycleFound = false;
    cycleStartIdx = [];
    
    % Detection phase: advance t (1 step) and h (2 steps)
    while true
        t = phi(t);       % Tortoise advances by 1 step
        
        % Edge case: check if h can advance two steps
        if phi(h) > numel(phi) || phi(phi(h)) > numel(phi)
            cycleFound = false;
            break;
        end
        
        h = phi(phi(h));  % Hare advances by 2 steps
        if t == h
            cycleFound = true;
            break;
        end
        
        % Check if we've reached nodes that aren't in the path
        if ~ismember(t, path) || ~ismember(h, path)
            break;
        end
    end

    % If a cycle is detected, find the start of the cycle
    if cycleFound
        t = path(1);  % Reset tortoise to the start of the path
        idx = 1;
        while t ~= h
            t = phi(t);
            h = phi(h);
            idx = idx + 1;
        end
        cycleStartIdx = idx;  % Cycle starts at index 'idx'
    end
end
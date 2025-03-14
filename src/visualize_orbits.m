% visualize_orbits.m
% Esta função cria uma visualização gráfica dos resultados da função orbits.m

function visualize_orbits(phi, orb, ord, psi, deg, init)
    % Se os argumentos não foram fornecidos, executar orbits
    if nargin < 1
        % Exemplo padrão
        phi = [2; 3; 4; 5; 6; 3; 8; 9; 10; 7];
        [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
    elseif nargin == 1
        % Apenas phi fornecido, calcular os outros
        [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
    end

    % Verificar entrada
    if isempty(phi)
        disp('Grafo vazio: não há nada para visualizar.');
        return;
    end
    
    % Criar novo figure
    figure('Name', 'Visualização de Orbits', 'Position', [100, 100, 1000, 600]);
    
    % Número de nós
    n = numel(phi);
    
    % Criar grafo direcionado
    G = digraph();
    
    % Adicionar nós
    for i = 1:n
        G = addnode(G, 1);
    end
    
    % Adicionar arestas
    for i = 1:n
        G = addedge(G, i, phi(i));
    end
    
    % Definir cores para componentes
    num_components = max(orb);
    colors = hsv(num_components);
    
    % Criar vetor de cores de nós
    node_colors = zeros(n, 3);
    for i = 1:n
        node_colors(i, :) = colors(orb(i), :);
    end
    
    % Criar vetor de formas de nós
    % Círculo para nós cíclicos, quadrado para não-cíclicos
    node_shapes = cell(n, 1);
    for i = 1:n
        if deg(i) == -1
            node_shapes{i} = 'o';  % Círculo para nós cíclicos
        else
            node_shapes{i} = 's';  % Quadrado para nós não-cíclicos
        end
    end
    
    % Tamanhos dos nós - maiores para nós iniciais
    node_sizes = 20 * ones(n, 1);
    if ~isempty(init)
        node_sizes(init) = 40;
    end
    
    % Layout do grafo - usar 'force' para um layout baseado em forças
    % que mantém componentes conectados juntos
    layout = 'force';
    
    % Plotar o grafo
    subplot(1, 2, 1);
    h = plot(G, 'Layout', layout, 'NodeColor', node_colors, 'MarkerSize', node_sizes);
    
    % Aplicar formas de nós
    for i = 1:n
        h.NodeMarker{i} = node_shapes{i};
    end
    
    % Adicionar rótulos aos nós
    labelnode(h, 1:n, cellstr(num2str((1:n)')));
    
    % Destacar componentes diferentes com cores
    colormap(hsv(num_components));
    
    % Adicionar título e legendas
    title('Grafo de Permutação com Componentes Conectados');
    xlabel(['Número de componentes: ', num2str(num_components)]);
    
    % Criar uma tabela com informações sobre os nós
    subplot(1, 2, 2);
    
    % Criar dados para a tabela
    data = table((1:n)', phi, orb, ord, psi, deg, ...
                 'VariableNames', {'Node', 'phi', 'Orbit', 'Order', 'psi', 'Degree'});
    
    % Formatar dados para exibição
    data_cell = table2cell(data);
    
    % Adicionar cabeçalho
    header = {'Nó', 'phi', 'Órbita', 'Ordem', 'psi', 'Grau'};
    
    % Exibir tabela como texto
    % Calcular posição da tabela
    axis off;
    text(0, 1, 'Informações dos Nós:', 'FontWeight', 'bold', 'FontSize', 14);
    text(0, 0.95, '-----------------------------------', 'FontSize', 12);
    text(0, 0.9, sprintf('%-5s %-5s %-7s %-7s %-5s %-7s', header{:}), 'FontSize', 12);
    text(0, 0.85, '-----------------------------------', 'FontSize', 12);
    
    % Desenhar linhas da tabela
    for i = 1:min(n, 20)  % Limitar a 20 linhas por questões de espaço
        y_pos = 0.8 - (i-1)*0.04;
        line_text = sprintf('%-5d %-5d %-7d %-7d %-5d %-7d', ...
                          data_cell{i,1}, data_cell{i,2}, data_cell{i,3}, ...
                          data_cell{i,4}, data_cell{i,5}, data_cell{i,6});
        text(0, y_pos, line_text, 'FontSize', 11);
    end
    
    % Se houver mais de 20 nós, indicar que alguns foram omitidos
    if n > 20
        text(0, 0.8 - 20*0.04, '...', 'FontSize', 11);
        text(0, 0.8 - 21*0.04, sprintf('(+ %d nós não mostrados)', n-20), 'FontSize', 11);
    end
    
    % Adicionar informações sobre componentes
    text(0, 0.2, 'Estatísticas:', 'FontWeight', 'bold', 'FontSize', 14);
    text(0, 0.15, sprintf('Total de nós: %d', n), 'FontSize', 12);
    text(0, 0.1, sprintf('Componentes conectados: %d', num_components), 'FontSize', 12);
    text(0, 0.05, sprintf('Nós cíclicos: %d (%.1f%%)', sum(deg == -1), sum(deg == -1)/n*100), 'FontSize', 12);
    text(0, 0, sprintf('Nós não-cíclicos: %d (%.1f%%)', sum(deg == 0), sum(deg == 0)/n*100), 'FontSize', 12);
    
    % Adicionar legenda
    text(0, -0.1, 'Legenda:', 'FontWeight', 'bold', 'FontSize', 12);
    text(0, -0.15, '○ - Nó cíclico    □ - Nó não-cíclico    Nó maior - Nó inicial', 'FontSize', 11);
    text(0, -0.2, 'Cores representam componentes diferentes', 'FontSize', 11);
end
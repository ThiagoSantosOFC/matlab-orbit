% random_test_orbits.m
% Este script testa a função orbits.m com grafos aleatórios de diferentes tamanhos
% e analisa o desempenho e a consistência dos resultados

function random_test_orbits()
    clc;
    disp('Iniciando testes aleatórios para a função orbits.m...');
    disp('-------------------------------------------');
    
    % Diferentes tamanhos de grafos para testar
    sizes = [10, 50, 100, 500, 1000];
    
    % Número de testes para cada tamanho
    num_tests = 5;
    
    % Estrutura para armazenar estatísticas
    stats = struct('size', {}, 'time', {}, 'components', {}, 'cycles', {});
    
    % Loop pelos diferentes tamanhos
    for s = 1:numel(sizes)
        size = sizes(s);
        disp(['Testando grafos de tamanho: ', num2str(size)]);
        
        % Inicializar estatísticas para este tamanho
        times = zeros(num_tests, 1);
        components = zeros(num_tests, 1);
        cycles = zeros(num_tests, 1);
        
        % Executar múltiplos testes para este tamanho
        for t = 1:num_tests
            disp(['  Teste ', num2str(t), ' de ', num2str(num_tests)]);
            
            % Gerar grafo aleatório
            rng(t * 100 + size);  % Semente reproduzível mas diferente para cada teste
            phi = randi(size, size, 1);
            
            % Medir tempo de execução
            tic;
            [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
            times(t) = toc;
            
            % Contar componentes (maior valor em orb)
            components(t) = max(orb);
            
            % Contar ciclos (quantos nós têm deg == -1)
            cycles(t) = sum(deg == -1);
            
            % Verificar consistência
            try
                % 1. Verificar se todos os nós têm órbita atribuída
                assert(all(orb > 0), 'Falha: alguns nós não têm órbita atribuída');
                
                % 2. Verificar a consistência do pseudo-inverso para nós cíclicos
                cycle_nodes = find(deg == -1);
                for i = 1:numel(cycle_nodes)
                    node = cycle_nodes(i);
                    assert(phi(psi(node)) == node, ['Falha: inconsistência phi(psi) para nó ', num2str(node)]);
                end
                
                % 3. Verificar se nós no mesmo componente têm a mesma órbita
                for comp = 1:max(orb)
                    comp_nodes = find(orb == comp);
                    % Escolher um nó de referência
                    ref_node = comp_nodes(1);
                    
                    % Para cada nó no componente, deve existir um caminho para/de outro nó
                    for node = comp_nodes(:)'
                        found_path = false;
                        
                        % Tentar seguir um caminho do nó de referência para o nó atual
                        current = ref_node;
                        for step = 1:size
                            if current == node
                                found_path = true;
                                break;
                            end
                            current = phi(current);
                            if current == ref_node
                                break;  % Detectou ciclo, parar busca
                            end
                        end
                        
                        if ~found_path
                            % Tentar seguir um caminho do nó atual para o nó de referência
                            current = node;
                            for step = 1:size
                                if current == ref_node
                                    found_path = true;
                                    break;
                                end
                                current = phi(current);
                                if current == node
                                    break;  % Detectou ciclo, parar busca
                                end
                            end
                        end
                        
                        % Se ainda não encontrou caminho, tentar ver se ambos levam ao mesmo ciclo
                        if ~found_path
                            % Seguir de ref_node até encontrar um ciclo
                            visited1 = zeros(size, 1);
                            current = ref_node;
                            for step = 1:size
                                visited1(current) = step;
                                current = phi(current);
                                if visited1(current) > 0
                                    break;  % Ciclo encontrado
                                end
                            end
                            cycle1_start = current;
                            
                            % Seguir de node até encontrar um ciclo
                            visited2 = zeros(size, 1);
                            current = node;
                            for step = 1:size
                                visited2(current) = step;
                                current = phi(current);
                                if visited2(current) > 0
                                    break;  % Ciclo encontrado
                                end
                            end
                            cycle2_start = current;
                            
                            % Verificar se os ciclos se sobrepõem
                            current = cycle1_start;
                            for step = 1:size
                                if current == cycle2_start
                                    found_path = true;
                                    break;
                                end
                                current = phi(current);
                                if current == cycle1_start
                                    break;
                                end
                            end
                        end
                        
                        assert(found_path, ['Falha: Nós ', num2str(ref_node), ' e ', num2str(node), ...
                                           ' estão na mesma órbita mas não têm conexão']);
                    end
                end
                
                disp('    ✓ Verificação de consistência passou');
            catch ME
                disp(['    ✗ Verificação de consistência falhou: ', ME.message]);
            end
        end
        
        % Salvar estatísticas para este tamanho
        stats(s).size = size;
        stats(s).time = times;
        stats(s).components = components;
        stats(s).cycles = cycles;
        
        % Mostrar resumo
        disp(['  Tempo médio: ', num2str(mean(times)), ' segundos']);
        disp(['  Número médio de componentes: ', num2str(mean(components))]);
        disp(['  Número médio de nós em ciclos: ', num2str(mean(cycles)), ' (', ...
               num2str(mean(cycles)/size*100), '%)']);
        disp('-------------------------------------------');
    end
    
    % Apresentar resumo final de desempenho
    disp('Resumo de desempenho:');
    disp('-------------------------------------------');
    disp('Tamanho | Tempo (s) | Componentes | % Ciclos');
    disp('-------------------------------------------');
    for s = 1:numel(sizes)
        disp(sprintf('%7d | %9.6f | %11.2f | %7.2f%%', ...
            stats(s).size, mean(stats(s).time), mean(stats(s).components), ...
            mean(stats(s).cycles)/stats(s).size*100));
    end
    disp('-------------------------------------------');
    
    % Plotar resultados
    figure;
    
    % Plotar tempo vs tamanho
    subplot(1, 3, 1);
    plot([stats.size], cellfun(@mean, {stats.time}), '-o', 'LineWidth', 2);
    title('Tempo de Execução');
    xlabel('Tamanho do Grafo');
    ylabel('Tempo (segundos)');
    grid on;
    
    % Plotar componentes vs tamanho
    subplot(1, 3, 2);
    plot([stats.size], cellfun(@mean, {stats.components}), '-o', 'LineWidth', 2);
    title('Número de Componentes');
    xlabel('Tamanho do Grafo');
    ylabel('Componentes');
    grid on;
    
    % Plotar percentagem de ciclos vs tamanho
    subplot(1, 3, 3);
    cycle_percent = arrayfun(@(x) mean(x.cycles)/x.size*100, stats);
    plot([stats.size], cycle_percent, '-o', 'LineWidth', 2);
    title('Percentagem de Nós em Ciclos');
    xlabel('Tamanho do Grafo');
    ylabel('% Nós em Ciclos');
    grid on;
    
    % Ajustar layout
    sgtitle('Desempenho da Função orbits.m em Grafos Aleatórios');
    
    disp('Testes aleatórios concluídos.');
end
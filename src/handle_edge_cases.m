% handle_edge_cases.m
% Esta função testa especificamente os edge cases mais problemáticos para orbits.m

function handle_edge_cases()
    clc;
    disp('Testando edge cases específicos para orbits.m...');
    disp('-------------------------------------------');
    
    % Lista de edge cases a testar
    test_cases = {
        % Caso 1: Grafo vazio
        struct('name', 'Grafo vazio', 'phi', []),
        
        % Caso 2: Grafo com um único nó (self-loop)
        struct('name', 'Único nó com self-loop', 'phi', 1),
        
        % Caso 3: Grafo com um único nó (sem self-loop - impossível em teoria, mas testar)
        struct('name', 'Único nó sem self-loop', 'phi', 1),
        
        % Caso 4: Grafo onde todos os nós apontam para o mesmo nó
        struct('name', 'Todos apontam para nó 1', 'phi', [1; 1; 1; 1; 1]),
        
        % Caso 5: Grafo em linha com terminação em self-loop
        struct('name', 'Grafo em linha', 'phi', [2; 3; 4; 5; 5]),
        
        % Caso 6: Múltiplos self-loops
        struct('name', 'Múltiplos self-loops', 'phi', [1; 2; 3; 4; 5]),
        
        % Caso 7: Ciclo perfeito
        struct('name', 'Ciclo perfeito', 'phi', [2; 3; 4; 5; 1]),
        
        % Caso 8: Múltiplos ciclos desconectados
        struct('name', 'Múltiplos ciclos desconectados', 'phi', [2; 1; 5; 6; 3; 4; 8; 7]),
        
        % Caso 9: Ciclo com múltiplos nós conectados
        struct('name', 'Ciclo com múltiplos nós conectados', 'phi', [2; 3; 1; 3; 3; 3; 3; 3; 3; 3]),
        
        % Caso 10: Estrutura complexa
        struct('name', 'Estrutura complexa', 'phi', [2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 1]),
        
        % Caso 11: Grafo com nó isolado
        struct('name', 'Grafo com nó isolado', 'phi', [2; 3; 1; 4]),
        
        % Caso 12: Estrutura de árvore
        struct('name', 'Estrutura de árvore', 'phi', [4; 4; 4; 4; 6; 6; 8; 8; 8; 8]),
        
        % Caso 13: Ciclo com entrada mas sem saída
        struct('name', 'Ciclo com entrada mas sem saída', 'phi', [2; 3; 4; 2])
    };
    
    % Executar testes
    for i = 1:numel(test_cases)
        tc = test_cases{i};
        disp(['Testando Caso ', num2str(i), ': ', tc.name]);
        
        try
            % Executar orbits
            [orb, ord, psi, deg, init, term, prin, conn] = orbits(tc.phi);
            
            % Visualizar os resultados
            n = numel(tc.phi);
            if n == 0
                disp('  Grafo vazio - sem saídas para mostrar');
            else
                disp('  Resultados:');
                disp('  --------------------------------------------');
                disp('  Nó | phi | orb | ord | psi | deg | Observação');
                disp('  --------------------------------------------');
                
                for j = 1:n
                    % Preparar string de observação
                    obs = '';
                    if ismember(j, init)
                        obs = [obs, 'Inicial '];
                    end
                    if deg(j) == -1
                        obs = [obs, 'Cíclico '];
                    else
                        obs = [obs, 'Não-cíclico '];
                    end
                    
                    % Verificar relação phi-psi
                    if j == psi(tc.phi(j))
                        obs = [obs, 'phi-psi consistente '];
                    else
                        obs = [obs, '⚠️ phi-psi inconsistente '];
                    end
                    
                    disp(sprintf('  %2d | %3d | %3d | %3d | %3d | %3d | %s', ...
                        j, tc.phi(j), orb(j), ord(j), psi(j), deg(j), obs));
                end
                disp('  --------------------------------------------');
                
                % Mostrar informações adicionais
                disp(['  Número de componentes: ', num2str(max(orb))]);
                disp(['  Nós iniciais: ', mat2str(init)]);
                
                % Verificar consistência
                check_consistency(tc.phi, orb, ord, psi, deg);
            end
        catch ME
            disp(['  ⚠️ Erro: ', ME.message]);
        end
        disp('-------------------------------------------');
    end
    
    disp('Teste de edge cases concluído.');
end

% Função auxiliar para verificar a consistência dos resultados
function check_consistency(phi, orb, ord, psi, deg)
    n = numel(phi);
    issues = 0;
    
    % 1. Verificar se todos os nós têm uma órbita atribuída
    if any(orb <= 0)
        disp('  ⚠️ Problema: Alguns nós não têm órbita atribuída');
        issues = issues + 1;
    end
    
    % 2. Verificar a consistência de phi-psi para nós cíclicos
    for i = 1:n
        if deg(i) == -1 % Nó cíclico
            if phi(psi(i)) ~= i
                disp(['  ⚠️ Problema: Inconsistência phi-psi para nó ', num2str(i)]);
                disp(['      phi(psi(', num2str(i), ')) = phi(', num2str(psi(i)), ') = ', ...
                     num2str(phi(psi(i))), ' mas deveria ser ', num2str(i)]);
                issues = issues + 1;
            end
        end
    end
    
    % 3. Verificar se nós na mesma órbita têm a mesma etiqueta de órbita
    for comp = 1:max(orb)
        comp_nodes = find(orb == comp);
        
        % Verificar conectividade dentro da órbita
        for i = 1:numel(comp_nodes)
            node = comp_nodes(i);
            connected = false;
            
            % Seguir o phi para ver se chegamos a outro nó da componente
            visited = false(n, 1);
            current = node;
            while ~visited(current)
                visited(current) = true;
                next = phi(current);
                
                if current ~= node && ismember(current, comp_nodes)
                    connected = true;
                    break;
                end
                
                current = next;
                if visited(current)
                    break;
                end
            end
            
            if ~connected && numel(comp_nodes) > 1
                disp(['  ⚠️ Problema: Nó ', num2str(node), ' está na órbita ', ...
                     num2str(comp), ' mas não parece estar conectado a outros nós da mesma órbita']);
                issues = issues + 1;
            end
        end
    end
    
    % 4. Verificar se ciclos são corretamente identificados
    for i = 1:n
        visited = false(n, 1);
        current = i;
        cycle_detected = false;
        
        while ~visited(current)
            visited(current) = true;
            current = phi(current);
            
            if visited(current)
                cycle_detected = true;
                break;
            end
        end
        
        if cycle_detected && deg(i) ~= -1
            disp(['  ⚠️ Problema: Nó ', num2str(i), ' pertence a um ciclo mas não está marcado como cíclico']);
            issues = issues + 1;
        elseif ~cycle_detected && deg(i) == -1
            disp(['  ⚠️ Problema: Nó ', num2str(i), ' está marcado como cíclico mas não pertence a um ciclo']);
            issues = issues + 1;
        end
    end
    
    % Resumo da verificação
    if issues == 0
        disp('  ✓ Verificação de consistência: Nenhum problema encontrado');
    else
        disp(['  ⚠️ Verificação de consistência: ', num2str(issues), ' problemas encontrados']);
    end
end
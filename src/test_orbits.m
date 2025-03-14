% test_orbits.m
% Conjunto de testes para verificar a função orbits.m com vários edge cases

function test_orbits()
    clc;
    disp('Iniciando testes da função orbits.m...');
    disp('-------------------------------------------');
    
    % Total de testes
    total_tests = 10;
    passed_tests = 0;
    
    %% Teste 1: Grafo vazio
    try
        disp('Teste 1: Grafo vazio');
        phi = [];
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar saídas para grafo vazio
        assert(isempty(orb) && isempty(ord) && isempty(psi) && isempty(deg), 'Falha: saídas não vazias para grafo vazio');
        disp('✓ Teste 1 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 1 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 2: Grafo com um único nó (self-loop)
    try
        disp('Teste 2: Grafo com um único nó (self-loop)');
        phi = 1;
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar saídas para um único nó com self-loop
        assert(orb(1) == 1, 'Falha: órbita incorreta');
        assert(ord(1) == 1, 'Falha: ordem incorreta');
        assert(psi(1) == 1, 'Falha: pseudo-inverso incorreto');
        assert(deg(1) == -1, 'Falha: grau incorreto para nó cíclico');
        disp('✓ Teste 2 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 2 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 3: Grafo linear (caminho simples sem ciclos)
    try
        disp('Teste 3: Grafo linear (caminho simples sem ciclos)');
        phi = [2; 3; 4; 5; 5];  % 1->2->3->4->5->(5 aponta para si mesmo)
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar identificação de componentes
        assert(all(orb == 1), 'Falha: órbitas incorretas');
        assert(isequal(ord, [1; 2; 3; 4; 5]), 'Falha: ordens incorretas');
        assert(isequal(deg, [0; 0; 0; 0; -1]), 'Falha: graus incorretos');
        assert(isempty(init), 'Falha: nós iniciais incorretos');
        disp('✓ Teste 3 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 3 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 4: Grafo com ciclo simples
    try
        disp('Teste 4: Grafo com ciclo simples');
        phi = [2; 3; 1];  % 1->2->3->1 (ciclo)
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar identificação de ciclo
        assert(all(orb == 1), 'Falha: órbitas incorretas');
        assert(isequal(deg, [-1; -1; -1]), 'Falha: todos os nós deveriam ser cíclicos');
        disp('✓ Teste 4 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 4 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 5: Grafos múltiplos componentes
    try
        disp('Teste 5: Grafos com múltiplos componentes');
        phi = [2; 3; 1; 5; 6; 4];  % Dois ciclos: 1->2->3->1 e 4->5->6->4
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar identificação de múltiplos componentes
        assert(orb(1) == orb(2) && orb(2) == orb(3), 'Falha: primeira órbita incorreta');
        assert(orb(4) == orb(5) && orb(5) == orb(6), 'Falha: segunda órbita incorreta');
        assert(orb(1) ~= orb(4), 'Falha: componentes não distinguidos');
        assert(all(deg == -1), 'Falha: todos os nós deveriam ser cíclicos');
        disp('✓ Teste 5 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 5 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 6: Grafo com múltiplas árvores conectadas a ciclos
    try
        disp('Teste 6: Grafo com múltiplas árvores conectadas a ciclos');
        phi = [2; 3; 4; 4; 6; 7; 5; 9; 5];  % Nós 4-5-6-7 formam um ciclo, com árvores conectadas
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar estrutura combinada
        assert(deg(4) == -1 && deg(5) == -1 && deg(6) == -1 && deg(7) == -1, 'Falha: nós cíclicos incorretos');
        assert(deg(1) == 0 && deg(2) == 0 && deg(3) == 0, 'Falha: nós não-cíclicos incorretos');
        disp('✓ Teste 6 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 6 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 7: Grafo em estrela
    try
        disp('Teste 7: Grafo em estrela');
        phi = [1; 1; 1; 1; 1];  % Todos os nós apontam para o nó 1 (estrela)
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar estrutura em estrela
        assert(deg(1) == -1, 'Falha: centro da estrela deve ser cíclico');
        assert(all(deg(2:5) == 0), 'Falha: pontas da estrela devem ser não-cíclicas');
        disp('✓ Teste 7 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 7 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 8: Grafo completamente desconectado
    try
        disp('Teste 8: Grafo completamente desconectado');
        phi = [1; 2; 3; 4; 5];  % Cada nó aponta para si mesmo
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar nós desconectados
        assert(all(orb ~= orb'), 'Falha: todos os nós devem ter órbitas diferentes');
        assert(all(deg == -1), 'Falha: todos os nós devem ser cíclicos (self-loops)');
        disp('✓ Teste 8 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 8 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 9: Casos extremos de índices (limites do grafo)
    try
        disp('Teste 9: Casos extremos de índices');
        % Todos os nós apontam para o último nó
        n = 10;
        phi = repmat(n, n, 1);
        phi(n) = n;  % Último nó aponta para si mesmo
        
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar resultados
        assert(deg(n) == -1, 'Falha: último nó deve ser cíclico');
        assert(all(deg(1:n-1) == 0), 'Falha: outros nós devem ser não-cíclicos');
        disp('✓ Teste 9 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 9 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Teste 10: Teste com valores aleatórios
    try
        disp('Teste 10: Teste com valores aleatórios');
        % Criar grafo aleatório
        n = 100;
        rng(42);  % Fixar a semente para reprodutibilidade
        phi = randi(n, n, 1);
        
        [orb, ord, psi, deg, init, term, prin, conn] = orbits(phi);
        
        % Verificar estrutura básica das saídas
        assert(numel(orb) == n, 'Falha: tamanho da saída orb incorreto');
        assert(numel(ord) == n, 'Falha: tamanho da saída ord incorreto');
        assert(numel(psi) == n, 'Falha: tamanho da saída psi incorreto');
        assert(numel(deg) == n, 'Falha: tamanho da saída deg incorreto');
        
        % Verificar se phi(psi) é consistente para nós cíclicos
        for i = 1:n
            if deg(i) == -1 % Nó cíclico
                assert(phi(psi(i)) == i, 'Falha: inconsistência entre phi e psi');
            end
        end
        
        disp('✓ Teste 10 passou');
        passed_tests = passed_tests + 1;
    catch ME
        disp(['✗ Teste 10 falhou: ', ME.message]);
    end
    disp('-------------------------------------------');
    
    %% Sumário dos testes
    disp(['Testes concluídos: ', num2str(passed_tests), ' de ', num2str(total_tests), ' testes passaram']);
    if passed_tests == total_tests
        disp('Todos os testes passaram! A função orbits.m está funcionando corretamente.');
    else
        disp('Alguns testes falharam. Revise a função orbits.m e corrija os problemas encontrados.');
    end
end
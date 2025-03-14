% run_orbits_tests.m
% Script principal para executar todos os testes do orbits.m

% Limpar workspace e console
clear all;
clc;

disp('===============================================');
disp('VALIDAÇÃO COMPLETA DA FUNÇÃO ORBITS.M');
disp('===============================================');
disp('Este script executa uma série de testes para validar');
disp('a função orbits.m, incluindo edge cases e casos aleatórios.');
disp('-----------------------------------------------');

% Perguntar ao usuário quais testes deseja executar
disp('Selecione os testes que deseja executar:');
disp('1. Testes básicos (edge cases)');
disp('2. Testes aleatórios');
disp('3. Visualização gráfica de exemplos');
disp('4. Todos os testes');
disp('0. Sair');

option = input('Sua escolha (0-4): ');

switch option
    case 0
        disp('Saindo...');
        return;
        
    case 1
        disp('Executando testes básicos...');
        disp('-----------------------------------------------');
        test_orbits();  % Executa testes básicos
        pause(1);
        disp('-----------------------------------------------');
        disp('Executando testes de edge cases específicos...');
        handle_edge_cases();  % Executa testes de edge cases específicos
        
    case 2
        disp('Executando testes aleatórios...');
        disp('-----------------------------------------------');
        random_test_orbits();  % Executa testes aleatórios
        
    case 3
        disp('Visualizando exemplos...');
        disp('-----------------------------------------------');
        
        % Perguntar qual exemplo visualizar
        disp('Selecione o exemplo para visualizar:');
        disp('1. Grafo em estrela (todos apontam para nó 1)');
        disp('2. Grafo com ciclo perfeito');
        disp('3. Grafo com ciclos múltiplos');
        disp('4. Grafo complexo');
        disp('5. Grafo aleatório');
        disp('6. Definir grafo manualmente');
        
        viz_option = input('Sua escolha (1-6): ');
        
        switch viz_option
            case 1
                phi = [1; 1; 1; 1; 1];  % Grafo em estrela
                disp('Visualizando grafo em estrela (todos apontam para nó 1)...');
                [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
                visualize_orbits(phi, orb, ord, psi, deg, init);
                
            case 2
                phi = [2; 3; 4; 5; 1];  % Ciclo perfeito
                disp('Visualizando grafo com ciclo perfeito...');
                [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
                visualize_orbits(phi, orb, ord, psi, deg, init);
                
            case 3
                phi = [2; 1; 5; 6; 3; 4; 8; 7];  % Múltiplos ciclos
                disp('Visualizando grafo com ciclos múltiplos...');
                [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
                visualize_orbits(phi, orb, ord, psi, deg, init);
                
            case 4
                phi = [2; 3; 4; 5; 6; 7; 8; 9; 10; 3];  % Grafo complexo
                disp('Visualizando grafo complexo...');
                [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
                visualize_orbits(phi, orb, ord, psi, deg, init);
                
            case 5
                n = input('Número de nós para o grafo aleatório: ');
                phi = randi(n, n, 1);
                disp('Visualizando grafo aleatório...');
                [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
                visualize_orbits(phi, orb, ord, psi, deg, init);
                
            case 6
                disp('Defina o vetor phi (exemplo: [2, 3, 1] para um grafo com 3 nós):');
                phi = input('phi = ');
                phi = phi(:);  % Garantir que é um vetor coluna
                disp('Visualizando grafo definido manualmente...');
                [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
                visualize_orbits(phi, orb, ord, psi, deg, init);
                
            otherwise
                disp('Opção inválida.');
        end
        
    case 4
        disp('Executando todos os testes...');
        disp('-----------------------------------------------');
        
        % Executar todos os testes em sequência
        disp('1. Testes básicos:');
        test_orbits();
        pause(1);
        
        disp('2. Testes de edge cases específicos:');
        handle_edge_cases();
        pause(1);
        
        disp('3. Testes aleatórios:');
        random_test_orbits();
        pause(1);
        
        disp('4. Visualização de exemplo:');
        % Escolher um exemplo para visualizar
        phi = [2; 3; 4; 5; 6; 3; 8; 9; 10; 7];  % Grafo complexo
        [orb, ord, psi, deg, init, ~, ~, ~] = orbits(phi);
        visualize_orbits(phi, orb, ord, psi, deg, init);
        
    otherwise
        disp('Opção inválida.');
end

disp('===============================================');
disp('Testes concluídos!');
disp('===============================================');
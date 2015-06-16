% How this script works
% Because BNT does not support structure learning with partial observations and the fact
% that full Bayesian inference in such cases is difficult, instead I run the Bayesian
% structure learning algorithm using four different CPDs for the chip value node
% 
% The four cases each assign the highest chip value to a different chip. If the two graphs
% get the same score for all four CPDs, then clearly this detail doesn't matter for the
% structure learning algorithm.
%
% Note: this is exactly what I find. In particular, I always find a 2/3 bias in favor
% of the copy machine, which is exactly the result you get if you assume a random choice
% function

clear all;

% g = 1: B1 --> B2
% g = 2: B1 <-- B2

% Always observe outcome AA
% Random condition: BB -> max reward
% Copy condition: AB -> max reward
% Uncertain condition: No CPD for C node
RANDOM_COND = 1;
COPY_COND = 2;
UNCERTAIN_COND = 3;

cond = UNCERTAIN_COND;

B1 = 1; B2 = 2; C = 3; V = 4;
dag{1} = zeros(4,4);
dag{2} = zeros(4,4);

% Graph 1
dag{1}(B1,B2) = 1;
dag{1}([B1 B2], C) = 1;
dag{1}(C,V) = 1;
% Graph 2
dag{2}(B2,B1) = 1;
dag{2}([B1 B2], C) = 1;
dag{2}(C,V) = 1;

ns = [2 2 4 4];

% CPT for node B1
cpt{1}{B1} = [0.5 0.5];
cpt{2}{B1} = [1 0, 0 1];
for i=1:4
    params{i}{1,B1} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1};
    params{i}{2,B1} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', cpt{2}{B1}};
    
    % CPT for B2: unknown
    params{i}{1,B2} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1};
    params{i}{2,B2} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1};
    
    % CPT for node C (chip color)
    % Just arbitrarily assign values 1:4 for the 4 possible values of B1 and B2
    % Outcome AA: B1=1, B2=1, C=1
    % Outcome BA: B1=2, B2=1, C=2
    % Outcome AB: B1=1, B2=2, C=3
    % Outcome BB: B1=2, B2=2, C=4
    params{i}{1,C} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1]};
    params{i}{2,C} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1]};
end

% AA --> max reward (4) 
params{1}{1,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [0 1 0 0, 0 0 1 0, 0 0 0 1, 1 0 0 0]};
params{1}{2,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [0 1 0 0, 0 0 1 0, 0 0 0 1, 1 0 0 0]};
data{1} = [1 1 1 4]';
% BA --> max reward (4)
params{2}{1,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 0 1 0, 0 0 0 1, 0 1 0 0]};
params{2}{2,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 0 1 0, 0 0 0 1, 0 1 0 0]};
data{2} = [1 1 1 1]';
% AB --> max reward (4) Copy condition
params{3}{1,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 1 0 0, 0 0 0 1, 0 0 1 0]};
params{3}{2,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 1 0 0, 0 0 0 1, 0 0 1 0]};
data{3} = [1 1 1 1]';
% BB --> max reward (4) Random condition
params{4}{1,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1]};
params{4}{2,V} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', [1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1]};
data{4} = [1 1 1 1]';

n = 5000;


% Generate predictions for the makes sense questions
% Here I just compute P(B1=1,B2=1 | graph) for each graph

% I don't bother running cases with different CPDs for the V node because I already
% established that this information isn't used by the model.
pchoice = zeros(n,2);
for i=1:n
    bnet1 = mk_bnet(dag{1}, ns);
    bnet1.CPD{B1} = tabular_CPD(bnet1, B1, [0.5 0.5]);
    bnet1.CPD{B2} = tabular_CPD(bnet1, B2, 'prior_type', 'dirichlet', 'dirichlet_weight', 1);
    bnet1.CPD{C} = tabular_CPD(bnet1, C, [1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1]);
    bnet1.CPD{V} = tabular_CPD(bnet1, V, [1 0 0 0, 0 1 0 0, 0 0 0 1, 0 0 1 0]);
    engine = jtree_inf_engine(bnet1);
    ev = cell(1,4);
    %ev{B1} = 1;
    [engine, ll] = enter_evidence(engine, ev);
    m = marginal_nodes(engine, [B1 B2]);
    pchoice(i,1) = m.T(1,1);
    
    bnet2 = mk_bnet(dag{2}, ns);
    bnet2.CPD{B1} = tabular_CPD(bnet2, B1, [1 0, 0 1]);
    bnet2.CPD{B2} = tabular_CPD(bnet2, B2, 'prior_type', 'dirichlet', 'dirichlet_weight', 1);
    bnet2.CPD{C} = tabular_CPD(bnet2, C, [1 0 0 0, 0 1 0 0, 0 0 1 0, 0 0 0 1]);
    bnet2.CPD{V} = tabular_CPD(bnet2, V, [1 0 0 0, 0 1 0 0, 0 0 0 1, 0 0 1 0]);
    engine = jtree_inf_engine(bnet2);
    ev = cell(1,4);
    %ev{B1} = 1;
    [engine, ll] = enter_evidence(engine, ev);
    m = marginal_nodes(engine, [B1 B2]);
    pchoice(i,2) = m.T(1,1);
end






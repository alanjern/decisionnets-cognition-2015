% Expt 3 and 4 decision net maximizing model
clear all;
close all;

nRounds = 10;   % Number of observed rounds
nConditions = 3;    % Number of different observed sequeces
nOutcomes = 3;      % Number of different outcomes in each round
nModels = 3;    % Number of different models (or cards)

evector = 0; % Probability of making a "mistake"
            
% Different rount outcomes
C = 1;      % Consistent
V1 = 2;     % Violation 1 (response matches box 1)
V2 = 3;     % Violation 2 (response matches box 2)

% Sequences of outcomes for the different conditions
outcomes = [C C C C C C C C C C;
            C C C V1 C V1 V1 V1 C C;
            C C C V1 C V1 V1 V2 C C];

% For each round, compute the cumulative probability of each
% card (model)
nEs = length(evector);
probabilities = zeros(nModels,nRounds,nConditions,nEs);
for i=1:length(evector)
    e = evector(i);

    % Conditional probabilty table showing probability of outcomes
    % given each card
    cpd = zeros(nModels,nOutcomes);

    % Let e be the probability of a mistake

    % Model 1: both boxes observed
    cpd(1,C) = 1-e;
    cpd(1,V1) = e/2;
    cpd(1,V2) = e/2;
    % Model 2: box 2 observed
    cpd(2,C) = (1/2)*(1-e);
    cpd(2,V1) = (1/2)*(1-e);
    cpd(2,V2) = e;
    % Model 3: no box observed
    cpd(3,:) = [1/3 1/3 1/3];

    for c=1:nConditions
        for r=1:nRounds
            % Compute the unormalized likelihoods of each model given the
            % sequence so far
            p = ones(3,1);
            for rpast=1:r
                p(1) = p(1) * cpd(1,outcomes(c,rpast));
                p(2) = p(2) * cpd(2,outcomes(c,rpast));
                p(3) = p(3) * cpd(3,outcomes(c,rpast));
            end
            probabilities(:,r,c,i) = p / sum(p);
        end
    end
end

figuresize = [0 0 1.1 0.7];

if (length(evector) == 1)
    for c=1:nConditions
        maxmodelfigures(c) = figure();
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'PaperPosition', figuresize);
        
        axis([1 10 0 1]);
        hold on;
        plot(1:10, probabilities(3,:,c,1), 'r.-');
        plot(1:10, probabilities(2,:,c,1), 'b+-');
        plot(1:10, probabilities(1,:,c,1), 'cx-');
        box off;
        set(gca, 'YTick', [0 0.5 1]);
        set(gca, 'YTickLabel', {});
        set(gca, 'XTick', 1:1:10);
        set(gca, 'XTickLabel', {});
        set(gca,'fontsize',8);
        
        hold off;
    end
    
%    figure(maxmodelfigures(1));
%    print -depsc maxmodel1;
%    figure(maxmodelfigures(2));
%    print -depsc maxmodel2;
%    figure(maxmodelfigures(3));
%    print -depsc maxmodel3;
end
    

% Save the non-parameterized model results
maxpreds = probabilities; 
%save maxmodelpredictions maxpreds;


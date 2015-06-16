% Shape Game model
clear all;
close all;

nRounds = 10;   % Number of observed rounds
nConditions = 3;    % Number of different observed sequeces
nOutcomes = 3;      % Number of different outcomes in each round
nModels = 3;    % Number of different models (or cards)


% e = probability of a "mistake" (i.e., choosing at random)
% Best fitting value for info is e=0.018
% Best fitting value for util is e=0
e_info = 0.007
e_util = 0;
            
% Different round outcomes
D = 1;      % All shapes different
M1 = 2;     % Response matches box 1
M2 = 3;     % Response matches box 2

% Sequences of outcomes for the different conditions
outcomes = [D D D D D D D D D D;
            D D D M1 D M1 M1 M1 D D;
            D D D M1 D M1 M1 M2 D D];
            

% Info version

% Conditional probabilty table showing probability of outcomes
% given each card
cpd = zeros(nModels,nOutcomes);

% Model 1: both boxes observed
cpd(1,D) = 1-e_info;
cpd(1,M1) = e_info/2;
cpd(1,M2) = e_info/2;
% Model 2: box 2 observed
cpd(2,D) = (1/2)*(1-e_info);
cpd(2,M1) = (1/2)*(1-e_info);
cpd(2,M2) = e_info;
% Model 3: no box observed
cpd(3,:) = [1/3 1/3 1/3];
%
%% Model 1: both boxes observed
%cpd(1,D) = (1-e_info)*1 + e_info*(1/3);
%cpd(1,M1) = (1-e_info)*0 + e_info*(1/3);
%cpd(1,M2) = (1-e_info)*0 + e_info*(1/3);
%% Model 2: box 2 observed
%cpd(2,D) = (1-e_info)*(1/2) + e_info*(1/3);
%cpd(2,M1) = (1-e_info)*(1/2) + e_info*(1/3);
%cpd(2,M2) = (1-e_info)*0 + e_info*(1/3);
%% Model 3: no box observed
%cpd(3,:) = [1/3 1/3 1/3];

% For each round, compute the cumulative probability of each
% card (model)
probabilitiesInfo = zeros(nModels,nRounds,nConditions);

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
        probabilitiesInfo(:,r,c) = p / sum(p);
    end
end


% Utility version

% Conditional probabilty table showing probability of outcomes
% given each card
cpd = zeros(nModels,nOutcomes);
% Model 1: both boxes observed
cpd(1,D) = 1-e_util;
cpd(1,M1) = e_util/2;
cpd(1,M2) = e_util/2;
% Model 2: box 2 observed
cpd(2,D) = (1/2)*(1-e_util);
cpd(2,M1) = (1/2)*(1-e_util);
cpd(2,M2) = e_util;
% Model 3: no box observed
cpd(3,:) = [1/3 1/3 1/3];
%
%% Model 1: both boxes count
%cpd(1,D) = (1-e_util)*1 + e_util*(1/3);
%cpd(1,M1) = (1-e_util)*0 + e_util*(1/3);
%cpd(1,M2) = (1-e_util)*0 + e_util*(1/3);
%% Model 2: box 1 doesn't count
%cpd(2,D) = (1-e_util)*(1/2) + e_util*(1/3);
%cpd(2,M1) = (1-e_util)*(1/2) + e_util*(1/3);
%cpd(2,M2) = (1-e_util)*0 + e_util*(1/3);
%% Model 3: no boxes count
%cpd(3,:) = [1/3 1/3 1/3];

% For each round, compute the cumulative probability of each
% card (model)
probabilitiesUtil = zeros(nModels,nRounds,nConditions);

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
        probabilitiesUtil(:,r,c) = p / sum(p);
    end
end

figuresize = [0 0 1.1 0.7];

for c=1:nConditions
    fittedinfomodelfigures(c) = figure();
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figuresize);
    
    axis([1 10 0 1]);
    hold on;
    plot(1:10, probabilitiesInfo(3,:,c), 'r.-');
    plot(1:10, probabilitiesInfo(2,:,c), 'b+-');
    plot(1:10, probabilitiesInfo(1,:,c), 'cx-');
    box off;
    set(gca, 'YTick', [0 0.5 1]);
    set(gca, 'YTickLabel', {});
    set(gca, 'XTick', 1:1:10);
    set(gca, 'XTickLabel', {});
    set(gca,'fontsize',8);
    hold off;
    
    fittedutilmodelfigures(c) = figure();
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figuresize);
    
    axis([1 10 0 1]);
    hold on;
    plot(1:10, probabilitiesUtil(3,:,c), 'r.-');
    plot(1:10, probabilitiesUtil(2,:,c), 'b+-');
    plot(1:10, probabilitiesUtil(1,:,c), 'cx-');
    box off;
    set(gca, 'YTick', [0 0.5 1]);
    set(gca, 'YTickLabel', {});
    set(gca, 'XTick', 1:1:10);
    set(gca, 'XTickLabel', {});
    set(gca,'fontsize',8);
    hold off;
end

%figure(fittedinfomodelfigures(1));
%print -depsc expt1fittedmodel1;
%figure(fittedinfomodelfigures(2));
%print -depsc expt1fittedmodel2;
%figure(fittedinfomodelfigures(3));
%print -depsc expt1fittedmodel3;
%figure(fittedutilmodelfigures(1));
%print -depsc expt2fittedmodel1;
%figure(fittedutilmodelfigures(2));
%print -depsc expt2fittedmodel2;
%figure(fittedutilmodelfigures(3));
%print -depsc expt2fittedmodel3;
    
    

% Plot the results
%figure;
%for i=1:length(evector)
%    for c=1:nConditions
%        subplot(length(evector),3,c+3*(i-1));
%        hold on;
%        xlabel('Observation');
%        ylabel('Card probabilities');
%        axis([1 10 0 1]);
%        
%        plot(1:10, probabilities(3,:,c,i), 'r.-');
%        plot(1:10, probabilities(2,:,c,i), 'b.-');
%        plot(1:10, probabilities(1,:,c,i), 'c.-');
%        t = sprintf('e = %.3f',evector(i));
%        title(t);
%    end
%end


% Save the non-parameterized model results
fittedpreds = {probabilitiesInfo; probabilitiesUtil};; 
%save fittedmodelpredictions fittedpreds;



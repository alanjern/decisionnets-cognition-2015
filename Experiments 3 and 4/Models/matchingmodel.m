% Shape Game probability matching model

clear all;
close all;

nRounds = 10;   % Number of observed rounds
nConditions = 3;    % Number of different observed sequeces
nOutcomes = 3;      % Number of different outcomes in each round
nModels = 3;    % Number of different models (or cards)
            
% Different rount outcomes
C = 1;      % Consistent
V1 = 2;     % Violation 1 (response matches box 1)
V2 = 3;     % Violation 2 (response matches box 2)

% Sequences of outcomes for the different conditions
outcomes = [C C C C C C C C C C;
            C C C V1 C V1 V1 V1 C C;
            C C C V1 C V1 V1 V2 C C];

% Info version
a = 1;
% Conditional probabilty table showing probability of outcomes
% given each card
cpd = zeros(nModels,nOutcomes);
% Model 1: both boxes observed
evC = 2 / (2+1+1);
evV1 = 1 / (2+1+1);
evV2 = 1 / (2+1+1);
cpd(1,C) = evC^a / (evC^a + evV1^a + evV2^a);
cpd(1,V1) = evV1^a / (evC^a + evV1^a + evV2^a);
cpd(1,V2) = evV2^a / (evC^a + evV1^a + evV2^a);
% Model 1: box 2 observed
evC = 2*(1/2) + 1*(1/2);
evV1 = 2*(1/2) + 1*(1/2);
evV2 = 1;
cpd(2,C) = evC^a / (evC^a + evV1^a + evV2^a);
cpd(2,V1) = evV1^a / (evC^a + evV1^a + evV2^a);
cpd(2,V2) = evV2^a / (evC^a + evV1^a + evV2^a);
% Model 3: no box observed
cpd(3,:) = [1/3 1/3 1/3];

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


% Util version

% Conditional probabilty table showing probability of outcomes
% given each card
cpd = zeros(nModels,nOutcomes);
% Model 1: both boxes observed
cpd(1,C) = 20^a / (20^a+10^a+10^a);
cpd(1,V1) = 10^a / (20^a+10^a+10^a);
cpd(1,V2) = 10^a / (20^a+10^a+10^a);
% Model 1: box 2 observed
cpd(2,C) = 10^a / (10^a+10^a+0^a);
cpd(2,V1) = 10^a / (10^a+10^a+0^a);
cpd(2,V2) =  0^a;
% Model 3: no box observed
cpd(3,:) = [1/3 1/3 1/3];

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

% Plot the results

figuresize = [0 0 1.1 0.7];

for c=1:nConditions
    matchinfomodelfigures(c) = figure();
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
    
    matchutilmodelfigures(c) = figure();
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

%figure(matchinfomodelfigures(1));
%print -depsc expt1matchmodel1;
%figure(matchinfomodelfigures(2));
%print -depsc expt1matchmodel2;
%figure(matchinfomodelfigures(3));
%print -depsc expt1matchmodel3;
%figure(matchutilmodelfigures(1));
%print -depsc expt2matchmodel1;
%figure(matchutilmodelfigures(2));
%print -depsc expt2matchmodel2;
%figure(matchutilmodelfigures(3));
%print -depsc expt2matchmodel3;

% Save the model predictions
matchpreds = {probabilitiesInfo; probabilitiesUtil};
%save matchmodelpredictions matchpreds;

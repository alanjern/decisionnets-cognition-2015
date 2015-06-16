% Shape Game comparison model: The "logic" model

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

% For each round, compute the cumulative probability of each
% card (model)
probabilities = zeros(nModels,nRounds,nConditions);
for c=1:nConditions
    for r=1:nRounds
        % Compute the unormalized likelihoods of each model given the
        % sequence so far
        p = ones(3,1);
        for rpast=1:r
            switch outcomes(c,rpast)
                case C
                    p(1) = p(1) * 1;
                    p(2) = p(2) * 1;
                    p(3) = p(3) * 1;
                case V1
                    p(1) = p(1) * 0;
                    p(2) = p(2) * 1;
                    p(3) = p(3) * 1;
                case V2
                    p(1) = p(1) * 0;
                    p(2) = p(2) * 0;
                    p(3) = p(3) * 1;
            end
        end
        probabilities(:,r,c) = p / sum(p);
    end
end

% Plot the results

figuresize = [0 0 1.1 0.7];

for c=1:nConditions
    logicmodelfigures(c) = figure();
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figuresize);
    
    axis([1 10 0 1]);
    hold on;
    plot(1:10, probabilities(3,:,c), 'r.-');
    plot(1:10, probabilities(2,:,c), 'b+-');
    plot(1:10, probabilities(1,:,c), 'cx-');
    box off;
    set(gca, 'YTick', [0 0.5 1]);
    set(gca, 'YTickLabel', {});
    set(gca, 'XTick', 1:1:10);
    set(gca, 'XTickLabel', {});
    set(gca,'fontsize',8);
    
    hold off;
end

%figure(logicmodelfigures(1));
%print -depsc logicmodel1;
%figure(logicmodelfigures(2));
%print -depsc logicmodel2;
%figure(logicmodelfigures(3));
%print -depsc logicmodel3;


%figure;
%for c=1:nConditions
%    subplot(1,3,c);
%    hold on;
%    xlabel('Observation');
%    ylabel('Card probabilities');
%    axis([1 10 0 1]);
%    
%    plot(1:10, probabilities(3,:,c), 'r.-');
%    plot(1:10, probabilities(2,:,c), 'b.-');
%    plot(1:10, probabilities(1,:,c), 'c.-');
%end

% Save the model predictions
logicpreds = probabilities;
save logicmodelpredictions logicpreds;

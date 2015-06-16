clear all;
close all;

TRIANGLE = 1;         
SQUARE = 2;           
RANDOMMACHINE = 1;
COPYMACHINE = 2;
machineRewards = [1 2 5 1000];

nStructureLearningJudgments = 1;

datapath = './rawdata/';

% Explanation file
explainfile = fopen('explain.txt', 'w');

% Payout change file
payoutchangeexplainfile = fopen('payoutchange.txt', 'w');

w = what(datapath);
files = w.mat;

structureLearningRatings = zeros(length(files),3);
makesSenseJudgments = zeros(length(files),3,2);

for f=1:length(files)
    load(strcat(datapath,files{f}));
    
    
    % First analyze the structure learning results
    % Condition 1: SQUARE SQUARE = $10
    %	Prediction: Random (low score)
    % Condition 2: TRIANGLE SQUARE = $10
    %	Prediction: Copy (high score)
    % Condition 3: No reward information
    %	Prediction: Middle score
    
    % First collect the responses corresponding to the structure learning phase
    structureLearningRawData = {data.responses{3}{1} data.responses{5}{1} data.responses{7}{1}};

	questionOrder = data.structureLearningPhasePrimeQuestionOrder;
	

    for i=1:3
    	c = data.structureLearningPhaseConditionOrder(i);
    	structureLearningRatings(f,c) = ...
    		structureLearningRawData{i}{1}(3);
    	makesSenseJudgments(f,c,questionOrder(1)) = structureLearningRawData{i}{1}(1);
    	makesSenseJudgments(f,c,questionOrder(2)) = structureLearningRawData{i}{1}(2);
    	if (data.structureLearningPhaseResponseScaleLabelOrder(1) == 2)
    		switch structureLearningRatings(f,c)
    			case 1
    				structureLearningRatings(f,c) = 7;
    			case 2
    				structureLearningRatings(f,c) = 6;
    			case 3
    				structureLearningRatings(f,c) = 5;
    			case 4
    				structureLearningRatings(f,c) = 4;
    			case 5
    				structureLearningRatings(f,c) = 3;
    			case 6
    				structureLearningRatings(f,c) = 2;
    			case 7
    				structureLearningRatings(f,c) = 1;
    		end
    	end
    	structureLearningExplanations{f}{c} = ...
    		structureLearningRawData{i}{2};
    end
    
    fprintf(explainfile, '=== Subject %d: Condition order: %s ===\n', data.subjectNum, mat2str(data.structureLearningPhaseConditionOrder));
    fprintf(explainfile, 'Ratings: %s \n', mat2str(structureLearningRatings(f,:)));
    for c=1:3
    	fprintf(explainfile, 'Makes sense? %s \n', mat2str(reshape(makesSenseJudgments(f,c,:),2,1)));
    end

    for c=1:3
    	e = char(structureLearningExplanations{f}{c});
    	eLines = size(e,1);
    	fprintf(explainfile, 'Condition %d: ', c);
    	for l=1:eLines
        	fprintf(explainfile, '%s', e(l,:));
        end
        fprintf(explainfile, '\n\n');
    end
    
    
    
    % Collect the judgment for the payout change phase
    payoutChangeRawData = {data.responses{11}{1} data.responses{15}{1}};
    nPayoutChangeCorrectResponses = 0;
    
    fprintf(payoutchangeexplainfile, '=== Subject %d: Condition order: %s ===\n', data.subjectNum, mat2str(data.payoutChangePhaseConditionOrder));
    for c=1:2
    	switch data.payoutChangePhaseConditionOrder(c)
    		case RANDOMMACHINE
    			fprintf(payoutchangeexplainfile, 'Random Machine\n');
    		case COPYMACHINE
    			fprintf(payoutchangeexplainfile, 'Copy Machine\n');
    		otherwise
    			% error
    	end
    	
    	payouts1 = data.payoutChangePhaseRewardOrder1(c,:);
    	payouts2 = data.payoutChangePhaseRewardOrder2(c,:);
    	
    	fprintf(payoutchangeexplainfile, ...
    		'                    SQR SQR   SQR TRI   TRI SQR   TRI TRI\n');
    	fprintf(payoutchangeexplainfile, ...
    		'Training payouts    %d        %d        %d        %d\n', ...
    		machineRewards(payouts1(data.keyOrder == 1)), ...
    		machineRewards(payouts1(data.keyOrder == 2)), ...
    		machineRewards(payouts1(data.keyOrder == 3)), ...
    		machineRewards(payouts1(data.keyOrder == 4)));
    	fprintf(payoutchangeexplainfile, ...
    		'Final payouts       %d        %d        %d        %d\n', ...
    		machineRewards(payouts2(data.keyOrder == 1)), ...
    		machineRewards(payouts2(data.keyOrder == 2)), ...
    		machineRewards(payouts2(data.keyOrder == 3)), ...
    		machineRewards(payouts2(data.keyOrder == 4)));
    		
    	for t=1:2
			fprintf(payoutchangeexplainfile, 'Saw: ');
			switch data.payoutChangePhaseConditionOrder(c)
				case RANDOMMACHINE
					if (data.payoutChangePhaseJudgmentStimuli{c}{t}{1} == TRIANGLE)
						fprintf(payoutchangeexplainfile, 'TRI\n');
					else
						fprintf(payoutchangeexplainfile, 'SQR\n');
					end
				case COPYMACHINE
					fprintf(payoutchangeexplainfile, '--\n');
				otherwise
					% error
			end
			
			
			if (payoutChangeRawData{c}{1}(t) == TRIANGLE)
				fprintf(payoutchangeexplainfile, 'Predicted: TRI\n');
			else
				fprintf(payoutchangeexplainfile, 'Predicted: SQR\n');
			end
			fprintf(payoutchangeexplainfile, '%s\n', payoutChangeRawData{c}{2}{t});
			
		end
		
		fprintf(payoutchangeexplainfile, '\n');
		
    end
    
    fprintf(payoutchangeexplainfile, '\n\n');
end







% Now plot results
structureLearningRatings_model = [1 7 5];
makesSenseJudgments_model = [4 1; 1 4; 2.5 4];

close all;


defaultfigure1 = [0 0 1.65 1.125];
defaultfigure2 = [0 0 1.1 1.125];

% Decision net model structure learning predictions
figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure1);
bar(structureLearningRatings_model,'k');
axis([0.5 3.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2dnetstructure;

% Decision net model makes sense predictions
figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar(makesSenseJudgments_model(1,:),'k');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2dnetmakessense_random;

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar(makesSenseJudgments_model(2,:),'k');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2dnetmakessense_copy;

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar(makesSenseJudgments_model(3,:),'k');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2dnetmakessense_uncertain;


% Bayes net model structure learning predictions
figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure1);
bar([5 5 5],'k');
axis([0.5 3.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2bnetstructure;

% Bayes net model makes sense predictions
figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar([2.5 4],'k');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2bnetmakessense_random;

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar([2.5 4],'k');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2bnetmakessense_copy;

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar([2.5 4],'k');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2bnetmakessense_uncertain;


% Human
n = length(files);
meanStructureLearningRatings = mean(structureLearningRatings);
stdStructureLearningRatings = std(structureLearningRatings);
sesStructureLearningRatings = std(structureLearningRatings) ./ sqrt(n);

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure1);
bar(meanStructureLearningRatings, 'k');
hold on;
errorbar(1:3, meanStructureLearningRatings, sesStructureLearningRatings, 'k.');
axis([0.5 3.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2humanstructure;

meanMakesSenseRatings1 = reshape(mean(makesSenseJudgments(:,1,:)),1,2);
stdMakesSenseRatings1 = reshape(std(makesSenseJudgments(:,1,:)),1,2);
sesMakesSenseRatings1 = reshape(std(makesSenseJudgments(:,1,:)),1,2) ./ sqrt(n);

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar(meanMakesSenseRatings1,'k');
hold on;
errorbar(1:2, meanMakesSenseRatings1, sesMakesSenseRatings1, 'k.');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2humanmakessense_random;

meanMakesSenseRatings2 = reshape(mean(makesSenseJudgments(:,2,:)),1,2);
stdMakesSenseRatings2 = reshape(std(makesSenseJudgments(:,2,:)),1,2);
sesMakesSenseRatings2 = reshape(std(makesSenseJudgments(:,2,:)),1,2) ./ sqrt(n);

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar(meanMakesSenseRatings2,'k');
hold on;
errorbar(1:2, meanMakesSenseRatings2, sesMakesSenseRatings2, 'k.');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2humanmakessense_copy;

meanMakesSenseRatings3 = reshape(mean(makesSenseJudgments(:,3,:)),1,2);
stdMakesSenseRatings3 = reshape(std(makesSenseJudgments(:,3,:)),1,2);
sesMakesSenseRatings3 = reshape(std(makesSenseJudgments(:,3,:)),1,2) ./ sqrt(n);

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
bar(meanMakesSenseRatings3,'k');
hold on;
errorbar(1:2, meanMakesSenseRatings3, sesMakesSenseRatings3, 'k.');
axis([0.5 2.5 0 8]);
box off;
set(gca, 'YTick', [1 7]);
set(gca, 'YTickLabel', {});
set(gca, 'XTickLabel', {});
%print -depsc expt2humanmakessense_uncertain;

fprintf('=== Expt 1 ===\n');

% Determine how many people gave correct answers when payout changed
nCorrectPayoutChange = 4*n - 6; % six incorrect responses
fprintf('Proportion of correct responses to payout change questions: %.3f\n', nCorrectPayoutChange/(4*n));

fprintf('=== Expt 2 ===\n');

% Do statistical tests
fprintf('=== Structure learning test results ===\n');
[h p ci stats] = ttest(structureLearningRatings(:,1), structureLearningRatings(:,3));
fprintf('Random (M=%.3f, SD=%.3f) vs. uncertain (M=%.3f, SD=%.3f): t=%.3f, df=%d, p = %f\n', ...
    meanStructureLearningRatings(1), stdStructureLearningRatings(1), ...
    meanStructureLearningRatings(3), stdStructureLearningRatings(3), ...
    stats.tstat, stats.df, p);
[h p ci stats] = ttest(structureLearningRatings(:,2), structureLearningRatings(:,3));
fprintf('Copy (M=%.3f, SD=%.3f) vs. uncertain (M=%.3f, SD=%.3f): t=%.3f, df=%d, p = %f\n', ...
    meanStructureLearningRatings(2), stdStructureLearningRatings(2), ...
    meanStructureLearningRatings(3), meanStructureLearningRatings(3), ...
    stats.tstat, stats.df, p);

fprintf('=== Makes sense test results ===\n');
[h p ci stats] = ttest(makesSenseJudgments(:,1,1), makesSenseJudgments(:,1,2));
fprintf('Random (M=%.3f, SD=%.3f vs. M=%.3f, SD=%.3f): t=%.3f, df=%d, p = %f\n', ...
    meanMakesSenseRatings1(1), stdMakesSenseRatings1(1), ...
    meanMakesSenseRatings1(2), stdMakesSenseRatings1(2), ...
    stats.tstat, stats.df, p);
[h p ci stats] = ttest(makesSenseJudgments(:,2,1), makesSenseJudgments(:,2,2));
fprintf('Copy (M=%.3f, SD=%.3f vs. M=%.3f, SD=%.3f): t=%.3f, df=%d, p = %f\n', ...
    meanMakesSenseRatings2(1), stdMakesSenseRatings2(1), ...
    meanMakesSenseRatings2(2), stdMakesSenseRatings2(2), ...
    stats.tstat, stats.df, p);
[h p ci stats] = ttest(makesSenseJudgments(:,3,1), makesSenseJudgments(:,3,2));
fprintf('Uncertain (M=%.3f, SD=%.3f vs. M=%.3f, SD=%.3f): t=%.3f, df=%d, p = %f\n', ...
    meanMakesSenseRatings3(1), stdMakesSenseRatings3(1), ...
    meanMakesSenseRatings3(2), stdMakesSenseRatings3(2), ...
    stats.tstat, stats.df, p);


% Determine how many subjects fit the pattern
nFitting = 0;
for i=1:size(structureLearningRatings,1);
	r = structureLearningRatings(i,:);
	if (r(1) <= r(3) && r(3) <= r(2) && not(r(1) == r(3) && r(3) == r(2)))
		nFitting = nFitting + 1;
	end
end
fprintf('Proportion of subjects fitting pattern: %.3f\n', nFitting/n);
	


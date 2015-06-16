clear all;
close all;
datapath = './';

w = what(datapath);
files = w.mat;

plotaverages = 1;
plotnormalized = 1;
firstsubject = 10;
lastsubject = 29;
nsubjects = 1+(lastsubject-firstsubject);


% Matrix of subject numbers
subnums = zeros(length(files),1);
% Matrix of exp versions
expVersions = zeros(length(files),1);

% Matrix of judgments
for i=1:length(files)
    for j=1:3
        judgments{i}{j} = zeros(10,3);
    end
end


% Matrix of explanations
for i=1:length(files)
    explanations{i} = cell(1,10);
end

% Explanation file
explainfile = fopen('explain.txt', 'w');

for f=1:length(files)
    load(strcat(datapath,files{f}));
    
    % Skip if not in subject range
    if (data.subjectNum < firstsubject || data.subjectNum > lastsubject)
        continue;
    end
    
    % Get the version number
    expVersions(f) = data.expVersion;
    
    % Get the condition order
    if (data.expVersion == 1)
        condOrder = data.infoConditionOrder;
    else
        condOrder = data.utilConditionOrder;
    end
    
    % Parse out the judgments and explanations
    responses{1} = data.responses{3}{1};
    responses{2} = data.responses{5}{1};
    responses{3} = data.responses{7}{1};
    for c=1:3
        % Rescale judgments so they go from 0-6
        judgments{f}{condOrder(c)} = responses{c}{1} - 1;
        explanations{f}{condOrder(c)} = responses{c}{2};
        
        % Normalize the judgments
        judgments_normalized{f}{condOrder(c)} = judgments{f}{condOrder(c)};
        for r=1:10
            % Get the judgments for current record
            currJudgments = judgments_normalized{f}{condOrder(c)}(r,:);
            judgments_normalized{f}{condOrder(c)}(r,:) = ...
                currJudgments / sum(currJudgments);
        end
    end
    
    % Write out the explanations
    versionName = '';
    if (data.expVersion == 1)
        versionName = 'Information';
    else
        versionName = 'Utility';
    end
    fprintf(explainfile, '=== Subject %d: %s, Condition order: %s ===\n', data.subjectNum,versionName,mat2str(condOrder));

    for c=1:3
        fprintf(explainfile, '-- Condition %d --\n',c);
        expl = explanations{f}{c};
        for t=1:10
            fprintf(explainfile, 'Round %d: ',t);
            for l=1:size(expl,1)
                fprintf(explainfile, '%s\n', expl{t}(l,:));
            end
        end
    end
    fprintf(explainfile, '\n\n');
    
end


% Compute the averages
nInfo = 0;
nUtil = 0;
for f=1:length(files)
    if (expVersions(f) == 1)
        nInfo = nInfo + 1;
    else
        nUtil = nUtil + 1;
    end
    for c=1:3
        for j=1:3
            if (expVersions(f) == 1)
                allInfoJudgments{c}{j}(nInfo,:) = judgments{f}{c}(:,j)';
                allInfoJudgments_normalized{c}{j}(nInfo,:) = judgments_normalized{f}{c}(:,j)';
            elseif (expVersions(f) == 2);
                allUtilJudgments{c}{j}(nUtil,:) = judgments{f}{c}(:,j)';
                allUtilJudgments_normalized{c}{j}(nUtil,:) = judgments_normalized{f}{c}(:,j)';
            end
        end
    end
end

% Number of bootstrap samples
nboot = 10000;

if (plotaverages == 1)


    figuresize = [0 0 1.1 0.7];
    
    for c=1:3
        humaninfofigures(c) = figure();
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'PaperPosition', figuresize);
        axis([1 10 0 1]);
        hold on;
        
        humanutilfigures(c) = figure();
        set(gcf, 'PaperUnits', 'inches');
        set(gcf, 'PaperPosition', figuresize);
        axis([1 10 0 1]);
        hold on;
    end

    % Make the average plots
    for c=1:3
        %figure(averageresults)
        
        
        
        if (nInfo > 0)
            figure(humaninfofigures(c));

            for j=1:3
                if (nInfo > 1)
                    avgInfoJudgments{j} = mean(allInfoJudgments{c}{j});
                    infoJudgmentsStds{j} = std(allInfoJudgments{c}{j});
                    avgInfoJudgments_normalized{j} = mean(allInfoJudgments_normalized{c}{j});
                    infoJudgmentsStds_normalized{j} = std(allInfoJudgments_normalized{c}{j});
                    
                    for r=1:10
                        % Compute the bootstrap SE estimates
                        judgmentsCopy = allInfoJudgments{c};
                        infoBootSEs(r,:) = bootstrap_judgments(judgmentsCopy, r, nInfo, nboot);
                    end
                else
                    avgInfoJudgments{j} = allInfoJudgments{c}{j};
                    avgInfoJudgments_normalized{j} = allInfoJudgments_normalized{c}{j};
                    infoJudgmentsStds{j} = zeros(1,10);
                end
            end
            
            % Make plots for Experiment 3
            if (plotnormalized == 1)
                errorbar(1:10, avgInfoJudgments_normalized{1}, infoBootSEs(:,1), 'r.-');
                errorbar(1:10, avgInfoJudgments_normalized{2}, infoBootSEs(:,2), 'b+-');
                errorbar(1:10, avgInfoJudgments_normalized{3}, infoBootSEs(:,3), 'cx-');
            else
                errorbar(1:10, avgInfoJudgments{1}, infoJudgmentsStds{1} / sqrt(nInfo), 'r.-');
                errorbar(1:10, avgInfoJudgments{2}, infoJudgmentsStds{2} / sqrt(nInfo), 'b+-');
                errorbar(1:10, avgInfoJudgments{3}, infoJudgmentsStds{3} / sqrt(nInfo), 'cx-');
            end

            box off;
            set(gca, 'YTick', [0 0.5 1]);
            set(gca, 'YTickLabel', {});
            set(gca, 'XTick', 1:1:10);
            set(gca, 'XTickLabel', {});
            set(gca,'fontsize',8);
        end
        
        if (nUtil > 0)
            
            figure(humanutilfigures(c));

            for j=1:3
                if (nUtil > 1)
                    avgUtilJudgments{j} = mean(allUtilJudgments{c}{j});
                    utilJudgmentsStds{j} = std(allUtilJudgments{c}{j});
                    avgUtilJudgments_normalized{j} = mean(allUtilJudgments_normalized{c}{j});
                    utilJudgmentsStds_normalized{j} = std(allUtilJudgments_normalized{c}{j});
                    
                    for r=1:10
                        % Compute the bootstrap SE estimates
                        judgmentsCopy = allUtilJudgments{c};
                        utilBootSEs(r,:) = bootstrap_judgments(judgmentsCopy, r, nInfo, nboot);
                    end
                else
                    avgUtilJudgments{j} = allUtilJudgments{c}{j};
                    avgUtilJudgments_normalized{j} = allUtilJudgments_normalized{c}{j};
                    utilJudgmentsStds{j} = zeros(1,10);
                end
            end
            % Make plots for Experiment 4
            if (plotnormalized == 1)
                errorbar(1:10, avgUtilJudgments_normalized{1}, utilBootSEs(:,1), 'r.-');
                errorbar(1:10, avgUtilJudgments_normalized{2}, utilBootSEs(:,2), 'b+-');
                errorbar(1:10, avgUtilJudgments_normalized{3}, utilBootSEs(:,3), 'cx-');
            else
                errorbar(1:10, avgUtilJudgments{1}, utilJudgmentsStds{1} / sqrt(nUtil), 'r.-');
                errorbar(1:10, avgUtilJudgments{2}, utilJudgmentsStds{2} / sqrt(nUtil), 'b+-');
                errorbar(1:10, avgUtilJudgments{3}, utilJudgmentsStds{3} / sqrt(nUtil), 'cx-');
            end
%            hold off;

            box off;
            set(gca, 'YTick', [0 0.5 1]);
            set(gca, 'YTickLabel', {});
            set(gca, 'XTick', 1:1:10);
            set(gca, 'XTickLabel', {});
            set(gca,'fontsize',8);

        end
    end
    
%    figure(humaninfofigures(1));
%    print -depsc expt1human1;
%    figure(humaninfofigures(2));
%    print -depsc expt1human2;
%    figure(humaninfofigures(3));
%    print -depsc expt1human3;
%    
%    figure(humanutilfigures(1));
%    print -depsc expt2human1;
%    figure(humanutilfigures(2));
%    print -depsc expt2human2;
%    figure(humanutilfigures(3));
%    print -depsc expt2human3;

    
    % Compute MSEs and correlations
    MAXMODEL = 1;
    MATCHMODEL = 2;
    LOGICALMODEL = 3;
    BNETMODEL = 4;
    
    rInfo = zeros(4,3);
    rUtil = zeros(4,3);
    
    load './predictions/maxmodelpredictions';
    load './predictions/logicmodelpredictions';
    load './predictions/matchmodelpredictions';
    load './predictions/bnetmodelpredictions';
    
    for c=1:3
    
        infojudgments{c} = [mean(allInfoJudgments_normalized{c}{1})';
                            mean(allInfoJudgments_normalized{c}{2})';
                            mean(allInfoJudgments_normalized{c}{3})'];
        maxinfopreds{c} = [maxpreds(3,:,c)';
                           maxpreds(2,:,c)';
                           maxpreds(1,:,c)'];
        maxinfocorr{c} = corrcoef(infojudgments{c}, maxinfopreds{c});
        rInfo(MAXMODEL,c) = maxinfocorr{c}(1,2);
        
        
        matchinfopreds{c} = [matchpreds{1}(3,:,c)';
                             matchpreds{1}(2,:,c)';
                             matchpreds{1}(1,:,c)'];
        matchinfocorr{c} = corrcoef(infojudgments{c}, matchinfopreds{c});
        rInfo(MATCHMODEL,c) = matchinfocorr{c}(1,2);
        
        
        logicinfopreds{c} = [logicpreds(3,:,c)';
                             logicpreds(2,:,c)';
                             logicpreds(1,:,c)'];
        logicinfocorr{c} = corrcoef(infojudgments{c}, logicinfopreds{c});
        rInfo(LOGICALMODEL,c) = logicinfocorr{c}(1,2);
        
        bnetinfopreds{c} = [bnetpreds{1}(3,:,c)';
                             bnetpreds{1}(2,:,c)';
                             bnetpreds{1}(1,:,c)'];
        bnetinfocorr{c} = corrcoef(infojudgments{c}, bnetinfopreds{c});
        rInfo(BNETMODEL,c) = bnetinfocorr{c}(1,2);
        
        
        
        utiljudgments{c} = [mean(allUtilJudgments_normalized{c}{1})';
                            mean(allUtilJudgments_normalized{c}{2})';
                            mean(allUtilJudgments_normalized{c}{3})'];
        maxutilpreds{c} = [maxpreds(3,:,c)';
                           maxpreds(2,:,c)';
                           maxpreds(1,:,c)'];
        maxutilcorr{c} = corrcoef(utiljudgments{c}, maxutilpreds{c});
        rUtil(MAXMODEL,c) = maxutilcorr{c}(1,2);
        
        
        matchutilpreds{c} = [matchpreds{2}(3,:,c)';
                             matchpreds{2}(2,:,c)';
                             matchpreds{2}(1,:,c)'];
        matchutilcorr{c} = corrcoef(utiljudgments{c}, matchutilpreds{c});
        rUtil(MATCHMODEL,c) = matchutilcorr{c}(1,2);
        
        
        logicutilpreds{c} = [logicpreds(3,:,c)';
                             logicpreds(2,:,c)';
                             logicpreds(1,:,c)'];
        logicutilcorr{c} = corrcoef(utiljudgments{c}, logicutilpreds{c});
        rUtil(LOGICALMODEL,c) = logicutilcorr{c}(1,2);
        
        bnetutilpreds{c} = [bnetpreds{2}(3,:,c)';
                             bnetpreds{2}(2,:,c)';
                             bnetpreds{2}(1,:,c)'];
        bnetutilcorr{c} = corrcoef(utiljudgments{c}, bnetutilpreds{c});
        rUtil(BNETMODEL,c) = bnetutilcorr{c}(1,2);

    end
    
    % Compute overall correlations
    allinfojudgments = [infojudgments{1}; infojudgments{2}; infojudgments{3}];
    allutiljudgments = [utiljudgments{1}; utiljudgments{2}; utiljudgments{3}];
    allmaxinfopreds = [maxinfopreds{1}; maxinfopreds{2}; maxinfopreds{3}];
    allmaxutilpreds = [maxutilpreds{1}; maxutilpreds{2}; maxutilpreds{3}];
    allmatchinfopreds = [matchinfopreds{1}; matchinfopreds{2}; matchinfopreds{3}];
    allmatchutilpreds = [matchutilpreds{1}; matchutilpreds{2}; matchutilpreds{3}];
    alllogicinfopreds = [logicinfopreds{1}; logicinfopreds{2}; logicinfopreds{3}];
    alllogicutilpreds = [logicutilpreds{1}; logicutilpreds{2}; logicutilpreds{3}];
    allbnetinfopreds = [bnetinfopreds{1}; bnetinfopreds{2}; bnetinfopreds{3}];
    allbnetutilpreds = [bnetutilpreds{1}; bnetutilpreds{2}; bnetutilpreds{3}];
    
    allmaxinfocorr = corrcoef(allinfojudgments, allmaxinfopreds);
    allmaxutilcorr = corrcoef(allutiljudgments, allmaxutilpreds);
    allmatchinfocorr = corrcoef(allinfojudgments, allmatchinfopreds);
    allmatchutilcorr = corrcoef(allutiljudgments, allmatchutilpreds);
    alllogicinfocorr = corrcoef(allinfojudgments, alllogicinfopreds);
    alllogicutilcorr = corrcoef(allutiljudgments, alllogicutilpreds);
    allbnetinfocorr = corrcoef(allinfojudgments, allbnetinfopreds);
    allbnetutilcorr = corrcoef(allutiljudgments, allbnetutilpreds);
    
    rInfoOverall(MAXMODEL) = allmaxinfocorr(1,2);
    rUtilOverall(MAXMODEL) = allmaxutilcorr(1,2);
    rInfoOverall(MATCHMODEL) = allmatchinfocorr(1,2);
    rUtilOverall(MATCHMODEL) = allmatchutilcorr(1,2);
    rInfoOverall(LOGICALMODEL) = alllogicinfocorr(1,2);
    rUtilOverall(LOGICALMODEL) = alllogicutilcorr(1,2);
    rInfoOverall(BNETMODEL) = allbnetinfocorr(1,2);
    rUtilOverall(BNETMODEL) = allbnetutilcorr(1,2);
    
    
    % Find best fitting max model
    % Cycle through all possible values of parameter e
    evector = 0:.001:.04;
    load './predictions/maxmodelpredictions2';
    for i=1:length(evector)
        % compute correlation for info judgments
        allmaxpreds2{i} = [maxpreds(3,:,1,i)';
                       maxpreds(2,:,1,i)';
                       maxpreds(1,:,1,i)';
                       maxpreds(3,:,2,i)';
                       maxpreds(2,:,2,i)';
                       maxpreds(1,:,2,i)';
                       maxpreds(3,:,3,i)';
                       maxpreds(2,:,3,i)';
                       maxpreds(1,:,3,i)'];
        allmaxinfocorr2{i} = corrcoef(allinfojudgments, allmaxpreds2{i});
        allmaxutilcorr2{i} = corrcoef(allutiljudgments, allmaxpreds2{i}); 
        rInfoMaxmodel(i) = allmaxinfocorr2{i}(1,2);
        rUtilMaxmodel(i) = allmaxutilcorr2{i}(1,2);
    
        fprintf('e = %f, Expt 3 r = %f, Expt 4 r = %f\n', evector(i), rInfoMaxmodel(i), rUtilMaxmodel(i));
    end
    
end

        


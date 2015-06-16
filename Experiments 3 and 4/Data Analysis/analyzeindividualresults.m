clear all;
close all;
datapath = './';

w = what(datapath);
files = w.mat;

FITTEDMODEL = 1;
MAXMODEL = 2;
MATCHMODEL = 3;
LOGICALMODEL = 5;
BNETMODEL = 4;

subjectTypesInfo = zeros(1,5);
subjectTypesUtil = zeros(1,5);
nInfo = 0;
nUtil = 0;

mse = zeros(3,3,length(files));

for f=1:length(files)
    load(strcat(datapath,files{f}));
    
    % Get the version number
    expVersions(f) = data.expVersion;
    
    % Get the condition order
    if (data.expVersion == 1)
        condOrder = data.infoConditionOrder;
        versionName = 'Info';
    else
        condOrder = data.utilConditionOrder;
        versionName = 'Util';
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
    
    
    
    % Load model predictions
    load './predictions/fittedmodelpredictions';
    load './predictions/maxmodelpredictions';
    load './predictions/logicmodelpredictions';
    load './predictions/matchmodelpredictions';
    load './predictions/bnetmodelpredictions';
    

    % Compute correlation for each of the models
    alljudgments = [judgments_normalized{f}{1}(:,1);
                    judgments_normalized{f}{1}(:,2);
                    judgments_normalized{f}{1}(:,3);
                    judgments_normalized{f}{2}(:,1);
                    judgments_normalized{f}{2}(:,2);
                    judgments_normalized{f}{2}(:,3);
                    judgments_normalized{f}{3}(:,1);
                    judgments_normalized{f}{3}(:,2);
                    judgments_normalized{f}{3}(:,3)];                    
     
    allfittedinfopreds = [fittedpreds{1}(3,:,1)';
                       fittedpreds{1}(2,:,1)';
                       fittedpreds{1}(1,:,1)';
                       fittedpreds{1}(3,:,2)';
                       fittedpreds{1}(2,:,2)';
                       fittedpreds{1}(1,:,2)';
                       fittedpreds{1}(3,:,3)';
                       fittedpreds{1}(2,:,3)';
                       fittedpreds{1}(1,:,3)'];
    allfittedutilpreds = [fittedpreds{2}(3,:,1)';
                       fittedpreds{2}(2,:,1)';
                       fittedpreds{2}(1,:,1)';
                       fittedpreds{2}(3,:,2)';
                       fittedpreds{2}(2,:,2)';
                       fittedpreds{2}(1,:,2)';
                       fittedpreds{2}(3,:,3)';
                       fittedpreds{2}(2,:,3)';
                       fittedpreds{2}(1,:,3)'];
                    
    allmaxinfopreds = [maxpreds(3,:,1)';
                       maxpreds(2,:,1)';
                       maxpreds(1,:,1)';
                       maxpreds(3,:,2)';
                       maxpreds(2,:,2)';
                       maxpreds(1,:,2)';
                       maxpreds(3,:,3)';
                       maxpreds(2,:,3)';
                       maxpreds(1,:,3)'];
    allmaxutilpreds = allmaxinfopreds;
    
    allmatchinfopreds = [matchpreds{1}(3,:,1)';
                       matchpreds{1}(2,:,1)';
                       matchpreds{1}(1,:,1)';
                       matchpreds{1}(3,:,2)';
                       matchpreds{1}(2,:,2)';
                       matchpreds{1}(1,:,2)';
                       matchpreds{1}(3,:,3)';
                       matchpreds{1}(2,:,3)';
                       matchpreds{1}(1,:,3)'];
    allmatchutilpreds = [matchpreds{2}(3,:,1)';
                       matchpreds{2}(2,:,1)';
                       matchpreds{2}(1,:,1)';
                       matchpreds{2}(3,:,2)';
                       matchpreds{2}(2,:,2)';
                       matchpreds{2}(1,:,2)';
                       matchpreds{2}(3,:,3)';
                       matchpreds{2}(2,:,3)';
                       matchpreds{2}(1,:,3)'];
                       
    alllogicinfopreds = [logicpreds(3,:,1)';
                       logicpreds(2,:,1)';
                       logicpreds(1,:,1)';
                       logicpreds(3,:,2)';
                       logicpreds(2,:,2)';
                       logicpreds(1,:,2)';
                       logicpreds(3,:,3)';
                       logicpreds(2,:,3)';
                       logicpreds(1,:,3)'];
    alllogicutilpreds = alllogicinfopreds;
    
    allbnetinfopreds = [bnetpreds{1}(3,:,1)';
                       bnetpreds{1}(2,:,1)';
                       bnetpreds{1}(1,:,1)';
                       bnetpreds{1}(3,:,2)';
                       bnetpreds{1}(2,:,2)';
                       bnetpreds{1}(1,:,2)';
                       bnetpreds{1}(3,:,3)';
                       bnetpreds{1}(2,:,3)';
                       bnetpreds{1}(1,:,3)'];
    allbnetutilpreds = [bnetpreds{2}(3,:,1)';
                       bnetpreds{2}(2,:,1)';
                       bnetpreds{2}(1,:,1)';
                       bnetpreds{2}(3,:,2)';
                       bnetpreds{2}(2,:,2)';
                       bnetpreds{2}(1,:,2)';
                       bnetpreds{2}(3,:,3)';
                       bnetpreds{2}(2,:,3)';
                       bnetpreds{2}(1,:,3)'];
    
    allfittedinfocorr = corrcoef(alljudgments, allfittedinfopreds);
    allfittedutilcorr = corrcoef(alljudgments, allfittedutilpreds);
    allmaxinfocorr = corrcoef(alljudgments, allmaxinfopreds);
    allmaxutilcorr = corrcoef(alljudgments, allmaxutilpreds);
    allmatchinfocorr = corrcoef(alljudgments, allmatchinfopreds);
    allmatchutilcorr = corrcoef(alljudgments, allmatchutilpreds);
    alllogicinfocorr = corrcoef(alljudgments, alllogicinfopreds);
    alllogicutilcorr = corrcoef(alljudgments, alllogicutilpreds);
    allbnetinfocorr = corrcoef(alljudgments, allbnetinfopreds);
    allbnetutilcorr = corrcoef(alljudgments, allbnetutilpreds);
    
    rInfoOverall(FITTEDMODEL) = allfittedinfocorr(1,2);
    rUtilOverall(FITTEDMODEL) = allfittedutilcorr(1,2);
    rInfoOverall(MAXMODEL) = allmaxinfocorr(1,2);
    rUtilOverall(MAXMODEL) = allmaxutilcorr(1,2);
    rInfoOverall(MATCHMODEL) = allmatchinfocorr(1,2);
    rUtilOverall(MATCHMODEL) = allmatchutilcorr(1,2);
    rInfoOverall(LOGICALMODEL) = alllogicinfocorr(1,2);
    rUtilOverall(LOGICALMODEL) = alllogicutilcorr(1,2);
    rInfoOverall(BNETMODEL) = allbnetinfocorr(1,2);
    rUtilOverall(BNETMODEL) = allbnetutilcorr(1,2);
    
    % Categorize subject
    if (data.expVersion == 1)
        overallType = find(rInfoOverall == max(rInfoOverall));
        subjectTypesInfo(overallType) = subjectTypesInfo(overallType) + 1;
        
        nInfo = nInfo+1;
        subjectInfoCorrs(nInfo,:) = rInfoOverall;
    else
        overallType = find(rUtilOverall == max(rUtilOverall));
        subjectTypesUtil(overallType) = subjectTypesUtil(overallType) + 1;
        
        nUtil = nUtil+1;
        subjectUtilCorrs(nUtil,:) = rUtilOverall;
    end
    

end

defaultfigure1 = [0 0 1.125 1.65];
defaultfigure2 = [0 0 1.125 1.32];

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure1);
barh(fliplr(subjectTypesInfo),'k');
axis([0 12 0.5 5.5]);
set(gca, 'XTick', [0 10]);
set(gca, 'XTickLabel', {});
set(gca, 'YTickLabel', {});
box off;
%print -depsc expt3individuals;

figure();
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', defaultfigure2);
barh(fliplr(subjectTypesUtil(2:end)), 'k');
axis([0 12 0.5 4.5]);
set(gca, 'XTick', [0 10]);
set(gca, 'XTickLabel', {});
set(gca, 'YTickLabel', {});
box off;
%print -depsc expt4individuals;




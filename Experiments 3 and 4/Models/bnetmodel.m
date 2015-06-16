clear all;

% g = 1: B1 --> B3 <-- B2
% g = 2: B1     B3 <-- B2
% g = 3: B1     B3     B2


B1 = 1; B2 = 2; B3 = 3; U = 4;
dag{1} = zeros(4,4);
dag{2} = zeros(4,4);
dag{3} = zeros(4,4);

% Graph 1
dag{1}(B1,B3) = 1;
dag{1}(B2,B3) = 1;
dag{1}([B1 B2 B3], U) = 1;

% Graph 2
dag{2}(B2,B3) = 1;
dag{2}([B1 B2 B3], U) = 1;

% Graph 3
dag{3}([B1 B2 B3], U) = 1;

ns = 3*ones(1,4);

% Generate the CPT for node U
cpt{U} = zeros(1,3^4);
i = 1;
for u=1:3
    for b3=1:3
        for b2=1:3
            for b1=1:3
                if (b3 ~= b1 && b3 ~= b2 && u == 3)
                    cpt{U}(i) = 1;
                elseif (b3 == b1 && b3 == b2 && u == 1)
                    cpt{U}(i) = 1;
                elseif ( ((b3 == b1 && b3 ~= b2) || (b3 ~= b1 && b3 == b2)) && u == 2 )
                    cpt{U}(i) = 1;
                else
                    cpt{U}(i) = 0;
                end
                i = i + 1;
            end
        end
    end
end
    
% Set the CPT for the U node
for i=1:3
    params{i} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1};
end
params{U} = {'prior_type', 'dirichlet', 'dirichlet_weight', 1, 'CPT', cpt{U}};

                
% Number of simulated data sets to generate           
nDataSets = 5000;

% Generate some data sets
% For the U node, we use the following code
% 1 = 0 points
% 2 = 10 points
% 3 = 20 points
for s=1:nDataSets
    for i=1:10
        % All different
        data{1}{s}(i,:) = [randperm(3) 3];
        % Some M1 observations
        data{2}{s}(i,:) = [randperm(3) 3];
        % Some M1 and M2 observations
        data{3}{s}(i,:) = [randperm(3) 3];
    end
    % Fill in the M1 and M2 trials
    data{2}{s}(4,3) = data{2}{s}(4,1); % M1
    data{2}{s}(4,4) = 2;
    data{2}{s}(6,3) = data{2}{s}(6,1); % M1
    data{2}{s}(6,4) = 2;
    data{2}{s}(7,3) = data{2}{s}(7,1); % M1
    data{2}{s}(7,4) = 2;
    data{2}{s}(8,3) = data{2}{s}(8,1); % M1
    data{2}{s}(8,4) = 2;
    
    data{3}{s}(4,3) = data{3}{s}(4,1); % M1
    data{3}{s}(4,4) = 2;
    data{3}{s}(6,3) = data{3}{s}(6,1); % M1
    data{3}{s}(6,4) = 2;
    data{3}{s}(7,3) = data{3}{s}(7,1); % M1
    data{3}{s}(7,4) = 2;
    data{3}{s}(8,3) = data{3}{s}(8,2); % M2
    data{3}{s}(8,4) = 2;
end

for s=1:nDataSets
    if (mod(s,10) == 0)
        fprintf('Scoring set %d\n',s);
    end

    for i=1:10
        % Get the scores
        for j=1:3 % Loop over data sets
            logscores{j} = score_dags(data{j}{s}(1:i,:)', ns, dag, 'params', params);
            scores{j}(:,i) = exp(logscores{j}) ./ sum(exp(logscores{j}));
        end 
    end
    for j=1:3 % Loop over data sets
        for k=1:3 % Loop over dags
            allscores{j}{k}(s,:) = scores{j}(k,:);
        end
    end
end

% Compute means
for j=1:3 % Loop over data sets
    for k=1:3 % Loop over dags
        meanscores{j}{k} = mean(allscores{j}{k});
        stds{j}{k} = std(allscores{j}{k});
        ses{j}{k} = stds{j}{k} / sqrt(nDataSets);
    end
end


% Plot results
close all;

figuresize = [0 0 1.1 0.7];
for i=1:3
    expt1bnetmodelfigures(i) = figure();
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figuresize);
    
    axis([1 10 0 1]);
    hold on;
    
    plot(1:10, meanscores{i}{3}, 'r.-');
    plot(1:10, meanscores{i}{2}, 'b+-');
    plot(1:10, meanscores{i}{1}, 'cx-');
    box off;
    set(gca, 'YTick', [0 0.5 1]);
    set(gca, 'YTickLabel', {});
    set(gca, 'XTick', 1:1:10);
    set(gca, 'XTickLabel', {});
    set(gca,'fontsize',8);
    
    hold off;
        
end

for i=1:3
    expt2bnetmodelfigures(i) = figure();
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figuresize);
    
    axis([1 10 0 1]);
    hold on;
    
    plot(1:10, zeros(1,10)+1/3, 'r.-');
    plot(1:10, zeros(1,10)+1/3, 'b+-');
    plot(1:10, zeros(1,10)+1/3, 'cx-');
    box off;
    set(gca, 'YTick', [0 0.5 1]);
    set(gca, 'YTickLabel', {});
    set(gca, 'XTick', 1:1:10);
    set(gca, 'XTickLabel', {});
    set(gca,'fontsize',8);
    
    hold off;
end

%figure(expt1bnetmodelfigures(1));
%print -depsc expt1bnetmodel1;
%figure(expt1bnetmodelfigures(2));
%print -depsc expt1bnetmodel2;
%figure(expt1bnetmodelfigures(3));
%print -depsc expt1bnetmodel3;
%
%figure(expt2bnetmodelfigures(1));
%print -depsc expt2bnetmodel1;
%figure(expt2bnetmodelfigures(2));
%print -depsc expt2bnetmodel2;
%figure(expt2bnetmodelfigures(3));
%print -depsc expt2bnetmodel3;

probabilitiesInfo = zeros(3,10,3);
probabilitiesUtil = zeros(3,10,3);
for c=1:3
    probabilitiesInfo(1,:,c) = meanscores{c}{1};
    probabilitiesInfo(2,:,c) = meanscores{c}{2};
    probabilitiesInfo(3,:,c) = meanscores{c}{3};
    
    probabilitiesUtil(1,:,c) = zeros(1,10)+1/3;
    probabilitiesUtil(2,:,c) = zeros(1,10)+1/3;
    probabilitiesUtil(3,:,c) = zeros(1,10)+1/3;
end

% Save the non-parameterized model results
bnetpreds = {probabilitiesInfo; probabilitiesUtil}; 
%save bnetmodelpredictions bnetpreds;

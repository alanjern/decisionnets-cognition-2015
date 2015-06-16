function bootSE = bootstrap_judgments(judgments, r, n, nboot)
% bootstrap for normalization procedure
% for first set of judgments in condition 1
%nboot = 50000;
%n = 22;
bootsamples = zeros(nboot,3);
for b=1:nboot
    if (mod(b,1000) == 0)
        fprintf('Sample %d\n',b);
    end
    for s=1:22
        % sample a set of values
        sindex = randint(1,1,[1 n]);
        % get those judgments
        judge(s,:) = [judgments{1}(sindex,r) judgments{2}(sindex,r) judgments{3}(sindex,r)];
        % normalize them
        judge(s,:) = judge(s,:) / sum(judge(s,:));
    end
    
    % compute means for this bootstrap sample and record
    bootsamples(b,:) = mean(judge);
    bootSE = std(bootsamples);
end

%------------------------------------------------------------------
% StructureLearningExperiment class
%
% This creates a complete run of the structure learning experiment
%------------------------------------------------------------------

classdef StructureLearningExperiment < handle
    properties (Constant)
        nPlayRounds = 1;       % Number of rounds subject plays in interactive part
        nPayoutChangePhaseStimuliPairs = 3;	% Number of training pairs of stimuli seen during first part
                                            % of the payout change phase
        nPayoutChangePhaseJudgmentStimuliPairs = 1; % Number of judgment pairs in second part
        
        nChipColorSets = 9;
        chipColors = {{[0 0 0.5], [0 0.5 0.5], [0 1 1], [0.5 0.5 0]}, ...
                      {[0.5 1 0.5], [1 0 1], [1 1 0], [0 0 1]}, ...
                      {[0 0.5 1], [0.5 0 0], [0.5 0.5 0.5], [0.5 1 1]}, ...
                      {[1 0.5 0], [1 1 0.5], [0 0.5 0], [0 1 0]}, ...
                      {[0.5 0. 0.5], [0.5 0.5 1], [1 0 0], [1 0.5 0.5]}, ...
                      {[0 1 0.5], [0.5 0 1], [0.5 1 0], [1 0 0.5]}, ...
                      {[0 0 0.5], [0 0.5 0.5], [0 1 1], [0.5 0.5 0]}, ...
                      {[0.5 1 0.5], [1 0 1], [1 1 0], [0 0 1]}, ...
                      {[0 0.5 1], [0.5 0 0], [0.5 0.5 0.5], [0.5 1 1]}, ...
                      {[1 0.5 0], [1 1 0.5], [0 0.5 0], [0 1 0]}, ...
                      {[0.5 0. 0.5], [0.5 0.5 1], [1 0 0], [1 0.5 0.5]}};
        
%         symbols = {{'O','i'}, {'=','R'}, {'T','%'}, ...
%                    {'#','S'}, {'_','Q'}, {'^',']'}, ...
%                    {'X','m'}, {'-','`'}, {'M','v'}};

		symbols = {{'16.png','12.png'}, {'18.png','15.png'}, {'5.png','1.png'}, ...
				   {'2.png','6.png'}, {'14.png','4.png'}, {'13.png','10.png'}, ...
				   {'11.png','9.png'}, {'8.png','17.png'}, {'7.png','3.png'}};


        %symbolFont = 'Wingdings';
                      
%        
%        chipColors = {{[0 0 0.5], [0 0 1], [0 0.5 0]}, ...
%                      {[0 0.5 0.5], [0 0.5 1], [0 1 0], [0 1 0.5]}, ...
%                      {[0 1 1], [0.5 0 0], [0.5 0 0.5], [0.5 0 1]}, ...
%                      {[0.5 0.5 0], [0.5 0.5 0.5], [0.5 0.5 1], [0.5 1 0]}, ...
%                      {[0.5 1 0.5], [0.5 1 1], [1 0 0], [1 0 0.5]}, ...
%                      {[1 0 1], [1 0.5 0], [1 0.5 0.5], [1 0.5 1]}, ...
%                      {[1 1 0], [1 1 0.5], };
        
        machineTypes = [MachineConstants.RANDOMMACHINE MachineConstants.COPYMACHINE];
%        machineOutcomes = {{MachineConstants.SQUARE MachineConstants.SQUARE MachineConstants.RED}, ...
%                        {MachineConstants.SQUARE MachineConstants.TRIANGLE MachineConstants.BLUE}, ...
%                        {MachineConstants.TRIANGLE MachineConstants.SQUARE MachineConstants.YELLOW}, ...
%                        {MachineConstants.TRIANGLE MachineConstants.TRIANGLE MachineConstants.MAGENTA}};
        structureLearningMachineRewards = {{'$1000','$?','$?','$?'}, ...  % Payout structures
                                          {'$?','$?','$1000','$?'}, ...
                                          {'$?','$?','$?','$?'}};
                                          
        interactiveMachineRewardsRandom = {{'$1000', '$2', '$5', '$1'}, ...
                        		      		{'$1', '$2', '$1000', '$5'}};
        interactiveRewardMatricesRandom = {[1 5; 2 1000], ...
                 							[5 1000; 2 1]};
        interactiveMachineRewardsCopy = {{'$1', '$5', '$2', '$1000'}, ...
                        		      		{'$2', '$1000', '$5', '$1'}};
        interactiveRewardMatricesCopy = {[1000 2; 5 1], ...
         								[1 5; 1000 2]};
                        		      
        scaleLabels = {'Random Machine', 'Copy Machine'};
                                          
        machineRewards = [1 2 5 1000];
        
    end
    properties
        nBlocks;             % Number of Blocks in the experiment
        currBlock;           % Index into block order of current Block
        blocks;              % Cell array of experiment Blocks
        blockOrder;          % Array specifying the ordering of the Blocks
        blockListener;       % Listener for block events
        subjectInfo;         % Information about the current subject
        subjectData;         % Data from the current subject
        window;              % Window where experiment is displayed (reference to figure handle)

        interactiveRounds;   % Interactive rounds for versions 1 and 2
        
        machineOutcomes;
        

        % Subject variables
        outcomeOrder;          % Order of the outcome key
        interactivePhaseOrder; % [RANDOM COPY] or [COPY RANDOM]
        interactiveRewardOrder;
        interactiveDisplayShapes; % A 4 x 2 array with containing the displayed machine shapes for the interactive rounds
        payoutChangePhaseOrder; % [RANDOM COPY] or [COPY RANDOM]
        structureLearningPhaseOrder;      % Order of conditions between Reward1, Reward2, and Reward3
        scaleLabelOrder; 	% [RANDOM COPY] or [COPY RANDOM]
        structureLearningPrimeQuestionOrder; % [RANDOM COPY] or [COPY RANDOM]
        
        structureLearningRounds1;      % Cell array of judgment rounds
        structureLearningRounds2;
        structureLearningRounds3;
        %structureLearningStimuli;      % 3 x nOutcomes matrix where row i is the order of stimuli for condition i
        structureLearningStimulus; 	   % The test stimulus used in all the structure learning conditions
        structureLearningQuestions;
        
        payoutChangeRewardOrder;       % 2 x nOutcomes matrix where row i is the order of rewards for condition i
        payoutChangeRewardOrder2;	   % Rewards for the second judgment phase
        payoutChangePhaseStimuli;	   % (2 x nPayoutChangePhaseStimuliPairs) x 3 cell array
        payoutChangePhaseRewardSequence; % (2 x nPayoutChangePhaseStimuliPairs) x 3 array of actual payouts 
        payoutChangePhaseJudgmentStimuli;	% 2 x nPayoutChangePhaseJudgmentStimuliPairs x 3 cell array
        
    end
    methods
        % Constructor
        function e = StructureLearningExperiment(window)
            e.subjectInfo = Subject();
            e.blockListener = [];
            e.window = window;
            
            % Set randomization properties
            e.outcomeOrder = randperm(MachineConstants.nOutcomes);
            e.interactivePhaseOrder = randperm(2);
            e.interactiveRewardOrder = randperm(2);
        	e.interactiveDisplayShapes = zeros(4,2);
        	e.interactiveDisplayShapes(1,:) = randperm(2);
        	e.interactiveDisplayShapes(2,:) = fliplr(e.interactiveDisplayShapes(1,:));
        	e.interactiveDisplayShapes(3,:) = randperm(2);
        	e.interactiveDisplayShapes(4,:) = fliplr(e.interactiveDisplayShapes(3,:));

            e.structureLearningPhaseOrder = randperm(3);
            e.structureLearningPrimeQuestionOrder = randperm(2);
            e.payoutChangePhaseOrder = randperm(2);
            e.scaleLabelOrder = randperm(2);
			%e.structureLearningStimulus = {MachineConstants.TRIANGLE MachineConstants.TRIANGLE MachineConstants.MAGENTA}; % Always show TRIANGLE TRIANGLE
			
% 	        machineOutcomes = {{MachineConstants.SQUARE MachineConstants.SQUARE MachineConstants.RED}, ...
%                 {MachineConstants.SQUARE MachineConstants.TRIANGLE MachineConstants.BLUE}, ...
%                 {MachineConstants.TRIANGLE MachineConstants.SQUARE MachineConstants.YELLOW}, ...
%                 {MachineConstants.TRIANGLE MachineConstants.TRIANGLE MachineConstants.MAGENTA}};
        end
        
        
        function o = createMachineOutcomes(e, colorIndex)
            o = {{MachineConstants.SQUARE MachineConstants.SQUARE e.chipColors{colorIndex}{1}}, ...
                 {MachineConstants.SQUARE MachineConstants.TRIANGLE e.chipColors{colorIndex}{2}}, ...
                 {MachineConstants.TRIANGLE MachineConstants.SQUARE e.chipColors{colorIndex}{3}}, ...
                 {MachineConstants.TRIANGLE MachineConstants.TRIANGLE e.chipColors{colorIndex}{4}}};
        end
        
        function s = createStructureLearningStimulus(e, colorIndex)
            s = {MachineConstants.TRIANGLE MachineConstants.TRIANGLE e.chipColors{colorIndex}{4}};
        end
        
        function q = createStructureLearningQuestions(e, playerName)
        
        	for i=1:2
        		switch e.structureLearningPrimeQuestionOrder(i)
        			case MachineConstants.RANDOMMACHINE
        				q{i} = sprintf('Would %s''s choice make sense if the machine on this ship was a Random Machine?', playerName);
        			case MachineConstants.COPYMACHINE
        				q{i} = sprintf('Would %s''s choice make sense if the machine on this ship was a Copy Machine?', playerName);
        		end
        	end
        	
        	q{3} = sprintf('Based on %s''s choice and the chip values you know, which type of machine do you think is on this ship?', playerName);
		end
        
        
        % Prompt for a subject number
        function promptSubjectNumber(e)
        	structureLearningOrders = perms(1:3);
        
            subjectNum = [];
            % Repeat until a valid entry
            while isempty(subjectNum)
                response = inputdlg('Enter subject number', 'Input required', 1.1);
                subjectNum = str2num(response{1});
            end
            e.subjectInfo.number = subjectNum;
            e.structureLearningPhaseOrder = structureLearningOrders(mod(subjectNum,6)+1,:);
        end        

        
        % Construct the experiment of blocks and screens
        function constructExperiment(e)
        
            for i=1:e.nChipColorSets
                e.structureLearningStimulus{i} = e.createStructureLearningStimulus(i);
                e.machineOutcomes{i} = e.createMachineOutcomes(i);
                for o=1:MachineConstants.nOutcomes
                    keyOrder{i}{o} = e.machineOutcomes{i}{e.outcomeOrder(o)};
                end
            end
            
        	   
			for o=1:MachineConstants.nOutcomes
				interactiveRewardOrderRandom{1}{o} = ...
					e.interactiveMachineRewardsRandom{1}{e.outcomeOrder(o)};
				interactiveRewardOrderRandom{2}{o} = ...
					e.interactiveMachineRewardsRandom{2}{e.outcomeOrder(o)};
					
				interactiveRewardOrderCopy{1}{o} = ...
					e.interactiveMachineRewardsCopy{1}{e.outcomeOrder(o)};
				interactiveRewardOrderCopy{2}{o} = ...
					e.interactiveMachineRewardsCopy{2}{e.outcomeOrder(o)};
					
			
				judgmentRewardOrder{1}{o} = ...
					e.structureLearningMachineRewards{1}{e.outcomeOrder(o)};
				judgmentRewardOrder{2}{o} = ...
					e.structureLearningMachineRewards{2}{e.outcomeOrder(o)};
				judgmentRewardOrder{3}{o} = ...
					e.structureLearningMachineRewards{3}{e.outcomeOrder(o)};
			end
            
            
            
           
			% Make the interactive rounds
			if (e.interactivePhaseOrder(1) == MachineConstants.RANDOMMACHINE)
				interactiveRewardOrder{1} = interactiveRewardOrderRandom;
				interactiveRewardOrder{2} = interactiveRewardOrderCopy;
				interactiveRewardMatrices{1} = e.interactiveRewardMatricesRandom;
				interactiveRewardMatrices{2} = e.interactiveRewardMatricesCopy;
			else
				interactiveRewardOrder{1} = interactiveRewardOrderCopy;
				interactiveRewardOrder{2} = interactiveRewardOrderRandom;
				interactiveRewardMatrices{1} = e.interactiveRewardMatricesCopy;
				interactiveRewardMatrices{2} = e.interactiveRewardMatricesRandom;
			end
				
			e.interactiveRounds{1} = InstructionScreen(e.window.figureHandle, {'In the first part of this experiment, you will learn about two different types of machines: Random Machines and Copy Machines.','','Both machines are used as part of a game found on cruise ships. The machines dispense colored chips that can be redeemed for dollar rewards.','','Each cruise ship only has one machine, but every machine dispenses four different colored chips: one $1000 chip, one $5 chip, one $2 chip, and one $1 chip.','','You will now play one round of the game at each of four different cruise ships.'});
			e.interactiveRounds{2} = PlayGameScreen(e.window.figureHandle, ...
				e.machineTypes(e.interactivePhaseOrder(1)), e.nPlayRounds, ...
				keyOrder{1}, interactiveRewardOrder{1}{1}, ...
				interactiveRewardMatrices{1}{1}, ...
				e.chipColors{1}, e.symbols{1}, e.interactiveDisplayShapes(1,:));
			e.interactiveRounds{3} = InstructionScreen(e.window.figureHandle, {'Now you will play a round on the machine of a different cruise ship.','','This machine uses different colored chips but still has one $1000 chip, one $5 chip, one $2 chip, and one $1 chip.'});
			e.interactiveRounds{4} = PlayGameScreen(e.window.figureHandle, ...
				e.machineTypes(e.interactivePhaseOrder(1)), e.nPlayRounds, ...
				keyOrder{2}, interactiveRewardOrder{1}{2}, ...
				interactiveRewardMatrices{1}{2}, ...
				e.chipColors{2}, e.symbols{2}, e.interactiveDisplayShapes(2,:));
			e.interactiveRounds{5} = InstructionScreen(e.window.figureHandle, {'Now you will play a round on the machine of a different cruise ship.','','This machine uses different colored chips but still has one $1000 chip, one $5 chip, one $2 chip, and one $1 chip.'});
			e.interactiveRounds{6} = PlayGameScreen(e.window.figureHandle, ...
				e.machineTypes(e.interactivePhaseOrder(2)), e.nPlayRounds, ...
				keyOrder{3}, interactiveRewardOrder{2}{1}, ...
				interactiveRewardMatrices{2}{1}, ...
				e.chipColors{3}, e.symbols{3}, e.interactiveDisplayShapes(3,:));
			e.interactiveRounds{7} = InstructionScreen(e.window.figureHandle, {'Now you will play a round on the machine of a different cruise ship.','','This machine uses different colored chips but still has one $1000 chip, one $5 chip, one $2 chip, and one $1 chip.'});
			e.interactiveRounds{8} = PlayGameScreen(e.window.figureHandle, ...
				e.machineTypes(e.interactivePhaseOrder(2)), e.nPlayRounds, ...
				keyOrder{4}, interactiveRewardOrder{2}{2}, ...
				interactiveRewardMatrices{2}{2}, ...
				e.chipColors{4}, e.symbols{4}, e.interactiveDisplayShapes(4,:));
			
% 			e.interactiveRounds{2} = PlayGameScreen(e.window.figureHandle, e.machineTypes(e.interactivePhaseOrder(1)), e.nPlayRounds, keyOrder{1}, interactiveRewardOrder{1}, e.chipColors{1}, e.symbols{1});
% 			e.interactiveRounds{3} = InstructionScreen(e.window.figureHandle, {'You will now use a different machine.'});
% 			e.interactiveRounds{4} = PlayGameScreen(e.window.figureHandle, e.machineTypes(e.interactivePhaseOrder(2)), e.nPlayRounds, keyOrder{1}, interactiveRewardOrder{2}, e.chipColors{1}, e.symbols{2});
			
			e.blocks{1} = Block(e.interactiveRounds);
			

			
			
			
% 			e.blocks{2} = Block({InstructionScreen(e.window.figureHandle, {'Please notify the experimenter to receive instructions before continuing.'})});
			e.blocks{2} = Block({InstructionScreen(e.window.figureHandle, {'In this next part of the experiment, you will see three choices made by three different players when playing the game. This time, however, you won''t know which type of machines the players were using and you may not know which chip is the $1000 chip, which is the $5 chip, and so on.','','Your task will be to try to figure out whether each player was using a Random Machine or a Copy Machine.','','First you will see a round from a player named Alice.'})});
			
			% Add the judgment rounds
			
			v = e.structureLearningPhaseOrder(1);
			e.structureLearningRounds1{1} = ViewGameScreen(e.window.figureHandle, 'Alice', e.symbols{5}, e.structureLearningStimulus{5}, keyOrder{5}, judgmentRewardOrder{v}, {e.scaleLabels{e.scaleLabelOrder}}, e.createStructureLearningQuestions('Alice'));
			
			v = e.structureLearningPhaseOrder(2);
			e.structureLearningRounds2{1} = ViewGameScreen(e.window.figureHandle, 'Bob', e.symbols{6}, e.structureLearningStimulus{6}, keyOrder{6}, judgmentRewardOrder{v}, {e.scaleLabels{e.scaleLabelOrder}}, e.createStructureLearningQuestions('Bob'));
			
			v = e.structureLearningPhaseOrder(3);
			e.structureLearningRounds3{1} = ViewGameScreen(e.window.figureHandle, 'Cindy', e.symbols{7}, e.structureLearningStimulus{7}, keyOrder{7}, judgmentRewardOrder{v}, {e.scaleLabels{e.scaleLabelOrder}}, e.createStructureLearningQuestions('Cindy'));
			
			e.blocks{3} = Block(e.structureLearningRounds1);
			e.blocks{4} = Block({InstructionScreen(e.window.figureHandle, {'Now you will move to a different cruise ship.','','You will see an outcome from a player, named Bob, using this ship''s machine, and you will make the same judgment as before.'})});
			e.blocks{5} = Block(e.structureLearningRounds2);
			e.blocks{6} = Block({InstructionScreen(e.window.figureHandle, {'Now you will move to a different cruise ship.','','You will see an outcome from a player, named Cindy, using this ship''s machine, and you will make the same judgment as before.'})});
			e.blocks{7} = Block(e.structureLearningRounds3);
			


            
            
			
			player4 = 'Mary';
			player5 = 'Nick';
			
			% Add the payout function change rounds
			for i=1:length(e.payoutChangePhaseOrder)
				e.payoutChangeRewardOrder(i,:) = randperm(MachineConstants.nOutcomes);
				e.payoutChangeRewardOrder2(i,:) = e.swapRewards(keyOrder{8+i-1}, ...
					e.payoutChangeRewardOrder(i,:), e.payoutChangePhaseOrder(i));
				[e.payoutChangePhaseStimuli{i} e.payoutChangePhaseRewardSequence(i,:)] = ...
					e.createPayoutChangePhaseSequence(e.nPayoutChangePhaseStimuliPairs, ...
					keyOrder{8+i-1}, ...
					e.machineRewards(e.payoutChangeRewardOrder(i,:)), ...
					e.payoutChangePhaseOrder(i));
				e.payoutChangePhaseJudgmentStimuli{i} = e.createPayoutChangePhaseJudgmentSequence( ...
					e.nPayoutChangePhaseJudgmentStimuliPairs);
			end
			
			e.blocks{8} = Block({InstructionScreen(e.window.figureHandle, {'In this part of the experiment, you will imagine you are watching someone play the game. For each of six rounds, you will be asked to predict what the player will do.','',sprintf('You will now move to a different cruse ship and you will watch a player named %s.',player4)})});

			rewards = e.makeRewardLabelStrings(e.machineRewards(e.payoutChangeRewardOrder(1,:)));
			rewards2 = e.makeRewardLabelStrings(e.machineRewards(e.payoutChangeRewardOrder2(1,:)));
			e.blocks{9} = Block({ViewRewardSequence(e.window.figureHandle, ...
			                    player4, ...
			                    e.symbols{8}, ...
			                    e.payoutChangePhaseStimuli{1}, ...
			                    e.payoutChangePhaseRewardSequence(1,:), keyOrder{8}, ...
			                    rewards, e.payoutChangePhaseOrder(1))});
			inst1 = sprintf('Now the values of the colored chips will change, but %s is still playing. %s is told what the new chip values are.', player4, player4);
			inst2 = sprintf('Once again, you will be asked to predict what %s will do, but you will not receive feedback this time.', player4);
			e.blocks{10} = Block({InstructionScreen(e.window.figureHandle, {inst1, '', inst2})});
			e.blocks{11} = Block({JudgeNewRewardSequence(e.window.figureHandle, ...
			                      player4, ...
			                      e.symbols{8}, ...
			                      e.payoutChangePhaseJudgmentStimuli{1}, keyOrder{8}, ...
			                      rewards2, e.payoutChangePhaseOrder(1))});
			                      
			e.blocks{12} = Block({InstructionScreen(e.window.figureHandle, {sprintf('Now you will move to a different cruise ship. You will watch a different player, named %s.', player5),'',sprintf('For each of six rounds, you will be asked to predict what %s will do.',player5)})});
			rewards = e.makeRewardLabelStrings(e.machineRewards(e.payoutChangeRewardOrder(2,:)));
			rewards2 = e.makeRewardLabelStrings(e.machineRewards(e.payoutChangeRewardOrder2(2,:)));
			e.blocks{13} = Block({ViewRewardSequence(e.window.figureHandle, ...
			                    player5, ...
			                    e.symbols{9}, ... 
			                    e.payoutChangePhaseStimuli{2}, ...
			                    e.payoutChangePhaseRewardSequence(2,:), keyOrder{9}, ...
			                    rewards, e.payoutChangePhaseOrder(2))});
			inst1 = sprintf('Now the values of the colored chips will change, but %s is still playing. %s is told what the new chip values are.', player5, player5);
			inst2 = sprintf('Once again, you will be asked to predict what %s will do, but you will not receive feedback this time.', player5);
			e.blocks{14} = Block({InstructionScreen(e.window.figureHandle, {inst1, '', inst2})});
			e.blocks{15} = Block({JudgeNewRewardSequence(e.window.figureHandle, ...
			                      player5, ...
			                      e.symbols{9}, ...
			                      e.payoutChangePhaseJudgmentStimuli{2}, keyOrder{9}, ...
			                      rewards2, e.payoutChangePhaseOrder(2))});
			
			e.blocks{16} = Block({GoodbyeScreen(e.window.figureHandle, {'Thanks for your participation. Please notify the experimenter.'})});
			

			e.blockOrder = 1:16;
			e.nBlocks = 16;
                        

        end
        
        
        % Make a cell array of reward label strings
        function s = makeRewardLabelStrings(e, payouts)
        	for p=1:length(payouts)
        		s{p} = sprintf('$%d', payouts(p));
        	end
        end
        
        % Swap the entries of the payout function so that different behavior should result
        function newPayouts = swapRewards(e, outcomes, payouts, machineVersion)
        	oldPayouts = zeros(2,2);
        	if (machineVersion == MachineConstants.COPYMACHINE)
        		% First fill out the old payout matrix
        		for i=1:MachineConstants.nOutcomes
        			o = outcomes{i};
        			oldPayouts(o{1},o{2}) = payouts(i);
        		end
        		% Then index into it and swap appropriate entries
        		for i=1:MachineConstants.nOutcomes
        			o = outcomes{i};
        			if (o{1} == MachineConstants.SQUARE && o{2} == MachineConstants.SQUARE)
						newPayouts(i) = oldPayouts(MachineConstants.TRIANGLE, MachineConstants.TRIANGLE);
					elseif (o{1} == MachineConstants.TRIANGLE && o{2} == MachineConstants.TRIANGLE)
						newPayouts(i) = oldPayouts(MachineConstants.SQUARE, MachineConstants.SQUARE);
					elseif (o{1} == MachineConstants.SQUARE && o{2} == MachineConstants.TRIANGLE)
						newPayouts(i) = oldPayouts(MachineConstants.TRIANGLE, MachineConstants.SQUARE);
					elseif (o{1} == MachineConstants.TRIANGLE && o{2} == MachineConstants.SQUARE)
						newPayouts(i) = oldPayouts(MachineConstants.SQUARE, MachineConstants.TRIANGLE);
					else 
						% error
					end
				end
			else
				% First fill out the old payout matrix
        		for i=1:MachineConstants.nOutcomes
        			o = outcomes{i};
        			oldPayouts(o{1},o{2}) = payouts(i);
        		end
        		% Then index into it and swap appropriate entries
        		for i=1:MachineConstants.nOutcomes
        			o = outcomes{i};
        			if (o{1} == MachineConstants.SQUARE && o{2} == MachineConstants.SQUARE)
						newPayouts(i) = oldPayouts(MachineConstants.SQUARE, MachineConstants.TRIANGLE);
					elseif (o{1} == MachineConstants.TRIANGLE && o{2} == MachineConstants.TRIANGLE)
						newPayouts(i) = oldPayouts(MachineConstants.TRIANGLE, MachineConstants.SQUARE);
					elseif (o{1} == MachineConstants.SQUARE && o{2} == MachineConstants.TRIANGLE)
						newPayouts(i) = oldPayouts(MachineConstants.SQUARE, MachineConstants.SQUARE);
					elseif (o{1} == MachineConstants.TRIANGLE && o{2} == MachineConstants.SQUARE)
						newPayouts(i) = oldPayouts(MachineConstants.TRIANGLE, MachineConstants.TRIANGLE);
					else 
						% error
					end
				end
			end
		end
					
        % For the payout change phase, compute the optimal response for a player
        % given the payouts and the current machine
        function [bestResponse bestPayout] = computeBestResponse(e, outcomes, payouts, machineShape, machineVersion)
            bestResponse = 0;
            bestPayout = 0;
            % If this is the Copy Machine, then we take the best we can
            % do from our two options
            if (machineVersion == MachineConstants.COPYMACHINE)
                for i=1:MachineConstants.nOutcomes
                    o = outcomes{i};
                    % Check to see if this is a viable outcome
                    if (o{1} == o{2} && payouts(i) > bestPayout)
                        bestResponse = o{1};
                        bestPayout = payouts(i);
                    end
                end
            % If this is the Random Machine, we take the best we can given
            % the current machine shape
            else
                for i=1:MachineConstants.nOutcomes
                    o = outcomes{i};
                    % Check to see if this is a viable outcome
                    if (o{1} == machineShape && payouts(i) > bestPayout)
                        bestResponse = o{2};
                        bestPayout = payouts(i);
                    end
                end
            end
        end
        
        % Given a set of outcomes, compute the indicator color associated with 
        % a given input
        function c = computeIndicatorColor(e, outcomes, machineShape, playerShape)
            for i=1:MachineConstants.nOutcomes
                o = outcomes{i};
                if (o{1} == machineShape && o{2} == playerShape)
                    c = o{3};
                    return;
                end
            end
        end
        
        
        % Create a sequence of observations for the payout change phase, given
        % a machine type and a reward structure
        function [sequence rewardSequence] = createPayoutChangePhaseSequence(e, nPairs, outcomes, payouts, machineVersion)
            if (machineVersion == MachineConstants.RANDOMMACHINE)
				machineShapes = repmat([MachineConstants.SQUARE MachineConstants.TRIANGLE], [1 nPairs]);
                sequenceOrder = randperm(2*nPairs);
                machineShapes = machineShapes(sequenceOrder);
                for i=1:length(machineShapes)
                    [playerShape r] = e.computeBestResponse(outcomes, payouts, machineShapes(i), machineVersion);
                    indicatorColor = e.computeIndicatorColor(outcomes, machineShapes(i), playerShape);
                    sequence{i} = {machineShapes(i) playerShape indicatorColor};
                    rewardSequence(i) = r;
                end
            else
                for i=1:(2*nPairs)
                    [playerShape r] = e.computeBestResponse(outcomes, payouts, 0, machineVersion);
                    indicatorColor = e.computeIndicatorColor(outcomes, playerShape, playerShape);
                    sequence{i} = {playerShape playerShape indicatorColor};
                    rewardSequence(i) = r;
                end
            end
        end
                
                
        % Create a sequence of judgment rounds for the payout change phase
        % Here, regardless of the machine we show one [SQR ?] round and one
        % [TRI ?] round in a random order for each pair. For the copy machine, neither of these
        % shapes will actually be displayed
        function sequence = createPayoutChangePhaseJudgmentSequence(e, nPairs)
        	machineShapes = repmat([MachineConstants.SQUARE MachineConstants.TRIANGLE], [1 nPairs]);
        	sequenceOrder = randperm(2*nPairs);
        	machineShapes = machineShapes(sequenceOrder);
        	for i=1:length(machineShapes)
        		sequence{i} = {machineShapes(i) 0 0}; % I'm putting dummy 0s in here now for debugging purposes
        	end
        end
        
        
        
        % Run the experiemnt
        function run(e)
            % Record the start time of the experiment
            e.subjectInfo.startTime = now;
            tic
            
            % Start the first block.
            e.currBlock = 1;
            % We listen for an endBlock event to start the next one
            b = e.blocks{e.blockOrder(e.currBlock)};
            e.blockListener = addlistener(b, 'EndBlock', @e.wrapUpBlock);
            b.executeBlock();
            
        end
        
        % Wrap up a block by collecting its data and continuing to the next block
        function wrapUpBlock(e,b,event)
            % Delete the listener
            delete(e.blockListener);
            % Collect the block's data
            e.subjectData{e.currBlock} = b.getData();
            %e.subjectData.addAt(e.blockOrder(e.currBlock), b.getData());
            % Start the next block if there is one
            if (e.currBlock < e.nBlocks)
                e.nextBlock();
            % Otherwise, end the experiment
            else
                e.endExperiment();
            end
        end
    end
    
    methods (Access = 'protected')
    
        % Execute the next block
        function nextBlock(e)
            e.currBlock = e.currBlock + 1;
            b = e.blocks{e.blockOrder(e.currBlock)};
            % Delete the old listener
            delete(e.blockListener);
            % Collect data
            
            % Add a new listener
            e.blockListener = addlistener(b, 'EndBlock', @e.wrapUpBlock);
            % Execute a block
            b.executeBlock();
        end
        
        % End the experiment
        function endExperiment(e)
            % Record the finish time of the experiment
            e.subjectInfo.finishTime = now;
            e.subjectInfo.totalTime = toc;
            
            e.saveData();
            
            fprintf('Experiment complete!\n');
        end
        
        % Collect the data into a struct and save
        function saveData(e)
        	fileName = sprintf('Subject%d_%s', ...
                        e.subjectInfo.number, datestr(e.subjectInfo.startTime,'yyyymmddHHMMSS'));
        	data = struct();
        	data.subjectNum = e.subjectInfo.number;
        	data.startTime = e.subjectInfo.startTime;
        	data.finsihTime = e.subjectInfo.finishTime;
        	data.totalTime = e.subjectInfo.totalTime;
        	
        	data.keyOrder = e.outcomeOrder;
        	data.interactivePhaseConditionOrder = e.interactivePhaseOrder;
        	data.interactivePhaseRewardOrder = e.interactiveRewardOrder;
        	data.interactivePhaseDisplayShapes = e.interactiveDisplayShapes;
        	data.structureLearningPhasePrimeQuestionOrder = e.structureLearningPrimeQuestionOrder;
        	data.structureLearningPhaseConditionOrder = e.structureLearningPhaseOrder;
        	data.structureLearningPhaseResponseScaleLabelOrder = e.scaleLabelOrder;
        	data.payoutChangePhaseConditionOrder = e.payoutChangePhaseOrder;
        	data.payoutChangePhaseStimuli = e.payoutChangePhaseStimuli;
        	data.payoutChangePhaseRewardOrder1 = e.payoutChangeRewardOrder;
        	data.payoutChangePhaseRewardOrder2 = e.payoutChangeRewardOrder2;
        	data.payoutChangePhaseJudgmentStimuli = e.payoutChangePhaseJudgmentStimuli;
        	
        	data.responses = e.subjectData;
        	
        	save(fileName, 'data');
        end
    end
end
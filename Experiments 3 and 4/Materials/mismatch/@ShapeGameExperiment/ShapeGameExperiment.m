%------------------------------------------------------------------
% ShapeGameExperiment class
%
% This creates a complete run of the Shape Game Experiment
%------------------------------------------------------------------

classdef ShapeGameExperiment < handle
    properties (Constant)
        nPlayRounds = 6;       % Number of rounds subject plays in interactive part
    
        machineStates = {[MachineConstants.SQUARE MachineConstants.TRIANGLE], ...
                         [MachineConstants.SQUARE MachineConstants.CIRCLE], ...
                         [MachineConstants.TRIANGLE MachineConstants.SQUARE], ...
                         [MachineConstants.TRIANGLE MachineConstants.CIRCLE], ...
                         [MachineConstants.CIRCLE MachineConstants.SQUARE], ...
                         [MachineConstants.CIRCLE MachineConstants.TRIANGLE]};
        nObservations = 10;
        
        % Sequences series
        % All consistent
        sequences = {[ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT, ...
                        ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT, ...
                        ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT, ...
                        ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT, ...
                        ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT], ...
        % Only type 1 violations
                    [ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT, ...
                        ObservationTypes.CONSISTENT ObservationTypes.INCONSISTENT1, ...
                        ObservationTypes.CONSISTENT ObservationTypes.INCONSISTENT1, ...
                        ObservationTypes.INCONSISTENT1 ObservationTypes.INCONSISTENT1, ...
                        ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT], ...
        % Type 1 and 2 violations
                    [ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT, ...
                        ObservationTypes.CONSISTENT ObservationTypes.INCONSISTENT1, ...
                        ObservationTypes.CONSISTENT ObservationTypes.INCONSISTENT1, ...
                        ObservationTypes.INCONSISTENT1 ObservationTypes.INCONSISTENT2, ...
                        ObservationTypes.CONSISTENT ObservationTypes.CONSISTENT]};
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
        
        expVersion;             % Whether this is an info or utility version
        pcGames;             % The interactive player card rounds
        jcGames;             % The interactive judge card rounds
        pcJudgments;         % The player card judgment rounds
        jcJudgments;         % The judge card judgment rounds
        pcConditionOrder;    % Player card condition order
        jcConditionOrder;    % Judge card condition order
        pcStimulusOrder;     % Orders of stimuli in each condition
        jcStimulusOrder;    
        pcStimuli;           % The actual stimuli in each condition
        jcStimuli;
    end
    methods
        % Constructor
        function e = ShapeGameExperiment(window)
            e.subjectInfo = Subject();
            e.blockListener = [];
            e.window = window;
        end
        
        % Prompt for a subject number
        function promptSubjectNumber(e)
            subjectNum = [];
            % Repeat until a valid entry
            while isempty(subjectNum)
                response = inputdlg('Enter subject number', 'Input required', 1.1);
                subjectNum = str2num(response{1});
            end
            e.subjectInfo.number = subjectNum;
        end
        
        % Prompt for the experiment version
        function promptExptVersion(e)
            expVersion = [];
            % Repeat until a valid entry
            while isempty(expVersion)
                response = inputdlg('Run which version?', 'Input required', 1.1);
                expVersion = str2num(response{1});
            end
            if (expVersion == 1)
                e.expVersion = JudgmentTypes.INFORMATION;
            else
                e.expVersion = JudgmentTypes.UTILITY;
            end
        end
        
        % Construct the experiment of blocks and screens
        % 1. Instruction screen
        % 2. Play game -- 10 rounds of each card
        % 3. Instruction screen
        % 4-6. Blocks 1-3 of judgments
        % If doing both versions of card, redo 1-6 with other card
        function constructExperiment(e)
            % Skip the first instruction screen for now
            % TODO
            
            % Make the interactive rounds
            e.pcGames{1} = PlayMismatchGameScreen(e.window.figureHandle, CardStates.PC_AB,CardStates.JC_NONE,...
                            e.nPlayRounds);
            e.pcGames{2} = InstructionScreen(e.window.figureHandle, {'Starting next version of game.'});
            e.pcGames{3} = PlayMismatchGameScreen(e.window.figureHandle, CardStates.PC_A,CardStates.JC_NONE,...
                            e.nPlayRounds);
            e.pcGames{4} = InstructionScreen(e.window.figureHandle, {'Starting next version of game.'});
            e.pcGames{5} = PlayMismatchGameScreen(e.window.figureHandle, CardStates.PC_P,CardStates.JC_NONE,...
                            e.nPlayRounds);
            e.jcGames{1} = PlayMismatchGameScreen(e.window.figureHandle, CardStates.PC_NONE,CardStates.JC_AB,...
                            e.nPlayRounds);
            e.jcGames{2} = InstructionScreen(e.window.figureHandle, {'Starting next version of game.'});
            e.jcGames{3} = PlayMismatchGameScreen(e.window.figureHandle, CardStates.PC_NONE,CardStates.JC_A,...
                            e.nPlayRounds);
            e.jcGames{4} = InstructionScreen(e.window.figureHandle, {'Starting next version of game.'});
            e.jcGames{5} = PlayMismatchGameScreen(e.window.figureHandle, CardStates.PC_NONE,CardStates.JC_P,...
                            e.nPlayRounds);
            
            e.pcConditionOrder = randperm(3);
            e.jcConditionOrder = randperm(3);
            
            % Make the stimuli
            for i=1:3
                e.pcStimulusOrder{i} = e.makeStimulusOrder();
                e.jcStimulusOrder{i} = e.makeStimulusOrder();
                e.pcStimuli{i} = e.makeStimuli(e.pcStimulusOrder{i}, e.sequences{e.pcConditionOrder(i)});
                e.jcStimuli{i} = e.makeStimuli(e.jcStimulusOrder{i}, e.sequences{e.jcConditionOrder(i)});
            end
            
            % Make the judgment screens
            e.pcJudgments{1} = ViewMismatchGameSequenceScreen(e.window.figureHandle, ...
                 e.pcStimuli{1}, JudgmentTypes.INFORMATION, 'Miles', 1);
            e.pcJudgments{2} = ViewMismatchGameSequenceScreen(e.window.figureHandle, ...
                 e.pcStimuli{2}, JudgmentTypes.INFORMATION, 'Rachel', 1);
            e.pcJudgments{3} = ViewMismatchGameSequenceScreen(e.window.figureHandle, ...
                 e.pcStimuli{3}, JudgmentTypes.INFORMATION, 'Chris', 1);
                 
            e.jcJudgments{1} = ViewMismatchGameSequenceScreen(e.window.figureHandle, ...
                 e.jcStimuli{1}, JudgmentTypes.UTILITY, 'Susan', 1);
            e.jcJudgments{2} = ViewMismatchGameSequenceScreen(e.window.figureHandle, ...
                 e.jcStimuli{2}, JudgmentTypes.UTILITY, 'Matt', 1);
            e.jcJudgments{3} = ViewMismatchGameSequenceScreen(e.window.figureHandle, ...
                 e.jcStimuli{3}, JudgmentTypes.UTILITY, 'Anna', 1);
                 
            % Make the blocks
            if (e.expVersion == JudgmentTypes.INFORMATION)
                e.blocks{1} = Block(e.pcGames);
                e.blocks{2} = Block({InstructionScreen(e.window.figureHandle, e.makeJudgmentSeriesInstructions('Miles'))});
                e.blocks{3} = Block({e.pcJudgments{1}});
                e.blocks{4} = Block({InstructionScreen(e.window.figureHandle, e.makeJudgmentSeriesInstructions('Rachel'))});
                e.blocks{5} = Block({e.pcJudgments{2}});
                e.blocks{6} = Block({InstructionScreen(e.window.figureHandle, e.makeJudgmentSeriesInstructions('Chris'))});
                e.blocks{7} = Block({e.pcJudgments{3}});
                e.blocks{8} = Block({InstructionScreen(e.window.figureHandle, {'End of experiment. Please notify the experimenter.'})});
            else
                e.blocks{1} = Block(e.jcGames);
                e.blocks{2} = Block({InstructionScreen(e.window.figureHandle, e.makeJudgmentSeriesInstructions('Susan'))});
                e.blocks{3} = Block({e.jcJudgments{1}});
                e.blocks{4} = Block({InstructionScreen(e.window.figureHandle, e.makeJudgmentSeriesInstructions('Matt'))});
                e.blocks{5} = Block({e.jcJudgments{2}});
                e.blocks{6} = Block({InstructionScreen(e.window.figureHandle, e.makeJudgmentSeriesInstructions('Anna'))});
                e.blocks{7} = Block({e.jcJudgments{3}});
                e.blocks{8} = Block({InstructionScreen(e.window.figureHandle, {'End of experiment. Please notify the experimenter.'})});
            end
            
            e.blockOrder = 1:8;
            e.nBlocks = 8;
        end
        
        % Make the instruction text before a judgment series
        function t = makeJudgmentSeriesInstructions(e, playerName)
            p1 = sprintf('You will now see a record of a series of %d rounds played by %s. %s played the same version of the game in all of these rounds, but you will only get to see the final outcome of three shapes in each round.', e.nObservations, playerName, playerName);
            p2 = sprintf('Your goal will be to figure out which version of the game %s was playing, based on the gameplay record.', playerName);
            t = {p1,'',p2};
        end
        
        % Make an ordering of stimulus sequences
        function o = makeStimulusOrder(e)
            o = zeros(1,e.nObservations);
            nMachineStates = length(e.machineStates);
            % If there are more observations than machine states, fill them in blocks
            % with repeats
            i = 1;
            while(sum(o == 0) ~= 0)
                blockOrder = randperm(nMachineStates);
                if (length(o(i:end)) < length(blockOrder))
                    o(i:end) = blockOrder(1:length(o(i:end)));
                    i = length(o)+1;
                else
                    o(i:(i+nMachineStates-1)) = blockOrder;
                    i = i+nMachineStates;
                end
            end
        end
        
        % Make a set of stimuli
        % machineOrder is an array of indices into the machine state array
        % trialtypes is an array of trial times (e.g. consistent, inconsistent1, etc)
        function s = makeStimuli(e, machineOrder, trialTypes)
            s = cell(1,length(machineOrder));
            for i=1:length(machineOrder)
                % Get the machine state
                mState = e.machineStates{machineOrder(i)};
                % Make the trial
                switch trialTypes(i)
                    case ObservationTypes.CONSISTENT
                        s{i} = e.makeConsistentTrial(mState);
                    case ObservationTypes.INCONSISTENT1
                        s{i} = e.makeInconsistent1Trial(mState);
                    case ObservationTypes.INCONSISTENT2
                        s{i} = e.makeInconsistent2Trial(mState);
                end
            end
        end
        
        
        % Make a consistent trial given the machine state
        % mState = [shape1 shape2]
        function t = makeConsistentTrial(e, mState)
            t = [mState 0];
            switch (mState(1))
                case MachineConstants.SQUARE
                    switch (mState(2))
                        case MachineConstants.TRIANGLE
                            t(3) = MachineConstants.CIRCLE;
                        case MachineConstants.CIRCLE
                            t(3) = MachineConstants.TRIANGLE;
                    end
                case MachineConstants.TRIANGLE
                    switch (mState(2))
                        case MachineConstants.CIRCLE
                            t(3) = MachineConstants.SQUARE;
                        case MachineConstants.SQUARE
                            t(3) = MachineConstants.CIRCLE;
                    end
                case MachineConstants.CIRCLE
                    switch (mState(2))
                        case MachineConstants.SQUARE
                            t(3) = MachineConstants.TRIANGLE;
                        case MachineConstants.TRIANGLE
                            t(3) = MachineConstants.SQUARE;
                    end
            end
        end
        
        % Make an inconsistent1 trial given the machine state
        % This trial is one in which the player shape matches
        % machine shape 2 and mismatches machine shape 1
        % mState = [shape1 shape2]
        function t = makeInconsistent1Trial(e, mState)
            % By assumption, mState(1) ~= mState(2), so
            % making this trial just amounts to copying mState(1)
            t = [mState mState(1)];
        end
        
        % Make an inconsistent2 trial given the machine state
        % This trial is one in which the player shape matches
        % machine shape 1 and mismatches machine shape 2
        % mState = [shape1 shape2]
        function t = makeInconsistent2Trial(e, mState)
            % By assumption, mState(1) ~= mState(2), so
            % making this trial just amounts to copying mState(2)
            t = [mState mState(2)];
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
            fileName = sprintf('Subject%d_Version%d_%s', ...
                         e.subjectInfo.number, e.expVersion, datestr(e.subjectInfo.startTime,'yyyymmddHHMMSS'));
                         
            data = struct();
            data.subjectNum = e.subjectInfo.number;
            data.startTime = e.subjectInfo.startTime;
            data.finishTime = e.subjectInfo.finishTime;
            data.totalTime = e.subjectInfo.totalTime;
            data.expVersion = e.expVersion;
            
            data.infoConditionOrder = e.pcConditionOrder;
            data.utilConditionOrder = e.jcConditionOrder;
            data.infoStimuli = e.pcStimuli;
            data.utilStimuli = e.jcStimuli;
            
            data.responses = e.subjectData;
            
            save(fileName, 'data');
        end
    end
end
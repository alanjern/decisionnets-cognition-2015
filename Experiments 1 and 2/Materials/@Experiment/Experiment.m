%------------------------------------------------------------------
% Experiment class
%
% This is the top level class for creating an Experiment. An
% Experiment displays a sequence of Blocks in a specified order
% and records whatever Data those Blocks generate.
%------------------------------------------------------------------

classdef Experiment < handle
    properties
        nBlocks;             % Number of Blocks in the experiment
        currBlock;           % Index into block order of current Block
        blocks;              % Cell array of experiment Blocks
        blockOrder;          % Array specifying the ordering of the Blocks
        blockListener;       % Listener for block events
        subjectInfo;         % Information about the current subject
        subjectData;         % Data from the current subject
        window;              % Window where experiment is displayed (reference to figure handle)
    end
    methods
        % Constructor
        function e = Experiment(blocks, blockOrder, window)
            % Check that there is at least one block
            if (length(blocks) < 1)
                err = MException('Experiment:BadInput', 'An Experiment must contain at least one block');
                throw(err);
            else
                e.blocks = blocks;
            end
            
            % Check that blockOrder is valid.
            % A blockOrder can skip blocks but cannot reference blocks
            % that don't exist.
            if (max(blockOrder) > e.nBlocks)
                err = MException('Experiment:BadInput', 'Block order contains value out of range');
                throw(err);
            else
                e.blockOrder = blockOrder;
                e.nBlocks = length(blockOrder);
                e.currBlock = 1;
            end
            e.subjectInfo = Subject();
            e.subjectData = DataCollection();
            e.blockListener = [];
            e.window = window;
        end
        
        % Prompt for a subject number
        % Returns an int with the subject number.
        function promptSubjectNumber(e)
            subjectNum = [];
            % Repeat until a valid entry
            while isempty(subjectNum)
                response = inputdlg('Enter subject number', 'Input required', 1.1);
                subjectNum = str2num(response{1});
            end
            e.subjectInfo.number = subjectNum;
        end
        
        % Run the experiemnt
        function run(e)
            % Record the start time of the experiment
            e.subjectInfo.startTime = now;
            tic
            
            % Start the first block.
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
            e.subjectData.addAt(e.blockOrder(e.currBlock), b.getData());
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
            
            % Store the data somehow
            % TODO!!!!!
            
            fprintf('Experiment complete!\n');
        end
    end
end
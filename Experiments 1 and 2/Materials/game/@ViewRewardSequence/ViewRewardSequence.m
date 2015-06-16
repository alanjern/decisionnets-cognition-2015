%------------------------------------------------------------------
% ViewRewardSequence class
%
%------------------------------------------------------------------

classdef ViewRewardSequence < Screen
    
    properties (Constant)
    
        
        defaultKeyPosition = [0.02 0.8];     % Base position of the indicator light key
        defaultInstructionPosition = [0.25 0.8 0.5 0.15];   % Position of instructions
        defaultMachineDescriptionPosition = [0.02 0.15 0.2 0.25]; % Position of machine descriptions
    
        % Locations of screen elements
        defaultButtonSetPosition = [.34 .15 .15 .1];
        defaultQuestionPosition = [.25 .32 .35 .06];
        defaultNextButtonPosition = [.9 .05 .05 .03];

        
        % Key appearnce settings
        outcomeKeyFontSize = 14;        % Font size of text on key
        
        % Question/judgment properties
        nQuestions = 1;                 % Total number of questions/judgments per trial
        nQuestionOptions = 2;           % Number of question options
        questionTextFontSize = 16;      % Size of question
        buttonLabelTextFontSize = 12;
        
    end

    properties 

        % Machine properties
        machineVersion;         % Version of the machine
        machinePosition;        % Position of machine (and size)
        machineAxes;            % Handle to the machine axes
        boxAxes;                % Array of handles to machine box axes
        indicatorAxes;          % Axes for indicator
        
        % Indicator key properties
        keyHandles;             % Handles to the mini-machine key   
        keyRecordBoxAxes;       % Axes for the boxes in the record mini-machines   
        outcomes;               % The possible shape and light outcomes
        rewards;                % The observed reward values
        

        %displayRound;         % The game round to display
        
        playerName;             % Name of the fictional player
        judgments;              % An array of nRounds x nQuestions numerical judgments
        
        questionButtonAxes;             % Handle to the question button axes
        questionButtonSetHandle;  % Handle to the set of radio buttons
        questionButtonHandles;  % Array of handles to individual radio buttons
        questionLabelHandles;   % Array of handles to the question labels (e.g. unlikely, likely)
        questionTextHandle;    % Array of handles to the question text;
        questionSubmitButton;   % Handle to submit button
        questionCurrentSelections; % Array of current selection on bank of questions
        squareButtonHandle;        % Handle to the square radio button label
        triangleButtonHandle;       % Handle to the triangle radio button label
        yourPredictionLabel;        % Handle to "Your Prediction" label next to buttons
        nextTrialButtonHandle;      % Handle to the next trial button
        
        % Sequence properties
        nRounds;				% Number of rounds to observe
        currRound;              % The round currently displayed on the screen
        sequence;				% A cell array of observed rounds to display
        symbols;				% The symbols used by the machine
        rewardSequence;         % An array of actual earned rewards
    
    end
    
    methods
        % Constructor
        function vs = ViewRewardSequence(figureHandle, playerName, symbols, sequence, rewardSequence, outcomes, rewards, machineVersion)
            vs = vs@Screen(figureHandle);
            
            vs.machineVersion = machineVersion;
            vs.machineAxes = [];
            vs.boxAxes = [];
            vs.indicatorAxes = 0;
            
            vs.sequence = sequence;
            vs.rewardSequence = rewardSequence;
            vs.nRounds = length(sequence);
            vs.currRound = 0;
            vs.symbols = symbols;
            
            vs.judgments = zeros(vs.nRounds,vs.nQuestions);
            vs.playerName = playerName;
            
            
            vs.questionButtonSetHandle = zeros(1,vs.nQuestions);
            vs.questionButtonHandles = zeros(1,vs.nQuestionOptions);
            vs.questionLabelHandles = zeros(1,2);
            vs.questionTextHandle = 0;
            vs.questionSubmitButton = 0;
            vs.questionCurrentSelections = zeros(1,vs.nQuestions);
            
            vs.keyHandles = [];
            vs.keyRecordBoxAxes = [];
            vs.outcomes = outcomes;
            vs.rewards = rewards;
            
        end
        
        function a = initAxes(vs)
            % Add an invisible set of axes that span the full figure
            figure(vs.figureHandle);
	        a = axes('position', [0 0 1 1]);
	        set(a, 'xtick', [], 'ytick', [], 'Color', 'none');
        end
        
        function clearAxes(vs)
            clf(vs.figureHandle);
            drawnow;
        end
        
        
        % Add the question buttons to the screen
        % Note that these buttons look identical to the machine buttons during the
        % interactive phase of the experiment, but they do not actually control the
        % machine
        function addQuestionButtons(vs, position)
        % Make the button area
            vs.questionButtonAxes = axes('position', position);
            axis off;
            
            % Add the button shapes
            % They are positioned relative to the button area
            buttonW = 1/3;
            spaceW = buttonW/4;
            buttonH = 4/5;
            spaceH = 1/6;
            
            hold on;
            % Add the square
			vs.squareButtonHandle = imshow(vs.symbols{1},'XData',[0 0.4],'YData',[0.5 0.9]);
			%axis image;

            % Add the triangle
			vs.triangleButtonHandle = imshow(vs.symbols{2},'XData',[0.55 0.95],'YData',[0.5 0.9]);
            
            % Add the radio buttons
            vs.questionButtonSetHandle = uibuttongroup('Position',[position(1) position(2)-1.5*spaceH*position(4) position(3) spaceH*1.5*position(4)], ...
                              'bordertype','none','backgroundcolor','w');
            % Create two radio buttons in the button group.
            vs.questionButtonHandles(MachineConstants.SQUARE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[spaceW+0.35*buttonW 0 buttonW 1], ...
                'parent',vs.questionButtonSetHandle, ...
                'userdata', MachineConstants.SQUARE, ...
                'HandleVisibility','off');
            vs.questionButtonHandles(MachineConstants.TRIANGLE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[2*spaceW+1.65*buttonW 0 buttonW 1], ...
                'parent',vs.questionButtonSetHandle, ...
                'userdata', MachineConstants.TRIANGLE, ...
                'HandleVisibility','off');
                
            axis image;
            
            % Add a "Your Prediction" label 
            ypLabelPos = [position(1)-0.1 position(2)+0.05 0.1 0.02];
            vs.yourPredictionLabel = uicontrol('style','text','units','normalized', ...
                    'position',ypLabelPos, ...
                    'string','Your prediction:','backgroundcolor','w','fontsize', ...
                    vs.questionTextFontSize, 'horizontalalignment','left');

            % Initialize some button group properties. 
            set(vs.questionButtonSetHandle,'SelectionChangeFcn',@vs.getSelection);
            set(vs.questionButtonSetHandle,'SelectedObject',[]);  % No selection

            % Add the submit button
            vs.questionSubmitButton = uicontrol('units','normalized', 'position', ...
                                           [position(1)+1.1*position(3) position(2)+0.25*position(4) ...
                                            1.5*buttonW*position(3) 0.5*buttonH*position(4)], ...
                                           'string', 'Submit', 'callback', @vs.submitJudgment);
                                           
            % Add the Next button
            vs.nextTrialButtonHandle = uicontrol('units','normalized', 'position', ...
                                            [position(1)+0.25 position(2)+0.25*position(4) ...
                                             1.5*buttonW*position(3) 0.5*buttonH*position(4)], ...
                                            'string', 'Next', 'callback', @vs.showNextRound, ...
                                            'visible', 'on');

        end
        
        
        % Add the question text
        function addQuestion(vs, position)
            qText = sprintf('Which picture do you think %s will choose in this round?', vs.playerName);
            vs.questionTextHandle = uicontrol('style','text','units','normalized','position',position, ...
                      'string',qText,'backgroundcolor','w','fontsize',vs.questionTextFontSize, ...
                      'horizontalalignment','left');
        end
        

        
        % Dispay the specified round
        function showRound(vs, roundIndex)
            % Get the specified round
            r = vs.sequence{roundIndex};
            
            % Draw the non player boxes
            if (vs.machineVersion == MachineConstants.RANDOMMACHINE)
                machinebox = MachineConstants.MACHINEBOX;
                switch r{machinebox}
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.boxAxes(machinebox), 0)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.boxAxes(machinebox), 0)
                end
            end
            
            vs.addInstructions(vs.defaultInstructionPosition);
        end
        
        % Record a question selection
        function getSelection(vs, src, data)
            % First figure out which question it is
            qnum = 0;
            for q=1:vs.nQuestions
                if (src == vs.questionButtonSetHandle(q))
                    qnum = q;
                    break;
                end
            end
            
            % Then record the response
            vs.questionCurrentSelections(qnum) = get(data.NewValue,'userdata');
        end
        
        
        % Reveal the player's actual choice
        function revealChoice(vs, roundIndex)
            % Disable the radio buttons
            set(vs.questionButtonHandles(MachineConstants.SQUARE), 'enable', 'off');
            set(vs.questionButtonHandles(MachineConstants.TRIANGLE), 'enable', 'off');
            set(vs.questionSubmitButton, 'enable', 'off');
            
            % Change the text to describe the choice
            r = vs.sequence{roundIndex};
            switch r{MachineConstants.PLAYERBOX}
                case MachineConstants.SQUARE
                    shape = 'first picture';
                case MachineConstants.TRIANGLE
                    shape = 'second picture';
                otherwise
                    % error
            end
            
            correct = 0;
            if (vs.judgments(vs.currRound, 1) == r{MachineConstants.PLAYERBOX})
                rText = sprintf('Correct! %s picked the %s for a reward of $%d. Click Next to continue.', ...
                                vs.playerName, shape, vs.rewardSequence(roundIndex));
                correct = 1;
            else
                rText = sprintf('Incorrect. %s picked the %s for a reward of $%d. Click Next to continue.', ...
                                vs.playerName, shape, vs.rewardSequence(roundIndex));
            end
            
            
            set(vs.questionTextHandle, 'string', rText);
            if (correct == 1)
            	set(vs.questionTextHandle, 'backgroundcolor', [1 0.5 1]);
            else
            	set(vs.questionTextHandle, 'backgroundcolor', [1 0.5 0.5]);
            end
            
            % Draw the choice and outcome
            % Random machine
            if (vs.machineVersion == MachineConstants.RANDOMMACHINE)
                playerbox = MachineConstants.PLAYERBOX;
                switch r{playerbox}
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.boxAxes(playerbox), 1)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.boxAxes(playerbox), 1)
                end
            % Copy machine
            else
                playerbox = MachineConstants.PLAYERBOX;
                machinebox = MachineConstants.MACHINEBOX;
                switch r{playerbox}
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.boxAxes(playerbox), 1)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.boxAxes(playerbox), 1)
                end
                switch r{machinebox}
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.boxAxes(machinebox), 0)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.boxAxes(machinebox), 0)
                end
            end
            
            axes(vs.indicatorAxes);
            fill([0 0 1 1], [0 1 1 0], r{3});
            axis off;
            
            % Change the submit button to a next button
            set(vs.nextTrialButtonHandle, 'visible', 'on', 'enable', 'on');
            
            %set(vs.questionSubmitButton, 'string', 'Next', 'callback', @vs.showNextRound);
            
        end
        
        % Hide all the question stuff
        function hideQuestions(vs)
            % Hide the buttons
            for q=1:vs.nQuestions
                set(vs.questionButtonSetHandle, 'visible', 'off');
            end
            % Hide submit button
            set(vs.questionSubmitButton, 'visible', 'off');
            % Hide next button
            set(vs.nextTrialButtonHandle, 'visible', 'off');
            % Hide the labels
            set(vs.squareButtonHandle, 'visible', 'off');
            set(vs.triangleButtonHandle, 'visible', 'off');
            % Hide the question text
            set(vs.questionTextHandle, 'visible', 'off');
            % Hide the "your prediction" label
            set(vs.yourPredictionLabel, 'visible', 'off');
        end
        
        % Reveal all the question stuff and reinitialize as needed
        function unhideQuestions(vs)
            % Unhide the buttons
            for q=1:vs.nQuestions
                set(vs.questionButtonSetHandle, 'visible', 'on');
            end
            % Unhide submit button
            set(vs.questionSubmitButton, 'visible', 'on');
            % Unhide next button
            set(vs.nextTrialButtonHandle, 'visible', 'on');
            % Unhide the labels
            set(vs.squareButtonHandle, 'visible', 'on');
            set(vs.triangleButtonHandle, 'visible', 'on');
            % Unhide the question text
            set(vs.questionTextHandle, 'visible', 'on');
            % Unhide the "your prediction" label
            set(vs.yourPredictionLabel, 'visible', 'on');
        end
        
        % Clear a box
        function clearBox(vs, boxIndex)
            % Switch to axes to clear
            axes(vs.boxAxes(boxIndex));
            % Draw the box outline
            if (boxIndex == MachineConstants.PLAYERBOX)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, 'edgecolor', ...
                      MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            axis off;
        end
        
        
        % Reset the specified machine box
        function resetBox(vs, boxIndex)
            % Switch to axes of the box to reset
            axes(vs.boxAxes(boxIndex));
            
            % Now fill it with a "shutter"
            shutter = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineShutterColor); 
            axis off;
        end
        
        % Reset the indicator light
        function resetIndicator(vs)
            % Switch to indicator axes
            axes(vs.indicatorAxes);
            
            % Now fill it with a "shutter"
            shutter = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineShutterColor, ...
                            'edgecolor', MachineConstants.indicatorEdgeColor); 
            axis off;
        end
        
        % Show the next round
        function showNextRound(vs, src, data)
            % Check to see if there are any rounds remaining
            if (vs.currRound >= vs.nRounds)
                % Clear the figure
                vs.clearAxes();
                % Set the data
                vs.data = vs.judgments;
                vs.hasData = 1;
                % Trigger an EndScreen event
                notify(vs,'EndScreen');
                return;
            end
            
            for q=1:vs.nQuestions
                % Reinitalize the button sets to have no selection
                set(vs.questionButtonSetHandle,'SelectedObject',[]);
            end
        
            vs.currRound = vs.currRound+1;
            
            % Hide the questions for a second so it looks like they are resetting
            vs.hideQuestions();
            
            % Clear all the boxes
            vs.clearBox(MachineConstants.PLAYERBOX);
            vs.resetBox(MachineConstants.MACHINEBOX);
            vs.resetIndicator();
            
            % Update the buttons and questions
            set(vs.questionButtonHandles(MachineConstants.SQUARE), 'enable', 'on');
            set(vs.questionButtonHandles(MachineConstants.TRIANGLE), 'enable', 'on');
            set(vs.questionSubmitButton, 'enable', 'on');
            set(vs.nextTrialButtonHandle, 'enable', 'off');
            qText = sprintf('Which shape do you think %s will choose in this round?', vs.playerName);
            set(vs.questionTextHandle, 'string', qText);
            set(vs.questionTextHandle, 'backgroundcolor', 'w');
            
            % Reveal the questions after a pause
            pause(1);
            
            % Show the next round
            vs.showRound(vs.currRound);
            vs.unhideQuestions();
            drawnow;
            
        end
        
        
        % Submit answers to question set
        function submitJudgment(vs, src, data)
            % Check if all questions have been answered
            for q=1:vs.nQuestions
                if (vs.questionCurrentSelections(q) == 0)
                    errordlg('You must make a judgment before proceeding.','Whoops');
                    return;
                end
            end
            
            % Record the answers
            for q=1:vs.nQuestions
                vs.judgments(vs.currRound, q) = vs.questionCurrentSelections(q);
            end
            
            vs.revealChoice(vs.currRound);
            
            % Clear the current answer buffers
            vs.questionCurrentSelections = zeros(1,vs.nQuestions);
        end

        
        % Add the instructions
        function addInstructions(vs, position)
            switch vs.machineVersion
                case MachineConstants.RANDOMMACHINE
                    m = 'Random Machine';
                case MachineConstants.COPYMACHINE
                    m = 'Copy Machine';
                otherwise
                    % error
            end
            instructions = {sprintf('Given the values of the colored chips shown on the left, please predict what %s will do on this round.', vs.playerName), '', sprintf('The machine on this cruise ship is a %s.', m)};
            uicontrol('style','text','units','normalized','position',position, ...
                    'string',instructions,'backgroundcolor','y',...
                    'horizontalalignment','left', ...
                    'fontsize',vs.questionTextFontSize);
        end
        
        
        % Add a square shape to the specified box
        % if playerBox = 1, this is a player box
        function addSquare(vs, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            
			imshow(vs.symbols{1},'XData',[0 1],'YData',[0 1]);
			hold on;
            axis image;
			if (playerBox)
				plot([0 0 1 1 0], [0 1 1 0 0], ...
					'color', MachineConstants.playerBoxEdgeColor, ...
					'linewidth', MachineConstants.playerBoxEdgeWidth);
			end
			
            hold off;
            axis off;
        end

        % Add a triangle shape to the specified box
        % if playerBox = 1, this is a player box
        function addTriangle(vs, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            
			imshow(vs.symbols{2},'XData',[0 1],'YData',[0 1]);
			hold on;
            axis image;
			if (playerBox)
				plot([0 0 1 1 0], [0 1 1 0 0], ...
					'color', MachineConstants.playerBoxEdgeColor, ...
					'linewidth', MachineConstants.playerBoxEdgeWidth);
			end
			
            hold off;
            axis off;
        end
        
        % Add a circle shape to the specified box
        % if playerBox = 1, this is a player box
%        function addCircle(vs, boxAxes, playerBox)
%            % Switch to axes where the square will be added
%            axes(boxAxes);
%            % Draw the box outline
%            if (playerBox)
%                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
%                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...,
%                     'edgecolor', MachineConstants.playerBoxEdgeColor);
%            else
%                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
%            end
%            % Now draw a blue square there with length = 3/4 the size
%            % of the machine square
%            hold on;
%            r = rectangle('position', [1/8 1/8 3/4 3/4], 'curvature', [1 1]);
%            set(r, 'FaceColor', MachineConstants.circleColor);
%            hold off;
%            axis off;
%        end

        
        % Add the machine that shows the current record on display
        function addMachine(vs, position)
        
            % Make the machine border
            vs.machineAxes = axes('position', position);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineColor);
            axis off;
            
            % Add the shape squares
            % They are positioned relative to the size of the machine
            l = position(1);
            b = position(2);
            w = position(3);
            h = position(4);
            
            boxW = w/3;                    % Relative sizes of machine elements
            spaceW = boxW/3;
            boxH = h*(2/3);
            spaceH = h*(1/6);            
                        
            box1pos = [l+spaceW b+spaceH boxW boxH];
            box2pos = [l+2*spaceW+boxW b+spaceH boxW boxH];
            box3pos = [l+4*spaceW+2*boxW b+spaceH boxW boxH];
            
            % Machine box
            vs.boxAxes(1) = axes('position', box1pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            % Player box
            vs.boxAxes(2) = axes('position', box2pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                 'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                 'edgecolor', MachineConstants.playerBoxEdgeColor);
            axis off;
            % Indicator box
            vs.indicatorAxes = axes('position', box3pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                'edgecolor', MachineConstants.indicatorEdgeColor);
            axis off;

        end
        
        
        % Add the indicator light key
        % This consists of a column of "mini-machines" that indicate the four possible
        % outcomes graphically
        function addIndicatorKey(vs, basePosition, outcomes, rewards)
            bigW = MachineConstants.defaultMachinePosition(3);
            bigH = MachineConstants.defaultMachinePosition(4);
            
            % Make mini versions of the machine
            miniW = bigW / 3;
            miniH = bigH / 3;
            spaceH = miniH / 2;
            
            for i=1:MachineConstants.nOutcomes
                pos = [basePosition(1) basePosition(2)-(i-1)*(miniH+spaceH) miniW miniH];
                
                
                
                % Make the machine border
                a = axes('position', pos);
                vs.keyHandles(i) = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineColor);
                axis off;
                
                % Add the boxes
                % They are positioned relative to the size of the machine
                l = pos(1);
                b = pos(2);
                w = pos(3);
                h = pos(4);
                
                boxW = w/3;                    % Relative sizes of machine elements
                spaceW = boxW/3;
                boxH = h*(2/3);
                spaceH = h*(1/6);            
                            
                box1pos = [l+spaceW b+spaceH boxW boxH];
                box2pos = [l+2*spaceW+boxW b+spaceH boxW boxH];
                box3pos = [l+8*spaceW+2*boxW b+spaceH boxW boxH];
                
                
                ba1 = axes('position', box1pos);
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
                switch outcomes{i}{1}
                    case MachineConstants.SQUARE
                        vs.addSquare(ba1, 0);
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(ba1, 0);
                    otherwise
                        % error
                end
                axis off;
                ba2 = axes('position', box2pos);
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
                switch outcomes{i}{2}
                    case MachineConstants.SQUARE
                        vs.addSquare(ba2, 1);
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(ba2, 1);
                    otherwise
                        % error
                end
                axis off;
                ba3 = axes('position', box3pos);
                fill([0 0 1 1], [0 1 1 0], outcomes{i}{3});
                axis off;
                
                arrowpos = [l+4*spaceW+2*boxW b+spaceH 3*spaceW boxH];
                arrowaxes = axes('position', arrowpos);
                arrow([0 0.5], [1 0.5]);
                axis off;
                                
                % Add the reward amount
                rewardPos = [pos(1)+2*pos(3) pos(2) 0.05 0.05];
                uicontrol('style','text','units','normalized','position',rewardPos, ...
                    'string',rewards{i},'backgroundcolor','w',...
                    'horizontalalignment','left', ...
                    'fontsize',vs.outcomeKeyFontSize);
            end
            
            % Finally, label the key
            keyPosition = [basePosition(1) basePosition(2)+0.1 0.1 0.03];
            uicontrol('style','text','units','normalized','position',keyPosition, ...
                    'string','Outcome Key','backgroundcolor','y',...
                    'horizontalalignment','center', ...
                    'fontsize',vs.outcomeKeyFontSize);
                    
            keyPosition = [basePosition(1)+0.11 basePosition(2)+0.1 0.1 0.03];
            uicontrol('style','text','units','normalized','position',keyPosition, ...
                    'string','Chip Value','backgroundcolor','c',...
                    'horizontalalignment','center', ...
                    'fontsize',vs.outcomeKeyFontSize);
                    
            % And add a separator between key and instructions
            axes(vs.axesHandle);
            x1 = basePosition(1)+8*spaceW+6*boxW;
            y1 = basePosition(2)-3*(miniH+spaceH);
            x2 = x1;
            y2 = basePosition(2)+0.1+0.03;
            line([x1 x2], [y1 y2], 'color', 'k');
            axis([0 1 0 1]);
                    
            % Add the reward amounts
            
            
        end
        
        
        % Add a box that reminds users what the machines are
%         function addMachineDescriptions(vs, position)
%             description = {'Random Machine: A random shape appears in the first box and player picks the shape in the second box.','','Copy Machine: The player picks one shape and it is copied into both boxes.'};
%             uicontrol('style','text','units','normalized','position',position, ...
%                     'string',description,'backgroundcolor','y',...
%                     'horizontalalignment','left', ...
%                     'fontsize',vs.outcomeKeyFontSize);
%         end
        
%---------- Main event loop ------------------------------------------------------------

        % This is the main function that the parent function invokes.
        % It initiates a series of screens that show a record of gameplay
        % and then ask for some inferences. At the end of the series, an
        % EndScreen event is triggered for the calling Block.
        function show(vs)
            % Make a set of axes
            vs.axesHandle = vs.initAxes();
            
            % Show the first record
            vs.currRound = 1;
            vs.addMachine(MachineConstants.defaultMachinePosition);
            vs.addQuestionButtons(vs.defaultButtonSetPosition);
            vs.addQuestion(vs.defaultQuestionPosition);
            vs.addIndicatorKey(vs.defaultKeyPosition, vs.outcomes, vs.rewards);
            %vs.addMachineDescriptions(vs.defaultMachineDescriptionPosition);
            vs.showRound(1);
        end
   
    end
    
% --------------------------------------------------------------------------------------
    
end

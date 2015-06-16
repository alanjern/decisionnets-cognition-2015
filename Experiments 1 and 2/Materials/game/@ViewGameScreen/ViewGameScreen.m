%------------------------------------------------------------------
% ViewGameScreen class
%
%------------------------------------------------------------------

classdef ViewGameScreen < Screen
    
    properties (Constant)
    
        
        defaultKeyPosition = [0.02 0.8];     % Base position of the indicator light key
        defaultInstructionPosition = [0.25 0.8 0.5 0.15];   % Position of instructions
        defaultMachineDescriptionPosition = [0.02 0.15 0.2 0.25]; % Position of machine descriptions
    
        % Locations of screen elements
        defaultButtonSetPositions = {[.3 .32 .37 .1],
        						     [.3 .16 .37 .1],
        						     [.3 .00 .37 .1]};
        defaultButtonLabelBasePositions = {[.28 .39],
            							  [.28 .23],
            							  [.28 .07]}
        defaultQuestionPositions = {[.25 .44 .45 .04],
                                    [.25 .28 .45 .04],
                                    [.25 .12 .45 .04]};
        defaultExplainBoxPosition = [.75 .15 .2 .18];
        defaultSubmitButtonPosition = [.9 .05 .05 .03];

        
        % Key appearnce settings
        outcomeKeyFontSize = 14;        % Font size of text on key
        
        % Question/judgment properties
        nQuestions = 3;                 % Total number of questions/judgments per trial
        nQuestionOptions = 7;           % Number of values on question scale
        questionTextFontSize = 14;      % Size of question
        buttonLabelTextFontSize = 12;
        
    end

    properties 

        % Machine properties
        machineVersion;         % Version of the machine
        machinePosition;        % Position of machine (and size)
        machineAxes;            % Handle to the machine axes
        boxAxes;                % Array of handles to machine box axes
        indicatorAxes;          % Axes for indicator
        boxShapeHandles;        % Array of handles to the shapes in the machine
        machineShapes;          % An array containing the shapes current in the machine boxes
        buttonAxes;             % Handle to the machine button axes
        buttonSetHandle;        % Handle to the set of buttons
        buttonHandles;          % Handles to each radio button
        machineSubmitButtonHandle; % Handle to machine submit button 
        
        % Indicator key properties
        keyHandles;             % Handles to the mini-machine key   
        keyRecordBoxAxes;       % Axes for the boxes in the record mini-machines   
        outcomes;               % The possible shape and light outcomes
        rewards;                % Their associated payouts
        

        displayRound;         % The game round to display
        symbols;				% The symbols used by the machine
        
        playerName;             % Name of the fictional player
        judgments;              % Judgments for each question
        judgmentExplanation;   % Response explanations
        
        questionButtonSetHandle;  % Handle to the set of radio buttons
        questionButtonHandles;  % Array of handles to individual radio buttons
        questionLabelHandles;   % Array of handles to the question labels (e.g. unlikely, likely)
        questionTextHandle;    % Array of handles to the question text;
        questionSubmitButton;   % Handle to submit button
        questionCurrentSelections; % Array of current selection on bank of questions
        explainBoxHandle;       % Handle to the explanation box
        explainBoxTextHandle;   % Handle to the explanation question text
        questionSeparatorHandle; % Handle to the line that separates buttons and explain box
        scaleLabels;			% Labels on the ends of the response scale
        questionText;			% The contents of the judgment questions

    end
    
    methods
        % Constructor
        function vs = ViewGameScreen(figureHandle, playerName, symbols, displayRound, outcomes, rewards, scaleLabels, qText)
            vs = vs@Screen(figureHandle);
            
            game.machineAxes = [];
            game.boxAxes = [];
            game.indicatorAxes = 0;
            game.boxShapeHandles = zeros(1,2);
            
            vs.displayRound = displayRound;
            vs.judgments = zeros(1,vs.nQuestions);
            vs.judgmentExplanation = '';
            vs.playerName = playerName;
            
            
            vs.questionButtonSetHandle = zeros(1,vs.nQuestions);
            vs.questionButtonHandles = zeros(vs.nQuestions,vs.nQuestionOptions);
            vs.questionLabelHandles = zeros(vs.nQuestions,2);
            vs.questionTextHandle = zeros(vs.nQuestions,vs.nQuestions);
            vs.questionSubmitButton = 0;
            vs.questionCurrentSelections = zeros(1,vs.nQuestions);
            vs.explainBoxHandle = 0;
            vs.explainBoxTextHandle = 0;
            vs.questionSeparatorHandle = 0;
            vs.scaleLabels{1} = {'Definitely not', 'Definitely yes'};
            vs.scaleLabels{2} = {'Definitely not', 'Definitely yes'};
            vs.scaleLabels{3} = scaleLabels;
            vs.questionText = qText;
            
            vs.keyHandles = [];
            vs.keyRecordBoxAxes = [];
            vs.outcomes = outcomes;
            vs.rewards = rewards;
            vs.symbols = symbols;
            
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
        
        
        % Add the set of questions to the screen
        % buttonSetPosition = [bottom,left,width,height] of radio buttons
        % labelBasePosition = [bottom,left] of first option label (i.e. "very unlikely")
        % submitButtonPosition = [bottom,left,width,height] of submit button
        % explainBoxPosition = [bottom,left,width,height] of text box for explanation
        function addQuestions(vs, questionPositions, buttonSetPositions, labelBasePositions, explainBoxPosition, ...
                                  submitButtonPosition, roundIndex)          
                                    
            for q=1:vs.nQuestions
            	
										
				% Add the set of radio buttons
				vs.questionButtonSetHandle(q) = uibuttongroup('Position',buttonSetPositions{q}, ...
									  'bordertype','none', 'backgroundcolor', 'w');
				
				
				% Create radio buttons in the button group.
				for v=1:vs.nQuestionOptions
					% Space buttons out evenly over width
					pos = [(v-1)*(1/vs.nQuestionOptions) 0.1 1/vs.nQuestionOptions 0.8];
					vs.questionButtonHandles(q,v) = uicontrol('Style','Radio',...
						'units','normalized','pos',pos,'string',num2str(v), ...
						'parent',vs.questionButtonSetHandle(q), ...
						'HandleVisibility','off');
				end
				
				% Initialize some button group properties. 
				set(vs.questionButtonSetHandle(q),'SelectionChangeFcn',@vs.getSelection);
				set(vs.questionButtonSetHandle(q),'SelectedObject',[]);  % No selection
				
				% Add the labels
				axes(vs.axesHandle);
				label1pos = [labelBasePositions{q}(1) labelBasePositions{q}(2) buttonSetPositions{q}(3)*(2/vs.nQuestionOptions) 0.04];
				if (q == 3)
					ltext1 = sprintf('Definitely a %s', vs.scaleLabels{q}{1});
					ltext2 = sprintf('Definitely a %s', vs.scaleLabels{q}{2});
				else
					ltext1 = vs.scaleLabels{q}{1};
					ltext2 = vs.scaleLabels{q}{2};
				end
				vs.questionLabelHandles(q,1) = uicontrol('style','text','units','normalized','position',label1pos, ...
						  'string',ltext1,'backgroundcolor','w',...
						  'fontsize',vs.buttonLabelTextFontSize, ...
						  'horizontalalignment','left');
	
				label2pos = [labelBasePositions{q}(1)+buttonSetPositions{q}(3)*(1-2/vs.nQuestionOptions) labelBasePositions{q}(2) buttonSetPositions{q}(3)*(2/vs.nQuestionOptions) 0.04];
				vs.questionLabelHandles(q,2) = uicontrol('style','text','units','normalized','position',label2pos, ...
						  'string',ltext2,'backgroundcolor','w','fontsize',vs.buttonLabelTextFontSize, ...
						  'horizontalalignment','right');
	
				%qText = sprintf('Based on this round and the chip values that you know, which type of machine do you think %s was using?', vs.playerName);
				vs.questionTextHandle(q) = uicontrol('style','text','units','normalized','position',questionPositions{q}, ...
						  'string',vs.questionText{q},'backgroundcolor','w','fontsize',vs.questionTextFontSize, ...
						  'horizontalalignment','left');
                      
        	end
                      
            % Add a line separating the buttons and the text box
            % Start the line at x = between the buttons and the edit box and y = bottom of card pictures
            x1 = (explainBoxPosition(1)+buttonSetPositions{1}(1)+buttonSetPositions{1}(3)) / 2;
            %y1 = explainBoxPosition(2);
            y1 = labelBasePositions{3}(2);
            % End the line at x = x1 and y = top of question text
            x2 = x1;
            y2 = questionPositions{1}(2)+questionPositions{1}(4);
            vs.questionSeparatorHandle = line([x1 x2], [y1 y2], 'color', 'k');
            axis([0 1 0 1]);
                      
            % Add the explanation box
            vs.explainBoxHandle = uicontrol('style','edit','units','normalized','position',explainBoxPosition, ...
                                            'max',2,'min',0,'backgroundcolor','w','horizontalalignment','left');
            % Add the explanation box question text
            eqPos = [explainBoxPosition(1) explainBoxPosition(2)+explainBoxPosition(4)+.02 ...
                     explainBoxPosition(3) .03];
            eqText = 'Please explain your judgments.';
            vs.explainBoxTextHandle = uicontrol('style','text','units','normalized','position',eqPos, ...
                                                    'string',eqText,'backgroundcolor','w', ...
                                                    'fontsize',vs.questionTextFontSize, ...
                                                    'horizontalalignment','left');
            % Add the submit button
            vs.questionSubmitButton = uicontrol('units','normalized', 'position', submitButtonPosition, ...
                                           'string', 'Submit', 'callback', @vs.submitJudgments);

        end


        
        % Submit answers to question set
        function submitJudgments(vs, src, data)
            % Get the explanation text
            explainText = get(vs.explainBoxHandle, 'string');
            % Check if all questions have been answered
            for q=1:vs.nQuestions
                if (vs.questionCurrentSelections(q) == 0)
                    errordlg('You must answer all questions before proceeding.','Whoops');
                    return;
                end
            end
            if (strcmp(explainText,'') == 1)
                errordlg('Please enter an explanation for your judgments.','Whoops');
                return;
            end
            
            % Record the answers
            for q=1:vs.nQuestions
                vs.judgments(q) = vs.questionCurrentSelections(q);
            end
            vs.judgmentExplanation = explainText;
            
            
            % Clear the current answer buffers
            vs.questionCurrentSelections = zeros(1,vs.nQuestions);
            set(vs.explainBoxHandle,'string','');
            for q=1:vs.nQuestions
                % Reinitalize the button sets to have no selection
                set(vs.questionButtonSetHandle(q),'SelectedObject',[]);
            end
            
            % Clear the figure
            vs.clearAxes();
            % Set the data
            vs.data = {vs.judgments, vs.judgmentExplanation};
            vs.hasData = 1;
            % Trigger an EndScreen event
            notify(vs,'EndScreen');
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
            vs.questionCurrentSelections(qnum) = str2num(get(data.NewValue,'string'));
        end
        
        
        % Display the specified round
        function showRound(vs)
        
            % Draw what's in it
            for b=1:2
                playerbox = 0;
                if (b == MachineConstants.PLAYERBOX)
                    playerbox = 1;
                end
                switch vs.displayRound{b}
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.boxAxes(b), playerbox)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.boxAxes(b), playerbox)
                    otherwise
                        % error
                end
            end
            
            axes(vs.indicatorAxes);
            %axes(vs.boxAxes(MachineConstants.INDICATORBOX));
            fill([0 0 1 1], [0 1 1 0], vs.displayRound{3});
            axis off;
            
            vs.addInstructions(vs.defaultInstructionPosition);
        end

        
        % Add the instructions
        function addInstructions(vs, position)
            instructions = {sprintf('Each of the four colored chips can be exchanged for a different dollar reward: $1000, $5, $2, or $1. %s knows what all of the chips are worth, but you only know what is shown on the left.',vs.playerName),'',sprintf('Here is the outcome of %s''s play.', vs.playerName)};
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
            
            vs.addMachine(MachineConstants.defaultMachinePosition);            
            vs.addQuestions(vs.defaultQuestionPositions, vs.defaultButtonSetPositions, ...
                            vs.defaultButtonLabelBasePositions, vs.defaultExplainBoxPosition, ...
                            vs.defaultSubmitButtonPosition);
            vs.addIndicatorKey(vs.defaultKeyPosition, vs.outcomes, vs.rewards);
            %vs.addMachineDescriptions(vs.defaultMachineDescriptionPosition);
            vs.showRound();
        end
   
    end
    
% --------------------------------------------------------------------------------------
    
end

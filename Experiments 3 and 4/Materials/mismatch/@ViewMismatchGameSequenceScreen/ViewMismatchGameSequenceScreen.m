%------------------------------------------------------------------
% ViewMismatchGameSequenceScreen class
%
%------------------------------------------------------------------

classdef ViewMismatchGameSequenceScreen < Screen
    
    properties (Constant)
    
        % Locations of screen elements
        defaultMainMachinePosition = [.25 .7 .3 .2];
        defaultCardBasePosition = [.2 .32];
        defaultButtonBasePosition = [.37 .32 .33 .1];
        defaultButtonLabelBasePosition = [.37 .44];
        defaultExplainBoxPosition = [.75 .15 .2 .3];
        defaultSubmitButtonPosition = [.9 .05 .05 .03];
        
        defaultBackButtonPosition = [.25 .6 .05 .03];
        defaultForwardButtonPosition = [.5 .6 .05 .03];

        % Mini record appearance settings
        miniRecordBasePosition = [.03 .95];     % Position of first mini record
        highlightedRecordColor = 'r';           % Color of highlight edge
        highlightEdgeWidth = 7;                 % Width of highlight edge
        miniRecordTrialNumberFontSize = 18;     % Font size of the round number next to mini record
        
        roundLabelPosition = [.35 .58 .1 .05];  % Position of round label
        roundLabelFontSize = 18;                % Font size of the current round label text
        
        % Question/judgment properties
        nQuestions = 3;                 % Total number of questions/judgments per trial
        nQuestionOptions = 7;           % Number of values on question scale
        questionTextFontSize = 12;      % Size of question
        
    end

    properties   
        currRecordPosition;     % Location where the currently displayed record appears
        currRecordAxes;         % Handle to the machine that displays the current record
        currRecordBoxAxes;      % Handle to the boxes of the machine
        miniRecordAxes;         % Array of handles to the thumbnail records
        miniRecordBorderHandles;    % Array of handles to the fill object that 
        miniRecordBoxAxes;      % Matrix of handles to thumbnail record boxes 
        showRecord;             % Binary flag that determines if the play record is displayed
      
        sequence;               % A cell array of mismatch game rounds to display
        nRounds;                % Number of rounds in the sequence
        currDisplayRound;       % The round currently displayed on the screen
        currJudgmentRound;      % The current round on which a judgment is being made
        currRoundLabelHandle;   % Handle to the label for the current round
        
        playerName;             % Name of the fictional player
        judgmentType;           % Type of question to ask: information or utility
        judgments;              % An array of nRounds x nQuestions numerical judgments
        judgmentExplanations;   % A cell array of nRounds judgment explanations
        
        questionCardHandles;    % Array of handles to the card pictures next to the questions
        questionButtonSetHandles;  % Array of handles to the sets of radio buttons
        questionButtonHandles;  % nSets x nOptions array of handles to individual radio buttons
        questionLabelHandles;   % Array of handles to the question labels (e.g. unlikely, likely)
        questionTextHandle;    % Array of handles to the question text;
        questionSubmitButton;   % Handle to submit button
        questionCurrentSelections; % Array of current selection on bank of questions
        explainBoxHandle;       % Handle to the explanation box
        explainBoxTextHandle;   % Handle to the explanation question text
        questionSeparatorHandle; % Handle to the line that separates buttons and explain box

    end
    
    methods
        % Constructor
        function vs = ViewMismatchGameSequenceScreen(figureHandle, sequence, judgmentType, playerName, showRecord)
            vs = vs@Screen(figureHandle);
            
            vs.currRecordPosition = [];
            vs.currRecordAxes = 0;
            vs.currRecordBoxAxes = zeros(1,MachineConstants.nBoxes);
            
            vs.sequence = sequence;
            vs.nRounds = length(sequence);
            vs.currDisplayRound = 0;
            vs.currJudgmentRound = 0;
            vs.judgmentType = judgmentType;
            vs.judgments = zeros(vs.nRounds,vs.nQuestions);
            vs.judgmentExplanations = cell(1,vs.nRounds);
            vs.playerName = playerName;
            vs.showRecord = showRecord;
            
            vs.currRoundLabelHandle = 0;
            
            vs.miniRecordAxes = zeros(1,vs.nRounds);
            vs.miniRecordBorderHandles = zeros(1,vs.nRounds);
            vs.miniRecordBoxAxes = zeros(vs.nRounds,MachineConstants.nBoxes);
            
            vs.questionCardHandles = zeros(1,vs.nQuestions);
            vs.questionButtonSetHandles = zeros(1,vs.nQuestions);
            vs.questionButtonHandles = zeros(vs.nQuestions,vs.nQuestionOptions);
            vs.questionLabelHandles = zeros(1,2);
            vs.questionTextHandle = 0;
            vs.questionSubmitButton = 0;
            vs.questionCurrentSelections = zeros(1,vs.nQuestions);
            vs.explainBoxHandle = 0;
            vs.explainBoxTextHandle = 0;
            vs.questionSeparatorHandle = 0;
            
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
        % cardBasePosition = [bottom,left] of first card
        % buttonBasePosition = [bottom,left,width,height] of first set of buttons
        % labelBasePosition = [bottom,left] of first option label (i.e. "very unlikely")
        % submitButtonPosition = [bottom,left,width,height] of submit button
        % explainBoxPosition = [bottom,left,width,height] of text box for explanation
        function addQuestions(vs, cardBasePosition, buttonBasePosition, labelBasePosition, explainBoxPosition, ...
                                  submitButtonPosition)
            % Draw a mini card which starts at the base position
            % and is half the size of the machine
            cardPosition{1} = zeros(1,4);
            cardPosition{1}(1:2) = cardBasePosition;
            % Scale by 1/2
            cardPosition{1}(3) = vs.currRecordPosition(3) / 2;
            cardPosition{1}(4) = vs.currRecordPosition(4) / 2;
            c(1) = Card(CardStates.PC_P);
            c(1).add(cardPosition{1}, MachineConstants.playerCardColor);
            
            % Add the subsequent cards with 1/2*height vertical space between them
            cardPosition{2} = zeros(1,4);
            cardPosition{2} = cardPosition{1};
            cardPosition{2}(2) = cardPosition{2}(2) - cardPosition{2}(4)*(5/4);
            % Scale by 1/2
            c(2) = Card(CardStates.PC_A);
            c(2).add(cardPosition{2}, MachineConstants.playerCardColor);
            
            cardPosition{3} = zeros(1,4);
            cardPosition{3} = cardPosition{2};
            cardPosition{3}(2) = cardPosition{3}(2) - cardPosition{3}(4)*(5/4);
            % Scale by 1/2
            c(3) = Card(CardStates.PC_AB);
            c(3).add(cardPosition{3}, MachineConstants.playerCardColor);
            
            % Store the handles
            vs.questionCardHandles = c;
            
            % Now add the set of radio buttons
            for q=1:vs.nQuestions
                % Compute position of set
                buttonSetPosition = buttonBasePosition;
                buttonSetPosition(2) = buttonSetPosition(2) - (q-1)*cardPosition{1}(4)*(5/4);
            
                vs.questionButtonSetHandles(q) = uibuttongroup('Position',buttonSetPosition, ...
                                  'bordertype','none', 'backgroundcolor', 'w');
                % Create radio buttons in the button group.
                for v=1:vs.nQuestionOptions
                    % Space buttons out evenly over width
                    pos = [(v-1)*(1/vs.nQuestionOptions) 0.1 1/vs.nQuestionOptions 0.8];
                    g.questionButtonHandles(q,v) = uicontrol('Style','Radio',...
                        'units','normalized','pos',pos,'string',num2str(v), ...
                        'parent',vs.questionButtonSetHandles(q), ...
                        'HandleVisibility','off');
                end
                
                % Initialize some button group properties. 
                set(vs.questionButtonSetHandles(q),'SelectionChangeFcn',@vs.getSelection);
                set(vs.questionButtonSetHandles(q),'SelectedObject',[]);  % No selection
            end
            
            % Add the labels
            axes(vs.axesHandle);
            vs.questionLabelHandles(1) = text(labelBasePosition(1), labelBasePosition(2), 'Very unlikely');
            vs.questionLabelHandles(2) = ... 
                    text(labelBasePosition(1)+buttonBasePosition(3)*(1-1/vs.nQuestionOptions), ...
                      labelBasePosition(2), 'Very likely', 'horizontalalignment', 'left');
                      
            % Add the actual question
%            if (vs.judgmentType == JudgmentTypes.INFORMATION)
%                qType = 'player';
%            else
%                qType = 'judge';
%            end
            qText = sprintf('Based on the record of gameplay through Round %d, how likely do you think it is that %s was playing the version of the game with the following cards?', vs.currJudgmentRound, vs.playerName);
            % Add the question above the labels and left-aligned with the first card picture
            qPos = [cardBasePosition(1) labelBasePosition(2)+.01 ...
                    cardPosition{1}(3)+buttonBasePosition(3) .05];
            vs.questionTextHandle = uicontrol('style','text','units','normalized','position',qPos, ...
                      'string',qText,'backgroundcolor','w','fontsize',vs.questionTextFontSize, ...
                      'horizontalalignment','left');
                      
            % Add a line separating the buttons and the text box
            % Start the line at x = between the buttons and the edit box and y = bottom of card pictures
            x1 = (explainBoxPosition(1)+buttonBasePosition(1)+buttonBasePosition(3)) / 2;
            y1 = cardPosition{3}(2);
            % End the line at x = x1 and y = top of question text
            x2 = x1;
            y2 = qPos(2)+qPos(4);
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
        
        % Hide all the question stuff
        function hideQuestions(vs)
            % Hide the card pictures
            for c=1:3
                vs.questionCardHandles(c).hide();
            end
            % Hide the buttons
            for q=1:vs.nQuestions
                set(vs.questionButtonSetHandles, 'visible', 'off');
            end
            % Hide submit button
            set(vs.questionSubmitButton, 'visible', 'off');
            % Hide the labels
            for l=1:2
                set(vs.questionLabelHandles(l), 'visible', 'off');
            end
            % Hide the question text
            set(vs.questionTextHandle, 'visible', 'off');
            % Hide the separator
            set(vs.questionSeparatorHandle, 'visible', 'off');
            % Hide the explain box
            set(vs.explainBoxHandle, 'visible', 'off');
            % Hide the explain box question
            set(vs.explainBoxTextHandle, 'visible', 'off');
        end
        
        % Reveal all the question stuff and reinitialize as needed
        function unhideQuestions(vs)
            % Unhide the card pictures
            for c=1:3
                vs.questionCardHandles(c).unhide();
            end
            % Unhide the buttons
            for q=1:vs.nQuestions
                set(vs.questionButtonSetHandles, 'visible', 'on');
                % Reinitalize the button sets to have no selection
                set(vs.questionButtonSetHandles(q),'SelectedObject',[]);
            end
            % Unhide submit button
            set(vs.questionSubmitButton, 'visible', 'on');
            % Unhide the labels
            for l=1:2
                set(vs.questionLabelHandles(l), 'visible', 'on');
            end
            % Update the question text
%            if (vs.judgmentType == JudgmentTypes.INFORMATION)
%                qType = 'player';
%            else
%                qType = 'judge';
%            end
            qText = sprintf('Based on the record of gameplay through Round %d, how likely do you think it is that %s was playing the version of the game with the following cards?', vs.currJudgmentRound, vs.playerName);
            % Unhide the question text
            set(vs.questionTextHandle, 'string', qText, 'visible', 'on');
            % Unhide the separator
            set(vs.questionSeparatorHandle, 'visible', 'on');
            % Unhide the explain box
            set(vs.explainBoxHandle, 'visible', 'on');
            % Unhide the explain box question
            set(vs.explainBoxTextHandle, 'visible', 'on');
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
                vs.judgments(vs.currJudgmentRound,q) = vs.questionCurrentSelections(q);
            end
            vs.judgmentExplanations{vs.currJudgmentRound} = explainText;
            
            % DEBUG
%            disp(vs.judgments);
%            disp(vs.judgmentExplanations);
            
            % Clear the current answer buffers
            vs.questionCurrentSelections = zeros(1,vs.nQuestions);
            set(vs.explainBoxHandle,'string','');
            for q=1:vs.nQuestions
                % Reinitalize the button sets to have no selection
                set(vs.questionButtonSetHandles(q),'SelectedObject',[]);
            end
            
            % Go to next round if there are any
            if (vs.currJudgmentRound < vs.nRounds)
                vs.showNextRound();
            else
                % Clear the figure
                vs.clearAxes();
                % Set the data
                vs.data = {vs.judgments, vs.judgmentExplanations};
                vs.hasData = 1;
                % Trigger an EndScreen event
                notify(vs,'EndScreen');
            end
        end
        
        % Display the next round and collect judgments
        function showNextRound(vs)
            vs.currJudgmentRound = vs.currJudgmentRound+1;
            vs.currDisplayRound = vs.currJudgmentRound;
            
            % Hide the questions for a second so it looks like they are resetting
            vs.hideQuestions();
       
            % Update the display
            vs.showRound(vs.currDisplayRound);
            % Show the previous rounds
            if (vs.showRecord == 1)
%                for r=1:vs.currJudgmentRound
%                    vs.showMiniGameplayRecord(r);
%                end
                % Remove highlighting from previous rounds
                for r=1:(vs.currJudgmentRound-1)
                    vs.dehighlightRound(r);
                end
                % Show the current round
                vs.showMiniGameplayRecord(vs.currJudgmentRound);
                vs.highlightRound(vs.currDisplayRound);
            end
            
            % Reveal the questions after a pause
            pause(1);
            vs.unhideQuestions();
            drawnow;
            
        end
        
        % Record a question selection
        function getSelection(vs, src, data)
            % First figure out which question it is
            qnum = 0;
            for q=1:vs.nQuestions
                if (src == vs.questionButtonSetHandles(q))
                    qnum = q;
                    break;
                end
            end
            
            % Then record the response
            vs.questionCurrentSelections(qnum) = str2num(get(data.NewValue,'string'));
        end
        
        
        % Dispay the specified round
        function showRound(vs, roundIndex)
            % Get the specified round
            r = vs.sequence{roundIndex};
            % Draw what's in it
            for b=1:MachineConstants.nBoxes
                playerbox = 0;
                if (b == MachineConstants.PLAYERBOX)
                    playerbox = 1;
                end
                switch r(b)
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.currRecordBoxAxes(b), playerbox)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.currRecordBoxAxes(b), playerbox)
                    case MachineConstants.CIRCLE
                        vs.addCircle(vs.currRecordBoxAxes(b), playerbox)
                end
            end
            
            % Add the label
            addRoundLabel(vs, roundIndex)
        end
        
        % Add the label that reads Round X under the big machine
        % r is just the number of the round
        function addRoundLabel(vs, r)
            labelText = sprintf('Round %d',r);
            % Create the label if it doesn't exist
            if (vs.currRoundLabelHandle == 0)
                vs.currRoundLabelHandle = uicontrol('style','text','units','normalized', ...
                             'position',vs.roundLabelPosition,'string',labelText, ...
                             'fontsize',vs.roundLabelFontSize, 'backgroundcolor','w');
            else % Otherwise just update it
                set(vs.currRoundLabelHandle, 'string', labelText);
            end
        end
        
        
        % Add a square shape to the specified box
        % if playerBox = 1, this is a player box
        function addSquare(vs, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            % Draw the box outline
            if (playerBox)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                     'edgecolor', MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            % Now draw a blue square there with width = 3/4 the size
            % of the machine square
            hold on;
            fill([1/8 1/8 7/8 7/8], [1/8 7/8 7/8 1/8], MachineConstants.squareColor);
            hold off;
            axis off;
        end
        
        % Add a triangle shape to the specified box
        % if playerBox = 1, this is a player box
        function addTriangle(vs, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            % Draw the box outline
            if (playerBox)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                     'edgecolor', MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            % Now draw a blue square there with length = 3/4 the size
            % of the machine square
            hold on;
            fill([1/8 1/2 7/8], [1/8 7/8 1/8], MachineConstants.triangleColor);
            hold off;
            axis off;
        end
        
        % Add a circle shape to the specified box
        % if playerBox = 1, this is a player box
        function addCircle(vs, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            % Draw the box outline
            if (playerBox)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...,
                     'edgecolor', MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            % Now draw a blue square there with length = 3/4 the size
            % of the machine square
            hold on;
            r = rectangle('position', [1/8 1/8 3/4 3/4], 'curvature', [1 1]);
            set(r, 'FaceColor', MachineConstants.circleColor);
            hold off;
            axis off;
        end

        
        % Add the machine that shows the current record on display
        function addMainMachine(vs, position)
            vs.currRecordPosition = position;
            % Make the machine border
            vs.currRecordAxes = axes('position', position);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineColor);
            axis off;
            
            % Add the shape squares
            % They are positioned relative to the size of the machine
            l = position(1);
            b = position(2);
            w = position(3);
            h = position(4);
            
            boxW = w/4;                    % Relative sizes of machine elements
            spaceW = boxW/4;
            boxH = h*(2/3);
            spaceH = h*(1/6);
                        
            box1pos = [l+spaceW b+spaceH boxW boxH];
            box2pos = [l+2*spaceW+boxW b+spaceH boxW boxH];
            box3pos = [l+3*spaceW+2*boxW b+spaceH boxW boxH];
            
            vs.currRecordBoxAxes(1) = axes('position', box1pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            vs.currRecordBoxAxes(2) = axes('position', box2pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            vs.currRecordBoxAxes(3) = axes('position', box3pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                 'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                 'edgecolor', MachineConstants.playerBoxEdgeColor);
            axis off;
        end
        
        % Add the buttons for moving through records
        % backPosition is the position of the back button
        % rightPosition is the position of the forward button
        function addButtons(vs, backPosition, forwardPosition)
            uicontrol('string','<<','units','normalized','position',backPosition','callback',@vs.prevRound);
            uicontrol('string','>>','units','normalized','position',forwardPosition','callback',@vs.nextRound);
        end
        
        
        % Add a mini machine that shows a smaller thumbnail record
        % Return a handle to the axes of the machine
        %   and an array of handles to the machine boxes
        % bigMachineSize is an [w,h] vector indicating the size of a big machine
        %   so that the mini machines can be scaled proportionally
        % basePosition is an [x,y] vector indicating the top-left position
        %   of the first machine
        % machineNumber is the number of the machine starting with 1
        function [a, ba1 ba2 ba3] = addMiniMachine(vs, bigMachineSize, basePosition, machineNumber)
            % Compute the machine position
            % We first compute the position of machine 1 and then shift
            % as needed
            bigW = bigMachineSize(1);
            bigH = bigMachineSize(2);
            % We want the space between machines to be 1/4 their height
            % h = mini machine height
            % n = max number of mini machines
            % ih = initial space height
            % (inital space height)*2 + (total mini machine height) + (total space height) = 1
            % (ih*2) + (h*n) + ((n-1)*(h/4)) = 1
            % ==> h = 4*(1-2*ih) / (5*n-1)
            n = vs.nRounds;
            ih = 1 - basePosition(2);
            miniH = 4*(1-2*ih) / (5*n-1);
            %miniH = ( -(4*n+1) + sqrt( (4*n+1)^2 + 16 ) ) / 2;
            % If there aren't many total rounds, we don't want giant machines
            miniHConstrained = min(miniH,0.5*bigH);
            % Now compute the proportional width
            miniWConstrained = (bigW/bigH)*miniHConstrained;
            
            % We can now determine position of first machine
            position1 = [basePosition(1) basePosition(2)-miniHConstrained miniWConstrained miniHConstrained];
            % And shift to get the position of this machine
            positionN = position1;
            positionN(2) = positionN(2) - (machineNumber-1)*(1 + 1/4)*miniHConstrained;
        
            % Make the machine border
            a = axes('position', positionN);
            vs.miniRecordBorderHandles(machineNumber) = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineColor);
            axis off;
            
            % Add the shape squares
            % They are positioned relative to the size of the machine
            l = positionN(1);
            b = positionN(2);
            w = positionN(3);
            h = positionN(4);
            
            boxW = w/4;                    % Relative sizes of machine elements
            spaceW = boxW/4;
            boxH = h*(2/3);
            spaceH = h*(1/6);
                        
            box1pos = [l+spaceW b+spaceH boxW boxH];
            box2pos = [l+2*spaceW+boxW b+spaceH boxW boxH];
            box3pos = [l+3*spaceW+2*boxW b+spaceH boxW boxH];
            
            ba1 = axes('position', box1pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            ba2 = axes('position', box2pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            ba3 = axes('position', box3pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                 'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                 'edgecolor', MachineConstants.playerBoxEdgeColor);
            axis off;
            
            % Add the machine number next to the machine
            axes(vs.axesHandle);
            text(positionN(1)-.02, positionN(2)+0.5*positionN(4), num2str(machineNumber), ...
                    'fontsize', vs.miniRecordTrialNumberFontSize);
        end
        
        
        % Display the record for round currRound in thumbnail size
        % The record will also be shifted down such that the nth round
        % will show up in the nth position of the mini gameplay record
        function showMiniGameplayRecord(vs, currRound)
            % Add mini machines for up to the current round
            [vs.miniRecordAxes(currRound), vs.miniRecordBoxAxes(currRound,1), ...
             vs.miniRecordBoxAxes(currRound,2) vs.miniRecordBoxAxes(currRound,3)] = ...
                vs.addMiniMachine(vs.currRecordPosition(3:4), vs.miniRecordBasePosition, ...
                                  currRound);
            
            % Add the shapes for that round
            r = vs.sequence{currRound};
            for b=1:MachineConstants.nBoxes
                playerbox = 0;
                if (b == MachineConstants.PLAYERBOX)
                    playerbox = 1;
                end
                switch r(b)
                    case MachineConstants.SQUARE
                        vs.addSquare(vs.miniRecordBoxAxes(currRound,b), playerbox)
                    case MachineConstants.TRIANGLE
                        vs.addTriangle(vs.miniRecordBoxAxes(currRound,b), playerbox)
                    case MachineConstants.CIRCLE
                        vs.addCircle(vs.miniRecordBoxAxes(currRound,b), playerbox)
                end
            end
        end
                
        
        % Highlight the displayed round in the gameplay record
        function highlightRound(vs, roundIndex)
            % Check that this is a valid round
            if (roundIndex > vs.currJudgmentRound)
                err = MException('ViewMismatchGameSequenceScreen:BadInput', ...
                                 'Cannot change round record before it has been displayed');
                throw(err);
            end
            
            % Get a handle to the round record border
            rHandle = vs.miniRecordBorderHandles(roundIndex);
            % Check that it exists
            if (rHandle == 0)
                err = MException('ViewMismatchGameSequenceScreen:OutOfRange', 'Round does not exist');
                throw(err);
            end
            
            % Add a red border around that record
            set(rHandle, 'linewidth', vs.highlightEdgeWidth, 'edgecolor', vs.highlightedRecordColor);
        end
        
        % Turn off the highlighting for a particular round
        function dehighlightRound(vs, roundIndex)
            % Check that this is a valid round
            if (roundIndex > vs.currJudgmentRound)
                err = MException('ViewMismatchGameSequenceScreen:BadInput', 'Cannot change round record before it has been displayed');
                throw(err);
            end
            
            % Get a handle to the round record border
            rHandle = vs.miniRecordBorderHandles(roundIndex);
            % Check that it exists
            if (rHandle == 0)
                err = MException('ViewMismatchGameSequenceScreen:OutOfRange', 'Round does not exist');
                throw(err);
            end
            
            % Add a red border around that record
            set(rHandle, 'linewidth', 1, 'edgecolor', 'k');
        end
        
        
        % Go back one round
        % Callback for back button
        function prevRound(vs, src, event)
            % If this is the first round, do nothing
            if (vs.currDisplayRound == 1)
                return;
            end
            
            % Update the current display to the previous round
            vs.showRound(vs.currDisplayRound-1);
            % Remove highlighting for current round
            vs.dehighlightRound(vs.currDisplayRound);
            % Add highlight the previous round
            vs.highlightRound(vs.currDisplayRound-1);
            % Update the number of the current round
            vs.currDisplayRound = vs.currDisplayRound-1;
        end
            
            
        
        % Go forward one round
        % Callback for forward button
        function nextRound(vs, src, event)
            % If this is the last visible round, do nothing
            if (vs.currDisplayRound == vs.currJudgmentRound)
                return;
            end
            
            % Update the current display to the previous round
            vs.showRound(vs.currDisplayRound+1);
            % Remove highlighting for current round
            vs.dehighlightRound(vs.currDisplayRound);
            % Add highlight the previous round
            vs.highlightRound(vs.currDisplayRound+1);
            % Update the number of the current round
            vs.currDisplayRound = vs.currDisplayRound+1;
        end
        
%---------- Main event loop ------------------------------------------------------------

        % This is the main function that the parent function invokes.
        % It initiates a series of screens that show a record of gameplay
        % and then ask for some inferences. At the end of the series, an
        % EndScreen event is triggered for the calling Block.
        function show(vs)
            % Make a set of axes
            vs.axesHandle = vs.initAxes();
            
            % Show the first record
            vs.currJudgmentRound = 1;
            vs.currDisplayRound = 1;
            vs.addMainMachine(vs.defaultMainMachinePosition);            
            vs.addQuestions(vs.defaultCardBasePosition, vs.defaultButtonBasePosition, ...
                            vs.defaultButtonLabelBasePosition, vs.defaultExplainBoxPosition, ...
                            vs.defaultSubmitButtonPosition);
            vs.showRound(1);
            if (vs.showRecord == 1)
                %vs.addButtons(vs.defaultBackButtonPosition, vs.defaultForwardButtonPosition);
                vs.showMiniGameplayRecord(1);
                vs.highlightRound(1);
            end
        end
   
    end
    
% --------------------------------------------------------------------------------------
    
end

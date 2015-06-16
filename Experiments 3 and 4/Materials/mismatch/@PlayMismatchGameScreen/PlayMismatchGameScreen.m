%------------------------------------------------------------------
% PlayMismatchGameScreen class
%
% Execute a series of Shape Mismatch Game rounds
%------------------------------------------------------------------

classdef PlayMismatchGameScreen < Screen
    
    properties (Constant)

        % Score board appearance settings
        defaultScoreBoardPosition = [.9 .1];    % Position of score board
        scoreBoardColor = [255 255 153]/255;    % Background color of score board
        scoreBoardFontSize = 30;                % Score board font size
        scoreBoardMargin = 10;                  % Score board text margins
        scoreBoardEdgeWidth = 5;                % Appearance of score board
        scoreBoardEdgeColor = 'k';
        
        roundScorePosition = [0.35 0.2];             % Position of popup that shows core for round
        roundScoreColor = [102 255 51]/255;         % Color of popup text
        roundScoreFontSize = 100;                   % Popup font size
        
    end

    properties     
        % Card properties   
        playerCard;             % A Card object representing the player card
        judgeCard;              % A Card object representing the judge card 
        pcInitialPosition;      % Initial position of player card
        jcInitialPosition;      % Initial position of judge card
        
        % Machine properties
        machinePosition;        % Position of machine (and size)
        machineAxes;            % Handle to the machine axes
        boxAxes;                % Array of handles to machine box axes
        boxShapeHandles;        % Array of handles to the shapes in the machine
        machineShapes;          % An array containing the shapes current in the machine boxes
        buttonAxes;             % Handle to the machine button axes
        buttonSetHandle;        % Handle to the set of buttons
        buttonHandles;          % Handles to each radio button
        machineSubmitButtonHandle; % Handle to machine submit button        
        
        % Game properties
        nRounds;                % Number of rounds to play
        currRound;              % Current round
        score;                  % Currect score
        scoreBoardHandle;       % Handle to score board
        endRoundFlag;           % Flag that marks the end of a round (after player submits)
    end
    
    methods
        % Constructor
        function game = PlayMismatchGameScreen(figureHandle, playerCardState, judgeCardState, nRounds)
            game = game@Screen(figureHandle);
            game.playerCard = Card(playerCardState);
            game.pcInitialPosition = [];
            game.judgeCard = Card(judgeCardState);
            game.jcInitialPosition = [];
            %game.axesHandle = game.initAxes();
            
            game.machineAxes = [];
            game.boxAxes = [];
            game.boxShapeHandles = zeros(1,3);
            game.buttonAxes = [];
            game.buttonSetHandle = [];
            game.buttonHandles = [];
            game.machineSubmitButtonHandle = [];
            game.machinePosition = [];
            game.machineShapes = repmat(MachineConstants.NOSHAPE, 1, MachineConstants.nBoxes);
            
            game.nRounds = nRounds;
            game.currRound = 1;
            game.score = 0;
            game.scoreBoardHandle = [];
            game.endRoundFlag = 0;
            
        end
        
        function a = initAxes(g)
            % Add an invisible set of axes that span the full figure
            figure(g.figureHandle);
	        a = axes('position', [0 0 1 1]);
	        set(a, 'xtick', [], 'ytick', [], 'Color', 'none');
        end
        
        function clearAxes(g)
            clf(g.figureHandle);
            drawnow;
        end
        
        % Functions in separate files
        % (I'll put them in separate files later)
        
        % Add the machine figure to the screen
        function addMachine(g, position)
            g.machinePosition = position;
            % Make the machine border
            g.machineAxes = axes('position', position);
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
            
            g.boxAxes(1) = axes('position', box1pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            g.boxAxes(2) = axes('position', box2pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            g.boxAxes(3) = axes('position', box3pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                 'linewidth', MachineConstants.playerBoxEdgeWidth, ...,
                 'edgecolor', MachineConstants.playerBoxEdgeColor);
            axis off;
        end
        
        % Add the shapes designated by the machine
        % shapes is a vector where shapes(i) is the shape to put into 
        % square i
        function addShapes(g, shapes)
            for i=1:length(shapes)
                if (shapes(i) == MachineConstants.NOSHAPE)
                    continue;
                elseif (shapes(i) == MachineConstants.SQUARE)
                    addSquare(g,i);
                elseif (shapes(i) == MachineConstants.TRIANGLE)
                    addTriangle(g,i);
                elseif (shapes(i) == MachineConstants.CIRCLE)
                    addCircle(g,i);
                else
                    err = MException('PlayMismatchGameScreen:BadInput', 'Invalid shape argumented passed to addShapes');
                    throw(err);
                end
            end
        end
        
        % Add a square shape to the specified box
        function addSquare(g, boxIndex)
            % Switch to axes where the square will be added
            axes(g.boxAxes(boxIndex));

            % Draw the box outline
            if (boxIndex == MachineConstants.PLAYERBOX)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                     'edgecolor', MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            % Now draw a blue square there with width = 3/4 the size
            % of the machine square
            hold on;
            g.boxShapeHandles(boxIndex) = fill([1/8 1/8 7/8 7/8], [1/8 7/8 7/8 1/8], ...
                              MachineConstants.squareColor);
            hold off;
            axis off;
            
            % Change machine box state
            g.machineShapes(boxIndex) = MachineConstants.SQUARE;
        end
        
        % Add a triangle shape to the specified box
        function addTriangle(g, boxIndex)
            % Switch to axes where the square will be added
            axes(g.boxAxes(boxIndex));
            
            % Draw the box outline
            if (boxIndex == MachineConstants.PLAYERBOX)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                     'edgecolor', MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            % Now draw a blue square there with length = 3/4 the size
            % of the machine square
            hold on;
            g.boxShapeHandles(boxIndex) = fill([1/8 1/2 7/8], [1/8 7/8 1/8], ...
                                  MachineConstants.triangleColor);
            hold off;
            axis off;
            
            % Change machine box state
            g.machineShapes(boxIndex) = MachineConstants.TRIANGLE;
        end
        
        % Add a circle shape to the specified box
        function addCircle(g, boxIndex)
            % Switch to axes where the square will be added
            axes(g.boxAxes(boxIndex));
            
            % Draw the box outline
            if (boxIndex == MachineConstants.PLAYERBOX)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, ...
                     'edgecolor', MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            % Now draw a blue square there with length = 3/4 the size
            % of the machine square
            hold on;
            g.boxShapeHandles(boxIndex) = rectangle('position', [1/8 1/8 3/4 3/4], 'curvature', [1 1]);
            set(g.boxShapeHandles(boxIndex), 'FaceColor', MachineConstants.circleColor);
            hold off;
            axis off;
            
            % Change machine box state
            g.machineShapes(boxIndex) = MachineConstants.CIRCLE;
        end
        
        % Clear a box
        function clearBox(g, boxIndex)
            % Switch to axes to clear
            axes(g.boxAxes(boxIndex));
            % Draw the box outline
            if (boxIndex == MachineConstants.PLAYERBOX)
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                     'linewidth', MachineConstants.playerBoxEdgeWidth, 'edgecolor', ...
                      MachineConstants.playerBoxEdgeColor);
            else
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            end
            axis off;
            
            % Change machine box state
            g.machineShapes(boxIndex) = MachineConstants.NOSHAPE;
            % And clear the handle to the box's shape
            g.boxShapeHandles(boxIndex) = 0;
        end
        
        % Add the machine buttons
        function addMachineButtons(g, position)
            % Make the button area
            g.buttonAxes = axes('position', position);
            axis off;
            
            % Add the button shapes
            % They are positioned relative to the button area
            buttonW = 1/4;
            spaceW = buttonW/4;
            buttonH = 2/3;
            spaceH = 1/6;
            
            hold on;
            % Add the square
            fill([spaceW spaceW spaceW+buttonW spaceW+buttonW], ...
                 [spaceH spaceH+buttonH spaceH+buttonH spaceH], MachineConstants.squareColor);
            % Add the triangle
            fill([2*spaceW+buttonW 2*spaceW+3/2*buttonW 2*spaceW+2*buttonW], ...
                 [spaceH spaceH+buttonH spaceH], MachineConstants.triangleColor);
            % Add the circle
            r = rectangle('position', [3*spaceW+2*buttonW spaceH buttonW buttonH], 'curvature', [1 1]);
            set(r, 'FaceColor', MachineConstants.circleColor);
            hold off;
            
            % Add the radio buttons
            g.buttonSetHandle = uibuttongroup('Position',[position(1) position(2)-spaceH*position(4) position(3) spaceH*1.5*position(4)], ...
                              'bordertype','none','backgroundcolor','w');
            % Create three radio buttons in the button group.
            g.buttonHandles(MachineConstants.SQUARE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[spaceW+0.35*buttonW 0 buttonW 1],'parent',g.buttonSetHandle, ...
                'HandleVisibility','off','enable','off');
            g.buttonHandles(MachineConstants.TRIANGLE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[2*spaceW+1.35*buttonW 0 buttonW 1],'parent',g.buttonSetHandle, ...
                'HandleVisibility','off','enable','off');
            g.buttonHandles(MachineConstants.CIRCLE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[3*spaceW+2.35*buttonW 0 buttonW 1],'parent',g.buttonSetHandle, ..., 
                'HandleVisibility','off','enable','off');
            % Initialize some button group properties. 
            set(g.buttonSetHandle,'SelectionChangeFcn',@g.pickShape);
            set(g.buttonSetHandle,'SelectedObject',[]);  % No selection

            % Add the submit button
            g.machineSubmitButtonHandle = uicontrol('units','normalized', 'position', ...
                                           [position(1)+1.1*position(3) position(2)+0.25*position(4) ...
                                            1.5*buttonW*position(3) 0.5*buttonH*position(4)], ...
                                           'enable', 'off', ...
                                           'string', 'Submit', 'callback', @g.playerSubmit);

        end
       
        % Add the "score board"
        % position is specified here as (x,y) relative to window axes
        function addScoreBoard(g, position)
            axes(g.axesHandle);
            set(g.axesHandle, 'units', 'normalized');
            g.scoreBoardHandle = text('position', position, 'margin', g.scoreBoardMargin, ...
                 'backgroundColor', g.scoreBoardColor, ...
                 'fontsize', g.scoreBoardFontSize, 'string', 'Score: 0', ...
                 'linewidth', g.scoreBoardEdgeWidth, 'edgecolor', g.scoreBoardEdgeColor, ...
                 'horizontalalignment', 'center', 'verticalalignment', 'middle');
        end
        
        % Update the score board
        % Add s points to the cumulative score and display result
        function updateScoreBoard(g, s)
            g.score = g.score + s;
            scoreBoardText = sprintf('Score: %d',g.score);
            set(g.scoreBoardHandle, 'string', scoreBoardText);
         end               
            
        
        % Put the selected shape into the user box
        function pickShape(g, src, data)
            switch data.NewValue
                case g.buttonHandles(MachineConstants.SQUARE)
                    g.addSquare(MachineConstants.PLAYERBOX);
                    g.machineShapes(MachineConstants.PLAYERBOX) = MachineConstants.SQUARE;
                case g.buttonHandles(MachineConstants.TRIANGLE)
                    g.addTriangle(MachineConstants.PLAYERBOX);
                    g.machineShapes(MachineConstants.PLAYERBOX) = MachineConstants.TRIANGLE;
                case g.buttonHandles(MachineConstants.CIRCLE)
                    g.addCircle(MachineConstants.PLAYERBOX);
                    g.machineShapes(MachineConstants.PLAYERBOX) = MachineConstants.CIRCLE;
                otherwise
                    % error
            end
        end
        
        % Reset the specified machine box
        function resetBox(g, boxIndex)
            % Switch to axes of the box to reset
            axes(g.boxAxes(boxIndex));
            % Bring the player card to the top of the visual stack
            uistack(g.playerCard.cardAxes, 'top');
            
            % Now fill it with a "shutter"
            shutter = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineShutterColor); 
            axis off;
            % Clear the handle to the shape object
            g.boxShapeHandles(boxIndex) = 0;
        end
        
        % Run the machine by clearing the shapes currently in the boxes
        % and then randomly selecting two new shapes to fill them
        function runMachine(g)
            % Clear the machine buttons
            set(g.buttonSetHandle,'SelectedObject',[]);
            
            % Clear the player box
            g.clearBox(MachineConstants.PLAYERBOX);
            
            % Clear the visible boxes
            if (g.playerCard.state == CardStates.PC_AB || g.playerCard.state == CardStates.PC_NONE) 
                g.resetBox(1);
            end;
            if (g.playerCard.state == CardStates.PC_AB || g.playerCard.state == CardStates.PC_A || ...
                g.playerCard.state == CardStates.PC_NONE)
                g.resetBox(2);
            end;
            
            % Pause for a moment while machine "runs"
            pause(0.5);
            
            % -----------------------------------------------------------
            %     WARNING: This is a MAJOR hack
            
            figFrame = getframe(g.figureHandle);
            figData = figFrame.cdata;
            fakeFigure = uicontrol(g.figureHandle,'Style','pushbutton', ...
                            'units','normalized','position',[0,0,1,1],'cdata',figData, ...
                            'enable', 'inactive');
            uistack(fakeFigure,'top');
            drawnow;
            
            % -----------------------------------------------------------
            
            % Sample two shapes for the first two boxes
            % Enforce the constraint that they must be different
            g.machineShapes = [];
            while (1)
                g.machineShapes(1:2) = randint(1,2,[1,3]);
                if (g.machineShapes(1) ~= g.machineShapes(2))
                    break;
                end
            end
            % Now draw the shapes
            for b=1:2
                switch g.machineShapes(b)
                    case MachineConstants.SQUARE
                        g.addSquare(b);
                    case MachineConstants.TRIANGLE
                        g.addTriangle(b);
                    case MachineConstants.CIRCLE
                        g.addCircle(b);
                    otherwise
                        % error
                end
            end
   

            % ---------------------------------------------------------
            %       MAJOR hack continued
            
            drawnow;
            pause(0.5);
            delete(fakeFigure);
            % ---------------------------------------------------------
 
            % Bring the player card to the top of the visual stack
            uistack(g.playerCard.cardAxes, 'top'); 


        end
        
                            
        % Add the player card
        function addPlayerCard(g)
            cardPosition = g.machinePosition;
            cardPosition(1) = cardPosition(1) + 1/3;
            g.pcInitialPosition = cardPosition;
            g.playerCard.add(cardPosition, MachineConstants.playerCardColor);
        end
        
        % Add the judge card
        function addJudgeCard(g)
            cardPosition = g.machinePosition;
            cardPosition(2) = cardPosition(2) + 1/4;
            g.jcInitialPosition = cardPosition;
            g.judgeCard.add(cardPosition, MachineConstants.judgeCardColor);
        end
        
        
        % Compute a score for the round based on the current machine state
        function s = computeScore(g)
            s = 0;
            % Check that all boxes have a shape
            if (~isempty(find(g.machineShapes == MachineConstants.NOSHAPE)))
                err = MException('PlayMismatchGameScreen:BadMachineState', 'Cannot compute score until every machine box is full');
                throw(err);
            else
                if (g.judgeCard.state == CardStates.JC_P)
                    % Give constant point reward for the JC_P card
                    s = 10;
                    return;
                end
                % Get the player shape
                player = g.machineShapes(MachineConstants.PLAYERBOX);
                % Compare to other shapes
                if (g.judgeCard.state == CardStates.JC_AB || g.judgeCard.state == CardStates.JC_NONE)
                    if (player ~= g.machineShapes(1))
                        s = s + 10;
                    end
                end
                if (g.judgeCard.state == CardStates.JC_AB || g.judgeCard.state == CardStates.JC_A || ...
                    g.judgeCard.state == CardStates.JC_NONE)
                    if (player ~= g.machineShapes(2))
                        s = s + 10;
                    end
                end
            end
        end       
            
        % Handle a player's response
        function playerSubmit(g, h, value)
            % We can ignore the value because it is binary and this function
            % is only called when the submit button is pushed
            
            % First check that the machine has been run
            % (i.e. there are machine shapes)
            if (g.machineShapes(1) == MachineConstants.NOSHAPE || g.machineShapes(2) == MachineConstants.NOSHAPE)
                errordlg('The machine hasn''t started yet','Whoops');
            % Then check if player chose a response
            elseif (g.machineShapes(MachineConstants.PLAYERBOX) == MachineConstants.NOSHAPE)
                % Print an error message
                errordlg('You must pick a shape first.','Whoops');
            else
                % Complete the round
                if (g.endRoundFlag == 1)
                    errordlg('You already picked a shape.','Whoops');
                else
                    % Set the end round flag
                    g.endRoundFlag = 1;
                    
                    % Move the player card off the machine
                    % Bring the card to the top of the visual stack
                    if (g.playerCard.state ~= CardStates.PC_NONE)
                        uistack(g.playerCard.cardAxes, 'top');
                        g.playerCard.moveCard(g.pcInitialPosition, MachineConstants.animationFrames);
                    end
                    
                    % Move the judge card onto the machine
                    % Bring the card to the top of the visual stack
                    if (g.judgeCard.state ~= CardStates.JC_NONE)
                        uistack(g.judgeCard.cardAxes, 'top');
                        g.judgeCard.moveCard(g.machinePosition, MachineConstants.animationFrames);
                    end
                            
                    % Compute score for this round
                    s = g.computeScore();
                    % Display score
                    scoreText = sprintf('+%d',s);
                    axes(g.axesHandle);
                    set(g.axesHandle, 'units', 'normalized');
                    scoreDisplay = text(g.roundScorePosition(1), g.roundScorePosition(2), ...
                                     scoreText,'color',g.roundScoreColor, ...
                                     'fontsize',g.roundScoreFontSize);
                    % Update cumulative score
                    g.updateScoreBoard(s);
                    % Keep on screen for a bit
                    pause(1);
                    % Then delete
                    delete(scoreDisplay);
                    
                    if (g.judgeCard.state ~= CardStates.JC_NONE)
                        % Move the judge card away
                        g.judgeCard.moveCard(g.jcInitialPosition, MachineConstants.animationFrames);
                    end
                    
                    % Keep playing if more rounds remain
                    if (g.currRound < g.nRounds)
                        g.currRound = g.currRound + 1;
                        % Clear the end round flag
                        g.endRoundFlag = 0;
                        % Start the next round
                        g.playRound(1);
                    else
                        % Otherwise, end the series of rounds and signal the calling Block
                        g.endPlay();
                    end
                end
            end
        end
                
        
        % Play one complete round
        function playRound(g, moveCard)
            % First, disable the buttons until the machine is finished running
            set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'off');
            set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'off');
            set(g.buttonHandles(MachineConstants.CIRCLE), 'enable', 'off');
            set(g.machineSubmitButtonHandle, 'enable', 'off');

            
            % Move the player card onto the machine
            pause(1);
            if (moveCard && g.playerCard.state ~= CardStates.PC_NONE)
                g.playerCard.moveCard(g.machinePosition, MachineConstants.animationFrames);
                pause(1);
            end
            
            % Run the machine
            g.runMachine();
            
            % Enable the submit button and wait for a player response ...
            set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'on');
            set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'on');
            set(g.buttonHandles(MachineConstants.CIRCLE), 'enable', 'on');
            set(g.machineSubmitButtonHandle, 'enable', 'on');
        end
  
        % End the game and signal the calling Block
        function endPlay(g)
            % Clear the figure
            g.clearAxes();
            % Trigger an EndScreen event
            notify(g,'EndScreen');
        end

%---------- Main event loop ------------------------------------------------------------

        % This is the main function that the parent function invokes.
        % It initiates a series of game rounds that signals the calling Block
        % at the end of the series.
        function show(g)
            % Make a set of axes
            g.axesHandle = g.initAxes();
            
            % Draw the game elements
            g.addMachine(MachineConstants.defaultMachinePosition);
            g.addMachineButtons(MachineConstants.defaultButtonPosition);
            g.addPlayerCard();
            g.addJudgeCard();
            g.addScoreBoard(g.defaultScoreBoardPosition);
        
            game.currRound = 1;
            % Start the first round
            pause(1.5);
            moveCard = 1;
            g.playRound(1); % Move the player card on the first round
        end
        
            
    end
    
% --------------------------------------------------------------------------------------
    
    methods (Access = private)
    
        % Determine if the box specified by boxIndex is concealed by the
        % player card
        function concealed = isConcealed(g, boxIndex)
            concealed = 0;
            pcState = g.playerCard.state;
            % First check to see if the card is covering the machine
            % TODO
            
            switch boxIndex
                case 1
                    if (pcState == CardStates.PC_A || pcState == CardStates.PC_P)
                        concealed = 1;
                    end
                case 2
                    if (pcState == CardStates.PC_P)
                        concealed = 1;
                    end
            end
        end
    end

end

        
            
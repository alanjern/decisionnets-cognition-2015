%------------------------------------------------------------------
% PlayGameScreen class
%
% Execute a series of game screens
%------------------------------------------------------------------

classdef PlayGameScreen < Screen

    properties (Constant)
    
        defaultKeyPosition = [0.02 0.8];     % Base position of the indicator light key
        defaultInstructionPosition = [0.25 0.75 0.5 0.2];   % Position of instructions
        
        % Key appearnce settings
        outcomeKeyFontSize = 14;        % Font size of text on key
        
    end

    properties     
        
        % Machine properties
        machineVersion;         % Version of the machine
        machinePosition;        % Position of machine (and size)
        machineAxes;            % Handle to the machine axes
        boxAxes;                % Array of handles to machine box axes
        indicatorAxes;          % Handles to the axes for the indicator shape
        boxShapeHandles;        % Array of handles to the shapes in the machine
        machineShapes;          % An array containing the shapes current in the machine boxes
        buttonAxes;             % Handle to the machine button axes
        buttonSetHandle;        % Handle to the set of buttons
        buttonHandles;          % Handles to each radio button
        machineSubmitButtonHandle; % Handle to machine submit button 
        displayShapes;			% An array of machine shapes to show
        rewardMessageHandle;	% Handle to the text message showing the reward for the round
        nextButtonHandle;		% Handle to the Next button
        
        symbols;				% Pair of symbols to use in this screen.
        
        % Indicator key properties
        keyHandles;             % Handles to the mini-machine key   
        keyRecordBoxAxes;       % Axes for the boxes in the record mini-machines 
        outcomes;               % Cell array of possible indicator outcomes 
        chipColors;             % Cell array of indicator/chip colors
                                % Order is: SQR SQR, SQR TRI, TRI SQR, TRI TRI
    	rewards;				% List of rewards for each chip
    	rewardMatrix;			% A lookup table for rewards
        
        % Game properties
        nRounds;                % Number of rounds to play
        currRound;              % Current round
        endRoundFlag;           % Flag that marks the end of a round (after player submits)
        
        % Player properties
        judgments;				% nRounds x 2 final outcomes (includes random + player shapes)
    end
    
    methods
        % Constructor
        function game = PlayGameScreen(figureHandle, machineVersion, nRounds, outcomes, rewards, rewardMatrix, chipColors, symbols, displayShapes)
            game = game@Screen(figureHandle);
            game.machineVersion = machineVersion;
            
            game.machineAxes = [];
            game.boxAxes = [];
            game.indicatorAxes = 0;
            game.boxShapeHandles = zeros(1,2);
            game.buttonAxes = [];
            game.buttonSetHandle = [];
            game.buttonHandles = [];
            game.machineSubmitButtonHandle = [];
            game.nextButtonHandle = [];
            game.machinePosition = [];
            game.machineShapes = repmat(MachineConstants.NOSHAPE, 1, MachineConstants.nBoxes);
            
            
            game.chipColors = chipColors;
            game.symbols = symbols;
            game.rewards = rewards;
            game.rewardMatrix = rewardMatrix;
            game.displayShapes = displayShapes;
            
            game.keyHandles = [];
            game.keyRecordBoxAxes = [];
            game.outcomes = outcomes;
            
            game.nRounds = nRounds;
            game.currRound = 1;
            game.endRoundFlag = 0;
            
            game.judgments = zeros(game.nRounds, 2);
            
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
            
            boxW = w/3;                    % Relative sizes of machine elements
            spaceW = boxW/3;
            boxH = h*(2/3);
            spaceH = h*(1/6);            
                        
            box1pos = [l+spaceW b+spaceH boxW boxH];
            box2pos = [l+2*spaceW+boxW b+spaceH boxW boxH];
            box3pos = [l+4*spaceW+2*boxW b+spaceH boxW boxH];
            
            % Machine box
            g.boxAxes(1) = axes('position', box1pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
            axis off;
            % Player box
            g.boxAxes(2) = axes('position', box2pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                 'linewidth', MachineConstants.playerBoxEdgeWidth, ...,
                 'edgecolor', MachineConstants.playerBoxEdgeColor);
            axis off;
            % Indicator box
            g.indicatorAxes = axes('position', box3pos);
            fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor, ...
                'edgecolor', MachineConstants.indicatorEdgeColor);
            axis off;

        end


        % Add a square shape to the specified box
        % if playerBox = 1, this is a player box
        function addSquare(g, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            
			imshow(g.symbols{1},'XData',[0 1],'YData',[0 1]);
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
        function addTriangle(g, boxAxes, playerBox)
            % Switch to axes where the square will be added
            axes(boxAxes);
            
			imshow(g.symbols{2},'XData',[0 1],'YData',[0 1]);
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

        
        % Add the indicator light to the indicator box
        function addIndicator(g)
            % Switch to axes where the square will be added
            %axes(g.boxAxes(MachineConstants.INDICATORBOX));
            axes(g.indicatorAxes);
            
            % Draw the box outline
            fill([0 0 1 1], [0 1 1 0], g.computeIndicatorColor()); % MachineConstants.machineSquareColor);
            axis off;
            
        end
        
        % Returns a string formatted reward for the given machine and player shapes
        function r = computeReward(g, mShape, pShape)
        
        	r = sprintf('$%d',g.rewardMatrix(mShape,pShape));
        end
        
        function addRewardMessage(g, position)
        	% Switch to the main figure axes
        	axes(g.axesHandle);
        	
        	rewardValue = g.computeReward(g.machineShapes(MachineConstants.MACHINEBOX), ...
        					g.machineShapes(MachineConstants.PLAYERBOX));
        	
        	g.rewardMessageHandle =  uicontrol('style','text','units', ...
        			'normalized','position',position, ...
                    'string',rewardValue,'backgroundcolor','w',...
                    'foregroundcolor','g',...
                    'horizontalalignment','left', ...
                    'fontsize', 100);
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
            buttonW = 1/3;
            spaceW = buttonW/4;
            buttonH = 4/5;
            spaceH = 1/6;
            
            hold on;
            % Add the square
			imshow(g.symbols{1},'XData',[0 0.4],'YData',[0.5 0.9]);
			%axis image;

            % Add the triangle
			imshow(g.symbols{2},'XData',[0.55 0.95],'YData',[0.5 0.9]);
			%axis image;
			
            hold off;
            
            % Add the radio buttons
            g.buttonSetHandle = uibuttongroup('Position',[position(1) position(2)-1.5*spaceH*position(4) position(3) spaceH*1.5*position(4)], ...
                              'bordertype','none','backgroundcolor','w');
            % Create three radio buttons in the button group.
            g.buttonHandles(MachineConstants.SQUARE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[spaceW+0.35*buttonW 0 buttonW 1],'parent',g.buttonSetHandle, ...
                'HandleVisibility','off','enable','off');
            g.buttonHandles(MachineConstants.TRIANGLE) = uicontrol('Style','Radio',...
                'units','normalized','pos',[2*spaceW+1.65*buttonW 0 buttonW 1],'parent',g.buttonSetHandle, ...
                'HandleVisibility','off','enable','off');
                
            axis image;
            
            % Initialize some button group properties. 
            set(g.buttonSetHandle,'SelectionChangeFcn',@g.pickShape);
            set(g.buttonSetHandle,'SelectedObject',[]);  % No selection

            % Add the submit button
            submitButtonPos = ...
            	[position(1)+1.1*position(3) position(2)+0.25*position(4) ...
                 1.5*buttonW*position(3) 0.5*buttonH*position(4)];
            g.machineSubmitButtonHandle = uicontrol('units','normalized', ...
            							  'position', submitButtonPos, ...
                                           'enable', 'off', ...
                                           'string', 'Submit', 'callback', @g.playerSubmit);
                                           
            % Add the next button
            nextButtonPos = submitButtonPos;
            nextButtonPos(1) = submitButtonPos(1)+1.3*submitButtonPos(3);
            g.nextButtonHandle = uicontrol('units','normalized', ...
            							   'position', nextButtonPos, ...
                                           'enable', 'off', ...
                                           'string', 'Next', 'callback', @g.pressNext);

        end
        
        
        % Add the indicator light key
        % This consists of a column of "mini-machines" that indicate the four possible
        % outcomes graphically
        function addIndicatorKey(g, basePosition, outcomes, rewards)
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
                g.keyHandles(i) = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineColor);
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
                        g.addSquare(ba1, 0);
                    case MachineConstants.TRIANGLE
                        g.addTriangle(ba1, 0);
                    otherwise
                        % error
                end
                axis off;
                ba2 = axes('position', box2pos);
                fill([0 0 1 1], [0 1 1 0], MachineConstants.machineSquareColor);
                switch outcomes{i}{2}
                    case MachineConstants.SQUARE
                        g.addSquare(ba2, 1);
                    case MachineConstants.TRIANGLE
                        g.addTriangle(ba2, 1);
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
                %arrow fixlimits;
                axis off;
               
                % Add the reward amount
                rewardPos = [pos(1)+2*pos(3) pos(2) 0.05 0.05];
                uicontrol('style','text','units','normalized','position',rewardPos, ...
                    'string',rewards{i},'backgroundcolor','w',...
                    'horizontalalignment','left', ...
                    'fontsize',g.outcomeKeyFontSize);
                
            end
            
            
            % Finally, label the key
            keyPosition = [basePosition(1) basePosition(2)+0.1 0.1 0.03];
            uicontrol('style','text','units','normalized','position',keyPosition, ...
                    'string','Outcome Key','backgroundcolor','y',...
                    'horizontalalignment','center', ...
                    'fontsize',g.outcomeKeyFontSize);
                    
            keyPosition = [basePosition(1)+0.11 basePosition(2)+0.1 0.1 0.03];
            uicontrol('style','text','units','normalized','position',keyPosition, ...
                    'string','Chip Value','backgroundcolor','c',...
                    'horizontalalignment','center', ...
                    'fontsize',g.outcomeKeyFontSize);
                    
            % And add a separator between key and instructions
            axes(g.axesHandle);
            x1 = basePosition(1)+8*spaceW+6*boxW;
            y1 = basePosition(2)-3*(miniH+spaceH);
            x2 = x1;
            y2 = basePosition(2)+0.1+0.03;
            line([x1 x2], [y1 y2], 'color', 'k');
            axis([0 1 0 1]);

            
        end
            
        
        % Add instructions for the appropriate machine
        function addInstructions(g, position)
            switch g.machineVersion
                case MachineConstants.RANDOMMACHINE
                    t = {'The machine on this cruise ship is a Random Machine.','','A Random Machine first randomly picks one of two pictures for the first box. Then you get to pick a picture for the second box. After you submit, a colored chip is dispensed. The color of the chip is based on the two pictures in the boxes, as shown in the key on the left.', '', 'The key also shows which colored chip is the $1000 chip, which is the $5 chip, and so on, on this cruise ship.','','Go ahead and try the game yourself.'};
                case MachineConstants.COPYMACHINE
                    t = {'The machine on this cruise ship is a Copy Machine.','','A Copy Machine copies whatever picture you pick into the two boxes. After you submit, a colored chip is dispensed. The color of the chip is based on the two pictures in the boxes, as shown in the key on the left.', '', 'The key also shows which colored chip is the $1000 chip, which is the $5 chip, and so on, on this cruise ship.','','Go ahead and try the game yourself.'};
                otherwise
                    % error
            end
            uicontrol('style','text','units','normalized','position',position, ...
                    'string',t,'backgroundcolor','y',...
                    'horizontalalignment','left', ...
                    'fontsize',14);
        end
            
                
       
        % Put the selected shape into the user box
        function pickShape(g, src, data)
        
            switch data.NewValue
                case g.buttonHandles(MachineConstants.SQUARE)
                    g.addSquare(g.boxAxes(MachineConstants.PLAYERBOX), 1);
                    g.machineShapes(MachineConstants.PLAYERBOX) = MachineConstants.SQUARE;
                    %g.judgments(g.currRound) = MachineConstants.SQUARE;
                case g.buttonHandles(MachineConstants.TRIANGLE)
                    g.addTriangle(g.boxAxes(MachineConstants.PLAYERBOX), 1);
                    g.machineShapes(MachineConstants.PLAYERBOX) = MachineConstants.TRIANGLE;
                    %g.judgments(g.currRound) = MachineConstants.TRIANGLE;
                otherwise
                    % error
            end
            
            if (g.machineVersion == MachineConstants.COPYMACHINE)
                switch data.NewValue
                    case g.buttonHandles(MachineConstants.SQUARE)
                        g.addSquare(g.boxAxes(MachineConstants.MACHINEBOX), 0);
                        g.machineShapes(MachineConstants.MACHINEBOX) = MachineConstants.SQUARE;
                        %g.judgments(g.currRound) = MachineConstants.SQUARE;
                    case g.buttonHandles(MachineConstants.TRIANGLE)
                        g.addTriangle(g.boxAxes(MachineConstants.MACHINEBOX), 0);
                        g.machineShapes(MachineConstants.MACHINEBOX) = MachineConstants.TRIANGLE;
                        %g.judgments(g.currRound) = MachineConstants.TRIANGLE;
                    otherwise
                        % error
                end
            end
        end
        
        % Reset the specified machine box
        function resetBox(g, boxIndex)
            % Switch to axes of the box to reset
            axes(g.boxAxes(boxIndex));
            
            % Now fill it with a "shutter"
            shutter = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineShutterColor); 
            axis off;
            % Clear the handle to the shape object
            g.boxShapeHandles(boxIndex) = 0;
        end
        
        % Reset the indicator light
        function resetIndicator(g)
            % Switch to indicator axes
            axes(g.indicatorAxes);
            
            % Now fill it with a "shutter"
            shutter = fill([0 0 1 1], [0 1 1 0], MachineConstants.machineShutterColor, ...
                            'edgecolor', MachineConstants.indicatorEdgeColor); 
            axis off;
        end
        
        % Run the machine by clearing the shapes currently in the boxes
        % and then randomly selecting two new shapes to fill them
        function runMachine(g)
            % Clear the machine buttons
            set(g.buttonSetHandle,'SelectedObject',[]);
            
            % Clear all the boxes
            g.clearBox(MachineConstants.PLAYERBOX);
            g.resetBox(MachineConstants.MACHINEBOX);
            g.resetIndicator();


            % Pause for a moment while machine "runs"
            pause(0.5);

            g.machineShapes = repmat(MachineConstants.NOSHAPE, 1, MachineConstants.nBoxes);
            % If this is the Random Machine, sample a shape for the first box
            if (g.machineVersion == MachineConstants.RANDOMMACHINE)
                %g.machineShapes(MachineConstants.MACHINEBOX) = randi(2,[1 1]);
                g.machineShapes(MachineConstants.MACHINEBOX) = ...
                	g.displayShapes(g.currRound);
            
                % And draw it on the screen
                switch g.machineShapes(MachineConstants.MACHINEBOX)
                    case MachineConstants.SQUARE
                        g.addSquare(g.boxAxes(MachineConstants.MACHINEBOX), 0);
                    case MachineConstants.TRIANGLE
                        g.addTriangle(g.boxAxes(MachineConstants.MACHINEBOX), 0);
                    otherwise
                        % error
                end
            end
        end
        
        % Handle a player's response
        function playerSubmit(g, h, value)
            % We can ignore the value because it is binary and this function
            % is only called when the submit button is pushed
            
            % Temporarily disable the submit button and the radio buttons
            set(g.machineSubmitButtonHandle, 'enable', 'off');
            set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'off');
            set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'off');
            
            % If this is the Random Machine, first check that the machine has been run
            % (i.e. that there is a shape in Box 1)
            if (g.machineVersion == MachineConstants.RANDOMMACHINE && ...
                g.machineShapes(MachineConstants.MACHINEBOX) == MachineConstants.NOSHAPE)
                errordlg('The machine hasn''t started yet','Whoops');
                set(g.machineSubmitButtonHandle, 'enable', 'on');
				set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'on');
				set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'on');
            % If this is the Copy Machine, check that machine hasn't been run
            % (i.e. that there are no shapes in Box 2)
            elseif (g.machineShapes(MachineConstants.PLAYERBOX) == MachineConstants.NOSHAPE)
                % Print an error message
                errordlg('You must pick a shape first.','Whoops');
                set(g.machineSubmitButtonHandle, 'enable', 'on');
				set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'on');
				set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'on');
            elseif (g.machineVersion == MachineConstants.COPYMACHINE && ...
                    g.machineShapes(MachineConstants.MACHINEBOX) == MachineConstants.NOSHAPE)
                errordlg('Something went wrong: Machine not wired up correctly','Whoops');
                set(g.machineSubmitButtonHandle, 'enable', 'on');
				set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'on');
				set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'on');
            % Then check if player chose a response
            else
                % Complete the round
                if (g.endRoundFlag == 1)
                    errordlg('You already picked a shape.','Whoops');
                else
                	% Record the round
                	g.judgments(g.currRound,:) = g.machineShapes;
                
                    % Set the end round flag
                    g.endRoundFlag = 1;
                    
                    % Set the indicator color
                    g.addIndicator();
                    
                    % Show the reward
                    g.addRewardMessage(MachineConstants.defaultRewardMessagePosition);
                    
                    % Enable the Next button
                    set(g.nextButtonHandle, 'enable', 'on');
%                     
%                     % Wait for a bit
%                     pause(MachineConstants.operationDelay);
%                     
%                     
%                     % Keep playing if more rounds remain
%                     if (g.currRound < g.nRounds)
%                         g.currRound = g.currRound + 1;
%                         % Clear the end round flag
%                         g.endRoundFlag = 0;
%                         % Start the next round
%                         g.playRound();
%                     else
%                         % Otherwise, end the series of rounds and signal the calling Block
%                         g.endPlay();
%                     end
                end
            end
        end
        
        
        % Do the next thing: either play next round or end play
        function pressNext(g, h, value)                    
			% Keep playing if more rounds remain
			if (g.currRound < g.nRounds)
				g.currRound = g.currRound + 1;
				% Clear the end round flag
				g.endRoundFlag = 0;
				% Disable the next button
				set(g.nextButtonHandle, 'enable', 'off');
				% Start the next round
				g.playRound();
			else
				% Otherwise, end the series of rounds and signal the calling Block
				g.endPlay();
			end
        end
                
        
        % Play one complete round
        function playRound(g)
            % First, disable the buttons until the machine is finished running
            set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'off');
            set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'off');
            %set(g.buttonHandles(MachineConstants.CIRCLE), 'enable', 'off');
            set(g.machineSubmitButtonHandle, 'enable', 'off');
            
            % Run the machine
            g.runMachine();
            
            % Enable the submit button and wait for a player response ...
            set(g.buttonHandles(MachineConstants.SQUARE), 'enable', 'on');
            set(g.buttonHandles(MachineConstants.TRIANGLE), 'enable', 'on');
            %set(g.buttonHandles(MachineConstants.CIRCLE), 'enable', 'on');
            set(g.machineSubmitButtonHandle, 'enable', 'on');
        end
  
        % End the game and signal the calling Block
        function endPlay(g)
            % Clear the figure
            g.clearAxes();
            % Set the data
            g.data = g.judgments;
            g.hasData = 1;
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
            g.addIndicatorKey(g.defaultKeyPosition, g.outcomes, g.rewards);
            g.addInstructions(g.defaultInstructionPosition);
        
            game.currRound = 1;
            % Start the first round
            g.playRound(); % Move the player card on the first round
        end
        
            
    end
    
% --------------------------------------------------------------------------------------
%    
    methods (Access = private)

        % Assign an indicator color, based on the machine shapes
        function color = computeIndicatorColor(g)
            color = MachineConstants.BLACK;
            
            if (g.machineShapes(MachineConstants.MACHINEBOX) == MachineConstants.SQUARE && ...
                g.machineShapes(MachineConstants.PLAYERBOX) == MachineConstants.SQUARE)
                color = g.chipColors{1};
            elseif (g.machineShapes(MachineConstants.MACHINEBOX) == MachineConstants.SQUARE && ...
                g.machineShapes(MachineConstants.PLAYERBOX) == MachineConstants.TRIANGLE)
                color = g.chipColors{2};
            elseif (g.machineShapes(MachineConstants.MACHINEBOX) == MachineConstants.TRIANGLE && ...
                g.machineShapes(MachineConstants.PLAYERBOX) == MachineConstants.SQUARE)
                color = g.chipColors{3};
            elseif (g.machineShapes(MachineConstants.MACHINEBOX) == MachineConstants.TRIANGLE && ...
                g.machineShapes(MachineConstants.PLAYERBOX) == MachineConstants.TRIANGLE)
                color = g.chipColors{4};
            else
                % error
            end
        end

    end

end

        
            
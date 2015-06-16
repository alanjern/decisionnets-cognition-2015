% %------------------------------------------------------------------
% InstructionScreen class
%
% Show a screen of instructions with a next screen button
%------------------------------------------------------------------

classdef InstructionScreen < Screen
    properties (Constant)
        defaultButtonPosition = [.7 .2 .06 .04];      % Position of next screen button
        defaultTextPosition = [.2 .3 .45 .5];        % Position of instructions
        instructionFontSize = 24;               % Size of instructions
    end
    
    properties
        instructionText;            % Instructions to display
    end
    
    methods
        % Constructor
        function is = InstructionScreen(figureHandle, instructionText)
            is = is@Screen(figureHandle);
            is.instructionText = instructionText;
        end
        
        function a = initAxes(is)
            % Add an invisible set of axes that span the full figure
            figure(is.figureHandle);
	        is = axes('position', [0 0 1 1]);
	        set(a, 'xtick', [], 'ytick', [], 'Color', 'none');
        end
        
        function clearAxes(is)
            clf(is.figureHandle);
            drawnow;
        end
        
        % Add the next screen button
        function addButton(is,position)
            uicontrol('units','normalized','position',position,...
                      'string','Continue','callback',@is.nextScreen);
        end
        
        % Callback after button is pushed
        function nextScreen(is, src, data)
            % Clear the screen
            is.clearAxes();
            % Trigger the EndScreen event
            notify(is,'EndScreen');
        end
        
        % Add the instructions
        function addInstructions(is,position)
            uicontrol('style','text','units','normalized','position',position, ...
                      'string',is.instructionText,'backgroundcolor','w',...
                      'horizontalalignment','left', ...
                        'fontsize',is.instructionFontSize);
        end
        
        % Show the instructions
        function show(is)
            is.addButton(is.defaultButtonPosition);
            is.addInstructions(is.defaultTextPosition);
        end
    end
end
            
            
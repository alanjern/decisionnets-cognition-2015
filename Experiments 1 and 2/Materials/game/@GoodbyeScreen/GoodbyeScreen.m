% %------------------------------------------------------------------
% GoodbyeScreen class
%
% Show a screen of instructions with a next screen button
%------------------------------------------------------------------

classdef GoodbyeScreen < Screen
    properties (Constant)
        defaultTextPosition = [.2 .3 .45 .5];        % Position of instructions
        instructionFontSize = 24;               % Size of instructions
    end
    
    properties
        instructionText;            % Instructions to display
    end
    
    methods
        % Constructor
        function is = GoodbyeScreen(figureHandle, instructionText)
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
        
        % Add the instructions
        function addInstructions(is,position)
            uicontrol('style','text','units','normalized','position',position, ...
                      'string',is.instructionText,'backgroundcolor','w',...
                      'horizontalalignment','left', ...
                        'fontsize',is.instructionFontSize);
        end
        
        % Show the instructions
        function show(is)
            is.addInstructions(is.defaultTextPosition);
            % Trigger the EndScreen event
            notify(is,'EndScreen');
        end
    end
end
            
            
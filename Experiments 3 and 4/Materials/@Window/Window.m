%------------------------------------------------------------------
% Window class
%
% This class contains information about a window (figure) in which
% an experiment can be displayed.
%
%------------------------------------------------------------------

classdef Window
    properties
        figureHandle;            % A handle to the the figure
        %axesHandle;              % A handle to the axes that fill the figure
        windowSize;              % Dimensions of the window
    end
    
    methods
        % Constructor
        % wSize = [left, bottom, width, height]
        function w = Window(wSize, color)
            % Default is full screen with white background
            if (nargin < 1)
                screenSize = get(0, 'screensize');
                w.windowSize = screenSize;
                % Fit comfortably within screen
                % Squash a bit vertically and shift up to
                % leave some space at the bottom of the screen
                w.windowSize(4) = 0.98*screenSize(4);
                w.windowSize(2) = 0.02*screenSize(4);
                
                color = 'w';
            else
                w.windowSize = wSize;
            end
            
            % Create the blank figure with the specified background color
            w.figureHandle = figure();
            set(w.figureHandle, 'Resize', 'on', 'menubar', 'none', 'units', get(0, 'units'), ...
	               'Position', w.windowSize, 'Color', color);
	        set(w.figureHandle, 'units', 'normalized');
%	               
%	        % Add an invisible set of axes that span the full figure
%	        w.axesHandle = axes('position', [0 0 1 1]);
%	        %axis(w.axesHandle, [0 1 0 1]);
%            set(w.axesHandle, 'xtick', [], 'ytick', [], 'Color', 'none');
%                
        end
    end
end

        
            
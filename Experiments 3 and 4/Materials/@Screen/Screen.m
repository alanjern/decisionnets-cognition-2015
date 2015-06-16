%------------------------------------------------------------------
% Screen class
%
% This class contains information about a single screen. This might
% include a single trial or a page of instructions. Classes that
% inherit the screen class must implement the show() function that
% contains everything that happens on this screen.
%
% This class must also send trigger an EndScreen event when the
% screen is done to signal to the block manager to show the next
% screen.
%
%------------------------------------------------------------------

classdef Screen < handle
    properties
        figureHandle;            % A handle to the the figure this screen is drawing in
        axesHandle;              % A handle to the axes this screen is drawing in
        
        hasData;                 % Set to true if this screen has data to return
        data;                    % The data to return
    end
    events
        EndScreen;
    end
    methods
        % Constructor
        % axesHandle argument is optional
        function s = Screen(figureHandle, axesHandle)
            if (nargin > 1)
                s.axesHandle = axesHandle;
            else
                s.axesHandle = [];
            end
            s.figureHandle = figureHandle;
            
            s.hasData = 0;
            s.data = [];
        end
    end
    
    methods (Abstract = true)
        % This function controls the action of the screen and must
        % eventually trigger an EndScreen event to the calling Block
        show(s);
        
        % This function initializes the axes of the screen and should
        % probably be called in the subclass's constructor or when the
        % Screen is activated
        initAxes(s);
        
        % This function clears the screen and should probably be called
        % just before the end of the screen
        clearAxes(s);
        
    end
end

        
            
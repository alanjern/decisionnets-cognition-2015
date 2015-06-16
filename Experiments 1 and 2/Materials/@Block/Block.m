%------------------------------------------------------------------
% Block class
%
% This class contains information about an experiment block.
% A block consists of a series of screens. Therefore, it might
% be a sequence of trials or it might be a series of instructions.
%
%------------------------------------------------------------------

classdef Block < handle
    properties
        nScreens;               % Total number of screens
        currScreen;             % Index of the current screen
        screens;                % A cell array of Screens
        screenListener;         % A listener for EndScreen events
        data;                   % Data collected from the current block
    end
    events
        EndBlock
    end
    methods
        % Constructor
        function b = Block(screens)
            % Check that there is at least one screen
            if (length(screens) < 1)
                err = MException('Block:BadInput', 'A Block must contain at least one screen');
                throw(err);
            else
                b.nScreens = length(screens);
                b.screens = screens;
                b.currScreen = 1;
            end
            b.data = []; 
            % b.data = Data(); % initialize an empty data object
        end
        
        % Execute the block: show the sequence of screens.
        function executeBlock(b)
            % Show the first screen
            % Listen for an endScreen event to show the next one
            s = b.screens{b.currScreen};
            b.screenListener = addlistener(s, 'EndScreen', @b.wrapUpScreen);
            s.show();
        end
        
        % Wrap up a screen
        % Right now this just goes to the next screen, but might want to
        % include a 'cleanup' operation (e.g. clear screen) here.
        function wrapUpScreen(b,s,event)
            % Delete the listener
            delete(b.screenListener);
            % Record the data if there is any
            if (s.hasData)
                b.data{b.currScreen} = s.data;
            end
            % Start the next screen if there is one
            if (b.currScreen < b.nScreens)
                b.nextScreen();
            % Otherwise, end the block
            else
                b.endBlock();
            end
        end
        
        % Return the data collected from this block
        function d = getData(b)
            d = b.data;
        end
    end
    
    methods (Access = 'protected')
    
        % Show the next screen
        function nextScreen(b)
            b.currScreen = b.currScreen + 1;
            s = b.screens{b.currScreen};
            % Add a new listener
            b.screenListener = addlistener(s, 'EndScreen', @b.wrapUpScreen);
            % Show the screen
            s.show();
        end
        
        % End the block
        function endBlock(b)
            % Trigger and EndBlock event
            notify(b,'EndBlock');
        end
    end
end

        
              
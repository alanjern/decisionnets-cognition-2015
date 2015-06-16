%------------------------------------------------------------------
% MyScreen class
%
%------------------------------------------------------------------

classdef MyScreen < Screen
    properties
        
    end
    
    methods
        % Constructor
        function ms = MyScreen(figureHandle, axesHandle)
            ms = ms@Screen(figureHandle, axesHandle);
        end
    end
    
    methods
        function show(ms)
            
            % add a block to a random part of the screen
            x0 = rand()
            y0 = rand()
            w = 0.1;
            h = 0.1;
            a = axes('position', [x0 y0 w h]);
            % Turn off the ticks and set background to white
            fill([0 0 1 1], [0 1 1 0], 'b');
            %set(a, 'xtick', [], 'ytick', [], 'Color', 'none');
            axis off;
            
            % end of screen
            notify(ms,'EndScreen');
        end
    end
end

        
            
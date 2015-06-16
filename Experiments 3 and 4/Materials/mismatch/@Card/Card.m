%------------------------------------------------------------------
% Card class
%
% This class contains information about a card in the shape mismatch
% game. The card might be a player card or a judge card.
%
%------------------------------------------------------------------

classdef Card < handle
    properties
        state;          % The state of the card (i.e. what it covers up)
        cardAxes;       % A handle to the card axes
        rectHandles;    % Handles the to rectangles that make up the card
        nRects;         % Number of rectangles
    end
    
    methods
        % Constructor
        function c = Card(state)
            c.state = state;
            c.cardAxes = [];
            c.rectHandles = [];
            c.nRects = 0;
        end
    
        % Add the player card
        function add(c, position, color)
            c.cardAxes = axes('position', position);
            axis off;
            axis([0 1 0 1]);
            
            boxW = 1/4;
            spaceW = boxW/4;
            boxH = 2/3;
            spaceH = 1/6;
            
            % Make the card
            if (c.state == CardStates.PC_NONE || c.state == CardStates.JC_NONE)
                return;
            end
            
            hold on;
            
            if (c.state == CardStates.PC_AB || c.state == CardStates.JC_AB)
                c.rectHandles(c.nRects+1) = ...
                    rectangle('position', [0 0 spaceW 1], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+2) = ...
                    rectangle('position', [0 0 2*spaceW+boxW spaceH], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+3) = ...
                    rectangle('position', [0 spaceH+boxH 2*spaceW+boxW spaceH], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+4) = ...
                    rectangle('position', [spaceW+boxW 0 spaceW 1], 'linestyle', 'none', 'facecolor', color);
                c.nRects = c.nRects+4;
            else
                c.rectHandles(c.nRects+1) = ...
                    rectangle('position', [0 0 spaceW+boxW 2*spaceH+boxH], 'linestyle', 'none', 'facecolor', color);
                c.nRects = c.nRects+1;
            end
            
            if (c.state == CardStates.PC_A || c.state == CardStates.PC_AB || ...
                c.state == CardStates.JC_A || c.state == CardStates.JC_AB)
                c.rectHandles(c.nRects+1) = ...
                    rectangle('position', [spaceW+boxW 0 spaceW 1], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+2) = ...
                    rectangle('position', [spaceW+boxW 0 2*spaceW+boxW spaceH], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+3) = ...
                    rectangle('position', [spaceW+boxW spaceH+boxH 2*spaceW+boxW spaceH], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+4) = ...
                    rectangle('position', [2*spaceW+2*boxW 0 spaceW 1], 'linestyle', 'none', 'facecolor', color);
                c.nRects = c.nRects+4;
            else
                c.rectHandles(c.nRects+1) = ...
                    rectangle('position', [spaceW+boxW 0 spaceW+boxW 2*spaceH+boxH], 'linestyle', 'none', 'facecolor', color);
                c.nRects = c.nRects + 1;
            end
            
            if (c.state == CardStates.PC_A || c.state == CardStates.PC_AB || c.state == CardStates.PC_P || ...
                c.state == CardStates.JC_A || c.state == CardStates.JC_AB || c.state == CardStates.JC_P)
                c.rectHandles(c.nRects+1) = ...
                    rectangle('position', [2*spaceW+2*boxW 0 spaceW 1], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+2) = ...
                    rectangle('position', [2*spaceW+2*boxW 0 2*spaceW+boxW spaceH], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+3) = ...
                    rectangle('position', [2*spaceW+2*boxW spaceH+boxH 2*spaceW+boxW spaceH], 'linestyle', 'none', 'facecolor', color);
                c.rectHandles(c.nRects+4) = ...
                    rectangle('position', [3*spaceW+3*boxW 0 spaceW 1], 'linestyle', 'none', 'facecolor', color);
                c.nRects = c.nRects+4;
            else
                c.rectHandles(c.nRects+1) = ...
                    rectangle('position', [2*spaceW+2*boxW 0 spaceW+boxW 2*spaceH+boxH], 'linestyle', 'none', 'facecolor', color);
                c.nRects = c.nRects+1;
            end
            
            hold off;    
        end
        
        % Hide the card without deleting it
        function hide(c)
            for r=1:c.nRects
                set(c.rectHandles(r),'visible','off');
            end
        end
        
        % Unhide the card
        function unhide(c)
            for r=1:c.nRects
                set(c.rectHandles(r),'visible','on');
            end
        end
            
        
        % Move the card to newPosition in nFrames steps
        function moveCard(c, newPosition, nFrames)
            % Get the current card position
            cardPosition = get(c.cardAxes, 'position');
            
            % Interpolate values between the card position and
            % machine position
            
            % X
            if (cardPosition(1) < newPosition(1))
                % Compute step size
                step = (newPosition(1) - cardPosition(1)) / (nFrames-1);
                dx = cardPosition(1):step:newPosition(1);
            elseif (cardPosition(1) > newPosition(1))
                step = (cardPosition(1) - newPosition(1)) / (nFrames-1);
                dx = fliplr(newPosition(1):step:cardPosition(1));
            else % cardPosition == machinePosition
                dx = repmat(cardPosition(1), 1, nFrames);
            end
            
            % Y
            if (cardPosition(2) < newPosition(2))
                % Compute step size
                step = (newPosition(2) - cardPosition(2)) / (nFrames-1);
                dy = cardPosition(2):step:newPosition(2);
            elseif (cardPosition(2) > newPosition(2))
                step = (cardPosition(2) - newPosition(2)) / (nFrames-1);
                dy = fliplr(newPosition(2):step:cardPosition(2));
            else % cardPosition == machinePosition
                dy = repmat(cardPosition(2), 1, nFrames);
            end
            
            % Animate!
            % Update the position of the card one frame at a time
            for f=1:nFrames
                nextPosition = [dx(f) dy(f) cardPosition(3) cardPosition(4)];
                set(c.cardAxes, 'position', nextPosition);
                drawnow;
            end
        end

    end
end

        
            
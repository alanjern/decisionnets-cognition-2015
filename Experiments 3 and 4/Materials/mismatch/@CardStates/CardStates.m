%------------------------------------------------------------------
% CardStates class
%
% This class acts as an enum that just contains constants defining
% the different card states.
%
%------------------------------------------------------------------

classdef (Sealed) CardStates

    properties (Constant)
        % Constants for the different states of the
        % player and judge cards.
        PC_NONE = 0;        % No player card
        PC_P = 1;           % Card only reveals player's response
        PC_A = 2;           % Card reveals slot A and player's response
        PC_AB = 3;           % Card reveals slots A and B and player's response
        
        JC_NONE = 4;        % No judges card
        JC_P = 5;           % Card only revals player's response
        JC_A = 6;           % Card reveals slot A and player's response
        JC_AB = 7;           % Card reveals slots A and B and player's response
    end
    
    methods (Access = private) % Cannot be instantiated
        function x = CardStates()
        end
    end
end

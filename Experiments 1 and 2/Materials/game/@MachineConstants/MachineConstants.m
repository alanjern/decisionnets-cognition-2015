%------------------------------------------------------------------
% MachineConstants class
%
% This class acts as an enum that just contains constants defining
% properties of the machine in the structure learning game
%
%------------------------------------------------------------------

classdef (Sealed) MachineConstants

    properties (Constant)
        % Constants for the different slot machine outcomes
        TRIANGLE = 1;         % Triangle
        SQUARE = 2;           % Sqaure
        CIRCLE = 3;           % Circle
        NOSHAPE = 4;          % No shape
        
        % Constants for the different payout shape colors
        RED = 'r';
        BLUE = 'b';
        YELLOW = 'y';
        MAGENTA = 'm';
        BLACK = 'k';
        
        % Versions of the machine
        RANDOMMACHINE = 1;    % Box 1 is random
        COPYMACHINE = 2;    % Boxes 1 and 2 are wired together
   
        % Color settings
        machineColor = [0.9 1 1];
        machineSquareColor = 'w';
        machineShutterColor = 'w'; % [0.5 0.5 0.5];
        squareColor = 'k';
        triangleColor = 'k';
        circleColor = 'm';
        
        % Machine appearance settings
        nBoxes = 2;                       % Number of boxes on machine
        MACHINEBOX = 1;                   % Position of the machine box
        PLAYERBOX = 2;                    % Position of the user box
        INDICATORBOX = 3;                 % Position of the indicator box that indicates the reward
        nOutcomes = 4;
        playerBoxEdgeWidth = 5;           % Appearance of user box
        playerBoxEdgeColor =  'c';
        defaultMachinePosition = [.3 .5 .22 .2]; %[.3 .45 .3 .2];    % Position of machine
        defaultRewardMessagePosition = [.65 .55 .2 .1];
        defaultButtonPosition = [.34 .35 .15 .1];    % Position of buttons
        operationDelay = 2;               % Number of seconds the machine waits before resetting
        bigMachineFontSize = 80;
        smallMachineFontSize = 30;
        font = 'Wingdings';
        
        indicatorEdgeColor = 'w';         % Appearance of indicator
        
        % Card appearance properties
        playerCardColor = [.6 .4 0];         % Card color
        judgeCardColor = [.5 .3 0];
        animationFrames = 20;          % Number of frames of animation when moving card; smaller = faster
    end
    
    methods (Access = private) % Cannot be instantiated
        function x = MachineConstants()
        end
    end
end

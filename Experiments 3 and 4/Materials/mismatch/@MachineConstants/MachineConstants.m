%------------------------------------------------------------------
% MachineConstants class
%
% This class acts as an enum that just contains constants defining
% properties of the machine in the shape mismatch game
%
%------------------------------------------------------------------

classdef (Sealed) MachineConstants

    properties (Constant)
        % Constants for the different slot machine outcomes
        TRIANGLE = 1;         % Triangle
        SQUARE = 2;           % Sqaure
        CIRCLE = 3;           % Circle
        NOSHAPE = 4;          % No shape
   
        % Color settings
        machineColor = [0.9 1 1];
        machineSquareColor = 'w';
        machineShutterColor = 'w'; % [0.5 0.5 0.5];
        squareColor = 'b';
        triangleColor = 'y';
        circleColor = 'm';
        
        % Machine appearance settings
        nBoxes = 3;                       % Number of boxes on machine
        PLAYERBOX = 3;                    % Position of the user box
        playerBoxEdgeWidth = 5;           % Appearance of user box
        playerBoxEdgeColor =  'c';
        defaultMachinePosition = [.3 .45 .3 .2];    % Position of machine
        defaultButtonPosition = [.34 .3 .15 .1];    % Position of buttons
        
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

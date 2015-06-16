%------------------------------------------------------------------
% Subject class
%
% This class stores basic information about a subject in an
% experiment.
%
% This is a bit of a stub for now.
%------------------------------------------------------------------

classdef Subject
    properties
        number ;                 % Subject number
        startTime;               % Experiment start time
        finishTime;              % Experiment finish time
        totalTime;               % Total time on experiment (in seconds)
    end
    
    methods
        % Constructor
        function s = Subject()
            % Set null values for all attributes
            s.number = [];        
            s.startTime = [];
            s.finishTime = [];
            s.totalTime = [];
        end
    end
end

        
            
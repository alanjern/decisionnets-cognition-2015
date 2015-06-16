%------------------------------------------------------------------
% JudgmentTypes class
%
% This class acts as an enum that just contains constants defining
% the different types of judgment questions
%
%------------------------------------------------------------------

classdef (Sealed) JudgmentTypes

    properties (Constant)
        % Constants for the different types of judgments
        INFORMATION = 1;           % Informational judgments
        UTILITY = 2;           % Utility questions
    end
    
    methods (Access = private) % Cannot be instantiated
        function x = JudgmentTypes()
        end
    end
end

%------------------------------------------------------------------
% ObservationTypes class
%
% This class acts as an enum that just contains constants defining
% the different types of observation trials during the judgment
% part of the experiment
%
%------------------------------------------------------------------

classdef (Sealed) ObservationTypes

    properties (Constant)
        % Constants for the different types of judgments
        CONSISTENT = 1;        % A consistent trial (all shapes mismatch)
        INCONSISTENT1 = 2;     % Player shape matches first machine shape
        INCONSISTENT2 = 3;     % Player shape matches second machine shape
    end
    
    methods (Access = private) % Cannot be instantiated
        function x = ObservationTypes()
        end
    end
end

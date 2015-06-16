%------------------------------------------------------------------
% DataCollection class
%
% This class is just a collection of data sets. It is most useful
% for storing data associated with different experiment Blocks.
%
%------------------------------------------------------------------

classdef DataCollection
    properties
        dataList;               % Cell array of Data objects
        nSets;                  % Number of data sets
    end
    
    methods
        % Constructor
        function dc = DataCollection(nDataSets)
            % Default constructor
            if (nargin == 0)
                % Create an empty cell array
                dc.dataList = cell(0);
                dc.nSets = 0;
            else
                % Constructor for a data collection of known size
                dc.dataList = cell(nDataSets,1);
                dc.nSets = nDataSets;
            end
        end
        
        % Add a data set to the end of the list.
        % This function is a partner to the default constructor
        % where the size of the collection is not known in advance.
        % Consequently, this function incrememnts the number of
        % data sets.
        function dcNew = add(dc, data)
            dcNew.nSets = dc.nSets + 1;
            dcNew.dataList = dc.dataList;
            dcNew.dataList{dcNew.nSets} = data;
        end
        
        % Add a data set to a specified place in the list.
        % This function is a partner to the constructor for a
        % collection of known size. Consequently, this function
        % does NOT increment the number of data sets.
        function dcNew = addAt(dc, setIndex, data)
            dcNew.dataList = dc.dataList;
            dcNew.dataList{setIndex} = data;
        end
    end
end

        
            
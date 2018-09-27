% INDEXOF returns the index of an inputted object in respect to a cell array
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function i = indexof(cellarray, object)

for i=1:numel(cellarray)
    if(cellarray{i}==object)
        return;
    end
end
i=-1; % failure
    
end
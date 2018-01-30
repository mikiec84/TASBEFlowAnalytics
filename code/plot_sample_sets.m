% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function plot_sample_sets(batch_description,results)

%fprintf('Outputting CSV data...\n');
    %sample_set_to_csv();
batch_size = size(batch_description,1);

fprintf('Outputting histograms');
% get/set should be replaced by push/pop of output settings
stemName = TASBEConfig.get('OS.StemName');
ERROR = [];
try
    for i=1:batch_size,
        condition_name = batch_description{i,1};
        TASBEConfig.set('OS.StemName', [stemName '-' condition_name]);
        sampleresults = results{i,2};
        plot_sample_histograms(sampleresults);
        fprintf('.');
    end
    fprintf('\n');
catch ERROR
end
TASBEConfig.set('OS.StemName', stemName);
if ~isempty(ERROR)
    rethrow(ERROR);
end

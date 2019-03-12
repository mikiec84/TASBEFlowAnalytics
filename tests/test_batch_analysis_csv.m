function test_suite = test_batch_analysis_csv
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_batch_analysis_csv_endtoend

CM = load_or_make_testing_colormodel();
stem1011 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox';
root1011 = '_PointCloud.csv';

% set up metadata
experimentName = 'LacI Transfer Curve';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
AP = AnalysisParameters(bins,{});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');

% Make a map of condition names to file sets
file_pairs = {...
  'Dox 0.1',    {[stem1011 '01' root1011]}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
  'Dox 0.2',    {[stem1011 '02' root1011]};
  'Dox 0.5',    {[stem1011 '05' root1011]};
  'Dox 1.0',    {[stem1011 '1' root1011]};
  'Dox 2.0',    {[stem1011 '2' root1011]};
  'Dox 5.0',    {[stem1011 '5' root1011]};
  'Dox 10.0',   {[stem1011 '10' root1011]};
  'Dox 20.0',   {[stem1011 '20' root1011]};
  'Dox 50.0',   {[stem1011 '50' root1011]};
  'Dox 100.0',  {[stem1011 '100' root1011]};
  'Dox 200.0',  {[stem1011 '200' root1011]};
  'Dox 500.0',  {[stem1011 '500' root1011]};
  'Dox 1000.0', {[stem1011 '1000' root1011]};
  'Dox 2000.0', {[stem1011 '2000' root1011]};
  };

n_conditions = size(file_pairs,1);

% Execute the actual analysis
TASBEConfig.set('OutputSettings.StemName','LacI-CAGop');
TASBEConfig.set('plots.plotPath','/tmp/plots');
TASBEConfig.set('OutputSettings.FixedInputAxis',[1e4 1e10]);
% Set CSVReaderHeader (temporary feature)
TASBEConfig.set('flow.defaultCSVReadHeader','LacI-CAGop.json');
% Make point cloud files
TASBEConfig.set('flow.outputPointCloud','true');
TASBEConfig.set('flow.pointCloudPath','/tmp/CSV/');
[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'EBFP2','EYFP','mKate'},AP);

% Make output plots
plot_batch_histograms(results,sampleresults,CM,{'b','g','r'});

save('/tmp/LacI-CAGop-batch.mat','AP','bins','file_pairs','results','sampleresults');

% Check the first five rows of the first point cloud file
% expected_pointCloud = [...
%     42801.34    40500.46    33567.67
%     2456.10     42822.39    1039.11
%     70903.34    68176.25    20623.25
%     2830130.69  17561178.05   1039.11
%     8742.07     2238.27     1039.11
%     ];

expected_pointCloud = [...
    42471.29    40352.2    37366.76
    2452.02     42665.24    1156.15
    70346.12    67919.83    22964.29
    2807178.51  17492541.02   1156.15
    8687.51     2229.52     1156.15
    ];

% The first point cloud file: /tmp/CSV/LacI-CAGop_Dox01_PointCloud.csv
firstPointCloudFile = '/tmp/CSV/LacI-CAGop_Dox01_PointCloud.csv';

% Read the point cloud into matlab tables
if (is_octave)
    cloudTable = csv2cell(firstPointCloudFile);
    cloudCell = cloudTable(2:end,:);
else
  cloudTable = readtable(firstPointCloudFile);
  cloudCell = table2cell(cloudTable);
end

% Split the cloud table
points = cloudCell(1:5,:);

% spot-check first five rows of binCounts
assertElementsAlmostEqual(cell2mat(points), expected_pointCloud, 'relative', 1e-2);

% Compare JSON headers (esp channel struct)
real_header = 'LacI-CAGop.json';
test_header = '/tmp/CSV/LacI-CAGop.json';

fid1 = fopen(real_header); 
raw1 = fread(fid1,inf); 
string1 = char(raw1'); 
fclose(fid1); 
real = loadjson(string1);
real_channels = real.channels;
real_channel = real_channels{1};

fid2 = fopen(test_header); 
raw2 = fread(fid2,inf); 
string2 = char(raw2'); 
fclose(fid2); 
test = loadjson(string2);
test_channels = test.channels;
test_channel = test_channels{1};

assertEqual(numel(real_channels), numel(test_channels));
assertEqual(real_channel.name, test_channel.name);
assertEqual(real_channel.print_name, test_channel.print_name);
assertEqual(real_channel.unit, test_channel.unit);

end
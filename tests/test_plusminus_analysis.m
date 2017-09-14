function test_suite = test_plusminus_analysis
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_plusminus_analysis_endtoend

load('../TASBEFlowAnalytics-Tutorial/template_colormodel/CM120312.mat');


% set up metadata
experimentName = 'LacI Transfer Curve';
device_name = 'LacI-CAGop';
inducer_name = '100xDox';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] MEFL, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
input = channel_named(CM, 'EBFP2');
output = channel_named(CM, 'EYFP');
constitutive = channel_named(CM, 'mKate');
AP = AnalysisParameters(bins,{'input',input; 'output',output; 'constitutive' constitutive});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');

% Make a map of the batches of plus/minus comparisons to test
% This analysis supports two variables: a +/- variable and a "tuning" variable
stem1011 = '../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';
batch_description = {...
 {'Lows';'BaseDox';
  % First set is the matching "plus" conditions
  {0.1,  {[stem1011 'B9_B09_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
   0.2,  {[stem1011 'B10_B10_P3.fcs']}};
  % Second set is the matching "minus" conditions 
  {0.1,  {[stem1011 'B3_B03_P3.fcs']};
   0.2,  {[stem1011 'B4_B04_P3.fcs']}}};
 {'Highs';'BaseDox';
  {10,   {[stem1011 'C3_C03_P3.fcs']};
   20,   {[stem1011 'C4_C04_P3.fcs']}};
  {10,   {[stem1011 'B9_B09_P3.fcs']};
   20,   {[stem1011 'B10_B10_P3.fcs']}}};
 };

% Execute the actual analysis
OSbin = OutputSettings('',device_name,'','/tmp/plots/');
results = process_plusminus_batch( CM, batch_description, AP, OSbin);

% Make additional output plots
for i=1:numel(results)
    OS = OutputSettings(batch_description{i}{1},device_name,'','/tmp/plots/');
    OS.PlotTickMarks = 1;
    plot_plusminus_comparison(results{i},OS)
end

save('-V7','/tmp/LacI-CAGop-plus-minus.mat','batch_description','AP','results');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in results:

expected_ratios1 = [...
    0.9703    1.0099    0.9604    0.9722    0.9359    0.9679    1.0177    ...
    1.0083    0.9675    1.0050    0.9423    1.0312    0.9417    0.9768    ...
    0.9417    0.9044    1.0601    0.9296    0.9193    0.9737    1.0260    ...
    0.9831    0.9670    1.0218    1.0087    1.0295    1.0014    0.9998    ...
    1.0122    0.9909    0.9744    1.0635    0.9223    0.9971    1.0246    ...
    0.9027    1.0512    0.8515    0.8538       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN;
    0.8953    0.9746    0.8948    0.9471    1.0188    0.9822    1.0057    ...
    0.9749    0.9391    0.9675    0.9057    0.9005    0.9873    1.0269    ...
    0.9367    1.0088    0.9284    0.8360    0.9268    0.9916    0.9157    ...
    0.9587    0.9869    0.9430    0.9397    0.9336    0.9287    0.9507    ...
    0.9031    0.9122    0.8376    0.9243    0.8898    0.7727    0.8641    ...
    0.8246    0.8080    0.8401    0.6543    0.6727       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN]';

expected_InSNR1 = [...
  -38.4867  -46.7731  -35.5302  -39.1779  -55.0857  -40.6221  -48.9905    ...
  -34.9919  -39.5790  -35.4469  -61.7799  -44.4814  -43.4279  -37.7208    ...
  -35.5624  -39.8118  -42.7565  -56.6078  -39.7806  -34.6803  -38.0924    ...
  -35.3169  -38.0582  -60.3043  -47.4826  -34.6696  -31.7850  -28.7535    ...
  -23.7945  -21.7045  -21.3608  -18.1324  -17.6059  -16.3149  -15.7278    ...
  -13.5991  -13.4115  -10.8743   -9.6963       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN;
  -32.0887  -33.3616  -49.8738  -45.4783  -45.4899  -42.9094  -34.9467    ...
  -41.8559  -51.3976  -41.1789  -38.7564  -29.0290  -44.9261  -35.9305    ...
  -39.7765  -54.8425  -35.1435  -40.6337  -61.2315  -32.1843  -28.9194    ...
  -40.3561  -27.9151  -23.7359  -24.7296  -19.7681  -18.9716  -16.3981    ...
  -13.8112  -13.3603  -12.6749  -11.4734   -9.4093   -9.0514   -9.0620    ...
   -8.4075   -8.1013   -8.8451   -4.7220   -5.3573       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN]';

expected_OutSNR1 = [...
  -41.3183  -50.2429  -38.2845  -41.7744  -34.1039  -40.3652  -45.7040    ...
  -52.2658  -40.3087  -57.0695  -35.6331  -41.9971  -36.8299  -45.2937    ...
  -37.2859  -32.8181  -37.6122  -35.5721  -34.2859  -43.8896  -44.0104    ...
  -47.1029  -40.7640  -43.6501  -51.1173  -39.6137  -65.0618  -79.3785    ...
  -44.7766  -47.2209  -37.4857  -29.5938  -27.4533  -56.8501  -37.8766    ...
  -25.6679  -32.1429  -22.4133  -23.3224       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN;
  -30.0115  -41.7135  -29.6292  -35.8754  -45.2217  -45.4710  -55.3789    ...
  -42.5061  -34.7584  -40.5219  -31.2667  -31.4094  -50.3513  -44.2578    ...
  -36.5406  -54.0465  -35.5705  -27.8890  -35.1778  -54.0854  -33.5441    ...
  -39.2779  -48.9068  -35.0830  -33.6274  -32.2079  -31.0901  -33.3312    ...
  -26.8562  -27.1486  -20.5093  -27.7771  -24.3766  -17.7613  -22.5291    ...
  -20.8888  -19.8080  -21.6260  -14.7413  -15.6473       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN]';

expected_ratios2 = [...
    0.9799    0.8603    0.9429    0.9002    0.8812    0.8419    0.8800    ...
    0.8202    0.7711    0.7017    0.7147    0.5842    0.6314    0.5934    ...
    0.6218    0.6014    0.5043    0.4882    0.4597    0.3598    0.3504    ...
    0.3199    0.2944    0.2396    0.2121    0.1934    0.1670    0.1706    ...
    0.1462    0.1249    0.1059    0.0964    0.0962    0.0751    0.0747    ...
    0.0835    0.0619    0.0547    0.0467       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN;
    0.9233    0.9879    0.8883    0.9438    0.8910    0.8466    0.8693    ...
    0.7810    0.7649    0.7215    0.6672    0.6337    0.5535    0.5742    ...
    0.6300    0.4653    0.4909    0.4391    0.3832    0.3361    0.3213    ...
    0.2669    0.2164    0.2147    0.1594    0.1556    0.1482    0.1182    ...
    0.1075    0.0924    0.0854    0.0756    0.0669    0.0627    0.0559    ...
    0.0515    0.0499    0.0385    0.0344    0.0295       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN]';

expected_InSNR2 = [...
  -21.1963  -26.6158  -21.9132  -17.9879  -20.7113  -19.1883  -18.4196    ...
  -17.5827  -17.2595  -15.0926  -12.8794  -10.2726   -7.7029   -8.1563    ...
   -7.0867   -6.2762   -5.1976   -4.4213   -3.4581   -2.2058   -1.0764    ...
    0.1683    0.6326    1.7828    2.5460    2.9160    3.4571    4.0342    ...
    4.0739    4.1928    4.5810    4.6582    4.1726    4.2136    3.9673    ...
    3.4146    3.4899    3.3603    2.7653       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN;
  -15.7332  -17.1835  -18.0340  -15.6126  -16.6907  -16.9892  -16.5681    ...
  -16.0786  -14.9607  -12.8603  -11.9509   -7.6502   -7.0587   -6.1694    ...
   -5.2828   -5.1719   -3.8769   -2.6165   -1.6114   -0.8715   -0.0164    ...
    1.2600    1.8654    2.2796    2.9937    3.3029    3.5995    3.5366    ...
    3.5815    3.5823    3.5107    3.3301    3.0945    2.9210    2.4259    ...
    2.2931    1.8081    2.4635    0.7259    0.5654       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN]';


expected_OutSNR2 = [...
  -44.6323  -26.3303  -35.0358  -30.2119  -28.3760  -25.7600  -28.3810    ...
  -24.7304  -22.3462  -19.9816  -20.4532  -16.9184  -18.8989  -18.1167    ...
  -19.0414  -18.4768  -15.9837  -15.5140  -14.8935  -12.3281  -11.8676    ...
  -10.8600   -9.8896   -7.9691   -6.9989   -6.0140   -4.9065   -4.5600    ...
   -3.6367   -2.9373   -2.0766   -1.5435   -1.7254   -1.3128   -1.0775    ...
   -2.2127   -1.3952   -0.8402   -1.0512       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN;
  -32.6757  -48.2326  -28.6996  -35.2253  -29.3861  -26.0682  -27.5917    ...
  -22.6545  -22.1132  -20.4854  -18.9041  -18.4372  -16.6377  -17.4651    ...
  -19.2380  -14.8698  -15.6067  -14.4182  -13.0225  -11.7181  -11.2481    ...
   -9.5725   -7.9817   -7.5206   -5.5750   -5.0216   -4.5008   -3.0912    ...
   -2.6040   -1.9551   -1.1934   -1.0207   -0.6434   -0.8012   -0.5208    ...
   -0.6116   -0.5649   -0.4492   -0.8235   -0.9530       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN]';

assertEqual(numel(results),2);
assertElementsAlmostEqual(results{1}.MeanRatio, [0.9764; 0.8880],   'relative', 1e-2);
assertElementsAlmostEqual(results{1}.Ratios, expected_ratios1,      'relative', 1e-2);
assertElementsAlmostEqual(results{1}.InputSNR, expected_InSNR1,     'relative', 1e-2);
assertElementsAlmostEqual(results{1}.OutputSNR, expected_OutSNR1,   'relative', 1e-2);

assertElementsAlmostEqual(results{2}.MeanRatio, [0.2379; 0.1786],   'relative', 1e-2);
assertElementsAlmostEqual(results{2}.Ratios, expected_ratios2,      'relative', 1e-2);
assertElementsAlmostEqual(results{2}.InputSNR, expected_InSNR2,     'relative', 1e-2);
assertElementsAlmostEqual(results{2}.OutputSNR, expected_OutSNR2,   'relative', 1e-2);


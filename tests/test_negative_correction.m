% make a synthetic data set:
sigma = 100;
n_events = 1e6;
noise = randn(n_events,1)*sigma;
log_range = [0 5];
baseline = 10.^(log_range(1) + (rand(n_events,1)*(log_range(2)-log_range(1))));
% baseline = [10.^(log_range(1) + (rand(n_events/2,1)*(log_range(2)-log_range(1))));
%             10.^(log_range(1) + (rand(n_events/2,1)*(log_range(2)/2-log_range(1))))];
cumulative = baseline+noise;

figure;
hist(noise,1e2);

figure;
hist(log10(abs(noise)),1e2);

h = figure; hist(log10(baseline),1e2);
xlabel('log_{10} a.u.'); ylabel('Count'); title('Original Event Distribution');
outputfig(h,'nc-original','plots');

figure; hist(log10(cumulative(cumulative>0)),1e2);

h = figure; hist(cumulative(cumulative<800),1e2);
xlabel('a.u.'); ylabel('Count'); title('Events Plus Instrument Noise');
outputfig(h,'nc-error','plots');


[corrected,cum_prob] = negative_correction(cumulative,sigma);
h=figure; hist(log10(corrected),1e2);
xlabel('log_{10} a.u.'); ylabel('Count'); title('Corrected Event Distribution'); xlim([0 5]);
outputfig(h,'nc-corrected','plots');

% make sure the distribution is nicely flat
n = hist(log10(corrected),1e2);
assertElementsAlmostEqual(n,10000*ones(1,100),0.05,'relative');

%figure; hist(log10(corrected(corrected<1000)),1e2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Can we decide what an ideal corrective plot would be?
% First X% into first bin, etc...
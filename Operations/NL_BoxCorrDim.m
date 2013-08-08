% NL_BoxCorrDim
% 
% Uses TSTOOL code corrdim to estimate the correlation dimension of a time-delay
% embedded time series using a box-counting approach.
% 
% TSTOOL: http://www.physik3.gwdg.de/tstool/
% 
% INPUTS:
% y, column vector of time series data
% 
% nbins, maximum number of partitions per axis
% 
% embedparams [opt], embedding parameters as {tau,m} in 2-entry cell for a
%                   time-delay, tau, and embedding dimension, m. As inputs to BF_embed.
% 
% Output statistics are simple summaries of the outputs from this algorithm.
% 

function out = NL_BoxCorrDim(y,nbins,embedparams)
% Ben Fulcher, November 2009

doplot = 0; % plot outputs to a figure

%% Preliminaries
N = length(y); % length of time series

% (1) Maxmum number of partitions per axis, nbins
if nargin < 2 || isempty(nbins)
    nbins = 100; % default number of bins per axis is 100
end

% (2) Set embedding parameters to defaults
if nargin < 3 || isempty(embedparams)
    embedparams = {'ac','cao'};
else
    if length(embedparams) ~= 2
        error('Embedding parameters should be formatted like {tau,m}')
    end
end

%% Embed the signal
% convert to embedded signal object for TSTOOL
s = BF_embed(y,embedparams{1},embedparams{2},1);

if ~strcmp(class(s),'signal') && isnan(s); % embedding failed
    error('Time-series embedding to signal class for TSTOOL failed')
end

%% Run
rs = data(corrdim(s,nbins));
% Contains ldr as rows for embedding dimensions 1:m as columns;
if doplot
    figure('color','w'); box('on');
    plot(rs,'k');
end

%% Output Statistics
% Note: these aren't particularly well motivated.
m = size(rs,2); % number of embedding dimensions
ldr = size(rs,1); % I don't really know what this means; = 17
for i = 2:m
    meani = mean(rs(:,i));
    eval(sprintf('out.meand%u = meani;',i))
    mediani = median(rs(:,i));
    eval(sprintf('out.mediand%u = mediani;',i))
    mini = min(rs(:,i));
    eval(sprintf('out.mind%u = mini;',i))
end

for i = 2:ldr
    meani = mean(rs(i,:));
    eval(sprintf('out.meanr%u = meani;',i))
    mediani = median(rs(i,:));
    eval(sprintf('out.medianr%u = mediani;',i))
    mini = min(rs(i,:));
    eval(sprintf('out.minr%u = mini;',i))
    meanchi = mean(diff(rs(i,:)));
    eval(sprintf('out.meanchr%u = meanchi;',i))
end

out.stdmean = std(mean(rs));
out.stdmedian = std(median(rs));

rsstretch = rs(:);
out.medianstretch = median(rsstretch);
out.minstretch = min(rsstretch);
out.iqrstretch = iqr(rsstretch);


end
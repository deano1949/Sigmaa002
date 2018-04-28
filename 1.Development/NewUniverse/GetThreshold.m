%% Get threshold for early exit for New Universe


%% Set up
ci_lvl=0.07; 
location='Home';

%%
if strcmp(location,'Home')
    addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));
    addpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)\14.bog_sog')
    addpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)\14.bog_sog\1.Development\EarlyExit');

    path='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\NewUniverse\';
elseif strcmp(location,'Coutts')
    addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
    addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)');
    path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\NewUniverse\';
else
    error('Unrecognised location; Coutts or Home');
end

load(strcat(path, 'NUV.mat'));

 Threshold = CH4_earlyexit(op,lo,hi,ci_lvl);

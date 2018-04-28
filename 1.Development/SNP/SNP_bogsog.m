function SNP_bogsog(location,stckselectmode,spread_mode)
%Input: location = 'Coutts'
%                  'Home'
%       stckselectionmode = 'ranked' or 'random'
%       spread_mode = '' or 'fix'
% clc;clear;
if strcmp(location,'Home')
    addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));
    path='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\SNP500\';
elseif strcmp(location,'Coutts')
    addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
    addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)');
    path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\SNP500\';
else
    error('Wrong location input; Coutts or Home');
end

load(strcat(path, 'SNP500.mat'));

bogtopN=5;
bogentryZscore=0.8;
boglookback=20;

sogtopN=10;
sogentryZscore=0.8;
soglookback=60;

% stckselectmode='ranked'; % or 'random' & 'ranked'
% spread_mode=''; % 'fix' or ''

[bogret,bog_performance, bogstockpick]=SNP_bog_livetrading(bogtopN,bogentryZscore,boglookback,stckselectmode,spread_mode,path);
[sogret,sog_performance, sogstockpick]=SNP_sog_livetrading(sogtopN,sogentryZscore,soglookback,stckselectmode,spread_mode,path);

bogsogret=bogret+sogret;
apr_si=prod(1+bogsogret).^(252/length(bogsogret))-1; %annualised returns since inception
sharpe_si=mean(bogsogret)*sqrt(252)/std(bogsogret); %sharpe ratio since inception
maxdd_si=maxdrawdown(100*cumprod(1+bogsogret)); %maxdrawdown since inception


outputfile='Matlab_simulation_output.xlsx';
xlswrite(outputfile,datestr(now),'MatlabBOGSOGoutput','A1');

info(1,1)={datestr(now)};
info(2,1)={'stckselectmode'};  info(2,2)={stckselectmode};
info(3,1)={'spread_mode'};      info(3,2)={spread_mode};
                                           info(4,2)={'BOG'};               info(4,3)={'SOG'};
info(5,1)={'topN'};                   info(5,2)={bogtopN};           info(5,3)={sogtopN};
info(6,1)={'EntryZscore'};        info(6,2)={bogentryZscore}; info(6,3)={sogentryZscore};
info(7,1)={'Lookback'};            info(7,2)={boglookback};     info(7,3)={soglookback};

xlswrite(outputfile,info,'MatlabBOGSOGoutput','A1');
xlswrite(outputfile,time,'MatlabBOGSOGoutput','A10');
xlswrite(outputfile,bogsogret,'MatlabBOGSOGoutput','B10');

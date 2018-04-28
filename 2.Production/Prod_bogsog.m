function [bogret,sogret,bog_performance,sog_performance,bsog_table]=Prod_bogsog(location,write,stckselectmode,spread_mode)
%Input: location = 'Coutts'
%                  'Home'
%       write = 'Y','N'
%       stckselectionmode = 'ranked' or 'random'
%       spread_mode = '' or 'fix'

% clc;clear;
if strcmp(location,'Home')
     addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));
    path='C:\Spectrion\Data\NewUniverse\';
    tradeuniversepath='C:\Users\gly19\Dropbox\GU\1.Investment\7. Operations\1. ScreenTradingUniverse\';
elseif strcmp(location,'Coutts')
     addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
     addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\Custom_Functions'));
     addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)');
    path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\NewUniverse\';
else
    error('Unrecognised location; Coutts or Home');
end

%% Define stocks in current trading universe
tradeuniverse='currentUniverse';
% tradeuniverse='';
load(strcat(path, 'NUV.mat'));
if strcmp(tradeuniverse,'currentUniverse')
    currentUniverse=readtable(strcat(tradeuniversepath,'ScreenTradingUniverse\2017 Q4\Trading_universe_2017_10_30.csv'));
    sym=currentUniverse.Symbol; 
    [list,~]=ismember(name,sym); %filter names in the current trading universe
else
    list=1:size(name,2);
end

data.op=op(:,list); data.hi=hi(:,list);data.lo=lo(:,list);data.cl=cl(:,list);data.name=name(list);data.time=time;

bogtopN=5;
bogentryZscore=0.8;
boglookback=20;

sogtopN=10;
sogentryZscore=0.8;
soglookback=60;


[bogret,bog_performance, bogstockpick]=Prod_bog_livetrading(bogtopN,bogentryZscore,boglookback,stckselectmode,spread_mode,write,data);
[sogret,sog_performance, sogstockpick]=Prod_sog_livetrading(sogtopN,sogentryZscore,soglookback,stckselectmode,spread_mode,write,data);

%% Sigma002
bogsogret=bogret+sogret;
apr_si=prod(1+bogsogret).^(252/length(bogsogret))-1; %annualised returns since inception
sharpe_si=mean(bogsogret)*sqrt(252)/std(bogsogret); %sharpe ratio since inception
maxdd_si=maxdrawdown(100*cumprod(1+bogsogret)); %maxdrawdown since inception

ret_2018=bogsogret(3274:end); ytd_2018=prod(1+ret_2018)-1; sharpe_2018=mean(ret_2018)*sqrt(252)/std(ret_2018); mdd_2018=maxdrawdown(100*cumprod(1+ret_2018));
ret_2017=bogsogret(3022:3273); ytd_2017=prod(1+ret_2017)-1; sharpe_2017=mean(ret_2017)*sqrt(252)/std(ret_2017); mdd_2017=maxdrawdown(100*cumprod(1+ret_2017));
ret_2016=bogsogret(2771:3022); ytd_2016=prod(1+ret_2016)-1; sharpe_2016=mean(ret_2016)*sqrt(252)/std(ret_2016); mdd_2016=maxdrawdown(100*cumprod(1+ret_2016));
ret_2015=bogsogret(2519:2770);ytd_2015=prod(1+ret_2015)-1; sharpe_2015=mean(ret_2015)*sqrt(252)/std(ret_2015); mdd_2015=maxdrawdown(100*cumprod(1+ret_2015));
ret_2014=bogsogret(2267:2518);ytd_2014=prod(1+ret_2014)-1; sharpe_2014=mean(ret_2014)*sqrt(252)/std(ret_2014); mdd_2014=maxdrawdown(100*cumprod(1+ret_2014));
ret_2013=bogsogret(2015:2266);ytd_2013=prod(1+ret_2013)-1; sharpe_2013=mean(ret_2013)*sqrt(252)/std(ret_2013); mdd_2013=maxdrawdown(100*cumprod(1+ret_2013));
ret_2012=bogsogret(1765:2014);ytd_2012=prod(1+ret_2012)-1; sharpe_2012=mean(ret_2012)*sqrt(252)/std(ret_2012); mdd_2012=maxdrawdown(100*cumprod(1+ret_2012));
ret_2011=bogsogret(1513:1764);ytd_2011=prod(1+ret_2011)-1; sharpe_2011=mean(ret_2011)*sqrt(252)/std(ret_2011); mdd_2011=maxdrawdown(100*cumprod(1+ret_2011));
ret_2010=bogsogret(1261:1512);ytd_2010=prod(1+ret_2010)-1; sharpe_2010=mean(ret_2010)*sqrt(252)/std(ret_2010); mdd_2010=maxdrawdown(100*cumprod(1+ret_2010));
ret_2009=bogsogret(1009:1260);ytd_2009=prod(1+ret_2009)-1; sharpe_2009=mean(ret_2009)*sqrt(252)/std(ret_2009); mdd_2009=maxdrawdown(100*cumprod(1+ret_2009));
ret_2008=bogsogret(756:1008);ytd_2008=prod(1+ret_2008)-1; sharpe_2008=mean(ret_2008)*sqrt(252)/std(ret_2008); mdd_2008=maxdrawdown(100*cumprod(1+ret_2008));
ret_2007=bogsogret(505:755);ytd_2007=prod(1+ret_2007)-1; sharpe_2007=mean(ret_2007)*sqrt(252)/std(ret_2007); mdd_2007=maxdrawdown(100*cumprod(1+ret_2007));
ret_2006=bogsogret(254:504);ytd_2006=prod(1+ret_2006)-1; sharpe_2006=mean(ret_2006)*sqrt(252)/std(ret_2006); mdd_2006=maxdrawdown(100*cumprod(1+ret_2006));

bsog_table=[apr_si sharpe_si maxdd_si;
    ytd_2018 sharpe_2018 mdd_2018;
    ytd_2017 sharpe_2017 mdd_2017;
    ytd_2016 sharpe_2016 mdd_2016;
    ytd_2015 sharpe_2015 mdd_2015;
    ytd_2014 sharpe_2014 mdd_2014;
    ytd_2013 sharpe_2013 mdd_2013;
    ytd_2012 sharpe_2012 mdd_2012;
    ytd_2011 sharpe_2011 mdd_2011;
    ytd_2010 sharpe_2010 mdd_2010;
    ytd_2009 sharpe_2009 mdd_2009;
    ytd_2008 sharpe_2008 mdd_2008;
    ytd_2007 sharpe_2007 mdd_2007;
    ytd_2006 sharpe_2006 mdd_2006;];

%%
if strcmp(write,'Y')
    outputfile='Matlab_simulation_output.xlsx';
    xlswrite(outputfile,datestr(now),'MatlabBOGSOGoutput','A1');

    info(1,1)={datestr(now)};
    info(2,1)={'stckselectmode'};  info(2,2)={stckselectmode};
    info(3,1)={'spread_mode'};     info(3,2)={spread_mode};
    info(4,2)={'BOG'};             info(4,3)={'SOG'};
    info(5,1)={'topN'};            info(5,2)={bogtopN};           info(5,3)={sogtopN};
    info(6,1)={'EntryZscore'};     info(6,2)={bogentryZscore}; info(6,3)={sogentryZscore};
    info(7,1)={'Lookback'};        info(7,2)={boglookback};     info(7,3)={soglookback};

    xlswrite(outputfile,info,'MatlabBOGSOGoutput','A1');
    xlswrite(outputfile,time,'MatlabBOGSOGoutput','A10');
    xlswrite(outputfile,bogsogret,'MatlabBOGSOGoutput','B10');
end
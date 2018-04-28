%% Description
% BogSog monte carlo simulation
% randomised stockselection and open price spread
addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\bog_sog\2.Production');

for i=1:200
    [bogret,sogret,bog_performance,sog_performance]=Prod_bogsog('Coutts','N','random','fix');
    BOG(:,i)=bogret;
    SOG(:,i)=sogret;
    BSOG(:,i)=bogret+sogret;
    bog_perf(:,i)=bog_performance.ZS8MA20.APR;
    sog_perf(:,i)=sog_performance.ZS8MA60.APR;
end
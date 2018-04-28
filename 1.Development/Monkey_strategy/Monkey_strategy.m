% clear;clc;
addpath(genpath( 'C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)\Common_codes'))
addpath 'O:\langyu\Reading\AlgorithmTrading_Chan_(2013)'
path='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\SNP500\';
load(strcat(path, 'SNP500.mat'));

bogtopN=5; % Max number of positions
sogtopN=10;
stockcount=size(name);
for i=1:1000
    [bogRI,bogAPR,bogSR ] = bogsog_monkey('bog',op,cl,bogtopN,stockcount);
   % [sogRI,sogAPR,sogSR ] = bogsog_monkey('sog',op,cl,sogtopN,stockcount);
    ret=bogRI;%+sogRI;
    Price(:,i)=ret2price(ret);
    APR(:,i)=prod(1+ret).^(252/length(ret))-1; %annualised returns since inception
    SR(:,i)=mean(ret)*sqrt(252)/std(ret); %sharpe ratio since inception
    MaxDD(:,i)=maxdrawdown(100*cumprod(1+ret)); %maxdrawdown since inception

end
    

%% Plot Fanchart
time1=datenum(time,'dd/mm/yy');
time1=time1(1:2518);
load bogmonkey.mat
h=fanchart(time1,PriceBOG(1:2518,:));
hold on
load gapstrategy.mat
gapstrat=gapstrat/100;
plot(time1,gapstrat(1:end));
hold off

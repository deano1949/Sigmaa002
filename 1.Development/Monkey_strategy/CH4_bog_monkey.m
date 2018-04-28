%Buy on Gap strategy
clear;clc;
addpath(genpath( 'O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'))
addpath 'O:\langyu\Reading\AlgorithmTrading_Chan_(2013)'
path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\SNP500\';
load(strcat(path, 'SNP500.mat'));

topN=5; % Max number of positions
j=1;

stdretC2C90d=backshift(1, smartMovingStd(calculateReturns(cl, 1), 90));

entryZscore=0.8;
k=1;
lookback=20; % for MA

%stock selector
stckselectmode='ranked';

%% price open price slippage into model
% abs(spread) mean: 0.16%; stdev: 0.2%
% spread mean: 0%; stdev: 0.255%
% Algo: if open price higher than previous close, spread is negative.
%       if open price is lower than previous close, spread is positive.
% The reason of it is to stress test the model with slippage, which always
% works against the model.
spread=0.0016;
spread_std=0.002;
spread_skew=-0.5;
spread_kurt=3;
% spread_mode='fix';
spread_mode='';

cl1=backshift(1,cl);
if ~strcmp(spread_mode,'')
        for i=2:size(op,1)
         for j=1:size(op,2)
            if strcmp(spread_mode,'fix') 
                 if op(i,j)>=cl1(i,j)
                     adj_op(i,j)=op(i,j)*(1-spread);
                 else
                     adj_op(i,j)=op(i,j)*(1+spread);
                 end
            elseif strcmp(spread_mode,'sim')
                 spread2=pearsrnd(spread,spread_std,spread_skew,spread_kurt);
                 if spread2<0
                     spread2=-spread2;
                 end

                 if op(i,j)>=cl1(i,j)
                     adj_op(i,j)=op(i,j)*(1-spread2);
                 else
                     adj_op(i,j)=op(i,j)*(1+spread2);
                 end
            end
         end
        end

        op=adj_op;
end
%%
buyPrice=backshift(1, lo).*(1-entryZscore*stdretC2C90d);

retGap=(op-backshift(1, lo))./backshift(1, lo);

pnl=zeros(size(cl,1), 1);

ma=backshift(1, smartMovingAvg(cl, lookback));

stockpick=cell(size(cl,1),topN);
retO2C=(cl-op)./op;
TC_roundtrip=0.00013*2; %tradingcost
for j=1:1000
    no_stock=randi(topN+1,size(cl,1),1)-1;
    positionTable=zeros(size(cl));
    for t=2:size(cl, 1)
        randpick=randi(size(name),no_stock(t),1);
        positionTable(t,randpick)=1;
    end
    
    
    tc=TC_roundtrip*ones(size(positionTable));%trading cost estimate percentage
    pnl=smartsum(positionTable.*(retO2C-tc), 2);
    ret=pnl/topN;
    ret(isnan(ret))=0;
    apr_si=prod(1+ret).^(252/length(ret))-1; %annualised returns since inception
    sharpe_si=mean(ret)*sqrt(252)/std(ret); %sharpe ratio since inception
%   maxdd_si=maxdrawdown(100*cumprod(1+ret)); %maxdrawdown since inception
    
    Price(:,j)=ret2price(ret);
    Apr_si(:,j)=apr_si;
    Sharpe_si(:,j)=sharpe_si;
%   Maxdd_si(:,j)=maxdd_si;
end

%% Plot Fanchart
time1=datenum(time,'dd/mm/yy');
h=fanchart(time1,Price(2:end,:));
hold on
load bog_performance.mat
bog_Price=ret2price(ret);
plot(time1,bog_Price(2:end,:));


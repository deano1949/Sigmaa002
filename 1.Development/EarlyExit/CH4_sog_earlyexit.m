%Sell on Gap strategy
clear;clc;
addpath 'O:\langyu\Reading\AlgorithmTrading_Chan_(2013)'
addpath 'O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'
path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\SNP500\';
load(strcat(path, 'SNP500.mat'));   
topN=10; % Max number of positions
j=1;

stdretC2C90d=backshift(1, smartMovingStd(calculateReturns(cl, 1), 90));
%stock selector
stckselectmode='ranked';
% stckselectmode='random';

for entryZscore=0.8%0:0.2:1.6
    for lookback=60 %20:10:100; % for MA
%Best output in terms of sharp ratio is MA = 50 or 60
load(strcat(path, 'SNP500.mat'));        
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
sellPrice=backshift(1, hi).*(1+entryZscore*stdretC2C90d);

retGap=(op-backshift(1, hi))./backshift(1, hi);

pnl=zeros(size(cl,1), 1);

positionTable=zeros(size(cl));

ma=backshift(1, smartMovingAvg(cl, lookback));

stockpick=cell(size(cl,1),topN);
for t=2:size(cl, 1)
    hasData=find(isfinite(retGap(t, :)) & op(t, :) > sellPrice(t, :) & op(t, :) < ma(t, :));
    if strcmp(stckselectmode,'ranked')  
        [foo idxSort]=sort(retGap(t, hasData), 'descend');
        positionTable(t, hasData(idxSort(1:min(topN, length(idxSort)))))=-1;
        pick=name(hasData(idxSort(1:min(topN, length(idxSort)))));
    elseif strcmp(stckselectmode,'random')
        cherrypick = CH4_stockselector(hasData,topN,'random');
        positionTable(t,cherrypick)=-1;
        pick=name(cherrypick);
    end
    if size(pick,2)>0
        for n=1:size(pick,2)
            stockpick(t,n)=pick(n);
        end
    end
end

retO2C=(cl-op)./op; %Hold until close
%% Early exit with threshold
k=1;
for lvl=0.07%0.06:0.01:0.16
exitmode='htc'; %hold until close
exitmode='erex'; %early exit
threshold_rerun='Y';
ci_lvl=lvl;
if strcmp(exitmode, 'erex')
    if strcmp(threshold_rerun,'Y')
        Threshold=CH4_earlyexit(op,lo,hi,ci_lvl);
    end
    threshold=Threshold.SOG;
    o2h=hi./op-1; %open2high 
    o2l=lo./op-1;
    o2c=cl./op-1;
    clposp1=(o2l>threshold).*o2c;
    clposp2=(o2l<=threshold).*threshold;
    retO2C=clposp1+clposp2;
end


%Exit position 2 : if touch previous high, close at previous high o/w close
%at day close.
% prevhi=backshift(1,hi);
% ex=prevhi.*(lo<prevhi)+cl.*(lo>=prevhi);
% retO2C=(ex-op)./op;

%%
TC_roundtrip=0.00013*2; %tradingcost
tc=TC_roundtrip*ones(size(positionTable));%TC estimate percentage

pnl=smartsum(positionTable.*(retO2C+tc), 2);
ret=pnl/topN; 
ret(isnan(ret))=0;

apr_si=prod(1+ret).^(252/length(ret))-1; %annualised returns since inception
sharpe_si=mean(ret)*sqrt(252)/std(ret); %sharpe ratio since inception
maxdd_si=maxdrawdown(100*cumprod(1+ret)); %maxdrawdown since inception

ret_2016=ret(2429:end); ytd_2016=prod(1+ret_2016)-1; sharpe_2016=mean(ret_2016)*sqrt(252)/std(ret_2016); mdd_2016=maxdrawdown(100*cumprod(1+ret_2016));
ret_2015=ret(2177:2428);ytd_2015=prod(1+ret_2015)-1; sharpe_2015=mean(ret_2015)*sqrt(252)/std(ret_2015); mdd_2015=maxdrawdown(100*cumprod(1+ret_2015));
ret_2014=ret(1925:2176);ytd_2014=prod(1+ret_2014)-1; sharpe_2014=mean(ret_2014)*sqrt(252)/std(ret_2014); mdd_2014=maxdrawdown(100*cumprod(1+ret_2014));
ret_2013=ret(1673:1924);ytd_2013=prod(1+ret_2013)-1; sharpe_2013=mean(ret_2013)*sqrt(252)/std(ret_2013); mdd_2013=maxdrawdown(100*cumprod(1+ret_2013));
ret_2012=ret(1423:1672);ytd_2012=prod(1+ret_2012)-1; sharpe_2012=mean(ret_2012)*sqrt(252)/std(ret_2012); mdd_2012=maxdrawdown(100*cumprod(1+ret_2012));
ret_2011=ret(1171:1422);ytd_2011=prod(1+ret_2011)-1; sharpe_2011=mean(ret_2011)*sqrt(252)/std(ret_2011); mdd_2011=maxdrawdown(100*cumprod(1+ret_2011));
ret_2010=ret(919:1170);ytd_2010=prod(1+ret_2010)-1; sharpe_2010=mean(ret_2010)*sqrt(252)/std(ret_2010); mdd_2010=maxdrawdown(100*cumprod(1+ret_2010));
ret_2009=ret(667:918);ytd_2009=prod(1+ret_2009)-1; sharpe_2009=mean(ret_2009)*sqrt(252)/std(ret_2009); mdd_2009=maxdrawdown(100*cumprod(1+ret_2009));
ret_2008=ret(415:666);ytd_2008=prod(1+ret_2008)-1; sharpe_2008=mean(ret_2008)*sqrt(252)/std(ret_2008); mdd_2008=maxdrawdown(100*cumprod(1+ret_2008));
ret_2007=ret(164:414);ytd_2007=prod(1+ret_2007)-1; sharpe_2007=mean(ret_2007)*sqrt(252)/std(ret_2007); mdd_2007=maxdrawdown(100*cumprod(1+ret_2007));

output_table=[apr_si sharpe_si maxdd_si;
    ytd_2016 sharpe_2016 mdd_2016;
    ytd_2015 sharpe_2015 mdd_2015;
    ytd_2014 sharpe_2014 mdd_2014;
    ytd_2013 sharpe_2013 mdd_2013;
    ytd_2012 sharpe_2012 mdd_2012;
    ytd_2011 sharpe_2011 mdd_2011;
    ytd_2010 sharpe_2010 mdd_2010;
    ytd_2009 sharpe_2009 mdd_2009;
    ytd_2008 sharpe_2008 mdd_2008;
    ytd_2007 sharpe_2007 mdd_2007;];
naming=strcat('ZS',num2str(entryZscore*10),'MA',num2str(lookback));
naming=strcat('cilvl',num2str(ci_lvl*100));
sog_performance_earlyexit.(naming)=mat2dataset(output_table,'VarNames',{'APR','SharpeRatio','maxDrawdown'},'ObsNames',{'Since Inception','Y2016','Y2015','Y2014','Y2013','Y2012','Y2011','Y2010','Y2009','Y2008','Y2007'});
sog_performance_earlyexit.retts(:,k)=ret;
k=k+1;
end
    end
end
%% Write output into Excel
save 'sog_performance_earlyexit.mat' sog_performance_earlyexit stockpick 
outputfile='Matlab_simulation_output_earlyexit.xlsx';
xlswrite(outputfile,time,'MatlabSOGoutput','A2');
xlswrite(outputfile,stockpick,'MatlabSOGoutput','B2');
xlswrite(outputfile,ret,'MatlabSOGoutput','M2');
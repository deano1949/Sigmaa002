function [traderet]=CH4_bog_CV()
%Buy on Gap strategy
% addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
% addpath(genpath('O:\3. Projects\181. Factor Model\Codes'))
path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\SNP500\';
load(strcat(path, 'SNP500.mat'));
rerun='Y'

if strcmp(rerun,'Y')
    topN=5; %Max number of positions
    k=1;
    j=1;
    stdretC2C90d=backshift(1, smartMovingStd(calculateReturns(cl, 1), 90));
%   stckselectmode='ranked';
    stckselectmode='random';
    
    for lookback=40:10:200; % for MA 40 ~ 200
        for entryZscore=0.6:0.2:1.2 % for Zscore 0.6 ~ 1.2

            buyPrice=backshift(1, lo).*(1-entryZscore*stdretC2C90d);
            retGap=(op-backshift(1, lo))./backshift(1, lo);
            positionTable=zeros(size(cl));
            ma=backshift(1, smartMovingAvg(cl, lookback));
            stockpick=cell(size(cl,1),topN);

            for t=2:size(cl,1)
                hasData=find(isfinite(retGap(t, :)) & op(t, :) < buyPrice(t, :) & op(t, :) > ma(t, :));
                if strcmp(stckselectmode,'ranked')
                    [foo idxSort]=sort(retGap(t, hasData), 'ascend');
                    positionTable(t, hasData(idxSort(1:min(topN, length(idxSort)))))=1;
                    pick=name(hasData(idxSort(1:min(topN, length(idxSort)))));
                elseif strcmp(stckselectmode,'random')
                    cherrypick = CH4_stockselector(hasData,topN,'random');
                    positionTable(t,cherrypick)=1;
                    pick=name(cherrypick);
                end
                if size(pick,2)>0  
                    for n=1:size(pick,2)
                        stockpick(t,n)=pick(n);
                    end
                end    
            end
            retO2C=(cl-op)./op;
            TC_roundtrip=0.00013*2; %tradingcost
            tc=TC_roundtrip*ones(size(positionTable));%trading cost estimate percentage
            pnl=smartsum(positionTable.*(retO2C-tc), 2);
            ret=pnl/topN;
            ret(isnan(ret))=0;
            apr_si=prod(1+ret).^(252/length(ret))-1; %annualised returns since inception
            sharpe_si=mean(ret)*sqrt(252)/std(ret); %sharpe ratio since inception
            maxdd_si=maxdrawdown(100*cumprod(1+ret)); %maxdrawdown since inception

            parameter(1,k)=lookback;
            parameter(2,k)=entryZscore;
            retTS(:,k)=ret;
            k=k+1;
        end
    end
    save 'variousParaRetTS_Rank_NO_TopN_5.mat' retTS time parameter
end
%% CV valuation
%load variousParaRetTS.mat
incr=63;
window=63*5;    %2530-91+1;        %63*5;%252*5;
k=10; %k-folds;
parition_mode='KFold';
startpt=91; %this is where 90D volatility is first available
endpt=91;
output=vertcat(parameter,zeros(2,size(parameter,2))); %evulation of each period
t=1;
traderet=zeros(size(time,1),1);
while endpt+incr<size(retTS,1)
    endpt=startpt+window-1;
    for j=1:size(retTS,2)
        y=retTS(startpt:endpt,j);
        sr=mean(y)*sqrt(252)/std(y);
        mse_sr= crossvalsharpe(y,k,parition_mode);
        sr_sr=sr/mse_sr; %sharpe ratio of sharpe ratio;
        apr_si=prod(1+y).^(252/length(y))-1;  %annualised returns since inception
        maxdd_si=maxdrawdown(100*cumprod(1+y));  %maxdrawdown since inception
        output(3,j)=sr;
        output(4,j)=mse_sr;
        output(5,j)=sr_sr;
        output(6,j)=apr_si;
        output(7,j)=maxdd_si;
    end
    %Trade with parameters with largest sharpe ratio of sharpe ratio.
    [~,id]=ismember(max(output(5,:)),output(5,:));
    %
    trade_para(t,1)=endpt+1; %timestamp of startpoint;
    trade_para(t,2)=endpt+incr; %timestamp of endpoint; %every half year
    trade_para(t,3)=parameter(1,id);
    trade_para(t,4)=parameter(2,id);
    if endpt+incr<size(retTS,1)
        traderet(endpt+1:endpt+incr,1)=retTS(endpt+1:endpt+incr,id);
    else
        traderet(endpt+1:size(retTS,1))=retTS(endpt+1:size(retTS,1),id);
    end   
    startpt=startpt+incr;
    t=t+1;
end
sr=mean(traderet)*sqrt(252)/std(traderet);
apr=prod(1+traderet).^(252/length(traderet))-1;  %annualised returns since inception
maxdd=maxdrawdown(100*cumprod(1+traderet));  %maxdrawdown since inception
ret=traderet;
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

output_table=[apr sr maxdd;
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

bog_performance=mat2dataset(output_table,'VarNames',{'APR','SharpeRatio','maxDrawdown'},'ObsNames',{'Since Inception','Y2016','Y2015','Y2014','Y2013','Y2012','Y2011','Y2010','Y2009','Y2008','Y2007'});

%% Output
%-----------------------------------------
% after tuning all cominbation of MA (0 ~ 200) and Zscore (0 ~ 1.4),we see
% the range of MA and Zscore are (40-200) and (0.6 ~ 1.2) respectively.


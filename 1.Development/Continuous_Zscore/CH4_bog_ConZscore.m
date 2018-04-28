%Buy on Gap strategy
%Convert trading signal into a continuous zscore
%----------------------------------------------

%% Choose location (where you are now?)
clear;clc;
location='Home';
if strcmp(location,'Coutts')
    addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
    addpath(genpath('O:\3. Projects\181. Factor Model\Codes'));
    addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\bog_sog');
    path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\SNP500\';
elseif strcmp(location,'Home')
    addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));
    path='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\SNP500\';
end
load(strcat(path, 'SNP500.mat'));

%% parameter setup
topN=5; %Max number of positions
j=1;
stdretC2C90d=backshift(1, smartMovingStd(calculateReturns(cl, 1), 90));
entryZscore=0.8; %0.8
k=1;
lookback=20; %20 % for MAx

%stock selector
stckselectmode='ranked';
% stckselectmode='random';

scoreoption=4;%-----------------------------
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
score=zeros(1,size(cl,2));
positionTable=zeros(size(cl));
ma=backshift(1, smartMovingAvg(cl, lookback));
stockpick=cell(size(cl,1),topN);
retma2C=cl./ma-1;
retO2C=(cl-op)./op;

 for t=2:size(cl, 1)
    position=zeros(1,size(cl,2));
   %hasData=find(isfinite(retGap(t, :)) & op(t, :) < buyPrice(t, :) & op(t, :) > ma(t, :));
    hasData=find(isfinite(retGap(t,:)) & op(t,:)<buyPrice(t,:) & op(t,:)>ma(t,:));%.*(ones(1,size(cl,2))-0.2*stdretC2C90d(t,:)));% stoploss = ma*(1-0.2*std)

   [foo idxSort]=sort(retGap(t, hasData), 'ascend');
    position(1, hasData(idxSort(1:min(topN, length(idxSort)))))=1;
    positionTable(t,hasData(idxSort(1:min(topN, length(idxSort)))))=1;
    pick=name(hasData(idxSort(1:min(topN, length(idxSort)))));
    x=op(t,:)./ma(t,:); % percentage return from ma
    if scoreoption==1 %score option 1: 1-100*(x-1)^2; x~[0.9,1.1]
        score=1-100*(x-ones(1,size(cl,2))).^2; % score is only positive when x ~ [0.9,1.1]
        score(score<0)=0;
    elseif scoreoption==2 %score option 2: normalised [buyPrice, MA]
        score=(buyPrice(t,:)-op(t,:))./(buyPrice(t,:)-ma(t,:));
    elseif scoreoption==3 %1-x/0.02 % as example: signal only picked up when op/ma-1<2% linear function
        score=ones(1,size(cl,2))-(x-ones(1,size(cl,2)))/0.02;
        score(score<0)=0;score(score>=1)=0;
        wgt=position.*score;
        sumwgt=smartsum(wgt); %total weight
        wgt=wgt/sumwgt; 
        wgt(wgt>0.1)=0.1; %restrict max weight at 20%
        wgt(isnan(wgt))=0; %change NaN to 0
        weight(t,:)=wgt; 
    elseif scoreoption==4 %score option 4: same logic as BOG but dynamic weights (not equal weighted)
        score=position.*retGap(t,:);
        score(isnan(score))=0;
        score=score/sum(score);
        wgt=position.*score;
        wgt(wgt>0.2)=0.2; %restrict max weight at 20%
        wgt(wgt<0.01)=0;
        wgt(isnan(wgt))=0; %change NaN to 0
        weight(t,:)=wgt; 
    end
    
    %sign weight
%     wgt=position.*score;
%     sumwgt=smartsum(wgt); %total weight
%     wgt=wgt/sumwgt; 
%     wgt(wgt>0.1)=0.1; %restrict max weight at 20%
%     wgt(isnan(wgt))=0; %change NaN to 0
%     weight(t,:)=wgt;  

    if size(pick,2)>0  
        for n=1:size(pick,2)
            stockpick(t,n)=pick(n);
        end
    end  
 end
 %%
%  score(t,:)=1-((op(t,:)-ma(t,:))./(buyPrice(t,:)-ma(t,:)))^2;   % 1-[(op-ma)/(buyprice-ma)]^2
TC_roundtrip=0.00013*2; %tradingcost
tc=TC_roundtrip*ones(size(positionTable));%trading cost estimate percentage

if scoreoption==4
    pnl=weight.*(retO2C-tc);
else
    pnl=weight.*(retma2C-tc);
end
pnl(isnan(pnl))=0;
ret=sum(pnl,2);
apr_si=prod(1+ret).^(252/length(ret))-1; %annualised returns since inception
sharpe_si=mean(ret)*sqrt(252)/std(ret); %sharpe ratio since inception
maxdd_si=maxdrawdown(100*cumprod(1+ret)); %maxdrawdown since inception
priceIndex=cumprod(1+ret);
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

%% Write output into excel
 bog_performance=mat2dataset(output_table,'VarNames',{'APR','SharpeRatio','maxDrawdown'},'ObsNames',{'Since Inception','Y2016','Y2015','Y2014','Y2013','Y2012','Y2011','Y2010','Y2009','Y2008','Y2007'});
% save 'bog_performance.mat' bog_performance stockpick ret
% outputfile='Matlab_simulation_output.xlsx';
% setting={['topN=' num2str(topN)],['spread: ' spread_mode],['selector: ' stckselectmode]};
% xlswrite(outputfile,setting,'MatlabBOGoutput','A1');
% xlswrite(outputfile,time,'MatlabBOGoutput','A2');
% xlswrite(outputfile,stockpick,'MatlabBOGoutput','B2');
% xlswrite(outputfile,ret,'MatlabBOGoutput','M2');
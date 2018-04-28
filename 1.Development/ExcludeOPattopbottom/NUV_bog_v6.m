function [ret,bog_performance, stockpick]=NUV_bog_v6(topN,entryZscore,lookback,stckselectmode,spread_mode,data)
%Buy on Gap strategy
%exclude those dates which open price = low price
% load(strcat(path, 'NUV.mat'));
cl=data.cl;
op=data.op;
lo=data.lo;
hi=data.hi;
time=data.time;
name=data.name;
stdretC2C90d=backshift(1, smartMovingStd(calculateReturns(cl, 1), 90));

% topN=5; % Max number of positions
% entryZscore=0.8;
% lookback=20; % for MA

%----stock selector------
%stckselectmode='ranked';
% stckselectmode='random';

%----open spread-------
% spread_mode='fix'; 
%spread_mode='';

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

positionTable=zeros(size(cl));

% ma1=backshift(1, smartMovingAvg(cl(:,1:500), lookback));
% ma2=backshift(1, smartMovingAvg(cl(:,501:end), lookback));
ma=backshift(1, smartMovingAvg(cl, lookback));%[ma1 ma2];

stockpick=cell(size(cl,1),topN);

for t=2:size(cl, 1)
 hasData=find(isfinite(retGap(t, :)) & op(t, :) < buyPrice(t, :) & op(t, :) > ma(t, :) & op(t,:)>lo(t,:));
 %%
    if strcmp(stckselectmode,'ranked')
        [foo idxSort]=sort(retGap(t, hasData), 'ascend');
        positionTable(t, hasData(idxSort(1:min(topN, length(idxSort)))))=1;
        pick=name(hasData(idxSort(1:min(topN, length(idxSort)))));
    elseif strcmp(stckselectmode,'random')
        cherrypick = Prod_stockselector(hasData,topN,'random');
        positionTable(t,cherrypick)=1;
        pick=name(cherrypick);
    end
%%         
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

ret_2016=ret(2771:end); ytd_2016=prod(1+ret_2016)-1; sharpe_2016=mean(ret_2016)*sqrt(252)/std(ret_2016); mdd_2016=maxdrawdown(100*cumprod(1+ret_2016));
ret_2015=ret(2519:2770);ytd_2015=prod(1+ret_2015)-1; sharpe_2015=mean(ret_2015)*sqrt(252)/std(ret_2015); mdd_2015=maxdrawdown(100*cumprod(1+ret_2015));
ret_2014=ret(2267:2518);ytd_2014=prod(1+ret_2014)-1; sharpe_2014=mean(ret_2014)*sqrt(252)/std(ret_2014); mdd_2014=maxdrawdown(100*cumprod(1+ret_2014));
ret_2013=ret(2015:2266);ytd_2013=prod(1+ret_2013)-1; sharpe_2013=mean(ret_2013)*sqrt(252)/std(ret_2013); mdd_2013=maxdrawdown(100*cumprod(1+ret_2013));
ret_2012=ret(1765:2014);ytd_2012=prod(1+ret_2012)-1; sharpe_2012=mean(ret_2012)*sqrt(252)/std(ret_2012); mdd_2012=maxdrawdown(100*cumprod(1+ret_2012));
ret_2011=ret(1513:1764);ytd_2011=prod(1+ret_2011)-1; sharpe_2011=mean(ret_2011)*sqrt(252)/std(ret_2011); mdd_2011=maxdrawdown(100*cumprod(1+ret_2011));
ret_2010=ret(1261:1512);ytd_2010=prod(1+ret_2010)-1; sharpe_2010=mean(ret_2010)*sqrt(252)/std(ret_2010); mdd_2010=maxdrawdown(100*cumprod(1+ret_2010));
ret_2009=ret(1009:1260);ytd_2009=prod(1+ret_2009)-1; sharpe_2009=mean(ret_2009)*sqrt(252)/std(ret_2009); mdd_2009=maxdrawdown(100*cumprod(1+ret_2009));
ret_2008=ret(756:1008);ytd_2008=prod(1+ret_2008)-1; sharpe_2008=mean(ret_2008)*sqrt(252)/std(ret_2008); mdd_2008=maxdrawdown(100*cumprod(1+ret_2008));
ret_2007=ret(505:755);ytd_2007=prod(1+ret_2007)-1; sharpe_2007=mean(ret_2007)*sqrt(252)/std(ret_2007); mdd_2007=maxdrawdown(100*cumprod(1+ret_2007));
ret_2006=ret(254:504);ytd_2006=prod(1+ret_2006)-1; sharpe_2006=mean(ret_2006)*sqrt(252)/std(ret_2006); mdd_2006=maxdrawdown(100*cumprod(1+ret_2006));
ret_2005=ret(2:253);ytd_2005=prod(1+ret_2005)-1; sharpe_2005=mean(ret_2005)*sqrt(252)/std(ret_2005); mdd_2005=maxdrawdown(100*cumprod(1+ret_2005));

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
    ytd_2007 sharpe_2007 mdd_2007;
    ytd_2006 sharpe_2006 mdd_2006;
    ytd_2005 sharpe_2005 mdd_2005;];

%% Write output into excel
naming=strcat('ZS',num2str(entryZscore*10),'MA',num2str(lookback));
bog_performance.(naming)=mat2dataset(output_table,'VarNames',{'APR','SharpeRatio','maxDrawdown'},'ObsNames',{'Since Inception','Y2016','Y2015','Y2014','Y2013','Y2012','Y2011','Y2010','Y2009','Y2008','Y2007','Y2006','Y2005'});
%save 'bog_performance.mat' bog_performance stockpick ret
outputfile='Matlab_simulation_output.xlsx';

xlswrite(outputfile,naming,'MatlabBOGoutput','A2');
xlswrite(outputfile,time,'MatlabBOGoutput','A5');
xlswrite(outputfile,stockpick,'MatlabBOGoutput','B5');
xlswrite(outputfile,ret,'MatlabBOGoutput','M5');
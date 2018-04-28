function ret=CH4_bog_ConZscore_intraday(IntraOP,IntraCl,hi,lo,cl,name)
%Buy on Gap strategy
%Convert trading signal into a continuous zscore
%----------------------------------------------

%% Choose location (where you are now?)
%% parameter setup
topN=500; %Max number of positions
j=1;
stdretC2C90d=backshift(1, smartMovingStd(calculateReturns(cl, 1), 90));
entryZscore=0.8; %0.8
k=1;
lookback=20; %20 % for Max

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
% if ~strcmp(spread_mode,'')
%         for i=2:size(op,1)
%          for j=1:size(op,2)
%             if strcmp(spread_mode,'fix') 
%                  if op(i,j)>=cl1(i,j)
%                      adj_op(i,j)=op(i,j)*(1-spread);
%                  else
%                      adj_op(i,j)=op(i,j)*(1+spread);
%                  end
%             elseif strcmp(spread_mode,'sim')
%                  spread2=pearsrnd(spread,spread_std,spread_skew,spread_kurt);
%                  if spread2<0
%                      spread2=-spread2;
%                  end
% 
%                  if op(i,j)>=cl1(i,j)
%                      adj_op(i,j)=op(i,j)*(1-spread2);
%                  else
%                      adj_op(i,j)=op(i,j)*(1+spread2);
%                  end
%             end
%          end
%         end
% 
%         op=adj_op;
% end
%% 
buyPrice=backshift(1, lo).*(1-entryZscore*stdretC2C90d);
retGap=(IntraOP-backshift(1, lo))./backshift(1, lo);
pnl=zeros(size(IntraCl,1), 1);
score=zeros(1,size(IntraCl,2));
positionTable=zeros(size(IntraCl));
ma=backshift(1, smartMovingAvg(cl, lookback));
stockpick=cell(size(IntraCl,1),topN);
retma2C=IntraCl./ma-1;
retO2C=(IntraCl-IntraOP)./IntraOP;

 for t=2:size(IntraCl, 1)
    position=zeros(1,size(IntraCl,2));
   %hasData=find(isfinite(retGap(t, :)) & op(t, :) < buyPrice(t, :) & op(t, :) > ma(t, :));
    hasData=find(isfinite(retGap(t,:)) & IntraOP(t,:)<buyPrice(t,:) & IntraOP(t,:)>ma(t,:));%.*(ones(1,size(cl,2))-0.2*stdretC2C90d(t,:)));% stoploss = ma*(1-0.2*std)

   [foo idxSort]=sort(retGap(t, hasData), 'ascend');
    position(1, hasData(idxSort(1:min(topN, length(idxSort)))))=1;
    positionTable(t,hasData(idxSort(1:min(topN, length(idxSort)))))=1;
    pick=name(hasData(idxSort(1:min(topN, length(idxSort)))));
    x=IntraOP(t,:)./ma(t,:); % percentage return from ma
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

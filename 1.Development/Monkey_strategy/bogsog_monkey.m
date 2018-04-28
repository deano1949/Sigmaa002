function [ret,apr_si,sharpe_si ] = bogsog_monkey(mode,op,cl,topN,stockcount)
%BOGSOG_MONKEY simulates monkey strategy for BOG_SOG strategy
%Monkey picks random number of stocks and randomly selects stocks to trade,
%each trade only holds for one day.
% Input: mode : either 'bog or 'sog'
%          op/cl: open and close price
%          topN: max # of trading stocks
%Output: ret: ret index
%            apr_si: annulaised percentage return
%            sharpe_si: sharpe ratio


% check
if ~(strcmp(mode,'bog') || strcmp(mode,'sog'))
        error('mode must be either bog or sog.');
end

addpath(genpath( 'O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'))
retO2C=(cl-op)./op;
TC_roundtrip=0.00013*2; %tradingcost
no_stock=randi(topN+1,size(cl,1),1)-1; %# of stocks
positionTable=zeros(size(cl));


if strcmp(mode,'bog') %bog_monkey
 
    for t=2:size(cl, 1)
        randpick=randi(stockcount,no_stock(t),1); %random pick stock names
        positionTable(t,randpick)=1; %long position
    end
    tc=TC_roundtrip*ones(size(positionTable));%trading cost estimate percentage
    pnl=smartsum(positionTable.*(retO2C-tc), 2);
elseif strcmp(mode,'sog') %sog_monkey
    for t=2:size(cl, 1)
        randpick=randi(stockcount,no_stock(t),1); %random pick stock names
        positionTable(t,randpick)=-1; %long position
    end
    tc=TC_roundtrip*ones(size(positionTable));%trading cost estimate percentage
    pnl=smartsum(positionTable.*(retO2C+tc), 2); 
end

ret=pnl/topN;
ret(isnan(ret))=0;
apr_si=prod(1+ret).^(252/length(ret))-1; %annualised returns since inception
sharpe_si=mean(ret)*sqrt(252)/std(ret); %sharpe ratio since inception
Price=ret2price(ret);
    

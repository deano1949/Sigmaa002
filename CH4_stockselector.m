function cherrypick = CH4_stockselector(hasData,topN,stckselectmode)
%CH4_STOCKSELECTOR Summary
% this function specifically deals with that algorithm could not instantly
% rank the top N stock which decrease/increase most at the opening bell.
% This is becuase stocks do not genuinely trade right after the market
% open. The first trade of illiquid stocks could well happen a few minute
% after. Therefore, our current algorithm does "first come first serve"
% basis. This is fine if there is less than N (pre-defined) stock signals,
% but it is not consistent with simulation if there are more than N
% signals. CH4_stockselector tries to mimick the environment as close as
% possible by randomly select N stocks to trade on "signal rich" days.
%
% INPUT:
% N : limit on the number of stocks to trade.
% mode: either 'ranked' or 'random'

    if ~strcmp(stckselectmode,'random')
        error('stocks selection mode must be random');
    end
    
    if size(hasData,2)<=topN
        cherrypick=hasData;
    else
        cherrypick=randperm(size(hasData,2),topN);
    end
end


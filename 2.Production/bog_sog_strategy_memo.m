%% Combination of "Buy on gap" and "Sell on gap" strategy review
%Simulated portfolio with BOG and SOG strategy implementation.
%Backtest time period: 11/06/2006 - 06/01/2016

%% Key parameters:
% moving average days = 20
% entryZscore = 0.8
% number of stocks = top 10
% standard diviation = 90 days

%% Results:
% Annualised portfolio return = 26.15%
% Sharp ratio = 2.563
% Maximum drawdown = 7.74%

%% Pitfalls that curb performance from real live trading
% (1) strategy signal depends on the open price and trade enters at the open. 
% Practically speaking, it is not achievable. However, we can use the pre-open
% mid-price to be the proxy of open price. But how close it is to open price,
% it requires more work.
% (2) Sell on Gap strategy could select stocks which are on short-sell restriction.
% The backtested performance could be inflated by assuming all stocks are shortable.
% (3) The above results are before trading costs.
%Files

%% 10.09.2016
% Trading universe has changed to "New Universe" from SNP500.
% The new universe is generated in more systematic way, 500 stocks are
% selected from NYSE and NASDAQ exchanges based on certain criterias (see
% C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\NewUniverse\Define_stock_universe_2016_08_27.xlsx
% for details)
% Main reason of switch to "New Universe" is 
%(1) a more systematic selection of universe;
%(2) Criterias reduces trading costs and commissions.


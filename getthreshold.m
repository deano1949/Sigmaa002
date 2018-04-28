function [Buy_th,Sell_th] = getthreshold(op,lo,hi,ci_lvl)
%GETTHRESHOLD: suggests an optimal early exit level of trading
%   Input: op/lo/hi are open/high/low price
%          ci_lvl : confidence interval level (1std=0.16 top/bottom 16%)
if ci_lvl>0.5
    error('confidence interval must be <0.5, it is the upper end of distribution')
end
o2h=hi./op-1; %return of open2high 
o2l=lo./op-1; %return of open2low

histmat=[];
for i=1:size(op,1)
    incret=o2l(i):0.001:o2h(i);
    histmat=[histmat incret];
end
sortid=sort(histmat);
nanpos=find(isnan(sortid));
if ~isempty(nanpos) && size(nanpos,2)~=size(op,1)
    sortid=sortid(1:nanpos-1);
end
buy_th_lvl=ceil((1-ci_lvl)*numel(sortid));
sell_th_lvl=ceil(ci_lvl*numel(sortid));

%% trading threshold
Buy_th=sortid(buy_th_lvl); %buy signal threshold
Sell_th=sortid(sell_th_lvl); %buy signal threshold

end


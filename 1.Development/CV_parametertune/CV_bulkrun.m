% matlabpool('open')
addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
addpath(genpath('O:\3. Projects\181. Factor Model\Codes'))


for i=1:20
    traderet=CH4_bog_CV();
    RET(:,i)=traderet;
    i
end
Output(1,:)=prod(1+RET).^(252/length(RET))-1; %annualised returns since inception
Output(2,:)=mean(RET)*sqrt(252)./std(RET); %sharpe ratio since inception
Output(3,:)=maxdrawdown(100*cumprod(1+RET)); %maxdrawdown since inception


%% Results
% BOG;
% CVWindow=63*5;
% CVIncr=63;
% N=5;
% Spread=N;
% Ranked=N;


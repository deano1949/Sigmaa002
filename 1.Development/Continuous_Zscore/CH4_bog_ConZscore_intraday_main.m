%% Description
% Refresh signal and reblancing every 15mins

%% Load data
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

%% Reformat intraday data
% Intrady data are available from 01/06/16 
Intradaypath='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\EODData\15mins\';
load(strcat(Intradaypath, 'SNPintrady.mat'));

intratime=intracl.datestamp;
[~,pos]=ismember(datenum(intratime{1},'dd-mm-yyyy'),datenum(time,'dd/mm/yyyy'));
enddate=pos+length(intratime)-1;

lo=lo(1:enddate,:);
cl=cl(1:enddate,:);
hi=hi(1:enddate,:);

%% loop through intraday data
%format open price %refresh signal @ T+1's open price (ideally @T's close
%price but EODdata close price has bad quality (waiting for Nan's data)).
%Becuase open price of any timeframe is subject to the time of first coming
%trade within the period.
priceName=fieldnames(intraop);
blankprice=zeros(pos-1,size(op,2));
N=size(priceName,1)-3;
%N=1;
for k=1:N
    opstamp=char(priceName(k));%char(priceName(k));
    clstamp=char(priceName(k+1));
    IntraOP=vertcat(blankprice,(intraop.(opstamp)));
    IntraCl=vertcat(blankprice,intraop.(clstamp));
    pnl(:,k)=CH4_bog_ConZscore_intraday(IntraOP,IntraCl,hi,lo,cl,name);
end
ret=sum(pnl,2);
%% Performance Evaluation
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
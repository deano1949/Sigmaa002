%% Description
% Given the fact that no all stocks are trading @ 0930 and price is
% extremely volatile @ first few second of trading, we explores the
% possibility of shifting trading @0931 (@close of 0930).
clc;clear;

%% Combined data
% replace open price by 09:31 price
SNPpath='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\SNP500\';
Intradaypath='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\EODData\15mins\';

load(strcat(SNPpath, 'SNP500.mat'));
load(strcat(Intradaypath, 'SNPintrady.mat'));

intratime=intracl.datestamp;
[~,pos]=ismember(datenum(intratime{1},'dd-mm-yyyy'),datenum(time,'dd/mm/yyyy'));
enddate=pos+length(intratime)-1;

op=vertcat(op(1:pos-1,:),intraop.t945); op(op==0)=NaN;
lo=lo(1:enddate,:);
cl=cl(1:enddate,:);
hi=hi(1:enddate,:);

save 'C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)\14.bog_sog\1.Development\Trading_at_0931\SNP500.mat' op hi lo cl name time

%% run BOGSOG
addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));

    
path0931='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)\14.bog_sog\1.Development\Trading_at_0931\';
path0930='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\SNP500\';

[ret,bog_performance, stockpick]=Dev_bog_0931(5,0.8,20,'ranked','',path0930);
[ret931,bog_performance931, stockpick931]=Dev_bog_0931(5,0.8,20,'ranked','',path0931);

% %% Price difference between t0930 close and t0931 open
% load '1mins\SNPintrady.mat'
% gap=(intraop.t931-intracl.t930)./intracl.t930;
% gap(intracl.t930==0)=0;
% gaprank=sort(reshape(abs(gap),37*522,1));
% 
% %% Price difference between t0930 close and t0945 open
% load '15mins\SNPintrady.mat'
% gap=(intraop.t945-intracl.t930)./intracl.t930;
% gap(intracl.t930==0)=0;
% gaprank=sort(reshape(abs(gap),37*522,1));
% 

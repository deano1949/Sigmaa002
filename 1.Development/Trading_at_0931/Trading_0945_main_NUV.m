%% Description
% Given the fact that no all stocks are trading @ 0930 and price is
% extremely volatile @ first few second of trading, we explores the
% possibility of shifting trading @0945
% clc;clear;

%% Combined data 
% replace open price by 09:45 price
NUVpath='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\NewUniverse\';
Intradaypath='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\EODData\MatlabFormat\15mins\';

load(strcat(NUVpath, 'NUV.mat'));
load(strcat(Intradaypath, 'NUV945.mat'));

intratime=NUV945.datestamp;
[~,pos]=ismember(datenum(intratime{1},'dd-mm-yyyy'),datenum(time,'dd/mm/yyyy'));
enddate=pos+length(intratime)-1;

if enddate>size(cl,1)
    dategap=enddate-size(cl,1);
    O=NUV945.O; O=O(1:end-dategap,:);
    op=vertcat(op(1:pos-1,:),O); op(op==0)=NaN;
    enddate=enddate-dategap;
else
    op=vertcat(op(1:pos-1,:),NUV945.O); op(op==0)=NaN;
end

lo=lo(1:enddate,:);
cl=cl(1:enddate,:);
hi=hi(1:enddate,:);
time=time(1:enddate,:);
%% Performance comparison between Trade @0930 and Trade @0945
addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));

%Trade at 0945
NUV945.O=op; NUV945.C=cl; NUV945.L=lo; NUV945.H=hi; NUV945.name=name; NUV945.time=time;
[ret945,bog_performance945, stockpick945]=Dev_bog_0931(100,0.8,20,'ranked','',NUV945);

%Trade at 0930
load(strcat(NUVpath, 'NUV.mat'));
NUV930.O=op; NUV930.C=cl; NUV930.L=lo; NUV930.H=hi; NUV930.name=name; NUV930.time=time;
[ret930,bog_performance930, stockpick930]=Dev_bog_0931(5,0.8,20,'ranked','',NUV930);

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

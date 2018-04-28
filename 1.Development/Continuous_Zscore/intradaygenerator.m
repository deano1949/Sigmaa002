%% Load Data
clc;clear;
location='Home';
if strcmp(location,'Home')
    addpath(genpath('C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\4. Alphas (new)'));
    path='C:\Users\Langyu\Desktop\Dropbox\GU\1.Investment\Data\SNP500\';
elseif strcmp(location,'Coutts')
    addpath(genpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\jplv7'));
    addpath('O:\langyu\Reading\AlgorithmTrading_Chan_(2013)');
    path='O:\langyu\Reading\AlgorithmTrading_Chan_(2013)\SNP500\';
else
    error('Unrecognised location; Coutts or Home');
end

load(strcat(path, 'SNP500.mat'));


%% random intraday price generator
[ro,co]=size(cl);
N=10;
Price=zeros(ro,co,N);
for i=1:ro
    for j=1:co
        lp=lo(i,j); hp=hi(i,j); %low price and high price
        p=lp+(hp-lp)*rand(N,1);%generate random price
        Price(i,j,:)=p;
    end
end

SimPrice.T0=op;
for k=1:N
    timestamp=['T' num2str(k)];
    SimPrice.(timestamp)=squeeze(Price(:,:,k));
end
 SimPrice.T100=cl;
 
 save SimPrice.mat SimPrice
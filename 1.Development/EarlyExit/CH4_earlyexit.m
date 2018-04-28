function Threshold = CH4_earlyexit(op,lo,hi,ci_lvl)
%EARLYEXIT_ Summary: bulk run to produce threshold for group of securities
%This function explicitly for BOG/SOG only
update_freq=63; %threshold updates semi-annually %can adjust to quaterly
col=size(op,2);
sz=size(op,1);
for j=1:col
    opsgl=op(:,j);
    losgl=lo(:,j);
    hisgl=hi(:,j);
    
    bth=NaN(sz,1); sth=NaN(sz,1);
    for i=90:update_freq:sz 
        op1=opsgl(1:i,1);lo1=losgl(1:i,1);hi1=hisgl(1:i,1);
        if sz>i+update_freq
            inx=i+update_freq;
        else
            inx=sz;
        end
        [bth(i+1:inx),sth(i+1:inx)]=getthreshold(op1,lo1,hi1,ci_lvl); %bth:threshold for bog; sth:threshold for sog;
    end
    BTH(:,j)=bth;
    STH(:,j)=sth;
end
BTH(isnan(BTH))=1; %no threshold meaning threshold at very high level
STH(isnan(STH))=-1; %no threshold meaning for SOG threshold at very low level
Threshold.BOG=BTH;
Threshold.SOG=STH;
save 'Threshold.mat' Threshold;
path=cd;
msg=['Threshold parameters are saved to ' path]
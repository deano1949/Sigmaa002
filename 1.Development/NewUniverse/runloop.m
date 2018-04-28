clc;clear;

for i=1:50

[bogret,sogret,~,~]=NUV_bogsog('Home','random','fix');

bog(:,i)=bogret;
sog(:,i)=sogret;
end
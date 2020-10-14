%
% use the model constructed by battery 38 36 37 to test battery
%%
%use the battery 38 36 37 to construct model
% linear by area
clear;
clc;
close all
load c38; load c36; load c37;
load s38; load s36; load s37; 
load c35; load s35;
%%

%提取0.8以上的电量及充电时间
a38=find(c38<0.8,1); a36=find(c36<0.8,1);
a37=find(c37<0.8,1); a35=find(c35<0.8,1);

% only 'healthy' data
c38=c38(1:a38); c36=c36(1:a36);
c37=c37(1:a37); c35=c35(1:a35);

s38=s38(1:a38); s36=s36(1:a36);
s37=s37(1:a37); s35=s35(1:a35);
%拟合并展现估计值与实际值
X=[s38' s36' s37'];%时间
Y=[c38' c36' c37'];%电量

%normalize
[x,F1]=mapminmax(X,0,1);   % x: nomalise area
[y,F2]=mapminmax(Y,0,1);   % y: nomalise capacity

%fitting
p0=polyfit(x,y,1);

%%
%estimate
tx=mapminmax('apply',s35',F1);%normalise testing input
est_tem=polyval(p0,tx');  %estimate
est=mapminmax('reverse',est_tem,F2) ;%real scale estimation
%%
%normalise estimation and actual data to plot SOH figure
c35=c35/1.1;%rated capacity is 1.1
est=est/1.1;%estimation
%%
% calculate MSE
% see the fitted result
c_fit_nor=polyval(p0,x);  %fitted capaity normzlised, row
% c_fit_real=mapminmax('reverse',c_fit_nor,F2) ;%real fitted
% MSE
MSE=sum((c_fit_nor-y).^2)/(a38+a36+a37-2);
%
numer=(tx-mean(x)).^2;%numerator fenzi
denom=sum((x-mean(x)).^2);%denominator fenmu
wid_half=tinv(1-0.025,a38+a36+a37-2)*sqrt(MSE*(1+1/(a38+a36+a37)+numer/denom));%the half width of the 95% confidence interval
%%
%figure for estimation
x1=(est'+wid_half)*100;% row
x2=(est'-wid_half)*100;%
xf=[x1 fliplr(x2)];
m=length(x1);
y1=1:m;
y2=fliplr(y1);
yf=[y1 y2];

figure
hold on
plot(c35*100,'r')
plot(est*100,'b')
H=fill(yf,xf,'g','facealpha',0.4)
set(H,{'LineStyle'},{'none'}) %设置颜色和线宽
axis([0 700 70 115])
xlabel('Cycle')
ylabel('SOH(%)')
legend('Real SOH','Estimation','95% Confidence interval')
% title('Bat.35 Estimation by charging time')
plot([0 700],[80 80],'m--')
plot(c35*100,'r')
plot(est*100,'b')
%%
r35=RMSE(c35,est)

mae35=MAE(c35,est)

mre35=MRE(c35,est)

me35=max(abs(c35-est))   %maximum error

r2=cod(c35,est)

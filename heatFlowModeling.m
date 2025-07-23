function heatFlowModeling
% import data.
wavl_atm=xlsread('atmosphericIRwindowData.xlsx','A:A');
t_atm=xlsread('atmosphericIRwindowData.xlsx','B:B');
%% set IR range & make 'atmosphericIRwindowData.xlsx' data more regular
wavl_start = 8;
wavl_end = 13;
num = 1000;
wavl_arr = linspace(wavl_start,wavl_end,num);
w_step=wavl_arr(2)-wavl_arr(1);
tau_full = interp1(wavl_atm, t_atm, wavl_arr, 'linear');
%% parameters
IR_emis = 1; % emittance of the object.
h = 12; % conduction and convection, W/m2
Tamb = 30 + 273; % Ambient temperature
I_ES_arr = [0 200 400 600 800 1000]; % Added other I_ES values to solar array
R_solar_arr = linspace(0, 1, 20); % Changed to linspace reflectance for the solar 
%% Calculation
detT_arr=zeros(length(I_ES_arr),length(R_solar_arr));
% 'detT_arr' is to store the temperature drop.
for ii=1:length(I_ES_arr)
I_ES= I_ES_arr(ii);
for jj=1:length(R_solar_arr)
R_solar = R_solar_arr(jj);
Tobj = Tamb;
% below is calculation
if Prad(Tobj) > P_cdcv(Tamb,Tobj) + Psun_abs() + Pamb(Tamb)
while Prad(Tobj)>P_cdcv(Tamb,Tobj)+Psun_abs()+Pamb(Tamb)
Tobj=Tobj-0.1;
end
else
while Prad(Tobj) < P_cdcv(Tamb,Tobj)+Psun_abs()+Pamb(Tamb)
Tobj=Tobj+0.1;
end
end
detT_arr(ii,jj)=Tamb-Tobj; % record the difference
end
end
%% plot temperature drop versus T_amb
figure()
for i = 1:size(detT_arr, 1)
plot(R_solar_arr, detT_arr(i,:), 'o-', 'LineWidth', 2);
hold on;
end
xlabel('\rho_{sun}');
ylabel('Temperature drop, detT [C]')
title('Temperature drop vs. Solar Reflectance')
legend(compose("I_{ES}=%d W/m^2", I_ES_arr));


%% DIY functions
function y=Ibb(wavl_ARR,T) % spectral.
% spectral hemisphere emissive power of a blackbody
C1=3.742e8/pi; % C1 unit: W.um^4.m^-2
C2= 1.439e4;
y=C1./((wavl_ARR.^5).*(exp(C2./(wavl_ARR.*T))-1));
end
function y = Prad(Tsample)
% input ambient temperautre, return radiation from the ambient.
y = pi*w_step*sum(IR_emis*Ibb(wavl_arr,Tsample));
end
function y = P_cdcv(T_env,T_film)
% input ambient temperautre, return radiation from the ambient.
y = h*(T_env - T_film);
end
function y = Psun_abs()
% input ambient temperautre, return radiation from the ambient.
y = (1-R_solar)*I_ES;
end
function y = Pamb(T)
% input ambient temperautre, return radiation from the ambient.
detP=0.01;
P_amb=0;
for p=0.01:detP:0.99 % p = cos(theta)
t = (1-tau_full.^(1/p));
% t: atmospherical transmittance w.r.t. wavl and angle
% below is to transfer integral into Riemann sum
TempValue=2*pi*detP*p*IR_emis*(w_step*sum(t.*Ibb(wavl_arr,T)));
P_amb = P_amb + TempValue;
end
y=P_amb;
end
end

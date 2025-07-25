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
Tamb = 30 + 273; % Ambient temperature
I_ES_arr = [0 200 400 600 800 1000]; % Added other I_ES values to solar array
R_solar_arr = linspace(0, 1, 20); % Changed to linspace reflectance for the solar 

% Define 10 random example materials
numMaterials = 10;
materials = struct('name', {}, 'IR_emis', {}, 'h', {});
for i = 1:numMaterials
    materials(i).name = ['Material' num2str(i)];
    materials(i).IR_emis = 0.05 + 0.9*rand(); % random between 0.05 and 0.95
    materials(i).h = 8 + 12*rand();           % random between 8 and 20
end

% --- Timing analysis ---

fprintf('Running serial computation...\n');
tic;
results_serial = computeForMaterials(materials, I_ES_arr, R_solar_arr, Tamb, tau_full, w_step, wavl_arr, false);
time_serial = toc;

fprintf('Running parallel computation...\n');
tic;
results_parallel = computeForMaterials(materials, I_ES_arr, R_solar_arr, Tamb, tau_full, w_step, wavl_arr, true);
time_parallel = toc;

fprintf('\nElapsed time (serial):   %.3f seconds\n', time_serial);
fprintf('Elapsed time (parallel): %.3f seconds\n', time_parallel);

% Use parallel results for plotting (they should be the same)
figure()
rows = 2; cols = 5;
for m = 1:numMaterials
    detT_arr = results_parallel{m}.detT_arr;
    subplot(rows,cols,m)
    for i = 1:size(detT_arr, 1)
        plot(R_solar_arr, detT_arr(i,:), 'o-', 'LineWidth', 2);
        hold on;
    end
    xlabel('\rho_{sun}');
    ylabel('Temperature drop, detT [C]')
    title(materials(m).name)
    legend(compose('I_{ES}=%d W/m^2', I_ES_arr));
end

end

function results = computeForMaterials(materials, I_ES_arr, R_solar_arr, Tamb, tau_full, w_step, wavl_arr, useParallel)
numMaterials = length(materials);
results = cell(numMaterials,1);
if useParallel
    parfor m = 1:numMaterials
        mat = materials(m);
        IR_emis = mat.IR_emis;
        h = mat.h;
        detT_arr=zeros(length(I_ES_arr),length(R_solar_arr));
        for ii=1:length(I_ES_arr)
            I_ES= I_ES_arr(ii);
            for jj=1:length(R_solar_arr)
                R_solar = R_solar_arr(jj);
                Tobj = Tamb;
                if Prad(Tobj, IR_emis, w_step, wavl_arr) > P_cdcv(Tamb,Tobj,h) + Psun_abs(R_solar,I_ES) + Pamb(Tamb, IR_emis, tau_full, w_step, wavl_arr)
                    while Prad(Tobj, IR_emis, w_step, wavl_arr)>P_cdcv(Tamb,Tobj,h)+Psun_abs(R_solar,I_ES)+Pamb(Tamb, IR_emis, tau_full, w_step, wavl_arr)
                        Tobj=Tobj-0.1;
                    end
                else
                    while Prad(Tobj, IR_emis, w_step, wavl_arr) < P_cdcv(Tamb,Tobj,h)+Psun_abs(R_solar,I_ES)+Pamb(Tamb, IR_emis, tau_full, w_step, wavl_arr)
                        Tobj=Tobj+0.1;
                    end
                end
                detT_arr(ii,jj)=Tamb-Tobj;
            end
        end
        results{m}.detT_arr = detT_arr;
        results{m}.name = mat.name;
    end
else
    for m = 1:numMaterials
        mat = materials(m);
        IR_emis = mat.IR_emis;
        h = mat.h;
        detT_arr=zeros(length(I_ES_arr),length(R_solar_arr));
        for ii=1:length(I_ES_arr)
            I_ES= I_ES_arr(ii);
            for jj=1:length(R_solar_arr)
                R_solar = R_solar_arr(jj);
                Tobj = Tamb;
                if Prad(Tobj, IR_emis, w_step, wavl_arr) > P_cdcv(Tamb,Tobj,h) + Psun_abs(R_solar,I_ES) + Pamb(Tamb, IR_emis, tau_full, w_step, wavl_arr)
                    while Prad(Tobj, IR_emis, w_step, wavl_arr)>P_cdcv(Tamb,Tobj,h)+Psun_abs(R_solar,I_ES)+Pamb(Tamb, IR_emis, tau_full, w_step, wavl_arr)
                        Tobj=Tobj-0.1;
                    end
                else
                    while Prad(Tobj, IR_emis, w_step, wavl_arr) < P_cdcv(Tamb,Tobj,h)+Psun_abs(R_solar,I_ES)+Pamb(Tamb, IR_emis, tau_full, w_step, wavl_arr)
                        Tobj=Tobj+0.1;
                    end
                end
                detT_arr(ii,jj)=Tamb-Tobj;
            end
        end
        results{m}.detT_arr = detT_arr;
        results{m}.name = mat.name;
    end
end
end

% --- Subfunctions below ---

function y=Ibb(wavl_ARR,T)
    C1=3.742e8/pi; % C1 unit: W.um^4.m^-2
    C2= 1.439e4;
    y=C1./((wavl_ARR.^5).*(exp(C2./(wavl_ARR.*T))-1));
end

function y = Prad(Tsample, IR_emis, w_step, wavl_arr)
    y = pi*w_step*sum(IR_emis*Ibb(wavl_arr,Tsample));
end

function y = P_cdcv(T_env,T_film,h)
    y = h*(T_env - T_film);
end

function y = Psun_abs(R_solar,I_ES)
    y = (1-R_solar)*I_ES;
end

function y = Pamb(T, IR_emis, tau_full, w_step, wavl_arr)
    detP=0.01;
    p=0.01:detP:0.99; % p = cos(theta)
    tau_full = tau_full(:); % ensure column
    wavl_arr = wavl_arr(:); % ensure column
    t = (1-tau_full.^(1./p)); % size: [numel(wavl_arr), numel(p)]
    Ibb_vals = Ibb(wavl_arr,T); % size: [numel(wavl_arr), 1]
    TempValue = 2*pi*detP*p.*IR_emis.*(w_step*sum(t.*Ibb_vals,1)); % sum over wavl_arr, keep p
    P_amb = sum(TempValue);
    y=P_amb;
end

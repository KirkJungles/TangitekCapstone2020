%Program reads CSV files of RCS vs frequency for both measured and
%simulated data. Compares RCS values and determines how well measurement
%matches simulation.
clc, clear, close all

%% User Parameters and filenames/filepaths

sphere_diam = 125; %Diameter of sphere in mm

%Load frequency and EXPERIMENTAL RCS dataset 1 into N x 2 matrix: [frequency RCS_values]
file_name = '8-13GHz_RCS-EXP_RAD-GATED.csv'; %Name of csv file
%file_path = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\Capstone\RCS_results\'; %Folder where file is stored
file_path = '' %Leave uncommented if destination is PWD
fpath_name_exp1 = [file_path file_name]; %concatenate file path and file name

% %Load frequency and EXPERIMENTAL RCS dataset 2 into N x 2 matrix: [frequency RCS_values]
% file_name = '8-13GHz_RCS-EXP_5-19_GATED.csv'; %Name of csv file
% %file_path = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\Capstone\RCS_results\'; %Folder where file is stored
% file_path = '' %Leave uncommented if destination is PWD
% fpath_name_exp2 = [file_path file_name]; %concatenate file path and file name

%Load frequency and SIMULATED RCS data into N x 2 matrix: [frequency RCS_values]
file_name = '2-40GHz-full-125mm-diameter.csv'; %Name of csv file
%file_path = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\MATLAB\Capstone\'; %Folder where file is stored
file_path = '' %Leave uncommented if destination is PWD
fpath_name_sim = [file_path file_name]; %concatenate file path and file name

%% Read EXPERIMENTAL Data File 1 From CSV

%Read and plot RCS for Experimental Dataset 1
file_data = csvread(fpath_name_exp1, 1,0); %Read data starting at Row offset = 1, Column offset = 0; omits text header

%Store file data in respective frequency and RCS vectors
freq_exp1 = file_data(:,1); 
RCS_exp1 = file_data(:,2);

%Plot RCS vs Frequency
figure(1)
plot(freq_exp1,RCS_exp1);
title('RCS of Copper Sphere, Experimental Data 1')
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

%% Read EXPERIMENTAL Data File 2 From CSV
% file_data = csvread(fpath_name_exp2, 1,0); %Read data starting at Row offset = 1, Column offset = 0; omits text header
% 
% %Store file data in respective frequency and RCS vectors
% freq_exp2 = file_data(:,1); 
% RCS_exp2 = file_data(:,2);
% 
% %Plot RCS vs Frequency
% figure(1)
% plot(freq_exp2,RCS_exp2);
% title('RCS of Copper Sphere, Experimental Data 2')
% xlabel('Frequency (GHz)')
% ylabel('Monostatic RCS (m^{2})')

%% Read SIMULATED Data Files From CSV

file_data = csvread(fpath_name_sim, 1,0); %Read data starting at Row offset = 1, Column offset = 0; omits text header

%Store file data in respective frequency and RCS vectors
freq_sim = file_data(:,1);
RCS_sim = file_data(:,2);

%Plot RCS vs Frequency
figure(2)
plot(freq_sim,RCS_sim);
title('RCS of Copper Sphere, Simulated')
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

% %Plot normalized RCS vs Frequency
% a = sphere_diam*10^-3/2
% lam = 299792458./(freq_sim*10^9)
% y_sim = RCS_sim/(pi*a^2)
% x = a./lam
% 
% figure
% subplot(2,1,1)
% plot(x,y_sim);
% title('Normalized RCS of Copper Sphere, Simulated')
% ylabel('\sigma / \pi a^2')
% xlabel('a/\lambda')
% xlim([0.5,3])
% ylim([0,4])
% 
% subplot(2,1,2)
% plot(x,y_sim);
% title('Normalized RCS of Copper Sphere, Simulated')
% ylabel('\sigma / \pi a^2')
% xlabel('a/\lambda')



%% Shorten Simulated data to frequency range of experimental

a = find(freq_sim == freq_exp1(1));
b = find(freq_sim == freq_exp1(end));

freq_sim = freq_sim(a:b);
RCS_sim = RCS_sim(a:b);

%% Plot Both Experimental and Simulated RCS

figure(3)
subplot(2,1,1)
plot(freq_exp1,RCS_exp1);
title('RCS of Copper Sphere, Experimental Data 1')
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

subplot(2,1,2)
plot(freq_sim,RCS_sim)
title('RCS of Copper Sphere, Simulated')
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

%Uncomment and adjust subplot() arguments on previous to plot Experimental
%Data 2
% subplot(3,1,2)
% plot(freq_exp2,RCS_exp2);
% title('RCS of Copper Sphere, Experimental Data 2')
% xlabel('Frequency (GHz)')
% ylabel('Monostatic RCS (m^{2})')

%% Interpolate Experimental RCS to match Simulated

%Interpolate experimental data to match same frequency points as
%simulation
RCS_exp1_matched = interp1(freq_exp1, RCS_exp1, freq_sim);
%RCS_exp2_matched = interp1(freq_exp2, RCS_exp2, freq_sim);
freq = freq_sim;

figure(4)
subplot(2,1,1)
plot(freq,RCS_exp1_matched)
title(['RCS of Copper Sphere, Experimental Data 1'])
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

subplot(2,1,2)
plot(freq,RCS_sim)
title(['RCS of Copper Sphere, Simulated'])
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

%Uncomment and adjust subplot() arguments on previous to plot Experimental
%Data 2
% subplot(3,1,2)
% plot(freq,RCS_exp2_matched)
% title(['RCS of Copper Sphere, Experimental Data 2'])
% xlabel('Frequency (GHz)')
% ylabel('Monostatic RCS (m^{2})')

%% Calculate Normalized RCS and Percent Error

%Calculate normalized RCS and a/lambda x axes
a = sphere_diam/2*10^-3;
lam = 299792458./(freq*10^9);
RCS_exp1_norm = RCS_exp1_matched/(pi*a^2);
%RCS_exp2_norm = RCS_exp2_matched/(pi*a^2)
RCS_sim_norm = RCS_sim/(pi*a^2);
x = a./lam;

%Calculate percent Error and average
percent_err = abs(RCS_exp1_norm-RCS_sim_norm)./RCS_sim_norm*100;
avg_err = mean(percent_err);
avg_err_plot = ones(1,length(x))*avg_err;

figure(5)
subplot(3,1,1)
plot(x,RCS_exp1_norm)
title(['Normalized RCS of Copper Sphere, Experimental Data 1'])
ylabel('\sigma / \pi a^2')
grid on

subplot(3,1,2)
plot(x, RCS_sim_norm)
title(['Normalized RCS of Copper Sphere, Simulated'])
ylabel('\sigma / \pi a^2')
xlabel('a/\lambda')
grid on

subplot(3,1,3)
plot(x, percent_err,x,avg_err_plot,'--')
title({'Percent Error',['Average Error: ' sprintf('%.2f',avg_err) '%']})
ylabel('%')
ylim([0 500])
xlabel('a/\lambda')
grid on

%Uncomment and adjust subplot() arguments on previous to plot Experimental
%Data 2
% subplot(3,1,2)
% plot(x,RCS_exp2_norm)
% title(['Normalized RCS of Copper Sphere, Experimental Data 2(GATED)'])
% ylabel('\sigma / \pi a^2')
% grid on



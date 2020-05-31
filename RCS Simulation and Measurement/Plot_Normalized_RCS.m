%Program accepts RCS csv files from ANSYS simulations and plots normalized
%RCS. 

clc, clear, close all

%% User Parameters and filenames/filepaths

sphere_diam = 125; %Diameter of sphere in mm

%Load simulated frequency and RCS data into N x 2 matrix: [frequency, RCS_values]
file_name = 'p04to8GHZ_RCS_SIM.csv'; %Name of csv file
%file_path = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\MATLAB\Capstone\'; %Folder where file is stored
file_path = '' %Leave uncommented if destination is PWD
fpath_name_sim = [file_path file_name]; %concatenate file path and file name

%% Read SIMULATED Data Files From CSV

file_data = csvread(fpath_name_sim, 1,0); %Read data starting at Row offset = 1, Column offset = 0; omits text header

%Store file data in respective frequency and RCS vectors
freq_sim = file_data(:,1);
RCS_sim = file_data(:,2);

%Plot RCS vs Frequency
figure(1)
plot(freq_sim,RCS_sim);
title('RCS of Copper Sphere, Simulated')
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

%Plot normalized RCS vs Frequency
a = sphere_diam*10^-3/2
lam = 299792458./(freq_sim*10^9)
y_sim = RCS_sim/(pi*a^2)
x = a./lam

figure(2)
plot(x,y_sim);
title('Normalized RCS of Copper Sphere from Simulation')
ylabel('\sigma / \pi a^2')
xlabel('a/\lambda')
%Kirk Jungles
%S21_to_RCS.m
%4/27/2020
%
%Program accepts S21_frii measurements from Tx-Rx Experiment 
%and accepts S21_rad Measurements from Radar Experiment
%Calculates RCS(sigma) as function of frequency

clc, clear, close all

%% User Input
%Experimental Parameters described in RCS document
R1 = 1.5 %Measured R1 for both experiments (meters)
sphere_diam = 125 %Sphere diameter in mm
GatingUsed_TxRx = 0 %Set to 1 if Gating used for Tx-Rx setup, else 0
GatingUsed_RCS = 1 %Set to 1 if Gating used for RCS setup, else 0

%NOTE ABOUT S2P FILES: MATLAB requires RF Toolbox to directly read .s2p
%files. If files are in s2p format, rename the s2p files to .txt files.

%Accept S21 CSV from Tx-Rx setup
fname_frii = '00_WR-90_1500mm_WR-90_no-gate.txt' %filename of S21_frii file
%fpath_frii = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\Capstone\RCS_measurements\' %Folder where frii file is stored
fpath_frii = '' %Leave uncommented if destination is PWD

%Accept CSV from Radar setup
fname_rad = 'WR-90_WR-90_1500mm_125mm_Cu-sphere_gate.txt' %filename of S21_rad file
%fpath_rad = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\Capstone\RCS_measurements\' %Folder where radar file is stored
fpath_rad = '' %Leave uncommented if destination is PWD

%Output filename and path
fname_out = '8-13GHz_RCS-EXP_RAD-GATED.csv' %filename of RCS output file
%fpath_out = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\Capstone\RCS_results\' %Folder where radar file is stored
fpath_out='' %Leave uncommented if destination is PWD

%Concatenate file paths and names
fpath_name_frii = [fpath_frii fname_frii] %concatenate file path and file name
fpath_name_rad = [fpath_rad fname_rad] %concatenate file path and file name
fpath_name_out = [fpath_out fname_out]

%% Extract data from files(.s2p->.txt)

%Formatting to extract S11 and frequency
if GatingUsed_TxRx == 1
    startRow = 10;
else
    startRow = 9;
end
 
formatSpec = '%14f%*14*s%*13f%14f%13f%[^\n\r]';

%Read frii S21 and frequency data from .txt file
%File given has format # HZ S RI R 50.0 
filename = fpath_name_frii
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);

%Store frii data in respective frequency and S param vectors
freq_frii = dataArray{1}*10^-9 %Frequency stored in MATLAB as GHz
Real_frii = dataArray{2}
Imag_frii = dataArray{3}
S21_frii = sqrt(Real_frii.^2 + Imag_frii.^2)

%Read Radar S21 and frequency data from .txt file
if GatingUsed_RCS == 1
    startRow = 10;
else
    startRow = 9;
end
%File given has format # HZ S RI R 50.0 
filename = fpath_name_rad
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);

%Store frii data in respective frequency and S param vectors
freq_rad = dataArray{1}*10^-9 %Frequency stored in MATLAB as GHz
Real_rad = dataArray{2}
Imag_rad = dataArray{3}
S21_rad = sqrt(Real_rad.^2 + Imag_rad.^2)


%% Extract data from files(.csv)
% 
% %Assumes files are in csv format as vertical vectors [frequency, S21]
% %May need changed
% %If filetypes not CSV, do something similar(TBA)
% 
% %Otherwise, if as assumed, do:
% %%%%%%%%%%%%%%%%%%%%%frii data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Read frii S21 and frequency data from csv file
% file_data = csvread(fpath_name_frii, 1,0) %Read data starting at Row offset = 1, Column offset = 0; omits text header
% 
% %Store frii data in respective frequency and S param vectors
% freq_frii = file_data(:,1) 
% S21_frii = file_data(:,2)
% 
% %%%%%%%%%%%%%%%%%%%%%%%rad data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Read S21_rad and drequency data from csv file
% file_data = csvread(fpath_name_rad, 1,0) %Read data starting at Row offset = 1, Column offset = 0; omits text header
% 
% %Store rad data in respective frequency and S param vectors
% freq_rad = file_data(:,1) 
% S21_rad = file_data(:,2)

%% Verify that frequency vectors are identical

%Check if frequency vectors same length, else error message
if length(freq_rad) ~= length(freq_frii)
    error('Frequency vectors not same length! Check data and consider repeating experiment.')
end

%Check if frequency vectors identical, else error message
for k = [1:length(freq_rad)]
    if freq_rad(k) ~= freq_frii(k)
        error('Frequency vector elements not matched! Check data and consider repeating experiment')
    end
end

freq = freq_frii
%If network analyzer does't reproduce identical frequency sweeps for
%some reason, comment out previous error checks and interpolate the S21_rad 
%array to match the S21_frii frequency components(RARE/Unexpected)

%S21_rad = interp1(freq_rad, S21_rad, freq_frii) 
%% Calculate sigma as function of frequency

%Using equation for RCS(sigma) in RCS document, calculate sigma from data
sigma = 4*pi*R1^2*((S21_rad.^2)./(S21_frii.^2)) %Units in meter^2


%Plot sigma, S21_frii, and S21_rad on same plot
figure
subplot(2,1,1)
plot(freq, sigma)
ylabel('RCS [m^2]')
title('Experimental RCS(\sigma)')
subplot(2,1,2)
plot(freq, S21_frii, freq, S21_rad)
xlabel('Frequency [GHz]')
ylabel('|S21|')
legend('S21 Tx-Rx setup', 'S21 RCS setup')


%% Calculate and plot Normalized RCS
a = sphere_diam*10^-3/2
lam = 299792458./(freq*10^9)
y_exp = sigma/(pi*a^2)
x = a./lam

%Plot Normalized RCS
figure
plot(x,y_exp)
title(['Normalized RCS of Copper Sphere, Experimental'])
ylabel('\sigma / \pi a^2')
xlabel('a/\lambda')


%% Export results to CSV

%format will be same as expected csv files with 'frequency(GHz)' and 'RCS(m^2)' headers on first line
%and vertical frequency and RCS vectors:
%[frequency, RCS]
header = ["Frequency(GHz)" "RCS(m^2)"]
data = [freq, sigma]

%Concatenate header and data to single matrix
CSV_matrix = [header; data]

%Write matrix to user-specified filepath\filename
writematrix(CSV_matrix, fpath_name_out)

fprintf('RCS data successfully written to %s \n', fpath_name_out)





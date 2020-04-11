%Program reads CSV files of RCS vs frequency for both measured and
%simulated data. Compares RCS values and determines how well measurement
%matches simulation.


clc, clear, close all

%% Read Data Files From CSV

%Load frequency and RCS data into N x 2 matrix: [frequency RCS_values]
file_name = '2-18GHZ-fullsweep.csv' %Name of csv file
file_path = '\\thoth.cecs.pdx.edu\Home03\kjungles\My Documents\Capstone\' %Folder where file is stored
file_path_name = [file_path file_name] %concatenate file path and file name
file_data = csvread(file_path_name, 1,0) %Read data starting at Row offset = 1, Column offset = 0; omits text header

%Store file data in respective frequency and RCS vectors
freq = file_data(:,1) 
RCS = file_data(:,2)

%Plot RCS vs Frequency
figure(1)
plot(freq,RCS)
title('RCS of Copper Sphere, R = 0.125 m')
xlabel('Frequency (GHz)')
ylabel('Monostatic RCS (m^{2})')

%Function that accepts 2 [freq, RCS] pairs,
%and outputs  2 [freq, RCS] pairs with a common frequency vector,
%which allows for comparison of RCS at identical frequencies
function freq_vector = freq_match([Freq1 RCS_1], [Freq_2 RCS_2])
    %determine which vector is longer
    
    
    %interpolate shorter vector values such that it 
    %is same length as longer vector and
    %is 
end

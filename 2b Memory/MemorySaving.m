%% This script allows you to open and explore the data in a *.nc file
clear all % clear all variables
close all % close all windows

FileName = '5011CEM\Model\o3_surface_20180701000000.nc'; % define the name of the file to be used, the path is included

Contents = ncinfo(FileName); % Store the file content information in a variable.

LoadAllData;

LoadHours;

LoadAllHours;

%% Section 5: Print our results
fprintf('\nResults:\n')
fprintf('Memory used for all data: %.2f MB\n', AllDataMem)
fprintf('Memory used for hourly data: %.2f MB\n', HourDataMem)
fprintf('Maximum memory used hourly = %.2f MB\n', HourMem)
fprintf('Hourly memory as fraction of all data = %.2f\n\n', HourMem / AllDataMem)
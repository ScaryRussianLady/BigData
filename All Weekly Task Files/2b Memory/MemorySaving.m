%% This script allows you to open and explore the data in a *.nc file
clear all % clear all variables
close all % close all windows

FileName = '5011CEM2021balodea2\Model\o3_surface_20180701000000.nc'; % define the name of the file to be used, the path is included

Contents = ncinfo(FileName); % Store the file content information in a variable.

[AllDataMem] = LoadAllData(FileName);

[HourDataMem] = LoadHours(FileName);

[HourMem] = LoadAllHours(FileName);

ReportResults;
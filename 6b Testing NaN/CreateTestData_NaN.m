%% Replaces one hours worth of data with NaN
clear all
close all

OriginalFileName = '5011CEM/Model/o3_surface_20180701000000.nc';
NewFileName = '5011CEM/Model/TestFileNaN.nc';
copyfile(OriginalFileName, NewFileName);

C = ncinfo(NewFileName);
ModelNames = {C.Variables(1:8).Name};


%% Change data to NaN
BadData = NaN(700,400,1);

%% Write to *.nc file
Hour2Replace = 12;
for idx = 1:8
    ncwrite(NewFileName, ModelNames{idx}, BadData, [1, 1, Hour2Replace]);
end

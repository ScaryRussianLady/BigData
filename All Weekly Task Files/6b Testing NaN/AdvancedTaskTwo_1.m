%% Replaces one hours worth of data with NaN
clear all
close all

OriginalFileName = './Model/o3_surface_20180701000000.nc';
NewFileName = './Model/TestFileNaN2.nc';
copyfile(OriginalFileName, NewFileName);

C = ncinfo(NewFileName);
ModelNames = {C.Variables(1:8).Name};


%% Change data to NaN
BadData = NaN(700,300,2);

%% Write to *.nc file
Hour2Replace = 10;
for idx = 1:8
    ncwrite(NewFileName, ModelNames{idx}, BadData, [1, 1, Hour2Replace]);
end

%% This script allows you to open and explore the data in a *.nc file
clear all % clear all variables
close all % close all windows

FileName = '5011CEM\Model\o3_surface_20180701000000.nc'; % define the name of the file to be used, the path is included

Contents = ncinfo(FileName); % Store the file content information in a variable.

LoadAllData;

LoadHours;


%% Section 4: Cycle through the hours and load all the models for each hour and record memory use
% We use an index named 'StartHour' in our loop
HourMem = 0; % storage variable for the maximum memory in use by our data variable
StartLat = 1; % starting latitude
NumLat = 400; % number of latitude positions
StartLon = 1; % starying longitude
NumLon = 700; % number of lingitude positions
% StartHour = 1; % starting time for analyises
NumHour = 1; % Number of hours of data to load

% loop through the hours loading one at a time
for StartHour = 1:25
    Models2Load = [1, 2, 4, 5, 6, 7, 8]; % list of models to load
    idxModel = 0; % current model
    for idx = 1:7
        idxModel = idxModel + 1; % move to next model index
        LoadModel = Models2Load(idx);% which model to load
        HourlyData(idxModel,:,:,:) = ncread(FileName, Contents.Variables(LoadModel).Name,...
            [StartLon, StartLat, StartHour], [NumLon, NumLat, NumHour]);
        fprintf('Loading %s\n', Contents.Variables(LoadModel).Name); % display loading information
    end
    
    % Record the maximum memory used by the data variable so far
    HourMem = max( [ HourMem, whos('HourlyData').bytes/1000000 ] );
    fprintf('Loaded Hour %i, memory used: %.3f MB\n', StartHour, HourMem); % display loading information
end

%% Section 5: Print our results
fprintf('\nResults:\n')
fprintf('Memory used for all data: %.2f MB\n', AllDataMem)
fprintf('Memory used for hourly data: %.2f MB\n', HourDataMem)
fprintf('Maximum memory used hourly = %.2f MB\n', HourMem)
fprintf('Hourly memory as fraction of all data = %.2f\n\n', HourMem / AllDataMem)
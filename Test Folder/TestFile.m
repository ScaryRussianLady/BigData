%% Script to examine NetCDF data formats and check for NaN
% Note, you would carry out this test each time you load data.
% You should NOT test the whole file at the start

clear all
close all

DataTypes = {'NC_Byte', 'NC_Char', 'NC_Short', 'NC_Int', 'NC_Float', 'NC_Double'};

%% Test File with Errors
NaNErrors = 0;
%% Set file to test
FileName = '5011CEM2021balodea2/Model/o3_surface_20180701000000.nc'; % un rem this line to see what happens with good data
Contents = ncinfo(FileName); % Store the file content information in a variable.
FileID = netcdf.open(FileName,'NC_NOWRITE'); % open file read only and create handle

%% Create and open log file
LogFileName = 'AnalysisLog.txt';

prompt = 'Would you like to clear the log file before you continue? (1(Yes)/0(No))';
x = input(prompt)

if x == 1
    LogID = fopen('AnalysisLog.txt', 'w');
    fprintf(LogID, '%s: Starting analysis of %s\n', datestr(now, 0), FileName);
else
    LogID = fopen('AnalysisLog.txt', 'a');
    fprintf(LogID, '%s: Starting analysis of %s\n', datestr(now, 0), FileName);
end
% create new log file, 'w' replaces the file if present. To continually
% append, use 'a'
%LogID = fopen('AnalysisLog.txt', 'a');
%fprintf(LogID, '%s: Starting analysis of %s\n', datestr(now, 0), DataFileName);


StartLat = 1;
StartLon = 1;

fprintf('Testing files: %s\n', FileName)
for idxHour = 1:25
    fprintf('Testing hour: %i\n', idxHour)
    for idx = 0:size(Contents.Variables,2)-1 % loop through each variable
        % read data type for each variable and store
        [~, datatype(idx+1), ~, ~] = netcdf.inqVar(FileID,idx);
    end
    
    for idxModel = 1:8
        Data(idxModel,:,:) = ncread(FileName, Contents.Variables(idxModel).Name,...
            [StartLat, StartLon, idxHour], [inf, inf, 1]); % 'inf' reads all the data
    end
    
    %DataInFile = DataTypes(datatype)'

    %% find character data types
    FindText = strcmp('NC_Char', DataTypes(datatype));
    
    if any(FindText)
        fprintf('Error, text variables present:\n')
        fprintf(LogID, '%s: %s processing data hour %i\n', datestr(now, 0), 'Text Error', idxHour);
    else
        fprintf('All data is numeric, continue analysis.\n')
        fprintf(LogID, '%s: %s processing data hour %i\n', datestr(now, 0), 'Success', idxHour);
    end
    % check for NaNs
    if any(isnan(Data), 'All')
        NaNErrors = 1;
        %% display warning
        fprintf('NaNs present\n')
        ErrorModel = find(isnan(Data), 1, 'first');
        %% find first error:
        fprintf('Analysis for hour %i is invalid, NaN errors recorded in model %s\n',...
            idxHour, Contents.Variables(ErrorModel).Name)
        
        % Write to log file
        fprintf(LogID, '%s: %s processing data hour %i\n', datestr(now, 0), 'NaN Error', idxHour);
    else
        % write to log file
        fprintf(LogID, '%s: %s processing data hour %i\n', datestr(now, 0), 'Success', idxHour);
        fprintf('No NaN Errors!\n')
    end
    
    fprintf('\n')
    
    pause(1)
end
 fprintf('Everything logged. Starting data analysis..\n')
 pause(2)
 ParallelProcessing
 fclose(LogID);
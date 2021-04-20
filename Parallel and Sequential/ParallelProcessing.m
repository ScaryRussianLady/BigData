function ParallelProcessing
%% 1: Load Data
close all

% the data to be analysed.
FileName = '5011CEM2021balodea2\Model\o3_surface_20180701000000.nc';

Contents = ncinfo(FileName);

Lat = ncread(FileName, 'lat');
Lon = ncread(FileName, 'lon');
NumHours = 25;

%% 2: Processing parameters
% ##  provided by customer  ##
RadLat = 30.2016;
RadLon = 24.8032;
RadO3 = 4.2653986e-08;

StartLat = 1;
NumLat = 400;
StartLon = 1;
NumLon = 700;

% number of processors available.
WorkerOptions = 6;
% initialise empty results array.
Results = [];

% cycle through each data set.        
for DataOptions = [50,100,500,1000,5000]
    % assign the current data set to DataParameter.
    DataParameter = DataOptions;
    % print out the current data set.
    fprintf('%i\n', DataParameter);
    % initialise an empty array for the y-values (processing time).
    y1Vals = [];
    % cycle through each processor.
    for idxPro = 1: WorkerOptions
        % print out the current processor.
        fprintf('%i\n', idxPro);
        
        %fprintf('%i', idx1)
        %% 3: Pre-allocate output array memory
        % the '-4' value is due to the analysis method resulting in fewer output
        % values than the input array.
        NumLocations = (NumLon - 4) * (NumLat - 4);
        EnsembleVectorPar = zeros(NumLocations, NumHours); % pre-allocate memory

        %% 4: Cycle through the hours and load all the models for each hour and record memory use
        % We use an index named 'NumHour' in our loop
        % The section 'parallel processing' will process the data location one
        % after the other, reporting on the time involved.
        tic
        for idxTime = 1:NumHours
            %% 5: Load the data for each hour
            % Each hour we read the data from the required models, defined by the
            % index variable. Each model data are placed on a 'layer' of the 3D
            % array resulting in a 7 x 700 x 400 array.
            % We do this by indexing through the model names, then defining the
            % start position as the beginnning of the Lat, beginning of the Lon and
            % beginning of the new hour. We then define the number of elements
            % along each data dimension, so the total number of Lat, the total
            % number of Lon, but only 1 hour.
            % You can use these values to select a smaller sub-set of the data if
            % required to speed up testing o fthe functionality.

            DataLayer = 1;
            for idx = [1, 2, 4, 5, 6, 7, 8]
                HourlyData(DataLayer,:,:) = ncread(FileName, Contents.Variables(idx).Name,...
                    [StartLon, StartLat, idxTime], [NumLon, NumLat, 1]);
                DataLayer = DataLayer + 1;
            end

            %% 6: Pre-process the data for parallel processing
            % This takes the 3D array of data [model, lat, lon] and generates the
            % data required to be processed at each location.
            % ## This process is defined by the customer ##
            % If you want to know the details, please ask, but this is not required
            % for the module or assessment.
            [Data2Process, LatLon] = PrepareData(HourlyData, Lat, Lon);


        %% Parallel Analysis
            %% 7: Create the parallel pool and attache files for use
            % set PoolSize to the current number of processors
            PoolSize = idxPro;

            if isempty(gcp('nocreate'))
                parpool('local',PoolSize);
            end
            poolobj = gcp;
            % attaching a file allows it to be available at each processor without
            % passing the file each time. This speeds up the process. For more
            % information, ask your tutor.
            addAttachedFiles(poolobj,{'EnsembleValue'});

        %     %% 8: Parallel processing is difficult to monitor progress so we define a
        %     % special function to create a wait bar which is updated after each
        %     % process completes an analysis. The update function is defined at the
        %     % end of this script. Each time a parallel process competes it runs the
        %     % function to update the waitbar.
            DataQ = parallel.pool.DataQueue; % Create a variable in the parallel pool

            %% 9: The actual parallel processing!
            % Ensemble value is a function defined by the customer to calculate the
            % ensemble value at each location. Understanding this function is not
            % required for the module or the assessment, but it is the reason for
            % this being a 'big data' project due to the processing time (not the
            % pure volume of raw data alone).
            T4 = toc;
            parfor idx = 8: DataParameter % size(Data2Process,1)
                [EnsembleVectorPar(idx, idxTime)] = EnsembleValue(Data2Process(idx,:,:,:), LatLon, RadLat, RadLon, RadO3);
                send(DataQ, idx);
            end


            T3(idxTime) = toc - T4; % record the parallel processing time for this hour of data
            fprintf('Parallel processing time for hour %i : %.1f s\n', idxTime, T3(idxTime))

        end % end time loop        

        T2 = toc;
        delete(gcp);

        %% 10: Reshape ensemble values to Lat, lon, hour format
        EnsembleVectorPar = reshape(EnsembleVectorPar, 696, 396, []);
        fprintf('Total processing time for %i workers = %.2f s\n', idxPro, sum(T3));
        format longG
        % append the processor and the time taken to process with the
        % current data set and number of processors.
        Results = [Results; idxPro, sum(T3)]
        % add the time taken to process to the y-value array.
        y1Vals = [y1Vals; sum(T3)]
    end
    % Run the function that produces the graph for parallel processing.
    ParGraph(DataParameter,WorkerOptions,y1Vals)
end
% lines 158-163 work out the line of best fit equation and then display
% this on the top left of the graph.

end % end function

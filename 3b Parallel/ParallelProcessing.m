function ParallelProcessing
%% 1: Load Data
close all

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

WorkerOptions = 6;
Results = [];

        
for DataOptions = [500,1000,5000]
    DataParameter = DataOptions;
    fprintf('%i\n', DataParameter);
    y1Vals = [];
    for idxPro = 1: WorkerOptions
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
        Results = [Results; idxPro, sum(T3)]
        y1Vals = [y1Vals; sum(T3)]
    end
    x1Vals = [1:WorkerOptions]
    figure(1)
    hold on
    plot(x1Vals, y1Vals, 'Color', rand(1,3), 'LineWidth', 3)
    xlabel('Number of Processors')
    ylabel('Processing Time (s)')
    title('Processing Time vs Number of Processors')
    p = polyfit(x1Vals,y1Vals,1);
    f = polyval(p,x1Vals);
    hold on
    plot(x1Vals,f,'--r')
end
xl = xlim;
yl = ylim;
xt = 0.05 * (xl(2)-xl(1)) + xl(1);
yt = 0.90 * (yl(2)-yl(1)) + yl(1);
caption = sprintf('y = %f * x + %f', p(1), p(2));
text(xt, yt, caption, 'FontSize', 8, 'Color', 'r', 'FontWeight', 'bold');
legend('500 Data', 'Best Fit: 500', '1,000 Data', 'Best Fit: 1,000', '5,000 Data', 'Best Fit: 5,000')

estimationOfProcessors = round((7200-p(2))/-p(1));
estimationOfProcessors
end % end function

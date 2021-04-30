FileName = '5011CEM2021balodea2/Model/o3_surface_20180701000000.nc';

TestFile
% print out that the data analysis will begin.
fprintf('Everything logged. Starting data analysis..\n')
fprintf('\n Running Sequential Processing..\n')
% run sequential processing.
SequentialProcessing
fprintf('\n Running Parallel Processing..\n')
 % run parallel processing.
ParallelProcessing
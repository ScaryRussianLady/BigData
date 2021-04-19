%% Plotting graphs in Matlab
clear all
close all

%% Show two plots on different y-axes
%% 500 data processed
x1Vals = [1:6];
y1Vals = [109.60, 62.49, 47, 38.55, 34.31, 32.32];
figure(1)
hold on
plot(x1Vals, y1Vals, '-bd')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')


%% 1,000 data processed
x2Vals = [1:6];
y2Vals = [256.68, 142.61, 97.97, 78.80, 70.61, 64];
figure(1)
yyaxis right
plot(x2Vals, y2Vals, '-rx')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')

x3Vals = [1:6];
y3Vals = [1583.08, 840.57, 607.31, 506.04, 446.73, 405.15];
figure(1)
yyaxis right
plot(x3Vals, y3Vals, '-rx')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Processing time vs number of processors')

legend('500 Data', '1,000 Data', '5,000 Data')


%% Show two plots on same y-axis
%% Mean processing time
y1MeanVals = y1Vals / 250;
y2MeanVals = y2Vals / 5000;

figure(2)
plot(x1Vals, y1MeanVals, '-bd')
hold on
plot(x2Vals, y2MeanVals, '-rx')
xlabel('Number of Processors')
ylabel('Processing time (s)')
title('Mean Processing time vs number of processors')
legend('250 Data', '5,000 Data')
function ParGraph(DataParameter,WorkerOptions,y1Vals)
% initialise x-value array with the number of processors.
x1Vals = [1:WorkerOptions];
figure(2)
% hold on to the previous values.
hold on
% plot x and y with a different colour for each data set.
plot(x1Vals, y1Vals, 'Color', rand(1,3), 'LineWidth', 2)
% x-axis labeled.
xlabel('Number of Processors')
% y-axis labeled.
ylabel('Processing Time (s)')
% title of the graph.
title('Processing Time vs Number of Processors (Parallel)')
% p returns m and c to be used for working out the lines of best fit.
p = polyfit(x1Vals,y1Vals,1);
f = polyval(p,x1Vals);
% hold on to the previous values in the graphh.
hold on
% plot the line of best fit.
plot(x1Vals,f,'--r')
xl = xlim;
yl = ylim;
xt = 0.05 * (xl(2)-xl(1)) + xl(1);
yt = 0.90 * (yl(2)-yl(1)) + yl(1);
caption = sprintf('y = %f * x + %f', p(1), p(2));
text(xt, yt, caption, 'FontSize', 8, 'Color', 'r', 'FontWeight', 'bold');
% keys so that the client has an easier time of understanding the values.
% work out the estimated number of processors required for the given target
% processing time.
% 7200 is the value of 2 hours in seconds.
estimationOfProcessors = round((7200-p(2))/-p(1));
% print out the estimation.
estimationOfProcessors
legend('50 Data', 'Best Fit: 50','100 Data', 'Best Fit: 100','500 Data', 'Best Fit: 500', '1,000 Data', 'Best Fit: 1,000', '5,000 Data', 'Best Fit: 5,000')


y1MeanVals = y1Vals / DataParameter;
figure(3)
plot(x1Vals, y1MeanVals, 'Color', rand(1,3), 'LineWidth', 2)
hold on
xlabel('Number of Processors')
ylabel('Processing Time (s)')
title('Mean Processing Time vs Number of Processors (Parallel)')
legend('50 Data','100 Data', '500 Data', '1,000 Data', '5,000 Data')
end
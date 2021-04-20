function SeqGraph(processor,time)
% initialise x-value array with the number of processors.
x1Vals = processor;
y1Vals = time;
figure(1)
% hold on to the previous values.
% plot x and y.
plot(x1Vals,y1Vals,'r.')
hold on
% x-axis labeled.
xlabel('Number of Processors')
% y-axis labeled.
ylabel('Processing Time (s)')
% title of the graph.
title('Processing Time vs Number of Processors (Sequential)')
hold on
legend('50 Data','100 Data','500 Data', '1,000 Data','5,000 Data')
end
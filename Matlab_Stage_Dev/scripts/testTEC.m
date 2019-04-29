clear all
delete(instrfindall)
clc

% produce a plot of temperature over time in seconds by querying the
% instrument at a set time interval
% goal is to test which settings produce the smallest temp fluctuation
% Victor Bass 2013
% Vince Wu Nov 2013

time = 10; % s
temp = 30; % degree
TEC = TECNewport3040;
TEC.connect();

TEC.set_current_limit(); % set TEC output current limit
TEC.set_target_temp(temp); % set the temp TEC will try to maintain

% run TEC for specified amount of time in seconds, recording temp periodically

TEC.start(); % turn on TEC output
test_stopwatch = tic; % stopwatch to keep track of time

% create axes to plot data on
figure, 
plot_axes = axes;
title('TEC test plot');
xlabel('Time (seconds)');
ylabel('Temperature (C)');

timeArray = [];
tempArray = [];
elapsedTime = toc(test_stopwatch);
while elapsedTime < time
    timeArray(end+1) = elapsedTime;
    tempArray(end+1) = str2double(TEC.currentTemp());
    plot(plot_axes, timeArray, tempArray, 'r-'), grid on;
    pause(0.25)
    elapsedTime = toc(test_stopwatch);
end

TEC.stop();
TEC.disconnect();
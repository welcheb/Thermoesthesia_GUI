%% create example thermoesthesia plots

%% clean slate
close all; clear all; clc;

%% habituation
csv_filename1 = './recordings/HABITUATION.csv';
d1 = Thermoesthesia_Plot(csv_filename1);
imwrite(frame2im(getframe(gcf)),'./png/HABITUATION.png');

%% cyclic cooling
csv_filename2 = './recordings/CYCLIC_COOLING.csv';
d1 = Thermoesthesia_Plot(csv_filename2);
imwrite(frame2im(getframe(gcf)),'./png/CYCLIC_COOLING.png');

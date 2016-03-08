%
% [DATA_STRUCT] = THERMOESTHESIA_PLOT(CSV_FILENAME)
%
% Reads and plots a thermoesthesia data in CSV file CSV_FILENAME.
%
% DATA_STRUCT contains 3 fields which are column vectors of the same length
%
% data_struct.s      % time in seconds
% data_struct.level  % thermoestesia level (integers 0 to 100) ('very cold' to 'very hot')
% data_struct.shiver % shiver status (0=='none', 1=='sporadic', 2=='constant')
%
% Developed with MATLAB R2014b
%
% Supported by a grant from the National Institutes of Health (NIH), National
% Institute of Diabetes and Digestive and Kidney Diseases (NIDDK) - R01DK105371
%
% Example:
%
%   % open Thermoesthesia GUI with default settings
%   csv_filename = Thermoesthesia_GUI('TEST');
%
%   % plot thermoesthesia values
%   data_struct = Thermoesthesia_Plot(csv_filename);
%

%
% History
% 2016.03.07 - welcheb - updated to version 0.1 for public posting
%
function [data_struct] = Thermoesthesia_Plot(csv_filename)

	%% version string
    version_str = 'v0.1';

    %% initialize emptry data structure
    data_struct = [];

    try
        data = csvread(csv_filename, 1, 0);
        data_struct.s = data(:,1)';
        data_struct.level = data(:,2)';
        data_struct.shiver = data(:,3)';
    catch
        error('Cannot load Thermoestesia file: %s', csv_filename);
    end

    fig_w = 800;
    fig_h = 600;
    figure('Position',[50, 50, fig_w, fig_h]);
    [hAx,hLine1,hLine2] = plotyy(data_struct.s, data_struct.level, ...
                                 data_struct.s, data_struct.shiver);

    % adjust axis limits
    set(hAx(1),'YLim',[0 105],'YTick',[0:10:100]);
    set(hAx(2),'YLim',[0 2.1],'YTick',[0:1:2]);

    hTitle = title(sprintf('\nThermoesthesia GUI (%s) ::: %s\n', version_str, csv_filename) );
    set(hTitle,'interpreter', 'none');
    grid on;
    hXlabel = xlabel('Time (s)');
    hYlabel1 = ylabel(hAx(1), sprintf('Thermoesthesia Level\n(0 == Very Cold, 50 == Comfortable (Neutral), 100 == Very Hot)') ); % left y-axis
    hYlabel2 = ylabel(hAx(2), sprintf('Shiver Status\n(0 == none, 1 == sporadic, 2 == constant)') ); % right y-axis

    % colors
    Line1_color = 'b';
    Line2_color = 'r';
    set(hLine1,'color',Line1_color);
    set(hLine2,'color',Line2_color);

    fontsize = 16;
    set(hTitle,'fontsize',fontsize);
    set(hXlabel,'fontsize',fontsize);
    set(hYlabel1,'fontsize',fontsize, 'color', Line1_color);
    set(hYlabel2,'fontsize',fontsize, 'color', Line2_color);

%
% tGUI(EXPERIMENT_NAME_STRING)
%
% Opens a Thermoesthesia GUI with figure title EXPERIMENT_NAME_STRING.
%
% If EXPERIMENT_NAME_STRING is not provided or is empty, it is set to TEST
%
% Starts a CSV file with name EXPERIMENT_NAME_STRING_YYYYMMDD_HHMMSS.csv
% in the ./recordings/ folder
%
% CSV file has three columns:
% 1. 's' : for seconds since GUI start (2 decimal places)
% 2. 'level' : integer marker level (integers 0 to 100) ('very cold' to 'very hot')
% 3. 'shiver' : shiver status (0=='none', 1=='sporadic', 2=='constant')
%
% Only button up events are recorded into the CSV file.
%
% One button is available to study personnel to start/pause recording.
%
% To start a new file, close the GUI and call again
%
% tGUI(EXPERIMENT_NAME_STRING)
%
% Open GUI with custom parameter settings
%
% tGUI(EXPERIMENT_NAME_STRING, GUI_PARAMS)
%
% Return the name of the CSV filename used to store Thermoesthesia values
%
% CSV_FILENAME = tGUI(EXPERIMENT_NAME_STRING)
%
% GUI_PARAMS is a structure with the following fields and default values
%
% gui_params.marker_color = 'g';     % marker color
% gui_params.marker_alpha = 'g';     % marker alpha (transparency) 0.0 to 1.0
% gui_params.txt_fontsize = 16;      % font size for shivering status text
% gui_params.txt_fontname = 'Arial'; % font size for shivering status text
% gui_params.txt_color = 'b';        % font color for shivering status text
% gui_params.shiver_box_color = 'r'; % box (ellipse) color for shivering status
% gui_params.keys_dn = [ double('.37') 28 31 13]; % keys to mover marker down
% gui_params.keys_up = [ double('+48') 29 30];    % keys to mover marker up
% gui_params.keys_shiver = [ double('- 56')];     % keys to change shiver status
% gui_params.gui_timer_period_seconds = 30;   % seconds between auto logging to file
% gui_params.beep_on = true;   % flag to activate audible beep of shiver status (1, 2 or 3 beeps for 'none', 'sporadic' or 'constant')
%
% Developed with MATLAB R2014b
%
% Supported by a grant from the National Institutes of Health (NIH), National
% Institute of Diabetes and Digestive and Kidney Diseases (NIDDK) - R01DK105371
%
% Usage notes:
%
% * Be sure to click Thermoesthesia GUI window with mouse after beginning
%   to record so that button events move marker and shiver status box.
%
% Example:
%
%   % open figure black background to make Thermoesthesia GUI clearly visible
%   hf555 = figure(555); set(hf555,'Color',[0 0 0],'menubar','none');
%
%   % open Thermoesthesia GUI with default settings
%   tGUI('TEST');
%

%
% History
% 2016.03.07 - welcheb - updated to version 0.1 for public posting
% 2016.10.27 - coolbac - updated to version 0.2.0 changes include:
%                      - shortened function name to tGUI
%
function csv_filename = tGUI(experiment_name_string, gui_params)

	%% Assign date_string and set tic
    date_string = datestr(now,'yyyymmdd_HHMMSS');
    tic;

    %% version string
    version_str = 'v0.1';

    %% Detect/assign experiment_name_string
    if nargin<1 || length(experiment_name_string)<1,
        experiment_name_string = 'TEST';
    end
    experiment_name_string = strrep(experiment_name_string,' ','_'); % use underscores for any spaces

    %% handle GUI parameters
    if nargin < 2,
        gui_params = [];
    end

    %% marker_color
    % marker color
    if ~isfield(gui_params,'marker_color')
        gui_params.marker_color = 'g';
    end

    %% marker_alpha
    % marker alpha (transparency) 0.0 to 1.0
    if ~isfield(gui_params,'marker_alpha')
        gui_params.marker_alpha = 0.6;
    end

    %% txt_fontsize
    % font size for shivering status text
    if ~isfield(gui_params,'txt_fontsize')
        gui_params.txt_fontsize = 16;
    end

    %% txt_fontname
    % font size for shivering status text
    if ~isfield(gui_params,'txt_fontname')
        gui_params.txt_fontname = 'Arial';
    end

    %% txt_color
    % font color for shivering status text
    if ~isfield(gui_params,'txt_color')
        gui_params.txt_color = 'b';
    end

    %% shiver_box_color
    % box (ellipse) color for shivering status
    % font color for shivering status text
    if ~isfield(gui_params,'shiver_box_color')
        gui_params.shiver_box_color = 'r';
    end

    %% keys_dn
    % keys to mover marker down
    if ~isfield(gui_params,'keys_dn')
        gui_params.keys_dn = [ double('.37') 28 31 13];
    end

    %% keys_up
    % keys to mover marker up
    if ~isfield(gui_params,'keys_up')
        gui_params.keys_up = [ double('+48') 29 30];
    end

    %% keys_shiver
    % keys to change shiver status
    if ~isfield(gui_params,'keys_shiver')
        gui_params.keys_shiver = [ double('- 56')];
    end

    %% keys_shiver
    % seconds between auto logging to file
    if ~isfield(gui_params,'gui_timer_period_seconds')
        gui_params.gui_timer_period_seconds = 30;
    end

    %% beep_on
    % flag to activate audible beep of shiver status (1 or 2 beeps for 'none', 'shiver')
    if ~isfield(gui_params,'beep_on')
        gui_params.beep_on = false;
    end

    %% open file and enter first default marker position
    global csv_filename;
    csv_filename = sprintf('./recordings/%s_%s.csv', experiment_name_string, date_string);
    fid = fopen(csv_filename,'w');
    if fid<0,
        error('Cannot open %s', csv_filename);
    end
    fprintf(fid,'"s","level","shiver"\n');
    global marker_level shiver_level_now shiver_level_prev;
    marker_level = 50;
    shiver_level_now = 0; % 0 == none, 1 == shiver
    shiver_level_prev = 0;
    fprintf(fid,'%.2f,%d,%d\n', toc, marker_level, shiver_level_now);
    fclose(fid); % close file after every write

    %% load Thermoesthesia_Visual_Analog_Scale image
    img = imread('./png/R01_BAT_FIG_8_Thermoesthesia_Visual_Analog_Scale.png');
    img_h = size(img,1);
    img_w = size(img,2);

    %%  Create and then hide the UI as it is being constructed.
    fig_w = 1600;
    button_region_h = 40;
    fig_h = round(fig_w/img_w * img_h) + button_region_h;
    hf = figure('Visible','on', ...
        'KeyPressFcn', {@figure_KeyPressFcn}, ...
        'KeyReleaseFcn', {@figure_KeyReleaseFcn}, ...
        'DeleteFcn', {@figure_DeleteFcn}, ...
        'menubar', 'none', ...
        'Color',[1 1 1], ...
        'name', sprintf('Thermoesthesia GUI (%s) ::: %s', version_str, experiment_name_string),'numbertitle','off', ...
        'Position',[50,50,fig_w,fig_h]);

    %% display image
    button_area_fraction = button_region_h / fig_h;
    hplot = subplot('Position',[0.0 button_area_fraction 1.0 1.0-button_area_fraction]);
    himg = imagesc(img);
    set(hplot,'Visible','off');

    %% shivering text
    txt_x0 = 792;
    txt_y0 = 350;
    txt_color = gui_params.txt_color;
    txt_fontname = gui_params.txt_fontname;
    txt_fontsize = gui_params.txt_fontsize;

    htxt_shiver = text(txt_x0, txt_y0, 'Shivering?');
    set(htxt_shiver, 'FontName', txt_fontname, 'FontSize', txt_fontsize, 'Color', txt_color);

    htxt_none = text(txt_x0 + 410, txt_y0, 'None');
    set(htxt_none, 'FontName', txt_fontname, 'FontSize', txt_fontsize, 'Color', txt_color);

    htxt_sporadic = text(txt_x0 + 640, txt_y0, 'Shivering');
    set(htxt_sporadic, 'FontName', txt_fontname, 'FontSize', txt_fontsize, 'Color', txt_color);

    %% draw initial shiver_box
    shiver_box_facecolor = 'none';
    shiver_box_edgecolor = gui_params.shiver_box_color;
    shiver_box_linewidth = 2;
    shiver_box_curvature = [0.8 0.8];
    shiver_box_position = [];
    update_shiver_box_position;
    hbox = rectangle('Position', shiver_box_position, 'Curvature', shiver_box_curvature);
    set(hbox, ...
        'FaceColor', shiver_box_facecolor, ...
        'EdgeColor', shiver_box_edgecolor, ...
        'LineWidth', shiver_box_linewidth, ...
        'Clipping', 'off');

    %% add pushbutton
    button_w = 150;
    button_h = 40;
    hbutton = uicontrol('Style','pushbutton','String','PAUSED', ...
        'FontSize', 16, ...
        'BackgroundColor', 0.8*[1.0 1.0 1.0], ...
        'Callback', {@pushbutton_Callback}, ...
        'Position',[10 10 button_w button_h]);
    global recording_flag;
    recording_flag = false;

    %% draw initial marker
    marker_color = gui_params.marker_color;
    marker_alpha = gui_params.marker_alpha;
    marker_y = [];
    marker_x = [];
    update_marker_xy;
    hmarker = patch(marker_x, marker_y, marker_color);
    set(hmarker,'FaceAlpha',marker_alpha);

    global keys_dn keys_up keys_shiver;
    keys_dn = [ double('.37') 28 31 13];
    keys_up = [ double('+48') 29 30];
    keys_shiver = [ double('- 56')];

    %% start a fixed rate timer
    gui_timer_period_seconds = gui_params.gui_timer_period_seconds;
    gui_timer = timer('StartDelay', 0, 'Period', gui_timer_period_seconds, 'TasksToExecute', 500, 'ExecutionMode', 'fixedRate');
    gui_timer.TimerFcn = @(~,~) log_to_file(true);
    start(gui_timer);

    function figure_KeyReleaseFcn(source,eventdata),

        %eventdata
        if length(eventdata.Character)>0,
            key_val = double(eventdata.Character(1));
            %disp(key_val);
            if any(key_val==keys_shiver),

                if shiver_level_now==0,
                    shiver_level_now = 1;
                    shiver_level_prev = 0;
                elseif shiver_level_now==1,
                    shiver_level_now = 0;
                    shiver_level_prev = 1;
                end

                this_beep_flag = true;
            else
                this_beep_flag = false;
            end % end keys_shiver if
        end

        update_shiver_box;

        log_to_file(this_beep_flag);

    end

    function figure_KeyPressFcn(source,eventdata),
        %eventdata
        if length(eventdata.Character)>0,
            key_val = double(eventdata.Character(1));
            %disp(key_val);
            if any(key_val==keys_dn),
                marker_level = max(0, marker_level - 1);
            elseif any(key_val==keys_up),
                marker_level = min(100, marker_level + 1);
            end
        elseif strcmp('clear',eventdata.Key),
             marker_level = max(0, marker_level - 1);
        end

        update_marker;
    end

    function pushbutton_Callback(source,eventdata)
        if recording_flag,
            recording_flag = false;
            set(hbutton,'String','PAUSED','BackgroundColor', 0.8*[1.0 1.0 1.0]);
        else
            recording_flag = true;
            set(hbutton,'String','RECORDING','BackgroundColor',[1.0 0.0 0.0]);
            log_to_file(true);
        end
    end

    function log_to_file(beep_flag),

        if nargin<1,
            beep_flag = false;
        end

        %% print entries to file
        if recording_flag,

            disp( sprintf('Recordings logged at %s', datestr(now)) );

            fid = fopen(csv_filename,'a'); % append
            if fid<0,
                error('Cannot open %s', csv_filename);
            end
            fprintf(fid,'%.2f,%d,%d\n', toc, marker_level, shiver_level_now);
            fclose(fid); % close file after every write
        else
            disp('NOT RECORDING!!!');
        end

        if beep_flag && gui_params.beep_on,
            %% play beeps for shiver level
            beep_pause = 0.5; % seconds
            beep on;
            for k=1:(shiver_level_now+1),
                beep
                pause(beep_pause);
            end
        end

    end

    % calculate marker x and y coordinates of marker arrow
    function update_marker_xy
        marker_pos_levels = [76 353 625 899 1169 1443 1711 1983 2260 2529 2802];
        marker_h = 75;
        marker_w = 40;

        marker_y1 = 100;

        if mod(marker_level,10)==0,
            marker_x1 = marker_pos_levels(marker_level/10 + 1);
        else
            marker_level_tens_place = floor(marker_level/10);
            marker_level_ones_place = marker_level - marker_level_tens_place * 10;
            marker_pos_tens_left = marker_pos_levels(marker_level_tens_place + 1);
            marker_pos_tens_right = marker_pos_levels(marker_level_tens_place + 2);
            marker_x1 = marker_pos_tens_left + marker_level_ones_place/10 * (marker_pos_tens_right - marker_pos_tens_left);
        end

        marker_y2 = marker_y1 - marker_h;
        marker_x2 = marker_x1 + marker_w/2;

        marker_y3 = marker_y1 - marker_h;
        marker_x3 = marker_x1 - marker_w/2;

        marker_y = [marker_y1 marker_y2 marker_y3];
        marker_x = [marker_x1 marker_x2 marker_x3];
    end

    %% calculate position of shiver box
    function update_shiver_box_position
        shiver_box_h = 80;
        shiver_box_w = 305;
        shiver_box_y = 310;
        shiver_box_x = [1120 1400 1735];

        shiver_box_position = [shiver_box_x(shiver_level_now+1) shiver_box_y shiver_box_w shiver_box_h];
    end

    %% update displayed marker position
    function update_marker
        update_marker_xy;
        set(hmarker,'XData', marker_x, 'YData', marker_y);
    end

    %% update displayed shiver box position
    function update_shiver_box
        update_shiver_box_position;
        set(hbox, 'Position', shiver_box_position);
    end

    %% handle figure deletion
    function figure_DeleteFcn(source,eventdata),
        delete(gui_timer);
    end

end

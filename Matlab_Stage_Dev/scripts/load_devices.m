function data = load_devices(benchObj, filename)

% This function takes in a .txt or .csv file containing information about the chip
% assuming the input format described below. The information for each
% device is stored in a device object by Device ID. The function returns
% a cell array of device objects.

% INPUT FORMAT: 
% <X-coord> <Y-coord> <Mode> <Wvl> <Type> <Device ID> <Comment>

try
    dev_data = importdata(filename);
    msg = strcat( 'Opened coordinate file: ', filename);
    benchObj.msg(msg);
catch ME
    msg = strcat('Cannot open coordinate file: ', filename);
    benchObj.msg('ERROR READING FILE');
    benchObj.msg(msg);
    rethrow(ME);
end

%% LOAD DATA

%Assume first line in the file is the text header containing column
%names

loaded = 1;
firstline = dev_data{1,1};
headers = textscan(firstline, '%s', 'delimiter', ',');
headers = headers{1};

x_coords = [];
y_coords = [];
deviceModes = {};
deviceTypes = {};
deviceWvls = [];
deviceIDs = {};
deviceComments = {};

% Import data
for i = 2:length(dev_data)
    thisDeviceData = dev_data{i, 1};
    if (loaded)
        thisDeviceData = textscan(thisDeviceData, '%s', 'delimiter', ',');
        
        thisDeviceData = thisDeviceData{1};
        thisDevice_x = str2double(thisDeviceData{1});
        thisDevice_y = str2double(thisDeviceData{2});
        thisDeviceMode = thisDeviceData{3};
        thisDeviceWvl = str2double(thisDeviceData{4});
        thisDeviceType = thisDeviceData{5};
        thisDeviceID = thisDeviceData{6};
        try
            thisDeviceComment = thisDeviceData{7};
        catch
            thisDeviceComment = ' ';
            msg = [thisDeviceID, ': Comment missing! Line: ', num2str(i)];
            benchObj.msg(msg);
        end
        
        % Check validness of X coordinate of this Device
        if isnumeric(thisDevice_x)
            x_coords(end+1) = thisDevice_x;
        else
            msg = ['Invalid "X coordinate" type in coordinatee file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg);
            loaded = 0;
            break;
        end
        % Check validness of Y coordinate of this Device
        if isnumeric(thisDevice_y)
            y_coords(end+1) = thisDevice_y;
        else
            msg = ['Invalid "Y coordinate" type in coordinatee file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg);
            loaded = 0;
            break;
        end
        % Check validness of device mode of this Device
        if ischar(thisDeviceMode)
            deviceModes{end+1} = thisDeviceMode;
        else
            msg = ['Invalid "Mode" type in coordinatee file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg);
            loaded = 0;
            break;
        end
        % Check validness of wavelength of this Device
        if isnumeric(thisDeviceWvl)
            deviceWvls(end+1) = thisDeviceWvl;
        else
            msg = ['Invalid "Wvl" type in coordinatee file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg);
            loaded = 0;
            break;
        end
        % Check validness of device type of this Device
        if ischar(thisDeviceType)
            deviceTypes{end+1} = thisDeviceType;
        else
            msg = ['Invalid "Type" type in coordinatee file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg);
            loaded = 0;
            break;
        end
        % Check validness of device ID (naming) of this Device
        validID = true;
        if ischar(thisDeviceID)
            firstChar = thisDeviceID(1);
            if ~isstrprop(firstChar, 'digit')
                strrep(thisDeviceID, '-', '_');
                strrep(thisDeviceID, ' ', '_');
                if ~isempty(thisDeviceID)
                    for index = 1:length(deviceIDs)
                        if strcmp(thisDeviceID, deviceIDs{index})
                            msg = ['Device: ', thisDeviceID, ...
                                ' already exists. Load aborted --- line: ',  num2str(i)];
                            benchObj.msg(msg);
                            break;
                        end
                    end
                    deviceIDs{end+1} = thisDeviceID;
                else
                    validID = false;
                end
            else
                validID = false;
            end
        else
            validID = false;
        end
        if ~validID
            msg = ['Invalid "DeviceID" Data in coordinate file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg)
            loaded = 0;
        end
        % Check validness of comment of this Device
        if ischar(thisDeviceComment)
            deviceComments{end+1} = thisDeviceComment;
        else
            msg = ['Invalid "Comment" Data in coordinate file line: ', num2str(i), '. Load aborted'];
            benchObj.msg(msg)
            loaded = 0;
        end
    else
        break; % break the loop if loaded gets set to 0 at any point in the reading process
    end
end

if loaded
    % Create device objects
    for i = 1:length(x_coords)
        device_prop = struct(...
            'x', x_coords(i), ...
            'y', y_coords(i), ...
            'mode', deviceModes{i}, ...
            'name', deviceIDs{i}, ...
            'comment', deviceComments{i}, ...
            'wvl', deviceWvls(i), ...
            'type', deviceTypes{i});
        
        benchObj.devices.(deviceIDs{i}) = DeviceClass(benchObj, device_prop);
    end
    data.x = x_coords';
    data.y = y_coords';
    data.mode = deviceModes;
    data.name = deviceIDs;
    data.comment = deviceComments;
    data.wvl = deviceWvls;
    data.type = deviceTypes;
end
end

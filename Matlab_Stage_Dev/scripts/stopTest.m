% Function to query user whether to delete the test files when "stop"
% button is pressed
% --- Vince Wu
function stopTest(obj, generalFilePath, dateTag)
testPanel = panel_index('test');
obj.msg('<<<<<<<<<<  Test canceled.  >>>>>>>>>>')
test = obj.AppSettings.infoParams.Task;
message = sprintf('Test: %s canceled.\nDo you want to delete dataset?', test);
response = questdlg(...
    message, ...
    'Cancel Test', ...
    'Yes', 'No', 'Yes');
if strcmp(response, 'Yes')
    deviceNames = fieldnames(obj.devices);
    for ii = 1:length(deviceNames)
        if obj.devices.(deviceNames{ii}).getProp('Selected')
            specificFilePath = strcat(...
                generalFilePath,...
                obj.devices.(deviceNames{ii}).Name,'\',...
                obj.AppSettings.infoParams.Task,'\',...
                dateTag,'\');
            if (exist(specificFilePath, 'dir') == 7) % If the directory exist, it would return 7
                try
                    rmdir(specificFilePath, 's'); % remove directory and all subdirectories
                    obj.devices.(deviceNames{ii}).resetScanNumber();
                    msg = ['Deleted ',specificFilePath];
                    obj.msg(msg);
                catch ME
                    obj.msg(ME.message);
                end
            end
        end
    end
    obj.msg('Test Dataset deleted!');
else % No
    obj.msg('Incomplete Dataset stored!');
end
set(obj.gui.panel(testPanel).testControlUI.stopButton, 'UserData', 0); % stop
set(obj.gui.panel(testPanel).testControlUI.stopButton, 'Enable', 'off');
set(obj.gui.panel(testPanel).testControlUI.pauseButton, 'Enable', 'off');
set(obj.gui.panel(testPanel).testControlUI.startButton, 'Enable', 'on');
end
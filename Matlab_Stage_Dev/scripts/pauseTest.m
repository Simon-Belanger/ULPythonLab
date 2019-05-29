% Vince Wu
function pauseTest(obj)
testPanel = panel_index('test');
test = obj.AppSettings.infoParams.Task;
obj.msg('<<<<<<<<<<  Test Pause.  >>>>>>>>>>');
message = sprintf('Test: %s paused.\nClick OK to continue', test);
uiwait(msgbox(message, 'Pause Test', 'modal'));
obj.msg('<<<<<<<<<<  Test Resume.  >>>>>>>>>>');
set(obj.gui.panel(testPanel).testControlUI.pauseButton, 'UserData', 0); % reset pause flag
set(obj.gui.panel(testPanel).testControlUI.pauseButton, 'Enable', 'on');
set(obj.gui.panel(testPanel).testControlUI.startButton, 'Enable', 'off');
end
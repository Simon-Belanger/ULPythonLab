% Call as such: [red,green1,green2,blue] = LucamGetSnapshotColorGain(<cameraNum>);
function [red, green1, green2, blue] = LucamGetSnapshotColorGain(cameraNum)
% LucamGetSnapshotColorGain - Returns the snapshot color gain values.
try
    gains = LuDispatcher(21, cameraNum);
catch
    errordlg(lasterr, 'Color Gain Error', 'modal');
end
red = gains(1);
green1 = gains(2);
green2 = gains(3);
blue = gains(4);
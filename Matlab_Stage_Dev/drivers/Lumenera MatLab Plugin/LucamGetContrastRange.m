% Call as such: [min,max] = LucamGetContrastRange(<cameraNum>);
function [min, max] = LucamGetContrastRange(cameraNum)
% - LucamGetContrastRange - Returns the valid range of contrast values.
try
    range = LuDispatcher(53, cameraNum);
catch
    errordlg(lasterr, 'Contrast Error', 'modal');
end
min = range(1);
max = range(2);
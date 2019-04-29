% Call as such: [min,max] = LucamGetSaturationRange(<cameraNum>);
function [min, max] = LucamGetSaturationRange(cameraNum)
% - LucamGetSaturationRange - Returns the valid range for the saturation value.
try
    range = LuDispatcher(56, cameraNum);
catch
    errordlg(lasterr, 'Saturation Error', 'modal');
end
min = range(1);
max = range(2);
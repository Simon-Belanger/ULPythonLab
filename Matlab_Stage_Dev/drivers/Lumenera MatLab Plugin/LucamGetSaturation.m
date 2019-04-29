function [saturation] = LucamGetSaturation(cameraNum)
% LucamGetSaturation - Returns the current saturation value.
try
    saturation = LuDispatcher(49, cameraNum);
catch
    errordlg(lasterr, 'Saturation Error', 'modal');
end
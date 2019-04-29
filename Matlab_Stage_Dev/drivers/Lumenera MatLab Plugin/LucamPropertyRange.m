function [min, max] = LucamPropertyRange(property, cameraNum)
% - LucamPropertyRange - Returns the property's valid range of values.
try
    range = LuDispatcher(51, cameraNum, property);
catch
    errordlg(lasterr, 'Property Error', 'modal');
end
min = range(1);
max = range(2);
function [value, flags] = LucamGetProperty(property, cameraNum)
% LucamGetProperty - Returns the current property value.
try
    propvalue = LuDispatcher(39, cameraNum, property);
catch
    errordlg(lasterr, 'Property Error', 'modal');
end
value = propvalue(1);
flags = propvalue(2);
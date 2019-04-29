function LucamSetProperty(flags, value, property, cameraNum)
% LucamSetProperty - Sets the property to the value provided.
try
    LuDispatcher(40, cameraNum, property, value, flags);
catch
    errordlg(lasterr, 'Property Error', 'modal');
end
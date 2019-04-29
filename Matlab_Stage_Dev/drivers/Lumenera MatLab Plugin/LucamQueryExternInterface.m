function [sInterface] = LucamQueryExternInterface(cameraNum)
% LucamQueryExternInterface - Returns the camera software version information and serial number.
try
    sInterface = LuDispatcher(58, cameraNum);
catch
    errordlg(lasterr, 'Query Version Error', 'modal');
end
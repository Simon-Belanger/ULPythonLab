function LucamConnect(cameraNum)
% LucamConnect - Connect to the Lumenera camera specified.
try
    LuDispatcher(-1, cameraNum);
catch
    errordlg(lasterr, 'Connect Error', 'modal');
end
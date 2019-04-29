function LucamSetCooling(cooling, temperature, cameraNum)
% LucamSetCooling - Toggles cooling and sets temperature.
try
    LuDispatcher(81, cameraNum, cooling, temperature, cameraNum);
catch
    errordlg(lasterr, 'Cooling Error', 'modal');
end
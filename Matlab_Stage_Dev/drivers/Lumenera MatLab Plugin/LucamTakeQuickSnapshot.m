function [image] = LucamTakeQuickSnapshot(width, height, xOffset, yOffset, exposure, gain, cameraNum)
% LUCAMTAKEQUICKSNAPSHOT - Takes a snapshot using the settings provided.
try
    connected = LuDispatcher(6, cameraNum);
    if(connected == false)
        LuDispatcher(-1);
    end
    LuDispatcher(2, cameraNum, width, height);
    LuDispatcher(9, cameraNum, xOffset, yOffset);
    LuDispatcher(15, cameraNum, exposure);
    LuDispatcher(17, cameraNum, gain)
    image = LuDispatcher(13, cameraNum);
    if(connected == false)
        LuDispatcher(-2, cameraNum);
    end
catch
    errordlg(lasterr, 'Quick Snapshot Error', 'modal');
end
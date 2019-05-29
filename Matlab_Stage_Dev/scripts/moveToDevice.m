function benchObj = moveToDevice(benchObj, currentDevice, targetDevice)
% Vince Wu 2013
if (strcmp(currentDevice.Name, targetDevice.Name))
    benchObj.msg(strcat('Already on device: ', currentDevice.Name));
else
    currentName = strrep(currentDevice.Name, '_', '-');
    targetName = strrep(targetDevice.Name, '_', '-');
    wb_msg = ['Moving to device: ', targetName];
    wh = waitbar(0.3, wb_msg, ...
        'Name', 'Please Wait', ...
        'WindowStyle', 'modal');
    movegui(wh, 'center');
    
    % Move in x direction
    benchObj.instr.opticalStage.move_x(-(targetDevice.X - currentDevice.X));
    
    waitbar(0.6, wh, wb_msg);
    % Move in y direction
    benchObj.instr.opticalStage.move_y(-(targetDevice.Y - currentDevice.Y));
    
    wb_msg = 'Success!';
    waitbar(0.8, wh, wb_msg);
    waitbar(1, wh, wb_msg);
    delete(wh)
    
    % Update location information in chip
    benchObj.chip.CurrentLocation = targetDevice.Name;
    
    msg = [...
        'Move from device: ', ...
        currentName, ': (', num2str(currentDevice.X), ', ', num2str(currentDevice.Y), ')'...
        ' to ', ...
        targetName, ': (', num2str(targetDevice.X), ', ', num2str(targetDevice.Y), ')'];
    benchObj.msg(msg);
end
end
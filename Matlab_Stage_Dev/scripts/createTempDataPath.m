function filePath = createTempDataPath(obj)
    % Create file path to store data
    % create directory path to save data = <dataDir>/<chip>/<die>/<task>/<date>/
    filePath = strcat(...
        obj.AppSettings.path.tempData,...
        obj.chip.Name,'\',...
        obj.AppSettings.infoParams.DieNumber,'\');
    if (exist(filePath, 'dir') ~= 7) % If the directory exist, it would return 7
        mkdir(filePath);
    end
end
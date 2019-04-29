function [dataDirPath, logFile] = create_test_data_dir(gui,format,userDataDir,chipTag,dieID,deviceID,testType)
% shons 2013
%CREATETESTDIR checks to see how much of the directory tree exists and then
%creates the necessary files and folders
%   format = [0,1]. If 1, clump dry test data into one folder
%   userDataDir = 'string' pulled from start gui page, example = 'shons'
%   chipTag = 'string', example = 'IMEC2011', 'IMEC2012', 'EB340'
%   dieID = 'string', example = 'r0c0', 'r0c1', 'a1', 'a2', etc.
%   deviceID = 'string', example = 'ring1', 'ring2', 'bragg1', etc.
%   

%UBC-specific format
% note: no history file saved or updated
% c:/testData/<userDataDir>/<chipTag>/<dieID>/<testType>/<date>/...
%   ...log.txt -- log file for assay
%   ...device1.mat -- one scanline of data for unique device
%   ...device2.mat -- one scanline of data for unique device
%   ...devicen.mat -- one scanline of data for unique device

%default format
% c:/testData/<userDataDir>/<chipTag>/<dieID>/<deviceID>/<testType>/<date>/...
%   ...log.txt -- log file for assay
%   ...scan1.mat
%   ...scan2.mat
%   ...scan3.mat
% history = c:/testData/<userDataDir>/<chipTag>/<dieID>/<deviceID>/history.txt

% check to see how much of the tree already exists, create what doesn't


    % check user
    dir=[userDataDir,'\'];
    if ~exist(dir,'dir')
        mkdir(dir); % create dir
        debug_msg(gui,'Creating user data directory.');
    end
    
    % check chipTag
    dir=[userDataDir,'\',chipTag,'\'];
    if ~exist(dir,'dir')
        mkdir(dir); % create dir
    end
    
    % check dieID
    dir=[userDataDir,'\',chipTag,'\',dieID,'\'];
    if ~exist(dir,'dir')
        mkdir(dir); % create dir
    end
    
	% create date and time folder
    % format jonas and i agreed upon: yyyy-mm-dd_hr-min-sec
    c=clock; % get current date and time
%    dt1=datestr(c,31); % result = 'yyyy-mm-dd hr:min:sec'
    dt1=datestr(c,29);
%    dt2 = regexprep(dt1,':','-'); % replace ':' w/ '-'
%    dtStr = regexprep(dt2,' ','_'); % replace ' ' w/ '_'
    dtStr=dt1;
        
    % check for UBC format and finish
    if format
        % check testType
        dir=[userDataDir,'\',chipTag,'\',dieID,'\',testType,'\'];
        if ~exist(dir,'dir')
            mkdir(dir); % create dir
        end
        
        % check date and time stamp
        dir=[userDataDir,'\',chipTag,'\',dieID,'\',testType,'\',dtStr,'\'];
        if ~exist(dir,'dir')
            mkdir(dir); % create dir
        end
        
        % create fullpath and return
        dataDirPath = [userDataDir,'\',chipTag,'\',dieID,'\',testType,'\',dtStr,'\'];
        logFile     = [userDataDir,'\',chipTag,'\',dieID,'\',testType,'\',dtStr,'\logFile.txt'];
        return
        
    else % default format
        % c:/biobenchData/<userDataDir>/<chipTag>/<dieID>/<deviceID>/<testType>/<date>/...

        % check deviceID
        dir=[userDataDir,'\',chipTag,'\',dieID,'\',deviceID,'\'];
        if ~exist(dir,'dir')
            mkdir(dir); % create dir
        end
        
        % check testType
        dir=[userDataDir,'\',chipTag,'\',dieID,'\',deviceID,'\',testType,'\'];
        if ~exist(dir,'dir')
            mkdir(dir); % create dir
        end
        
        % check date and time stamp
        dir=[userDataDir,'\',chipTag,'\',dieID,'\',deviceID,'\',testType,'\',dtStr,'\'];
        if ~exist(dir,'dir')
            mkdir(dir); % create dir
        end
        
        % create fullpath and return
        dataDirPath = [userDataDir,'\',chipTag,'\',dieID,'\',deviceID,'\',testType,'\',dtStr,'\'];
        logFile= [userDataDir,'\',chipTag,'\',dieID,'\',deviceID,'\',testType,'\',dtStr,'\','logFile.txt'];
        return
    end
end


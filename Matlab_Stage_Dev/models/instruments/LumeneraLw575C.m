classdef LumeneraLw575C < InstrClass
    % Vince Wu 2013
    properties
       PreviewAxes = 0;
       CameraObj = '';
       CameraFound = [];
       CameraID = 0; % Need to be found 
       Resolution = [0 0];
       NumOfBands = 3;
       PreviewImage = zeros(0, 0, 3);
       Capture = zeros(0, 0, 3);
    end
    
    methods
        function self = LumeneraLw575C(varargin)
            self.Name = 'Lw575C Camera';
            self.Group = 'Camera';
            self.Model = 'LW575C';
            self.Serial = '7100190';
            if nargin == 1
                user = varargin{1};
                self.CameraID = user.cameraParams.CameraID;
                self.Resolution = user.cameraParams.Resolution;
                self.NumOfBands = user.cameraParams.NumOfBands;
            end
        end
        
        function [self, msg] = connect(self)
                try
                    if (isempty(self.CameraFound))
                            self.findCamera(self);
                    end
                    self.CameraID = self.CameraFound(1); % Can be changed
                    self.CameraObj = videoinput('winvideo', self.CameraID);
                    self.Connected = 1;
                    msg = 'Camera Connected!';
                catch ME
                    msg = 'Error connecting Camera!';
                    disp(ME.message)
                end
        end
        
        function [self, msg] = start(self)
                if self.Connected == 1
                    try
                        self.Resolution = get(self.CameraObj, 'VideoResolution');
                        self.NumOfBands = get(self.CameraObj, 'NumberOfBands');
                        self.PreviewImage = image(zeros(self.Resolution(2)*2, ...
                                                        self.Resolution(1)*2, ...
                                                        self.NumOfBands), ...
                                                 'Parent', self.PreviewAxes);
                        preview(self.CameraObj, self.PreviewImage);   
                        msg = 'Camera ON';
                    catch ME
                        msg = 'Error turning on camera!';
                        disp(ME.message);
                    end
                else
                    msg = 'Camera is not connected!';
                end
        end
        
        function [self, msg] = capture(self)
                if self.Connected == 1
                    self.Capture = getsnapshot(self.CameraObj);
                    f = figure('NumberTitle', 'off', ...
                               'Name', 'Captured Image', ...
                               'MenuBar', 'none', ...
                               'ToolBar', 'figure', ...
                               'Units', 'normalized', ...
                               'Position', [0 0 0.66, 0.66]);
                    movegui(f, 'center');
                    set(findall(f, 'Tag', 'Standard.NewFigure'), 'Visible', 'off');
                    set(findall(f, 'Tag', 'Standard.FileOpen'), 'Visible', 'off');
                    imshow(self.Capture);
                else
                    msg = 'Camera is not connected!';
                end

        end
        
        function [self, msg] = close(self)
                if self.Connected == 1
                    try
                        stoppreview(self.CameraObj);
                        closepreview(self.CameraObj);
                        delete(self.PreviewImage);
                        msg = 'Camera OFF';
                    catch ME
                        msg = 'Error turning off camera!';
                        disp(ME.message);
                    end
                else
                    msg = 'Camera is not connected!';
                end
        end 
            
        function [self, msg] = disconnect(self)  
                try
                    delete(self.CameraObj);
                    self.Connected = 0;
                    msg = 'Camera disconnected!';
                catch ME
                    msg = 'Error disconnecting camera!';
                    disp(ME.message);
                end
        end 
    end
    
    
    methods(Static)
        function self = findCamera(self)
            cameraList = imaqhwinfo('winvideo');
            cameraInfo = cameraList.DeviceInfo;
            cameraName = cell(1, length(cameraInfo));
            for ii=1:length(cameraName)
                cameraName{ii} = cameraInfo(ii).DeviceName;
                if (strfind(cameraName{ii}, 'Lumenera'));
                    self.CameraFound(end+1) = ii;
                    % In case multiple canmeras are implemented
                end
            end
        end
    end    
end
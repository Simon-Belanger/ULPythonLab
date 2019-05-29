classdef DeviceClass < handle
    
    properties
        % from coordinates file
        Name; % string
        X; % x-coordinate
        Y; % y-coordinate
        Mode; % 'TE' or 'TM'
        Wvl; % designed-for wavelength (ex: 1220, 1310, 1550, etc.)
        Type; % device type (align, bio, device, test struct, etc.)
        Comment; % comment
        Rating; % tested quality of the device
        
        % for testing
        FilePath;
        Selected; % for testing 0=no, 1=yes
        PeakLocations; % (m) array of wavelength values for selected peaks
        PeakLocationsN; % Normalized PeakLocations
        PeakTrackWindow; % (m) window around peak location for tracking
    end
    
    properties (Access = protected)
        BenchObj;
        % sweep range determined by min/max values of PeakLocations
        StartWvl; % for sweep (m)
        StopWvl; % for sweep (m)
        Resolution; %sweep resolution (m) or step size
        NumOfDetectors; %number of channels recorded
        PreviousSweep; %Stores wvl and pwr values for last sweep
        ThisSweep; %Stores wvl and pwr values for the current sweep
        DetectorMemorySize; % number of points, should query for this
        
        % for testing
        TestStatus; % untested = 0, tested = 1
        UserDataDir; % path to user's data directory
        TestHistoryFile; % to be implemented
        ScanNumber;
    end
    
    methods
        % constructor
        function self = DeviceClass(varargin)
            
            % from obj
            %             self.UserDataDir = obj.settings.path.UserDataDir;
            self.BenchObj = varargin{1}; % bench object
            deviceInfo = varargin{2}; % device parameters
            
            % assume device info from coord file passed in struct
            self.X = deviceInfo.x;
            self.Y = deviceInfo.y;
            self.Mode = deviceInfo.mode;
            self.Name = deviceInfo.name;
            self.Comment = deviceInfo.comment;
            self.Wvl = deviceInfo.wvl;
            self.Type = deviceInfo.type;
            self.Rating = 'unknown'; % good, fair, bad, unusuable
            
            self.FilePath = '';
            self.PeakTrackWindow = {}; % in m
            self.Resolution = [];
            self.PeakLocations = {}; %field names will be nubmer (as detector)
            self.PeakLocationsN = {};
            self.NumOfDetectors = [];  %could be different than actual hardware detectors
            % default values
            self.Selected = 0; % selected for testing
            
            % pre-allocate for speed
            self.DetectorMemorySize = self.BenchObj.instr.detector.getProp('DataPoints');
            %             self.PreviousSweep.wvl = zeros(self.DetectorMemorySize,1);
            %             self.PreviousSweep.pwr = zeros(self.DetectorMemorySize,1);
            %             self.ThisSweep.wvl = zeros(self.DetectorMemorySize,1);
            %             self.ThisSweep.pwr = zeros(self.DetectorMemorySize,1);
            self.PreviousSweep = [];
            self.ThisSweep = [];
            self.ScanNumber = 0;
            self.TestStatus = 0;
        end
        
        %% get device history
        function self = getDeviceHistory(self)
        end
        
        %% determine pass/fail using threshold
        function rtn = passFailCheck(self, threshold)
            % initialize rtn
            rtn = zeros(1,self.NumOfDetectors);
            for ii = 1:self.NumOfDetectors
                if (threshold < max(self.ThisSweep(ii).pwr))
                    rtn(ii) = 1; % pass
                else
                    rtn(ii) = 0; % fail
                end
            end
        end
        
        % create test directory
        function self = testDir(self)
        end
        
%         function [self, output] = validateDataSet(self)
%             self.NumOfDetectors = length(self.ThisSweep);
%             for ii = 1:self.NumOfDetectors
%                 self.Resolution(ii) = self.ThisSweep(ii).wvl(2)-self.ThisSweep(ii).wvl(1);
%                 %no data
%             end
%             %             %comput extinction ratio or some other performance metrix
%             %             if max > extinction ratio
%             %                 self.Rating = 'excellent'
%             %             end
%             %
%             %            output = self.Rating;
%             output = 'good';
%             %             self.ScanNumber = self.ScanNumber + 1;
%             % update previous/current arrays
%         end
        
%         function self = trackPeak(self)
%             %Assumes data data is saved in self.ThisSweep and Self.PreviousSweep
%             %assumes that self.PeakLocations is not empty
%             
%             self.validateDataSet();
%             
%             %peakfinder(x0, thresh, extrema); extrema: valley or peak
%             %self.PeakLocations={[det1 at t=0], [det2 at t=0], [det3 at t=0]
%             %[det1 at t=1], [det2 at t=1], [det3 at t=1]}
%             %{scanNumber, detector}
%             
%             for ii=1:self.NumOfDetectors
%                 ind_range = self.PeakTrackWindow / self.Resolution(ii);
%                 if self.ScanNumber > 1
%                     [m, n] = size(self.PeakLocations{self.ScanNumber-1,ii});
%                 else
%                     [m, n] = size(self.PeakLocations{1,ii});
%                 end
%                 for jj=1:m
%                     if (self.ScanNumber>1)
%                         init_guess=self.PeakLocations{self.ScanNumber-1,ii}(jj);
%                     else
%                         init_guess=self.PeakLocations{1,ii}(jj);
%                     end
%                     ind=find(self.ThisSweep.wvl==init_guess);
%                     if ind
%                         x = self.ThisSweep(ii).wvl(ind-ind_range/2:ind+ind_range/2);
%                         y = self.ThisSweep(ii).pwr(ind-ind_range/2:ind+ind_range/2);
%                         [ind_PeakLoc, PeakMag] = peakfinder(y, 4, -1);
%                         self.PeakLocations{self.ScanNumber,ii}(jj)=x(ind_PeakLoc);
%                     else
%                         disp('no index found for init_guess');
%                     end
%                 end
%             end
%         end
        

        %% reset scan number
        function self = resetScanNumber(self)
            self.ScanNumber = 0;
        end
        
        %% get scan number
        function value = getScanNumber(self)
            value = self.ScanNumber;
        end
        
        %% reset rating
        function self = resetRating(self)
            self.Rating = 'unknown';
        end


        %% save data
        function self = saveData(self, wvlData, pwrData, params)
            % Increase the ScanNumber
            self.ScanNumber = self.ScanNumber + 1;
            % for now, just save off the data to a file
            %NumOfDetectors = self.BenchObj.instr.detector.getProp('NumOfDetectors');
            %pwrData: col = detector number
            %write the incoming wvlData and pwrData to the device class.
            [DataPoints, self.NumOfDetectors] = size(pwrData);
            
            %             %old data saved put into separate structure for peak tracking
            %             self.PreviousSweep = self.ThisSweep;
            %update device with current data
            for ii=1:self.NumOfDetectors  %loop through all the detectors
                self.ThisSweep(ii).wvl = wvlData(:,ii);
                self.ThisSweep(ii).pwr = pwrData(:,ii);
            end
            
            for i = 1:self.NumOfDetectors
                %            subplot(NumOfDetectors, 1, i)
                %            plot(wvlData(:,i), pwrData(:,i), color(i));
                scanResults(i) = struct(...
                    'Data', [wvlData(:,i), pwrData(:,i)]);
                %            legend(strcat('Detector No.', num2str(i - 1)));
            end
            
            file = strcat(self.FilePath, 'Scan', num2str(self.ScanNumber), '.mat');
            save(file, 'scanResults', 'params');
        end
        
        %% save plots

        function self = savePlot(self, wvlData, pwrData)
            %pwrData: col = detector number
            [~, self.NumOfDetectors] = size(pwrData);
            f = figure(...
                'Name', ['Sweep Results: ', 'Scan No.', num2str(self.ScanNumber)], ...
                'Units', 'normalized', ...
                'Position', [0 0 .84 .76], ...
                'NumberTitle', 'off', ...
                'Visible', 'off');
            movegui(f, 'center');
            color = ['r', 'g', 'b','r','g','b'];
            for i = 1:self.NumOfDetectors
                NegInf = find(pwrData(:,i)==-200);
                pwrData(NegInf,i) = -Inf;
                subplot(self.NumOfDetectors, 1, i)
                plot(wvlData(:,i), pwrData(:,i), color(i));
                legend(strcat('Detector No.', num2str(i - 1)));
            end
            print(f,'-dpdf',strcat(self.FilePath, 'Scan', num2str(self.ScanNumber),'.pdf'));
            saveas(f,strcat(self.FilePath, 'Scan', num2str(self.ScanNumber),'.fig'));
            delete(f);
        end
        
% Vince, not sure why you need this method. Shon        
        function boolean = hasDirectory(self)
            boolean = ~isempty(strtrim(self.FilePath));
        end
        
        function self = checkDirectory(self, filePath, taskType, dateTag)
            self.FilePath = strcat(...
                filePath, ...
                self.Name, '\', ...
                taskType, '\', ...
                dateTag, '\');
            if (exist(self.FilePath, 'dir') ~= 7) % If the directory exist, it would return 7
                mkdir(self.FilePath);
            end
        end
        
        function val = getProp(self, prop)
            try
                val = self.(prop);
            catch ME
                msg = strcat(self.Name, ' ', prop, ' does not exist.');
                disp(msg);
            end
        end
        
        function self = setProp(self, prop, val)
            try
                self.(prop) = val;
            catch ME
                msg = strcat(self.Name, ' ', prop, ' does not exist.');
                disp(msg);
            end
        end
        
        function self = trackPeaks(self)
            if self.ScanNumber == 1 % First Scan
                % For the first Scan, we only need to determine the
                % tracking windows for each peak selected
                self.setPeakWindow(10); % 10dB threshold
            else % After the first Scan self.ScanNumber >= 2
                % After the first Scan, we need to relocate the peaks for
                % each wet test sweep, and then  
                self.peaksTracking();
                self.setPeakWindow(10);
            end
        end
        
        function self = savePeaksTrackData(self)
            peaksTrackData = self.PeakLocations;
            peaksTrackDataN = self.PeakLocationsN;
            fileName = strcat(self.FilePath, 'PeakTracking.mat');
            save(fileName, 'peaksTrackData', 'peaksTrackDataN');
        end
    end
    
    methods (Access = private)
        function self = peaksTracking(self)
            for d = 1:self.NumOfDetectors
                tempSweepWvl = self.ThisSweep(d).wvl;
                tempSweepPwr = self.ThisSweep(d).pwr;
                for p = 1:length(self.PeakLocations{d})
                    % Get the wavelength window from the last test
                    wvlWindow = tempSweepWvl(self.PeakTrackWindow{d}{p});
                    pwrWindow = tempSweepPwr(self.PeakTrackWindow{d}{p});
                    % Assuming the peak is still in the tracking window,
                    % then it should has the minimum power
                    [~, peakInd] = min(pwrWindow);
                    peakWvl = wvlWindow(peakInd);
                    self.PeakLocations{d}{p}(end + 1) = peakWvl;
                    self.PeakLocationsN{d}{p}(end + 1) = peakWvl - self.PeakLocations{d}{p}(1);
                end
            end
        end
        
        function self = setPeakWindow(self, thresh) % thresh in dbW
            for d = 1:self.NumOfDetectors
                tempSweepPwr = self.ThisSweep(d).pwr;
                tempSweepWvl = self.ThisSweep(d).wvl;
                for p = 1:length(self.PeakLocations{d})
                    % Get the latest peak location
                    peakWvl = self.PeakLocations{d}{p}(end);
                    peakInd = find(tempSweepWvl == peakWvl);
                    % Get the corresponding power value of the peak
                    peakPwr = tempSweepPwr(peakInd);
                    leftWin = peakInd - 1;
                    rightWin = peakInd + 1;
                    % Get the left side window
                    while(tempSweepPwr(leftWin(end)) > peakPwr + thresh) && ...
                            (leftWin(end) > 1)
                        leftWin(end + 1) = leftWin(end) - 1;
                    end
                    leftWin = fliplr(leftWin);
                    %                     leftWin = tempSweepWvl(leftWin);
                    % Get the right side window
                    while(tempSweepPwr(rightWin(end)) > peakPwr + thresh) && ...
                            rightWin(end) < length(tempSweepWvl)
                        rightWin(end + 1) = rightWin(end) + 1;
                    end
                    %                     rightWin = tempSweepWvl(rightWin);
                    % Store the window into property
                    self.PeakTrackWindow{d}{p} = [leftWin ,peakInd, rightWin];
                end
                if length(self.PeakLocations{d}) <= 0
                    self.PeakTrackWindow{d} = {};
                end
            end
        end
    end
end


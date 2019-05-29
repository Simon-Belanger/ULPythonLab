classdef InstrClass < handle
    % Shon Schmidt 2013
    %INSTR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name; % instrument name (for pull-down menus)
        Group; % instrument group (ex: laser, pump, stage, etc.)
        Model; % instrument model #
        Serial;
        CalDate; % calibration date on instr
        Busy; % instrument is busy=1, not=0
        Connected; % instrument connected=1, disconnect=0
        Param; % instrument parameters, assign in constructor
    end
    
    % protected = derived class can access but outside the super and sub
    % class cannot. Anything that can change that the class needs to know
    % should be placed here
    properties (Access = protected)
        Obj; % handle to instrument object
        MsgH; % handle to debug message window
        PopupWinH; % handle to popup window for setting params
    end
    
    methods
        % constructor
        %         function self = instr(varargin)
        %             self.MsgH = varargin{1}; % handle to debug message window
        function self = InstrClass()
            self.Name = 'Virtual Instr';
            self.Group = 'Virtual Instr Group';
            self.Model = 'Virtual Model';
            self.CalDate = date;
            self.Busy = 0; % not busy
            self.Connected = 0; % not connected
            self.Param.COMPort = 0; % initialize for GUI window
        end
        
        function self = connect(self)
            self.Obj = 'Virtual Instr Obj';
            self.Connected = 1;
        end
        
        function val = isConnected(self)
            val = self.Connected;
        end
        
        function self = disconnect(self)
            self.Busy = 0;
            self.Connected = 0;
            delete(self.Obj);
        end
        
        % set parameter
        function self = setParam(self, field, val)
            % add type checking parser
            %            try
            self.Param.(field) = val;
            self.sendParams();
            %            catch ME
            %                self.MsgHWin(ME.message);
            %                return
            %            end
        end
        
        % get parameter
        function val = getParam(self, field)
            val = self.Param.(field);
        end
        
        % set property
        function self = setProp(self, prop, val)
            if self.(prop)
                self.(prop) = val;
            else
                msg = strcat(self.Name, ' ', prop, ' does not exist.');
                err = MException(msg);
                throw(err);
            end
        end
        
        % get property
        function val = getProp(self, prop)
            self.(prop)
            if self.(prop)
                val = self.(prop);
            else
                msg = strcat(self.Name, ' ', prop, ' does not exist.');
                err = MException(msg);
                throw(err);
            end
        end
        
        % get all parameters
        function val = getAllParams(self)
            val = self.Param;
        end
        
        % set all parameters
        function self = setAllParams(self, paramStruct)
            self.Param = paramStruct;
        end
        
        % add parameter
        function val = addParam(self, field, val)
            self.Param.(field) = val;
        end
        
        % delete parameter
        function self = delParam(self, field)
            clear (self.Param.(field));
        end
        
        % settings popup window
        function self = settingsWin(self)
            numParams = length(fieldnames(self.Param));
            self.PopupWinH = dialog('WindowStyle', 'modal', ...
                'Units', 'normalized', ...
                'Resize', 'on', ... 
                'Position', [.45 .75-.05*numParams .20 .05*numParams]); % need to check this
            
            % get list of all the indices in struct
            fields = fieldnames(self.Param);
            % convert struct to cell array
            cellA = struct2cell(self.Param);
            
            % loop through params and create gui elements
            for ii = 1:length(fieldnames(self.Param))
                
                size = length(fieldnames(self.Param));
                
                paramName(ii) = uicontrol('Parent', self.PopupWinH, ...
                    'Style', 'text', ...
                    'Units', 'normalized', ...
                    'Position', [.001 .95- 0.9*ii/size .3 1/(3*numParams)], ... 
                    'HorizontalAlignment', 'right', ...
                    'FontSize', 10, ...
                    'String', fields(ii));
                
                if (isnumeric(cellA{ii}))
                    paramType = 'numeric';
                elseif (ischar(cellA{ii}))
                    paramType = 'string';
                end
                
                paramVal(ii) = uicontrol('Parent', self.PopupWinH, ...
                    'Style', 'edit', ...
                    'Units', 'normalized', ...
                    'Position', [.4 .95- 0.9*ii/size .25 1/(2*numParams)], ... 
                    'HorizontalAlignment', 'right', ...
                    'FontSize', 10, ...
                    'String', cellA{ii},...
                    'Callback', {@self.settingsWinVal, ii, paramType});
                %                    'Callback', {@self.settingsWinVal, self, ii});
                %                    'String', self.Param.(fields{ii}));
                %                    'String', num2str(self.Param.(fields{ii})));
            end
            
            % done button
            doneButton = uicontrol('Parent', self.PopupWinH, ...
                'Style', 'pushbutton', ...
                'Units', 'normalized', ...
                'Position', [.78 .05 .2 1/(2*numParams)], ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 10, ...
                'String', 'Done',...
                'Callback', @self.settingsWinDone);
            %                'Callback', {@self.settingsWinDone, self.PopupWinH});
        end
        
        % settingsWinVal callback
        function self = settingsWinVal(self, hObject, eventData, ii, paramType)
            % get value
            newVal = get(hObject, 'String');
            if strcmp(paramType, 'numeric')
                newVal = str2double(newVal);
            end
            % get list of struct fields
            fields = fieldnames(self.Param);
            % set class property
            % Need to do some type checking here...
            self.Param.(fields{ii}) = newVal;
        end
        
        % done callback
        function settingsWinDone(self, hObject, eventData)
            uiresume;
            if self.Connected
                % write modified params to instrumnent (overload in derived class)
                self.sendParams();
            end
            delete(get(hObject, 'parent'));
        end
        
        % send params (overload in derived class)
        function reply = sendParams(self)
            % write modified params to instrumnent (overload in derived class)
%             msg = strcat(self.Name, ': Writing new params to instrument.');
%             disp(msg);
            self.Param; % print to console for now
            reply = 1; % 1=ok, 0=error
        end
        
    end % methods
    
    %     methods (Static)
    %         % done callback
    %         function settingsWinDone(hObject, eventData)
    %             uiresume;
    %             delete(get(hObject, 'parent'));
    %         end
    %     end % static methods
end


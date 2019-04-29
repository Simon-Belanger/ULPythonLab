function OK = check_recipe(recipe)
% shon: do some meaningful checks here...
% calc total time
% ensure velocity *time won't is w/in well vol
% ensure all spec'd wells are valid for loaded trays, etc.

% need to type check against what values class functions are expecting
% here's andrew's code for the laser as an example...
%             parser = inputParser;
%             parser.CaseSensitive = true;
%             addOptional(parser,'StartWvl',self.SweepParams.StartWvl,@isnumeric);
%             addOptional(parser,'StopWvl',self.SweepParams.StopWvl,@isnumeric);
%             addOptional(parser,'StepWvl',self.SweepParams.StepWvl,@isnumeric);
%             addOptional(parser,'PowerUnit',self.SweepParams.PowerUnit,@isnumeric);
%             addOptional(parser,'PowerLevel',self.SweepParams.PowerLevel,@isnumeric);
%             addOptional(parser,'NumberOfScans',self.SweepParams.NumberOfScans,@isnumeric);
%             addOptional(parser,'SweepSpeed',self.SweepParams.SweepSpeed,@isnumeric);
%             addOptional(parser,'PMChannels',self.SweepParams.PMChannels,@isnumeric);
%             addOptional(parser,'Clipping',self.SweepParams.Clipping,@isnumeric);
%             addOptional(parser,'ClipLimit',self.SweepParams.ClipLimit,@isnumeric);
%             addOptional(parser,'LowSSE',self.SweepParams.LowSSE,@isnumeric);
%             parse(parser,varargin{:});
%             params = parser.Results;

OK = 1;
end
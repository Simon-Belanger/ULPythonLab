%EXAMPLE_GPIB Code for communicating with an instrument.
%
%   This is the machine generated representation of an instrument control
%   session. The instrument control session comprises all the steps you are
%   likely to take when communicating with your instrument. These steps are:
%   
%       1. Create an instrument object
%       2. Connect to the instrument
%       3. Configure properties
%       4. Write and read data
%       5. Disconnect from the instrument
% 
%   To run the instrument control session, type the name of the file,
%   example_gpib, at the MATLAB command prompt.
% 
%   The file, EXAMPLE_GPIB.M must be on your MATLAB PATH. For additional information 
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command 
%   prompt.
% 
%   Example:
%       example_gpib;
% 
%   See also SERIAL, GPIB, TCPIP, UDP, VISA, BLUETOOTH.
% 
 
%   Creation time: 17-Mar-2014 11:00:56

% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 16, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('AGILENT', 32, 16);
else
    fclose(obj1);
    obj1 = obj1(1)
end

% Connect to instrument object, obj1.
fopen(obj1);

% Communicating with instrument object, obj1.
data1 = query(obj1, 'IDN?', '%s\n' ,'%s\n');
data2 = query(obj1, 'PHAO?', '%s\n' ,'%s\n');

% Flush the data in the input buffer.
flushinput(obj1);

% Communicating with instrument object, obj1.
data3 = query(obj1, 'POWE?', '%s\n' ,'%s\n');
fprintf(obj1, 'POWE?');
data4 = fscanf(obj1, '%s\n');

% Flush the data in the input buffer.
flushinput(obj1);

% Communicating with instrument object, obj1.
data5 = query(obj1, 'POWE?', '%s\n' ,'%s\n');

% Disconnect all objects.
fclose(obj1);

% Clean up all objects.
delete(obj1);


function [ freq, value1, value2 ] = queryData()
%%%=================================================================%
%   queryData()             Jonathan St-Yves jonhwoods@gmail.com    %
%                                                     March 2014    %
%                                                                   %
%   This function connects to the VNA and returns the screen data.  %
%   You usually only need value1 and the frequency.                 %
%   For remote control, type the command 'tmtool'                   %
%%%==================================================================



% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 16, 'Tag', '');
% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('AGILENT', 32, 16);
else
    fclose(obj1);
    obj1 = obj1(1);
end
% Configure instrument object, obj1
set(obj1, 'InputBufferSize', 20000);
set(obj1, 'OutputBufferSize', 512);
% Connect to instrument object, obj1.
fopen(obj1);




%IMPORTANT COMMANDS================
fprintf(obj1, '%s', 'form5;');
fprintf(obj1, '%s', 'outpform;');

head = fscanf(obj1, '%c', 2); %Read the #A header
dataLength = fread(obj1, 1, 'uint16'); %Read the lenght of the data (in bytes)
data = fread(obj1, dataLength/4, 'float'); %Read the 4 bytes data points)
value1=data(1:2:end);
value2=data(2:2:end);

start = str2num(query(obj1, 'star?;', '%s' ,'%s\n'));
stop = str2num(query(obj1, 'STOP?;', '%s' ,'%s\n'));
N_points = str2num(query(obj1, 'POIN?;', '%s' ,'%s\n'));

%DATA PROCESSING
freq=linspace(start,stop,N_points);
value1=value1';
value2=value2';






% Flush the data in the input buffer.
flushinput(obj1);
% Disconnect from instrument object, obj1.
fclose(obj1);
end


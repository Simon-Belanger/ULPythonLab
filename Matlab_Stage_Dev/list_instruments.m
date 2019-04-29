%
% Raphael Dube-Demers 
% 29 April 2016
% raphael.dube-demers.1@ulaval.ca
%
% List Installed Instruments
%

clear all; close all; clear classes; clc;

test_interface = {'gpib', 'visa', 'i2c', 'spi', 'matlab', 'ivi', 'vxipnp'};

fprintf('\n\nTesting selected interfaces...\n');

for k=1:numel(test_interface)
   
    
    try
        curr_interface = instrhwinfo(test_interface{k});
        curr_instrs = curr_interface.InstalledAdaptors;
        if iscell(curr_instrs)
            fprintf('\nUsing interface %s, the adaptors are :\n', test_interface{k});
            for m=1:numel(curr_instrs)
                fprintf('---->%s', curr_instrs{m});
                if (m == numel(curr_instrs))
                    fprintf('\n');
                end
            end
        elseif ~iscell(curr_instrs)
            fprintf('\nUsing interface %s, the adaptor is : %s\n', test_interface{k}, curr_instrs);
        end
    catch
        fprintf('\nNo InstalledAdaptors using interface %s!\n', test_interface{k});
    end 
end


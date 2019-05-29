        %%% Fake Laser Sweep Function for code development
        function [wvlVals, pwrVals] = fake_sweep(num_detectors)
            pwrVals = rand(num_detectors,51);
            wvlVals = [];
            wvl = 1500e-9:1e-9:1550e-9;
            for ii=1:num_detectors
                wvlVals = [wvlVals; wvl];
            end
        end
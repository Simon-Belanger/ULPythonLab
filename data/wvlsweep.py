from data.sweepobj import sweepobj
import matplotlib.pyplot as plt
import numpy as np
import os

# TODO : make this an agilent_aquire method of the sweepobj

def wvlsweep(LMS, data_dir, sweepPower=0, wvlStart=1540.0e-9, wvlStop=1570.0e-9, wvlStep=0.02e-9, plot_det1 = True, plot_det2 = True, filename=None):
        """
        Perform a wavelength sweep over the specified range.
        
        INPUTS :
            LMS       : hp816x object for remote control of the Lightwave Measurement System
            data_dir  : Directory where the data is stored
            wvlStart  : Wavelength sweep start wavelength [m]
            wvlStop   : Wavelength sweep stop wavelength [m]
            wvlStep   : Wavelength sweep step wavelength [m]
            plot_det1 : Plot the power for detector 1 (True or False)
            plot_det2 : Plot the power for detector 2 (True or False)
            filename  : name of the datafile 
        """
    
        # Set sweep parameters
        LMS.sweepUnit           = 'dBm'
        LMS.sweepLaserOutput    = 'lowsse' # lowsse ou highpower
        LMS.sweepSpeed          = '0.5nm'
        LMS.sweepPower          = sweepPower
        LMS.sweepNumScans       = 1
        LMS.sweepStartWvl       = wvlStart
        LMS.sweepStopWvl        = wvlStop
        LMS.sweepStepWvl        = wvlStep
        LMS.sweepInitialRange   = 0
        LMS.sweepRangeDecrement = 0
        LMS.sweepClipLimit      = -100

        # Perform the sweep
        wvl_sweep,pow_sweep = LMS.sweep()
        
        # Plot the results
        f = plt.figure()
        if plot_det1 == True:
            plt.plot(wvl_sweep*1e9,pow_sweep.transpose()[0], label='Detector1')
        if plot_det2 == True:
            plt.plot(wvl_sweep*1e9,pow_sweep.transpose()[1], label='Detector2')
        if plot_det1 or plot_det2:
            plt.xlabel('Wavelength (nm)')
            plt.ylabel('Power (dBm)')
            plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
            plt.show()
        
        # Save the results as a sweepobj
        if filename == None:
            filename = input("Enter the name of the file:")
            
        if not(filename==""):
            
            # Device/Sweep Information
            swobj = sweepobj()
            swobj.filename          = ""
            swobj.device            = ""
            swobj.info              = ""
            swobj.wavelength_start  = LMS.sweepStartWvl
            swobj.wavelength_stop   = LMS.sweepStopWvl
            swobj.wavelength_step   = LMS.sweepStepWvl
            swobj.xlims             = [LMS.sweepStartWvl*1e9, LMS.sweepStopWvl*1e9] # Defaults
            swobj.ylims             = [LMS.sweepClipLimit, 0] # Defaults
            
            # Put the data 
            swobj.wavelength = wvl_sweep
            swobj.detector_1 = pow_sweep.transpose()[0]
            swobj.detector_2 = pow_sweep.transpose()[1]
            
            # Save the datafile
            swobj.save(data_dir + filename)
            print("Saving the data to " + data_dir + filename + " ...")
            
from data.sweepobj import sweepobj
import matplotlib.pyplot as plt
import numpy as np
import os

# TODO : make this an agilent_aquire method of the sweepobj
# TODO : Make a function out of this and transform this to a notebook (console)

def wvlsweep(LMS, data_dir, wvl_start=1540.0e-9, wvl_stop=1570.0e-9, wvl_step=0.02e-9, plot_det1 = True, plot_det2 = True, filename=None):
        """
        Perform a wavelength sweep over the specified range.
        
        INPUTS :
            LMS       : hp816x object for remote control of the Lightwave Measurement System
            data_dir  : Directory where the data is stored
            wvl_start : Wavelength sweep start wavelength [m]
            wvl_stop  : Wavelength sweep stop wavelength [m]
            wvl_step  : Wavelength sweep step wavelength [m]
            plot_det1 : Plot the power for detector 1 (True or False)
            plot_det2 : Plot the power for detector 2 (True or False)
            filename  : name of the datafile 
        """
    
        # Init Instrument
        LMS.sweepUnit           = 'dBm'
        LMS.sweepLaserOutput    = 'lowsse' # lowsse ou highpower
        LMS.sweepPower          = -10
        LMS.sweepStartWvl       = wvl_start
        LMS.sweepStopWvl        = wvl_stop
        LMS.sweepStepWvl        = wvl_step
        LMS.sweepInitialRange   = -20
        LMS.sweepRangeDecrement = 20
        LMS.sweepClipLimit      = -100
        LMS.setPWMPowerUnit(2, 0, 'dBm')
        LMS.setPWMPowerUnit(2, 1, 'dBm')

        #Sweep
        wvl_sweep,pow_sweep = LMS.sweep()

        # Turn off the laser
        LMS.setTLSOutput('lowsse')
        LMS.setPWMPowerUnit(2, 0, 'dBm')
        LMS.setPWMPowerUnit(2, 1, 'dBm')
        LMS.setPWMPowerRange(2, 0, rangeMode='auto')
        LMS.setPWMPowerRange(2, 1, rangeMode='auto')
        
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
            
            filename = raw_input("Enter the name of the file:")
            
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
            swobj.ylims             = [-100, 0] # Defaults
            
            # Put the data 
            swobj.wavelength = wvl_sweep
            swobj.detector_1 = pow_sweep.transpose()[0]
            swobj.detector_2 = pow_sweep.transpose()[1]
            
            # Save the datafile
            swobj.save(data_dir + filename)
            print("Saving the data to " + data_dir + filename + " ...")
            
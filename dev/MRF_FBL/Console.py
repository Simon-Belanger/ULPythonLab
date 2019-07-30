#%% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
# ms-python.python added
import os
try:
	os.chdir(os.path.join(os.getcwd(), 'dev/MRF_FBL'))
	print(os.getcwd())
except:
	pass
#%% [markdown]
# ## Optimisation code
# 
# This script generates a microring filter (MRF) object made of a PD and 5 DC Sources. This device is then manipulated by the Coordinates Descent Algorithm to tune it.

#%%
# Load Modules
from Instruments import *
from methods.Algo import *
from methods.MRF import RealMRF
import os
get_ipython().run_line_magic('matplotlib', 'inline')

# Lightwave Measurement System
LMS = hp816x_instr.hp816x()

# DC Sources
V1 = Agilent_E3646A(6,1)
V2 = Keithley_2612B(26,'a')
V3 = Keithley_2612B(26,'b')
V4 = Keithley_2612B(25,'a')
V5 = Keithley_2612B(25,'b')

# Directory to store data
data_dir = os.getcwd() + "\\datatest\\V3_part2\\"

# Create the MRF object an|d connect to instruments
instruments = {'LMS': LMS,
             'DCsources': [V1, V2, V3, V4, V5],
             'LowerLimitDC': [0]*5,
             'UpperLimitDC': [3]*5}
mrf = RealMRF(instruments, 2,0.0001, data_dir)
mrf.connect_instruments()
mrf.DC_off()

#%% [markdown]
# # Test the averaging of the power

#%%
mrf.wvl_sweep(1530, 1560, 0.05)


#%%
mrf.LMS.setTLSWavelength(1538*1e-9)
x_i, f_i = CoordsDescent(mrf, 5, delay=0., mode='max', plotPowMat=True) # mode : manual, max, min
plotconvergence(f_i)
mrf.wvl_sweep(1530, 1560, 0.05)
print(mrf.applied_bias)


#%%
print(mrf.applied_bias)

#%% [markdown]
# Set the bias for each heater and then peform a wavelength sweep.

#%%
mrf.apply_bias_mult([2.01, 2.3686, 1.67219, 2.3907, 2.2592])
mrf.wvl_sweep(1530, 1560, 0.05)


#%%
mrf.LMS.setTLSWavelength(1538*1e-9)
mrf.average_power(2.)
NelderMead(mrf, [1.24, 1.3594, 1.13407, 1.24164, 1.22108], 'max')
mrf.wvl_sweep(1530, 1560, 0.02)


#%%
print(mrf.applied_bias)

#%% [markdown]
# ## Sweep Voltage and perform a wavelength sweep
# 
# This script is used to perform a bias sweep. For every bias point, a wavelength sweep is performed.

#%%
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


# Script for a single bias sweep WORKS
def sweep_bias_shape(wvl_start=1540, wvl_stop=1560, wvl_step=0.001, DCsource=None, bias_min=0, bias_max=0.5, bias_points=2, 
                     dirname = "\\datatest\\"):
    """"""
    
    #  Location to save the data
    data_dir = os.getcwd() + dirname
    
    # Table of content with file names
    toc = open(data_dir + "toc_data.txt","w+")

    # Initialize the DC source
    DCsource.connect()
    #DCsource.set_range_high()
    
    # Initialize the laser, connect it and set the sweep params
    hp = hp816x_instr.hp816x()
    hp.connect('GPIB0::20::INSTR')
    hp.sweepUnit = 'dBm'
    hp.sweepLaserOutput = 'lowsse' # lowsse ou highpower
    hp.sweepStartWvl = wvl_start * 1e-9
    hp.sweepStopWvl = wvl_stop * 1e-9
    hp.sweepStepWvl = wvl_step * 1e-9
    
    # Sweep the bias
    bias_testpoints = np.linspace(bias_min,bias_max,bias_points).tolist()
    for k in bias_testpoints: # For each bias value

        DCsource.source_voltage(k)
        #time.sleep(0.1)
        
        # Set the filename and add it to thew table of contents        
        filename = "V=" + '{:.3f}'.format(k).replace(".","_") + ".txt"
        toc.write(filename+'\n') # Could make sure adding an existing file is not possible
        
        # Perform the sweep
        wvl_sweep,pow_sweep = hp.sweep()
        
        # Plot the results
        plot_sweep=False
        if plot_sweep == True:
            
            plt.plot(wvl_sweep*1e9,pow_sweep.transpose()[0], label='Detector1')
            plt.plot(wvl_sweep*1e9,pow_sweep.transpose()[1], label='Detector2')
            plt.xlabel('Wavelength (nm)')
            plt.ylabel('Power (dBm)')
            plt.legend()
            plt.show()
        
        # Save the results
        if not(filename==""):
            np.savetxt(data_dir + filename, (wvl_sweep,pow_sweep.transpose()[0],pow_sweep.transpose()[1]))
            print("Saving file : " + filename)
        # Turn off the laser
        hp.setTLSOutput('lowsse', slot=0)
        hp.setTLSState('off' , slot=0)
        hp.setPWMPowerUnit(2, 0, 'dBm')
        hp.setPWMPowerUnit(2, 1, 'dBm')
        hp.setPWMPowerRange(2, 0, rangeMode='auto')
        hp.setPWMPowerRange(2, 1, rangeMode='auto')
    
    # Turn DC source Off
    DCsource.output_off()
    hp.disconnect()
    
    # Close the table of content file
    toc.close()
    
def load_and_plot(filename,color):
    """
    Load the wavelength sweep data in a specific file.
    """
    
    A,B,C = np.loadtxt(filename, dtype=float)

    plt.plot(A*1e9,B, label='Detector1',color=color)
    plt.plot(A*1e9,C, label='Detector2',color=color)
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')

def multiplot(directory):
    """
    Sweep the table of content stored along the data and plot all the bias sweep data..
    """
    
    data_dir = os.getcwd() + directory
    
    # Open the table of content
    toc = open(data_dir + "toc_data.txt")
    datafile_list = toc.read().split("\n")[:-1]
    
    cmap = cm.get_cmap('jet')
    compt = 0.
    for datafile in datafile_list: # For each bias value  
        load_and_plot(data_dir + datafile,cmap(compt/(len(datafile_list)-1)))
        compt += 1
    ax = plt.gca()
    ax.get_xaxis().get_major_formatter().set_useOffset(False)
    plt.show()
    
    # Close the table of content
    toc.close()


#%%
from Instruments import *

sweep_bias_shape(wvl_start=1515, wvl_stop=1560, wvl_step=0.05, DCsource=V1, bias_min=0, bias_max=2, bias_points=2, 
                     dirname = "\\datatest\\V1\\V1")

#source.output_off()

multiplot("\\datatest\\V1\\V1")


#%%
multiplot("\\datatest\\")

#%% [markdown]
# ## Tune the filter to specific central wavelengths, measure the transmission spectrum for each central wavelength

#%%
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


# Script for a single bias sweep WORKS
def sweep_central_wavelength(MRF, sweep_params=[1540,1570,0.02], filter_wavelengths=[1555,1565,1], dirname = "\\datatest\\"):
    """
    
    Args:
        MRF (MRF): Microring Filter Object.
        sweep_params (list): 3x1 List containing sweep parameters e.g. [wvl_start, wvl_stop, wvl_step].
        filter_wavelengths (list): 3x1 List containing tuning parameters e.g. [wvl_start, wvl_stop, N points]
        
    Returns:
    
    """
    
    #  Location to save the data
    data_dir = os.getcwd() + dirname
    
    # Table of content with file names
    toc = open(data_dir + "toc_data.txt","w+")
    
    # Table of content with file names
    lut = open(data_dir + "lut_data.txt","w+")
    lut.write('wvl/V1/V2/V3/V4/V5\n')

    # Sweep the central wavelength
    tuning_testpoints = np.linspace(filter_wavelengths[0],filter_wavelengths[1],filter_wavelengths[2]).tolist()
    for k in tuning_testpoints: # For each bias value
        
        # Tune the MRF object to the target central wavelength
        #tuning = tuneMRF(mrf, k, 0.1, 'Drop')
        tuneMRF(mrf, k, 0.1, 'Drop')  
        
        # Set the filename and add it to thew table of contents        
        filename = "c_wvl=" + '{:.3f}'.format(k).replace(".","_") + ".txt"
        toc.write(filename+'\n') # Could make sure adding an existing file is not possible
        
        # Store the tuning to a lookup table
        #lut.write('{:.3f}/{:.3f}/{:.3f}/{:.3f}/{:.3f}/{:.3f}\n'.format(k,*tuning))
        
        # Perform the sweep
        MRF.wvl_sweep(sweep_params[0], sweep_params[1], sweep_params[2])
    
    # Close the table of content and the lookup table
    toc.close()
    lut.close()


#%%
sweep_central_wavelength(mrf, sweep_params=[1532,1555,0.05], filter_wavelengths=[1535,1540,3], dirname = "\\datatest\\")



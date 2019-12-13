#%% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
# ms-python.python added
import os
try:
	os.chdir(os.path.join(os.getcwd(), 'dev/MRF_FBL'))
	print(os.getcwd())
except:
	pass

#%%
# Import the required modules
from Instruments import *
from Algo import *
from MRF import RealMRF    

# Map the heaters to the different DC sources
V1 = Agilent_E3646A('1')
V2 = Agilent_E3646A('2')
V3 = Keithley_2612B('b')
Vall = Keithley_2612B('a')

# Create the MRF object and connect to instruments
instruments = {'PD': Agilent_81635A(2,2),
             'DCsources': [V3, V2, V1],
              'limitDC': [16, 10, 16]}
mrf = RealMRF(instruments)
mrf.connect_instruments()


#%%
# Set V all to 1 V and V1,V2,V3 to half their range
Vall.connect()
Vall.source_voltage(1)
mrf.apply_bias(1,8)
mrf.apply_bias(2,8)
mrf.apply_bias(3,8)

# Find the wavelength where the dip by doing a sweep
ag = Agilent_81635A(2,2)
ag.connect()
ag.sweep(wavelength_start=1515, wavelength_stop=1525, wavelength_step=0.001, plot_sweep=True)

#Lower the bias from V_all a little bit
Vall.source_voltage(0.95)

#Use the algorithm to tune to the same wavelength
mrf.DC_off()
tuneMRF(mrf, 1520.20)

# Plot the final spectrum
ag = Agilent_81635A(2,2)
ag.connect()
ag.sweep(wavelength_start=1515, wavelength_stop=1525, wavelength_step=0.001, plot_sweep=True)


#%%
from Instruments import *
import numpy as np
import matplotlib.pyplot as plt
import os

source = Keithley_2612B('a')
#source = Keithley_2612B('b')
#source = Agilent_E3646A('1')
#source = Agilent_E3646A('2')


# Script for a single bias sweep WORKS
def sweep_bias_shape(wvl_start=1530, wvl_stop=1565, wvl_step=0.02, DCsource=source, bias_min=0, bias_max=6, bias_points=15, 
                     dirname = "\\datatest\\"):
    """"""
    
    #  Location to save the data
    data_dir = os.getcwd() + dirname

    # Initialize the DC source
    DCsource.connect()
    DCsource.set_range_high()
    
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
        
                
        filename = "V=" + '{:.3f}'.format(k).replace(".","_") + ".txt"
        
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
    
gfg=Agilent_E3646A('1')  
gfg.connect()
gfg.set_range_high()
gfg.source_voltage(16)
# Run the sweep
#sweep_bias_shape()  
import time
time.sleep(20)
# Script for a single bias sweep WORKS
#sweep_bias_shape(wvl_start=1545, wvl_stop=1555, wvl_step=0.001, DCsource=Agilent_E3646A('1'), bias_min=16.84210526, bias_max=19.36842105,
                 #bias_points=4, dirname = "\\V1\\")
#sweep_bias_shape(wvl_start=1545, wvl_stop=1555, wvl_step=0.001, DCsource=Keithley_2612B('b'), bias_min=0, bias_max=10, bias_points=20, 
                 #dirname = "\\V2\\")
#sweep_bias_shape(wvl_start=1545, wvl_stop=1555, wvl_step=0.001, DCsource=Agilent_E3646A('2'), bias_min=0, bias_max=16, bias_points=20, 
                 #dirname = "\\V3\\")
sweep_bias_shape(wvl_start=1545, wvl_stop=1580, wvl_step=0.02, DCsource=Keithley_2612B('a'), bias_min=0, bias_max=6, bias_points=10, 
                 dirname = "\\Vall\\")


#%%
###### Load the sweep data save to file 
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def load_and_plot(filename,color):
    
    A,B,C = np.loadtxt(filename, dtype=float)

    plt.plot(A*1e9,B, label='Detector1',color=color)
    plt.plot(A*1e9,C, label='Detector2',color=color)
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')
    
def multiplot(directory="\\V1\\", bias_min=0, bias_max=16, bias_points=20):
    
    data_dir = os.getcwd() + directory
    bias_testpoints = np.linspace(bias_min,bias_max,bias_points).tolist()
    cmap = cm.get_cmap('jet')
    for k in bias_testpoints: # For each bias value           
        filename = "V=" + '{:.3f}'.format(k).replace(".","_") + ".txt"
        load_and_plot(data_dir + filename,cmap(k/max(bias_testpoints)))
    ax = plt.gca()
    ax.get_xaxis().get_major_formatter().set_useOffset(False)
    plt.show()
#f.savefig(data_dir + 'fig.pdf')

f1 = plt.figure(1)
multiplot(directory="\\Chip193-20\\Vall\\", bias_min=0, bias_max=6, bias_points=10)
#f2 = plt.figure(2)
#multiplot(directory="\\V2\\", bias_min=0, bias_max=10, bias_points=20)
#f3 = plt.figure(3)
#multiplot(directory="\\V3\\", bias_min=0, bias_max=16, bias_points=20)
    


#%%
import Instruments
hp = Instruments.hp816x_instr.hp816x()

#hp = hp816x()
hp.connect('GPIB0::20::INSTR')
hp.sweepUnit = 'dBm'
hp.sweepLaserOutput = 'lowsse' # lowsse ou highpower
hp.setTLSOutput('lowsse', slot=0)
hp.setTLSState('off' , slot=0)
hp.setPWMPowerUnit(2, 0, 'dBm')
hp.setPWMPowerUnit(2, 1, 'dBm')
hp.setPWMPowerRange(2, 0, rangeMode='auto')
hp.setPWMPowerRange(2, 1, rangeMode='auto')


#%%
def load_and_plot(filename,color):
    
    A,B,C = np.loadtxt(filename, dtype=float)

    plt.plot(A*1e9,B, label='Detector1',color=color)
    plt.plot(A*1e9,C, label='Detector2',color=color)
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')
    
data_dir = os.getcwd() + "\\"
load_and_plot(data_dir + "align32_1.txt","r")
load_and_plot(data_dir + "align32_2.txt","k")
load_and_plot(data_dir + "align34_1.txt","r")
load_and_plot(data_dir + "align34_2.txt","k")
load_and_plot(data_dir + "align34_3.txt","b")
plt.show()


#%%
def load_and_plot(filename,color):
    
    A,B,C = np.loadtxt(filename, dtype=float)

    plt.plot(A*1e9,B, label='Detector1',color=color)
    plt.plot(A*1e9,C, label='Detector2',color=color)
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')
    
data_dir = os.getcwd() + "\\"
load_and_plot(data_dir + "align34_1.txt","r")
load_and_plot(data_dir + "align34_2.txt","k")
load_and_plot(data_dir + "align34_3.txt","b")
plt.show()


#%%
# Plot the response and substract the IO response
import os
import matplotlib.pyplot as plt
import numpy as np

# Grating couplers
A34,B34,C34 = np.loadtxt("align34_2.txt", dtype=float)
A32,B32,C32 = np.loadtxt("align32_2.txt", dtype=float)


def load_and_plot(filename,color):
    
    A,B,C = np.loadtxt(filename, dtype=float)

    plt.plot(A*1e9,B-B34, label='Detector1',color=color)
    plt.plot(A*1e9,C-C32, label='Detector2',color=color)
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')
    
data_dir = os.getcwd() + "\\chip193-20\\"
load_and_plot(data_dir + "R3_V1_fine.txt","b")
plt.show()


#%%
# Import the required modules
import visa
import time
import numpy as np
from scipy.optimize import minimize
import matplotlib.pyplot as plt
from Keithley_2612B import Keithley_2612B
from Agilent_81635A import Agilent_81635A
from Agilent_E3646A import Agilent_E3646A

# Coordinates descent Algorithm 
def sweep_bias(MRF,channel):
    """Coarse tuning of a MRF object using the coordinates descent algorithm."""
    
    # Possible bias values
    bias_min = 0
    bias_max = 3
    bias_points = 100
    bias_testpoints = np.linspace(bias_min,bias_max,bias_points).tolist()
    
    # Turn on the laser and set the wavelength
    MRF.PD.set_wavelength(1550)
    MRF.PD.laser_on()
   
    power_list = []
    for k in bias_testpoints: # For each bias value
        MRF.apply_bias(channel,k)
        time.sleep(0.2)
        power_list.append(MRF.PD.measure_power())
    plotsweep(bias_testpoints, power_list)
    MRF.apply_bias(channel,bias_testpoints[power_list.index(min(power_list))])
    # Turn on the laser 
    MRF.PD.laser_off()

# Coordinates descent Algorithm 
def CoordsDescent(MRF,number_iter):
    """Coarse tuning of a MRF object using the coordinates descent algorithm."""
    
    # Turn on the laser and set the wavelength
    MRF.PD.laser_on()
    for i in range(1,number_iter+1): # For each iteration
        for j in range(0,MRF.num_parameters): # For each ring
            power_list = []
            
            # Possible bias values
            bias_min = 0
            bias_max = MRF.limitDC[j]

            bias_points = 500
            bias_testpoints = np.linspace(bias_min,bias_max,bias_points).tolist()
            
            for k in bias_testpoints: # For each bias value
                MRF.apply_bias(j+1,k)
                time.sleep(0.2)
                power_list.append(MRF.PD.measure_power())            
            plotsweep(bias_testpoints, power_list)
            
            # pour choisir une valeur autre que le minimum
            bias_voulu = raw_input('Enter your bias:')
            if bias_voulu == "min":
                MRF.apply_bias(j+1,bias_testpoints[power_list.index(min(power_list))])
            else:
                MRF.apply_bias(j+1,bias_voulu)
                
    # Turn on the laser 
    MRF.PD.laser_off()
            
# Nelder Mead simplex algorithm
def NelderMead(MRF):
    """Fine tuning of a MRF object using the Nelder Mead simplex algorithm"""
    # Turn on the source
    MRF.PD.laser_on()
    # Initial guess
    x0 = MRF.applied_bias
    # Optimization
    res = minimize(MRF.minimize_MRF, x0, method='Nelder-Mead', tol=1e-6, options={'disp': True})
    #Turn off the source
    MRF.PD.laser_off()
    return res.x

def tuneMRF(MRF, wavelength):
    """Tune/stabilise the MRF object using coarse + fine algorithms"""
   
    MRF.PD.set_wavelength(wavelength)
    
    CoordsDescent(MRF,2) # Coordinates descent
    NelderMead(MRF) # Nelder Mead
    
def plotsweep(bias, power):
    plt.plot(bias, power)
    plt.plot([bias[power.index(min(power))]], [min(power)], marker='o', markersize=10, color="red")
    plt.xlabel("Bias [V]")
    plt.ylabel("Power [dBm]")
    plt.show()
    
def plotsweep2(ax, bias, power):
    ax.plot(bias, power)
    ax.plot([bias[power.index(min(power))]], [min(power)], marker='o', markersize=10, color="red")
    ax.xlabel("Bias [V]")
    ax.ylabel("Power [dBm]")
    return ax
    
# MRF object class
class RealMRF(object):
    """"""
    
    def __init__(self,instruments):
        self.PD = instruments['PD']      
        self.DCsources = instruments['DCsources']
        self.limitDC = instruments['limitDC']
        self.num_parameters = len(self.DCsources)
        self.applied_bias = [0.] * self.num_parameters
    
    def connect_instruments(self):
        """Conncet the DC sources remotely."""
        # Connect the power sensor
        self.PD.connect()
        # Connect the DC sources
        for instrument in self.DCsources:
            instrument.connect()
    
    def apply_bias(self,source_num,bias):
        """Set the bias for the ring #[ring_number] at [bias_value]"""
        self.applied_bias[source_num-1] = bias
        self.DCsources[source_num-1].source_voltage(bias)
        
    def DC_off(self):
        """Turn off the DC bias for all DC sources."""
        for i in range(self.num_parameters):
            self.apply_bias(i,0)      
    
    def test_MRF(self,bias_list):
        """"""
        # Apply bias to DC sources
        for i in range(self.num_parameters):
            self.apply_bias(i+1,bias_list[i])
        # Measure the optical power on the sensor
        return float(self.PD.measure_power())
    
    def minimize_MRF(self,bias_list):
        """Minimization optimisation function for the MRF object"""
        return self.test_MRF(bias_list)


#%%
# Import the required modules
import visa
import time
import numpy as np
from scipy.optimize import minimize
import matplotlib.pyplot as plt
from Keithley_2612B import Keithley_2612B
from Agilent_81635A import Agilent_81635A
from Agilent_E3646A import Agilent_E3646A

# Coordinates descent Algorithm 
def sweep_bias(MRF,channel):
    """Coarse tuning of a MRF object using the coordinates descent algorithm."""
    
    # Possible bias values
    bias_min = 0
    bias_max = 3
    bias_points = 100
    bias_testpoints = np.linspace(bias_min,bias_max,bias_points).tolist()
    
    # Turn on the laser and set the wavelength
    MRF.PD.set_wavelength(1550)
    MRF.PD.laser_on()
   
    power_list = []
    for k in bias_testpoints: # For each bias value
        MRF.apply_bias(channel,k)
        time.sleep(0.2)
        power_list.append(MRF.PD.measure_power())
    plotsweep(bias_testpoints, power_list)
    MRF.apply_bias(channel,bias_testpoints[power_list.index(min(power_list))])
    # Turn on the laser 
    MRF.PD.laser_off()

# Coordinates descent Algorithm 
def CoordsDescent(MRF,number_iter):
    """Coarse tuning of a MRF object using the coordinates descent algorithm."""
    
    # Turn on the laser and set the wavelength
    MRF.PD.laser_on()
    for i in range(1,number_iter+1): # For each iteration
        for j in range(0,MRF.num_parameters): # For each ring
            power_list = []
            
            # Possible bias values
            bias_min = 0
            bias_max = MRF.limitDC[j]

            bias_points = 500
            bias_testpoints = np.linspace(bias_min,bias_max,bias_points).tolist()
            
            for k in bias_testpoints: # For each bias value
                MRF.apply_bias(j+1,k)
                time.sleep(0.2)
                power_list.append(MRF.PD.measure_power())            
            plotsweep(bias_testpoints, power_list)
            
            # pour choisir une valeur autre que le minimum
            bias_voulu = raw_input('Enter your bias:')
            if bias_voulu == "min":
                MRF.apply_bias(j+1,bias_testpoints[power_list.index(min(power_list))])
            else:
                MRF.apply_bias(j+1,bias_voulu)
                
    # Turn on the laser 
    MRF.PD.laser_off()
            
# Nelder Mead simplex algorithm
def NelderMead(MRF):
    """Fine tuning of a MRF object using the Nelder Mead simplex algorithm"""
    # Turn on the source
    MRF.PD.laser_on()
    # Initial guess
    x0 = MRF.applied_bias
    # Optimization
    res = minimize(MRF.minimize_MRF, x0, method='Nelder-Mead', tol=1e-6, options={'disp': True})
    #Turn off the source
    MRF.PD.laser_off()
    return res.x

def tuneMRF(MRF, wavelength):
    """Tune/stabilise the MRF object using coarse + fine algorithms"""
   
    MRF.PD.set_wavelength(wavelength)
    
    CoordsDescent(MRF,2) # Coordinates descent
    NelderMead(MRF) # Nelder Mead
    
def plotsweep(bias, power):
    plt.plot(bias, power)
    plt.plot([bias[power.index(min(power))]], [min(power)], marker='o', markersize=10, color="red")
    plt.xlabel("Bias [V]")
    plt.ylabel("Power [dBm]")
    plt.show()
    
def plotsweep2(ax, bias, power):
    ax.plot(bias, power)
    ax.plot([bias[power.index(min(power))]], [min(power)], marker='o', markersize=10, color="red")
    ax.xlabel("Bias [V]")
    ax.ylabel("Power [dBm]")
    return ax
    
# MRF object class
class RealMRF(object):
    """"""
    
    def __init__(self,instruments):
        self.PD = instruments['PD']      
        self.DCsources = instruments['DCsources']
        self.limitDC = instruments['limitDC']
        self.num_parameters = len(self.DCsources)
        self.applied_bias = [0.] * self.num_parameters
    
    def connect_instruments(self):
        """Conncet the DC sources remotely."""
        # Connect the power sensor
        self.PD.connect()
        # Connect the DC sources
        for instrument in self.DCsources:
            instrument.connect()
    
    def apply_bias(self,source_num,bias):
        """Set the bias for the ring #[ring_number] at [bias_value]"""
        self.applied_bias[source_num-1] = bias
        self.DCsources[source_num-1].source_voltage(bias)
        
    def DC_off(self):
        """Turn off the DC bias for all DC sources."""
        for i in range(self.num_parameters):
            self.apply_bias(i,0)      
    
    def test_MRF(self,bias_list):
        """"""
        # Apply bias to DC sources
        for i in range(self.num_parameters):
            self.apply_bias(i+1,bias_list[i])
        # Measure the optical power on the sensor
        return float(self.PD.measure_power())
    
    def minimize_MRF(self,bias_list):
        """Minimization optimisation function for the MRF object"""
        return self.test_MRF(bias_list)


#%%
test1 = Agilent_E3646A('1')
test1.connect()
test1.set_range_high()
test1 = Agilent_E3646A('2')
test1.connect()
test1.set_range_high()
test2 = Keithley_2612B('a')
test2.connect()
test2.set_range(20)
test2 = Keithley_2612B('b')
test2.connect()
test2.set_range(20)

instruments = {'PD': Agilent_81635A(2,1),
             'DCsources': [Keithley_2612B('b'), Agilent_E3646A('1'), Agilent_E3646A('2')],
              'limitDC': [16, 16, 10]}

mrf = RealMRF(instruments)
mrf.connect_instruments()


#%%
test1 = Agilent_E3646A('1')
test1.connect()
test1.set_range_high()
test1 = Agilent_E3646A('2')
test1.connect()
test1.set_range_high()
test2 = Keithley_2612B('a')
test2.connect()
test2.set_range(20)
test2 = Keithley_2612B('b')
test2.connect()
test2.set_range(20)

instruments = {'PD': Agilent_81635A(2,1),
             'DCsources': [Keithley_2612B('b'), Agilent_E3646A('1'), Agilent_E3646A('2')],
              'limitDC': [16, 16, 10]}

mrf = RealMRF(instruments)
mrf.connect_instruments()


#%%
test1 = Agilent_E3646A('1')
test1.connect()
test1.set_range_high()
test1 = Agilent_E3646A('2')
test1.connect()
test1.set_range_high()
test2 = Keithley_2612B('a')
test2.connect()
test2.set_range(20)
test2 = Keithley_2612B('b')
test2.connect()
test2.set_range(20)

instruments = {'PD': Agilent_81635A(2,1),
             'DCsources': [Keithley_2612B('b'), Agilent_E3646A('1'), Agilent_E3646A('2')],
              'limitDC': [16, 16, 10]}

mrf = RealMRF(instruments)
mrf.connect_instruments()



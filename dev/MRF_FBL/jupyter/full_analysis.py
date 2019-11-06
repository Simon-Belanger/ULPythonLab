#%% Change working directory from the workspace root to the ipynb file location. Turn this addition off with the DataScience.changeDirOnImportExport setting
# ms-python.python added
import os
try:
	os.chdir(os.path.join(os.getcwd(), 'dev/MRF_FBL'))
	print(os.getcwd())
except:
	pass
#%% [markdown]
# This script will sweep through all bias voltages and take a wavelength sweep for each position. It will then be possible to get the best response.

#%%
from Instruments import *
import numpy as np
import matplotlib.pyplot as plt
import os
import time

def params2filename(p1)

# Wavelength sweep
wvl_start=1540
wvl_stop=1550
wvl_step=0.002

# Bias sweep
bias_min = [0,0,0]
bias_max = [10,16,10]
bias_points = 12

# Options
plot_sweep=False

    
#  Location to save the data
data_dir = os.getcwd() + "\\data\\"

    
# Initialize the DC sources
DC_source1 = Keithley_2612B('a')
DC_source2 = Keithley_2612B('b')
DC_source3 = Agilent_E3646A('2')
DC_source1.connect()
DC_source2.connect()
DC_source3.connect()
DC_source1.set_range_high()
DC_source2.set_range_high()
DC_source3.set_range_high()
    
# Initialize the laser, connect it and set the sweep params
hp = hp816x_instr.hp816x()
hp.connect('GPIB0::20::INSTR')
hp.sweepUnit = 'dBm'
hp.sweepLaserOutput = 'lowsse' # lowsse ou highpower
hp.sweepStartWvl = wvl_start * 1e-9
hp.sweepStopWvl = wvl_stop * 1e-9
hp.sweepStepWvl = wvl_step * 1e-9
    
# Sweep the bias
v1_values = np.linspace(bias_min[0],bias_max[0],bias_points).tolist()
v2_values = np.linspace(bias_min[1],bias_max[1],bias_points).tolist()
v3_values = np.linspace(bias_min[2],bias_max[2],bias_points).tolist()

for v1 in v1_values:
    
    # Apply voltage for source #1
    DC_source1.source_voltage(v1)
    
    for v2 in v2_values:
        
        # Apply voltage for source #1
        DC_source2.source_voltage(v2)
        
        for v3 in v3_values:
            
            # Apply voltage for source #1
            DC_source3.source_voltage(v3)
            
               
            filename = "V1=" + '{:.3f}'.format(v1).replace(".","_") + ","             + "V2=" + '{:.3f}'.format(v2).replace(".","_") + ","            + "V3=" + '{:.3f}'.format(v3).replace(".","_") +".txt"
        
            # Perform the wavelength sweep (and time it)
            start = time.time()
            wvl_sweep,pow_sweep = hp.sweep()
            print("sweep time = " + str(time.time() - start))
        
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

DC_source1.source_voltage(0)
DC_source2.source_voltage(0)
DC_source3.source_voltage(0)


#%%
###### Load the sweep data save to file 
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def load_and_plot(filename,color):
    
    A,B,C = np.loadtxt(filename, dtype=float)

    plt.plot(A*1e9,B, label='Detector1',color=color,)
    plt.plot(A*1e9,C, label='Detector2',color=color)
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')
    
data_dir = os.getcwd() + "\\data\\"

#Build data list


# Sweep the bias
bias_min = [0,0,0]
bias_max = [10,16,10]
bias_points = [12,12,12]
v1_values = np.linspace(bias_min[0],bias_max[0],bias_points[0]).tolist()
v2_values = np.linspace(bias_min[1],bias_max[1],bias_points[1]).tolist()
v3_values = np.linspace(bias_min[2],bias_max[2],bias_points[2]).tolist()

# plots printed
v1_values = v1_values[0:3]
v2_values = v2_values[0:3]
v3_values = v3_values[0:3]
n_curves = np.size(v1_values) * np.size(v2_values) * np.size(v3_values)
print(n_curves)
curve_count = 1.0
cmap = cm.get_cmap('jet')

f = plt.figure()
for v1 in v1_values:
    for v2 in v2_values:
        for v3 in v3_values:
            
            filename = "V1=" + '{:.3f}'.format(v1).replace(".","_") + ","             + "V2=" + '{:.3f}'.format(v2).replace(".","_") + ","            + "V3=" + '{:.3f}'.format(v3).replace(".","_") +".txt"
            load_and_plot(data_dir + filename,cmap(curve_count/n_curves))
            curve_count = curve_count + 1.0

ax = plt.gca()
ax.get_xaxis().get_major_formatter().set_useOffset(False)
plt.show()
f.savefig(data_dir + 'fig.pdf')


#%%
###### Find peaks and further analysis
import os
import scipy.signal as sig
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
    
data_dir = os.getcwd() + "\\data\\"



# Sweep the bias
bias_min = [0,0,0]
bias_max = [10,16,10]
bias_points = [12,12,12]
v1_values = np.linspace(bias_min[0],bias_max[0],bias_points[0]).tolist()
v2_values = np.linspace(bias_min[1],bias_max[1],bias_points[1]).tolist()
v3_values = np.linspace(bias_min[2],bias_max[2],bias_points[2]).tolist()

# plots printed
v1_values = v1_values[0:12]
v2_values = v2_values[0:12]
v3_values = v3_values[0:12]
n_sweeps = np.size(v1_values) * np.size(v2_values) * np.size(v3_values)
print(n_sweeps)
sweep_ind = 1
namelist = []
fmerit = []


for v1 in v1_values:
    for v2 in v2_values:
        for v3 in v3_values:
            
            filename = "V1=" + '{:.3f}'.format(v1).replace(".","_") + ","             + "V2=" + '{:.3f}'.format(v2).replace(".","_") + ","            + "V3=" + '{:.3f}'.format(v3).replace(".","_") +".txt"
            A,B,C = np.loadtxt(data_dir + filename, dtype=float)
            peak_ind = sig.find_peaks_cwt(C, np.array([500]))[0]
            peak_wvl = A[peak_ind]
            peak_thru = B[peak_ind]
            peak_drop = C[peak_ind]
            #print(peaks)
            #plt.plot(A*1e9,B, label='Detector1',color=cmap(curve_count/n_curves))
            #plt.plot(A*1e9,C, label='Detector2',color=cmap(curve_count/n_curves))
            #plt.plot(peak_wvl*1e9, peak_drop, marker='o', markersize=10, color="k")
            #plt.xlabel('Wavelength (nm)')
            #plt.ylabel('Power (dBm)')
            #curve_count = curve_count + 1.0
            sweep_ind = sweep_ind + 1.0
            progress = sweep_ind/n_sweeps
            if int(progress*100)%5 == 0:
                print(int(progress*100))
            
            namelist.append(filename)
            fmerit.append(peak_drop)

# Save sorted data
np.savetxt(data_dir + "namelist.txt", namelist, fmt="%s" )
np.savetxt(data_dir + "fmerit.txt", np.concatenate(fmerit).ravel())


#%%
indices = sorted(range(len(fmerit)), key=fmerit.__getitem__)
namelist_sorted = [namelist[i] for i in indices]
fmerit_sorted = [fmerit[i] for i in indices]
namelist_keep = namelist_sorted[-1:-100:-1]
#print(namelist_keep)

curve_count = 1.0
cmap = cm.get_cmap('jet')
f = plt.figure()
for filename in namelist_keep:
    A,B,C = np.loadtxt(data_dir + filename, dtype=float)
    plt.plot(A*1e9,B, label='Detector1',color=cmap(curve_count/len(namelist_keep)))
    plt.plot(A*1e9,C, label='Detector2',color=cmap(curve_count/len(namelist_keep)))
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Power (dBm)')
    curve_count = curve_count + 1.0

ax = plt.gca()
ax.get_xaxis().get_major_formatter().set_useOffset(False)
plt.show()


#%%
fmerit_sorted=np.concatenate(fmerit).ravel().tolist()
fmerit_sorted.sort()

plt.plot(fmerit_sorted, label='Detector1',color=cmap(curve_count/len(namelist_keep)))
plt.xlabel('Wavelength (nm)')
plt.ylabel('Power (dBm)')
plt.show()


#%%
namelist_sorted


#%%
np.savetxt(data_dir + "fmerit.txt", np.concatenate(fmerit).ravel())


#%%
fmerit



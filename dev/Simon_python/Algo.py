# Import the required modules
import time
import numpy as np
from scipy.optimize import minimize
import matplotlib.pyplot as plt

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
def NelderMead(MRF,x0=[]):
    """Fine tuning of a MRF object using the Nelder Mead simplex algorithm"""
    # Turn on the source
    MRF.PD.laser_on()
    # Initial guess
    if x0 == []:
        x0 = MRF.applied_bias
    # Optimization
    res = minimize(MRF.maximize_MRF, x0, method='Nelder-Mead', options={'disp': True, 'xatol': 0.0001, 'maxiter': 100, 'maxfev': 100})
    #Turn off the source
    MRF.PD.laser_off()
    return res.x

def tuneMRF(MRF, wavelength):
    """Tune/stabilise the MRF object using coarse + fine algorithms"""
   
    MRF.PD.set_wavelength(wavelength)
    
    CoordsDescent(MRF,2) # Coordinates descent
    NelderMead(MRF,[]) # Nelder Mead
    
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
"""
Various resonance wavelength alignment algorithms that can be used along with the 
MRF object to tune/align resonant systems.

Author      : Simon Bélanger-de Villers (simon.belanger-de-villers.1@ulaval.ca)
Created     : October 2018
Last edited : July 30th 2019
"""

# Import the required modules
import time, pickle
import numpy as np
from scipy.optimize import minimize
import matplotlib.pyplot as plt

# Coordinates descent Algorithm 
def sweep_bias(MRF, channel):
    " Coarse tuning of a MRF object using the coordinates descent algorithm. "
    
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
def CoordsDescent(MRF, number_iter, delay=0., mode='manual', plotPowMat=True):
    """
    Coarse tuning of a MRF object using the coordinates descent algorithm.
    
    Args:
        MRF (mrf): Microring filter object.
        number_iter (int): number of iterations to perform.
        delay (float): time delay between applying the bias and measuring the optical power [default = 0.1] .
    
    Returns:
    
    """
    
    x_i = [] # Bias applied
    f_i = [] # Max power measured
    power_mat = [[] for ii in range(MRF.num_parameters)] # Power map for each tuner

    # Turn on the laser and set the wavelength
    MRF.LMS.setTLSState('on')
    time.sleep(5)
    for i in range(1,number_iter+1): # For each iteration
        print("Progress update : Iteration #" + str(i) + " - Initiating ... ")
        for j in range(0,MRF.num_parameters): # For each ring
            print("Progress update : Iteration #" + str(i) + " - Sweeping ring #" + str(j) + " ...")
            power_list = []
            
            # Possible bias values
            bias_testpoints = np.arange(MRF.LowerLimitDC[j],MRF.UpperLimitDC[j]+MRF.ResolutionDC[j],MRF.ResolutionDC[j]).tolist()
            
            for k in bias_testpoints: # For each bias value
                MRF.apply_bias(j+1,k)
                time.sleep(delay)
                power_list.append(MRF.LMS.readPWM(2, MRF.PWMchannel))            
            power_mat[j].append(power_list)
            
            # Depending on the chosen mode
            if mode == 'manual': # Shows the power vs bias plot
                plotsweep(bias_testpoints, power_list)
                # pour choisir une valeur autre que le minimum
                bias_voulu = input('Enter your bias:') # raw_input if problems occur (e.g. Python 2.X)
                if bias_voulu == "min": # Easy command to get the minimal value
                    chosen_bias = bias_testpoints[power_list.index(min(power_list))]
                elif bias_voulu == "max": # Easy command to get the maximal value
                    chosen_bias = bias_testpoints[power_list.index(max(power_list))]
                else: # Custom value
                    chosen_bias = bias_voulu
            elif mode == 'min': # Always choose the minimum value
                chosen_bias = bias_testpoints[power_list.index(min(power_list))]
            elif mode == 'max': # Always choose the maximum value
                chosen_bias = bias_testpoints[power_list.index(max(power_list))]
            MRF.apply_bias(j+1, chosen_bias)    
        
        # Save the iteration Log
        x_i.append(MRF.applied_bias)
        f_i.append(max(power_list))

    # Turn on the laser 
    MRF.LMS.setTLSState('off')
    
    # Plot power map
    if plotPowMat == True:
        plotPowMap(MRF, power_mat)
        pickle.dump( power_mat, open( MRF.data_dir + "power_mat.p", "wb" ) )
    
    return x_i, f_i
            
# Nelder Mead simplex algorithm
def NelderMead(MRF, x0=[], port='max'):
    """Fine tuning of a MRF object using the Nelder Mead simplex algorithm"""
    
    # Turn on the source
    MRF.LMS.setTLSState('on')
    # Initial guess
    if x0 == []:
        x0 = MRF.applied_bias
    
    # Optimization
    if port == 'max':
        res = minimize(MRF.Drop_function, x0, method='Nelder-Mead', options={'disp': True, 'xtol': 0.0001, 'maxiter': 100, 'maxfev': 100})
    elif port == 'min':
        res = minimize(MRF.Thru_function, x0, method='Nelder-Mead', options={'disp': True, 'xtol': 0.0001, 'maxiter': 100, 'maxfev': 100})
     
    #Turn off the source
    MRF.LMS.setTLSState('off')
    return res.x

def tuneMRF(MRF, wavelength, delay=0.1, port='max'):
    """Tune/stabilise the MRF object using coarse + fine algorithms"""
   
    MRF.LMS.setTLSWavelength(wavelength*1e-9)
    
    CoordsDescent(MRF, 2, delay, port) # Coordinates descent
    NelderMead(MRF,[], port) # Nelder Mead
    
def plotsweep(bias, power):
    plt.plot(bias, power)
    plt.plot([bias[power.index(min(power))]], [min(power)], marker='o', markersize=10, color="red")
    plt.plot([bias[power.index(max(power))]], [max(power)], marker='o', markersize=10, color="red")
    plt.xlabel("Bias [V]")
    plt.ylabel("Power [dBm]")
    plt.show()
    
def plotsweep2(ax, bias, power):
    ax.plot(bias, power)
    ax.plot([bias[power.index(min(power))]], [min(power)], marker='o', markersize=10, color="red")
    ax.plot([bias[power.index(max(power))]], [max(power)], marker='o', markersize=10, color="red")
    ax.xlabel("Bias [V]")
    ax.ylabel("Power [dBm]")
    return ax

def plotconvergence(f_i):
    plt.plot(range(1,len(f_i)+1), f_i, marker='o', markersize=10, color="black")
    plt.xlabel("Number of iterations")
    plt.ylabel("Power [dBm]")
    plt.show()
    
def plotPowMap(MRF, power_mat):
    for i in range(0,len(power_mat)): # For each tuner
        bias_testpoints = np.arange(MRF.LowerLimitDC[i],MRF.UpperLimitDC[i]+MRF.ResolutionDC[i],MRF.ResolutionDC[i]).tolist()
        for j in range(0,len(power_mat[i])): # For each iteration
            legend_label = "Iteration " + str(j+1)
            plt.plot(bias_testpoints,power_mat[i][j],label=legend_label)
            plt.xlabel("Bias [V]")
            plt.ylabel("Power [dBm]")
            plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
        plt.show()
    
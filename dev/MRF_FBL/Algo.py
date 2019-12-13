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
def sweep_bias(MRF, channel, voltageList=np.linspace(0,3,100)):
    """ Coarse tuning of a MRF object using the coordinates descent algorithm. 
        Might be obsolete!!
    """
    
    # Turn on the laser and set the wavelength
    MRF.LMS.setTLSWavelength(1550e-9)
    MRF.LMS.setTLSState('on')
   
    power_list = []
    for voltage in voltageList.tolist(): # For each bias value
        MRF.apply_bias(channel, voltage)
        time.sleep(MRF.thermalDelay)
        powerList.append(MRF.measurePower())
    plotsweep(voltageList, powerList)
    MRF.apply_bias(channel, bias_testpoints[power_list.index(min(power_list))])
    # Turn on the laser 
    MRF.LMS.setTLSState('off')

# Coordinates descent Algorithm 
def CoordsDescent(MRF, numIter, mode='manual', plotPowMat=True):
    """ Coarse tuning of a MRF object using the coordinates descent algorithm.
    Args:
        MRF     : Microring filter object.                                              [mrf]
        numIter : Number of iterations to perform.                                      [int]
    Returns:
        x_i     : Command log (applied bias to the heaters).                                [list]
        f_i     : Output log (power measured a the PD).                                     [list]
    """
    
    x_i, f_i    = [], []                                    # Bias applied , Max power measured
    power_mat   = [[] for ii in range(MRF.num_parameters)]  # Power map for each tuner

    # Turn on the laser and set the wavelength
    MRF.LMS.setTLSState('on'), time.sleep(5)
    for i in range(1, number_iter+1): # For each iteration
        print("Progress update : Iteration #{}/{} - Initiating ... ".format(i, number_iter))
        for j in range(0, MRF.num_parameters): # For each ring
            print("Progress update : Iteration #{}/{} - Sweeping ring #{}/{} ...".format(i, number_iter+1, j+1, MRF.num_parameters))
            
            power_list = []
            for k in np.arange(MRF.LowerLimitDC[j], MRF.UpperLimitDC[j]+MRF.ResolutionDC[j], MRF.ResolutionDC[j]).tolist(): # For each bias value
                MRF.apply_bias(j+1, k)
                time.sleep(MRF.thermalDelay)
                power_list.append(MRF.measurePower())            
            power_mat[j].append(power_list)
            
            MRF.apply_bias(j+1, selectBiasPoint(bias_testpoints, power_list, mode))    
        
        x_i.append(MRF.applied_bias), f_i.append(max(power_list)) # Save the iteration Log

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
   
    MRF.LMS.setTLSWavelength(wavelength)
    
    CoordsDescent(MRF, 2, delay, port) # Coordinates descent
    NelderMead(MRF,[], port) # Nelder Mead
    
# Various Plotting methods
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

def selectBiasPoint(biasList, powerList, mode):
    """ Return the selected bias value that will be applied to the heaters from a data list consisting 
    if a pair bias/power. 
    
    mode : 
        min     : Always choose the bias value that minimizes the measured power.
        max     : Always choose the bias value that maximizes the measured power.
        manual  : Plots the measured power vs applied bias and waits for an user input of the bias to apply for every iteration.
    """

    # Depending on the chosen mode
    if mode == 'manual': # Shows the power vs bias plot
        plotsweep(biasList, powerList)
        userInput = input('Enter your bias:')

        if userInput == "min": # Easy command to get the minimal value
            selectedBias = biasList[powerList.index(min(powerList))]

        elif userInput == "max": # Easy command to get the maximal value
            selectedBias = biasList[powerList.index(max(powerList))]

        else: # Custom value
            selectedBias = float(userInput)

    elif mode == 'min': # Always choose the minimum value
        selectedBias = biasList[powerList.index(min(powerList))]

    elif mode == 'max': # Always choose the maximum value
        selectedBias = biasList[powerList.index(max(powerList))]

    else:
        print('This option is not valid!')

    return selectedBias

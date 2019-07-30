"""
MRF Object Class and subclasses

The MRF is an object controlling the microring filter. It handles input signal from a 
photodetector and returns inputs to the actuators (thermal phase shifters).

Author      : Simon Bélanger-de Villers (simon.belanger-de-villers.1@ulaval.ca)
Created     : October 2018
Last edited : July 30th 2019
"""

import time
import numpy as np
import matplotlib.pyplot as plt
import os

# MRF object class (Abstract form)
class RealMRF(object):

    # Delay between the moment the bias is applied and the time the optical power is measured
    thermal_delay = 0.3 
    
    def __init__(self,instruments, PWMchannel, ResolutionDC=None, data_dir=os.getcwd()):
        self.PWMchannel = PWMchannel-1
        self.LMS = instruments['LMS']      
        self.DCsources = instruments['DCsources']
        self.num_parameters = len(self.DCsources)
        self.LowerLimitDC = instruments['LowerLimitDC']
        self.UpperLimitDC = instruments['UpperLimitDC']
        if ResolutionDC == None:
            self.ResolutionDC = self.getDCresolution(instruments)
        else:
            self.ResolutionDC = [ResolutionDC] * self.num_parameters
        self.applied_bias = [0.] * self.num_parameters
        self.data_dir = data_dir
        print(self.data_dir)
    
    @staticmethod
    def getDCresolution(instruments):
        resolution = []
        for DC in instruments['DCsources']:
            resolution.append(DC.resolution)
        return resolution
            
    
    def connect_instruments(self):
        " Connect the DC sources remotely and set their range to high. "
        # Connect the power sensor
        self.LMS.connect('GPIB0::20::INSTR')
        self.setup_LMS()
        # Connect the DC sources
        for instrument in self.DCsources:
            instrument.connect()
            
    def setup_LMS(self):
        " Setup the Lightwave Measurement System for use. "
        self.LMS.setTLSOutput('lowsse')
        self.LMS.setPWMPowerUnit(2, 0, 'dBm')
        self.LMS.setPWMPowerUnit(2, 1, 'dBm')
        self.LMS.setPWMPowerRange(2, 0, rangeMode='auto')
        self.LMS.setPWMPowerRange(2, 1, rangeMode='auto')
        
    def wvl_sweep(self, wvl_start=1540, wvl_stop=1570, wvl_step=0.02, plot_det1 = True, plot_det2 = True, filename=None):
        " Perform a wavelength sweep over the specified range. "
        
        # Init Instrument
        self.LMS.sweepUnit              = 'dBm'
        self.LMS.sweepLaserOutput       = 'lowsse' # lowsse or highpower
        self.LMS.sweepStartWvl          = wvl_start * 1e-9
        self.LMS.sweepStopWvl           = wvl_stop * 1e-9
        self.LMS.sweepStepWvl           = wvl_step * 1e-9
        self.LMS.sweepInitialRange      = -20
        self.LMS.sweepRangeDecrement    = 20
    
        self.LMS.setPWMPowerUnit(2, 0, 'dBm')
        self.LMS.setPWMPowerUnit(2, 1, 'dBm')

        #Sweep
        wvl_sweep,pow_sweep = self.LMS.sweep()

        # Turn off the laser
        self.setup_LMS()
        
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
        
        # Save the results
        if filename == None:
            filename = raw_input("Enter the name of the file:")
        if not(filename==""):
            complete_name = self.data_dir + filename + '_' + str(wvl_start).replace('.',',') +'_' + str(wvl_stop).replace('.',',') + '_' + str(wvl_step).replace('.',',') 
            np.savetxt(complete_name + ".txt", (wvl_sweep,pow_sweep.transpose()[0],pow_sweep.transpose()[1]))
            f.savefig(complete_name + ".pdf")
    
    def apply_bias(self,source_num,bias):
        " Set the bias for the ring #[ring_number] at [bias_value]. "
        
        # Clamp the supplied bias value between 0 and the limit of the corresponding DC source
        limited_bias = self.limit_voltage(bias, self.LowerLimitDC[source_num-1], self.UpperLimitDC[source_num-1])
        
        # Apply the limited_bias value to the corresponding DC_source
        self.applied_bias[source_num-1] = limited_bias
        self.DCsources[source_num-1].source_voltage(limited_bias)
        
    def apply_bias_mult(self, bias_list):
        " Set the bias for each ring with values in a list of bias. "
        for i in range(self.num_parameters):
            self.apply_bias(i+1,bias_list[i])
            
    def average_power(self, avgtime):
        " Get the average power from the LMS. " 
        self.LMS.setPWMAveragingTime(2, self.PWMchannel, avgtime)
    
    @staticmethod
    def limit_voltage(bias, limit_inf, limit_sup):
        " Returns a bias value between 0 and limit. "
        if bias < limit_inf:
            print("Warning: The supplied bias value should be larger than " + str(limit_inf) + " V.")
        elif bias > limit_sup:
            print("Warning: The supplied bias is larger than the limit fixed at " + str(limit_sup) + " V.")
        return max(min(bias, limit_sup), limit_inf)
        
    def DC_off(self):
        " Turn off the DC bias for all DC sources. "
        for i in range(self.num_parameters):
            self.apply_bias(i,0)      
    
    def obj_function(self,bias_list):
        """ 
        Microring Filter objective function that has to be optimized.
        
        This function accepts a 1D array of shape self.num_parameters 
        corresponding to the different bias values applied to the filter.
        It returns a scalar value corresponding to the measured power.
        
        """
        # Apply corresponding bias to each DC source
        self.apply_bias_mult(bias_list)
        
        # Wait for the thermal steady state
        time.sleep(self.thermal_delay)
        
        # Measure the optical power on the sensor
        return float(self.LMS.readPWM(2, self.PWMchannel))
    
    def Drop_function(self,bias_list):
        " When tracking the drop port, inverse of the drop port power is used to minimze. "
        return -self.obj_function(bias_list)
    
    def Thru_function(self, bias_list):
        " When tracking the Thru port, the Thru port power is used to minimze. "
        return self.obj_function(bias_list)
    
    def get_bias(self):
        " Return the bias applied with the number of significative digits. "
        
        sig_figure = []
        for res_element in self.ResolutionDC:
            sig_figure.append(len(str(res_element))-2)
        print(sig_figure)


class mrfQontrolOva(RealMRF):
    """ 
    Implementation of the MRF with the LUNA Optical Vector Analyzer (OVA) and 
    the Qontrol multi-channel power supply.

    The purpose is to make a subclass that will make use of the Liskov substitution principle
    throughout the code.
    """
    def __init__(self):
        super.__init__(self)


class mrfLmsDCsources(RealMRF):
    """ 
    Implementation of the MRF with the Agilent Lightwave Measurement System and various 
    DC sources e.g. Keithley SMUs, Agilent Power Supplies.

    The purpose is to make a subclass that will make use of the Liskov substitution principle
    throughout the code.
    """    
    def __init__(self):
        super.__init__(self)
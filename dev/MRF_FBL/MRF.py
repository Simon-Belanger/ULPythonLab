"""
MRF Object Class and subclasses

The MRF is an object controlling the microring filter. It handles input signal from a 
photodetector and returns inputs to the actuators (thermal phase shifters).

Author      : Simon Bélanger-de Villers (simon.belanger-de-villers.1@ulaval.ca)
Created     : October 2018
Last edited : December 10th 2019
"""

import time, os, sys
import numpy as np
import matplotlib.pyplot as plt
sys.path.append(os.getcwd() + '\\..\\..\\')
from data.wvlsweep import wvlsweep

# MRF object class (Abstract form)
class RealMRF(object):

    thermalDelay        = 0.3       # Delay between the moment the bias is applied and the time the optical power is measured
    _activePort         = 'Drop'    # The active port is the port for which the measured optical power will be returned when calling measurePower()
    _PWMaveragingTime   = 0.02      # Averaging time for the photodetectors
    
    def __init__(self, instruments, ResolutionDC=None, dataDirectory=os.getcwd()):

        # Set the Parameters
        self.dropChan       = instruments['dropChan']       # (slot, channel) tuple for the drop port of the filter.
        self.thruChan       = instruments['thruChan']       # (slot, channel) tuple for the through port of the filter.
        self.LMS            = instruments['LMS']            # Lightwave Measurement System (LMS) object [hp816x].      
        self.DCsources      = instruments['DCsources']      # DC electrical power supplies objects.
        self.LowerLimitDC   = instruments['LowerLimitDC']   
        self.UpperLimitDC   = instruments['UpperLimitDC']
        self.numParameters  = len(self.DCsources)           # Number of actuators in the system. 
        if ResolutionDC == None:
            self.ResolutionDC = self.getDCresolution(instruments)
        else:
            self.ResolutionDC = [ResolutionDC] * self.numParameters
        self.applied_bias = [0.] * self.numParameters
        self.data_dir = dataDirectory
        print('Data directory is set to {}'.format(self.data_dir))

        self.connectInstruments()
        self.DC_on()

    def __del__(self):
        """ Finalizer for the class. Executes when object is cleared from memory. """
        self.DC_off()
        
    # Properties
    @property
    def laserWavelength(self):
        return self.LMS.getTLSWavelength()
    @laserWavelength.setter
    def laserWavelength(self, wavelength):
        self.LMS.setTLSWavelength(wavelength)

    @property
    def PWMaveragingTime(self):
        return self._PWMaveragingTime
    @PWMaveragingTime.setter
    def PWMaveragingTime(self, avgTime):
        self.LMS.setPWMAveragingTime(self.dropChan[0], self.dropChan[1], avgTime)
        self.LMS.setPWMAveragingTime(self.thruChan[0], self.thruChan[1], avgTime)
        self._PWMaveragingTime = avgTime

    @property
    def activePort(self):
        return self._activePort
    @activePort.setter
    def activePort(self, port):
        if port in ['Drop', 'Thru']:
            self._activePort = port
        else:
            print('Error! Valid pots are Drop and Thru')

    # methods
    def measurePower(self):
        """ Read the power measured on the PD at the Drop/Through port. """
        if self._activePort == 'Drop':
            return self.LMS.readPWM(self.dropChan[0], self.dropChan[1])
        elif self._activePort == 'Thru':
            return self.LMS.readPWM(self.thruChan[0], self.thruChan[1])         
    
    def connectInstruments(self):
        """ Connect the DC sources remotely and set their range to high. """
        # Connect the power sensor
        self.LMS.connect('GPIB0::20::INSTR')
        self.resetLMS()
        # Connect the DC sources
        for instrument in self.DCsources:
            instrument.connect()
            
    def resetLMS(self):
        """ Reset the Lightwave Measurement System to it's default parameters. """
        self.LMS.setTLSOutput('lowsse')
        self.LMS.setPWMPowerUnit(self.dropChan[0], self.dropChan[1], 'dBm')
        self.LMS.setPWMPowerUnit(self.thruChan[0], self.thruChan[1], 'dBm')
        self.LMS.setPWMPowerRange(self.dropChan[0], self.dropChan[1], rangeMode='auto')
        self.LMS.setPWMPowerRange(self.thruChan[0], self.thruChan[1], rangeMode='auto')

    def wavelengthSweep(self, sweepPower=0, wvlStart=1540e-9, wvlStop=1570e-9, wvlStep=0.02e-9, plot_det1 = True, plot_det2 = True, filename=None):
        """ Perform a wavelength sweep using the agilent LMS."""
        wvlsweep(self.LMS, self.data_dir, sweepPower, wvlStart, wvlStop, wvlStep, plot_det1, plot_det2, filename)
        self.resetLMS()
    
    def apply_bias(self, source_num, bias):
        """ Set the bias for the ring #[ring_number] at [bias_value]. """
        
        # Clamp the supplied bias value between 0 and the limit of the corresponding DC source
        limited_bias = self.limit_voltage(bias, self.LowerLimitDC[source_num-1], self.UpperLimitDC[source_num-1])
        
        # Apply the limited_bias value to the corresponding DC_source
        self.applied_bias[source_num-1] = limited_bias
        self.DCsources[source_num-1].source_voltage(limited_bias)
        
    def apply_bias_mult(self, bias_list):
        """ Set the bias for each ring with values in a list of bias. """
        for i in range(self.numParameters):
            self.apply_bias(i+1,bias_list[i])
        
    def DC_on(self):
        """ Turn on the output for all the power supplies and set the voltage to 0 V.  """
        for powerSupply in self.DCsources:
            powerSupply.source_voltage(0)
            powerSupply.output_on()
        print('All DC power supplies have been turned on.')   

    def DC_off(self):
        """ Turn off the DC bias for all DC sources. """
        for powerSupply in self.DCsources:
            powerSupply.source_voltage(0)
            powerSupply.output_off()
        print('All DC power supplies have been turned off.')      
    
    def objectiveFunction(self, bias_list):
        """ Microring Filter objective function that has to be optimized.
        This function accepts a 1D array of shape self.numParameters corresponding to the different bias values applied to the filter.
        It returns a scalar value corresponding to the measured power."""

        self.apply_bias_mult(bias_list)     # Apply corresponding bias to each DC source
        time.sleep(self.thermalDelay)       # Wait for the thermal steady state
        return float(self.measurePower())   # Measure and return the optical power on the sensor
    
    def Drop_function(self, biasList):
        """ When tracking the drop port, inverse of the drop port power is used to minimze. """
        return -self.objectiveFunction(biasList)
    
    def Thru_function(self, biasList):
        """ When tracking the Thru port, the Thru port power is used to minimze. """
        return self.objectiveFunction(biasList)
    
    def get_bias(self):
        """ Return the bias applied with the number of significative digits. """
        
        sig_figure = []
        for res_element in self.ResolutionDC:
            sig_figure.append(len(str(res_element))-2)
        print(sig_figure)

    @staticmethod
    def getDCresolution(instruments):
        resolution = []
        for DC in instruments['DCsources']:
            resolution.append(DC.resolution)
        return resolution  

    @staticmethod
    def limit_voltage(bias, limit_inf, limit_sup):
        """ Returns a bias value between 0 and limit. """
        if bias < limit_inf:
            print("Warning: The supplied bias value should be larger than " + str(limit_inf) + " V.")
        elif bias > limit_sup:
            print("Warning: The supplied bias is larger than the limit fixed at " + str(limit_sup) + " V.")
        return max(min(bias, limit_sup), limit_inf)
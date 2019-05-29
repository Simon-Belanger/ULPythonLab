import time
import numpy as np

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
        """Conncet the DC sources remotely and set their range to high."""
        # Connect the power sensor
        self.PD.connect()
        # Connect the DC sources
        for instrument in self.DCsources:
            instrument.connect()
            instrument.set_range_high()
    
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
        # Clip values to specified source range
        bias_list = np.clip(bias_list, 0, self.limitDC).tolist()
        # Apply bias to DC sources
        for i in range(self.num_parameters):
            self.apply_bias(i+1,bias_list[i])
            time.sleep(0.2)
        # Measure the optical power on the sensor
        return float(self.PD.measure_power())
    
    def maximize_MRF(self,bias_list):
        return self.test_MRF(bias_list) * -1
    
    def minimize_MRF(self,bias_list):
        """Minimization optimisation function for the MRF object"""
        return self.test_MRF(bias_list)
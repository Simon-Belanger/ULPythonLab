import matplotlib.pyplot as plt
import numpy as np
import time
from MRM import MRM
import winsound

class IQ(object):
    """ Class for a single channel IQ modulator. """
    
    def __init__(self, SMU_I, SMU_Q):

        # Create both Microring modulator objects
        self.I = MRM(SMU_I,'I')
        self.Q = MRM(SMU_Q,'Q')
        
        # Turn off the filters
        self.filter_off()
        
    def set_voltage(self, V):
        
        self.V = V
        self.I.V = V
        self.Q.V = V
        
    def calibrate(self, auto=False):
        if auto == True:
            user_input = "y"
        else:
            user_input = raw_input("Calibration requires that no optical power is present on the chip. Proceed? (y/n)\n")
        if user_input == "y":
            print("Calibration in progress ...\n")
            self.I.SMU.output_on()
            self.Q.SMU.output_on()
            
            self.I.Vd, self.Q.Vd, self.I.Id, self.Q.Id = self.sweep(self.V) 
            
            self.I.SMU.output_on()
            self.Q.SMU.output_on()
            print("Calibration finished!\n")
        else:
            print("Calibration aborted.\n")
            
    def autocalibrate(self, laser):
        """Perform a calibration when the laser is controlled remotely."""
        
        # Calibration
        laser.laser_off()
        time.sleep(3)
        self.calibrate(auto=True)
        
        # With laser power on
        laser.laser_on()
        time.sleep(15)
        Imin, Qmin = self.sweep_norm(auto=True)
        
        # Calibration complete
        print("Autocalibration complete.")
        winsound.Beep(2500, 200)
        winsound.Beep(2500, 200)
        
        return Imin, Qmin
        
    
    def sweep(self,V):
        """Sweep the voltage and measure the photocurrent."""
        i_I = []
        i_Q = []
        for v in V:
            i_I.append(self.I.update(v))
            i_Q.append(self.Q.update(v))
        plt.plot(V,np.asarray(i_I)*1e3, label = self.I.name)
        plt.plot(V,np.asarray(i_Q)*1e3, label = self.Q.name)
        plt.xlabel("Voltage [V]")
        plt.ylabel("Current [mA]")
        plt.legend()
        plt.show()
        return V, V, i_I, i_Q    
    
    def update_norm(self, V, delay = 0.5):

        # Apply voltage
        self.apply_voltage(V)
        
        time.sleep(delay)
        
        # Measure the current
        I = self.measure_current()[0]
        
        # Remove the resistive component
        V_closest = min(self.Vd, key=lambda x:abs(x-V))
        In = I - self.Id[self.Vd.index(V_closest)]
        
        return In
        
    def measure_Id(self, index):

        self.apply_voltage(self.V[index])
        
        V_closest = min(self.Vd, key=lambda x:abs(x-self.V[index]))
        Id = self.measure_current()[0] - self.Id[self.Vd.index(V_closest)]
        return Id
        
    def sweep_norm(self, auto=False):
        """Sweep the voltage and measure the photocurrent."""
        if auto == False:
            raw_input("Turn on the laser pefore proceeding! Press any key to continue.")
        self.I.SMU.output_on()
        self.Q.SMU.output_on()
        i_I = []
        i_Q = []
        for v in self.V:
            i_I.append(self.I.update_norm(v, 0))
            i_Q.append(self.Q.update_norm(v, 0))
        plt.plot(range(len(self.V))[2:],np.asarray(i_I)[2:]*1e6, label = self.I.name)
        plt.plot(range(len(self.V))[2:],np.asarray(i_Q)[2:]*1e6, label = self.Q.name)
        plt.xlabel("Voltage [V]")
        plt.ylabel("Current [uA]")
        plt.legend()
        plt.show()
        self.I.SMU.output_off()
        self.Q.SMU.output_off()
        return i_I.index(min(i_I)), i_Q.index(min(i_Q))
    
    def filter_off(self):
        """Turn the filters for the measured current to the off state."""
        # Turn off filters
        self.I.SMU.filter_off()
        self.Q.SMU.filter_off()
        print("Filters are now off.")
        
    def filter_on(self, count, filtertype):
        """Apply the given filter for both microrings."""
        
        #Set filter parameters
        self.I.SMU.set_filter(count, filtertype)
        self.Q.SMU.set_filter(count, filtertype)
        
        # Turn filters on
        self.I.SMU.filter_on()
        self.Q.SMU.filter_on()
        print("Filters are now on.")
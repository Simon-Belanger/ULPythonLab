import matplotlib.pyplot as plt
import numpy as np
import time

class MRM(object):
    """ Class for a single microring modulator. """

    Vd = None
    Id = None
    
    LowLim = 0
    HiLim = 4
    
    def __init__(self, SMU, name):

        self.SMU = SMU

        # Connect instruments
        self.SMU.connect()
        self.SMU.output_off()
        self.name = name

    def apply_voltage(self, V):
        """Apply bias to heater."""    
        self.SMU.source_voltage(V)

    def measure_current(self):
        """Measure the photocurrent generated by the microring resonator using the source meter unit (SMU)."""
        return self.SMU.measure_current()

    def update(self, V):
        """Apply the command (heater power) and measure the output (photocurrent)."""
        self.apply_voltage(V)
        return self.measure_current()[0]
    
    def sweep(self,V):
        """Sweep the voltage and measure the photocurrent."""
        I = []
        for v in V:
            I.append(self.update(v))
        plt.plot(V,np.asarray(I)*1e3, label = self.name)
        plt.xlabel("Voltage [V]")
        plt.ylabel("Current [mA]")
        plt.legend()
        plt.show()
        return V,I
        
    def calibrate(self):
        user_input = raw_input("Calibration requires that no optical power is present on the chip. Proceed? (y/n)\n")
        if user_input == "y":
            print("Calibration in progress ...\n")
            self.SMU.output_on()
            self.Vd, self.Id = self.sweep(self.V)
            self.SMU.output_off()
            print("Calibration finished!\n")
        else:
            print("Calibration aborted.\n")
            
    
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
        
    def sweep_norm(self):
        """Sweep the voltage and measure the photocurrent."""
        raw_input("Turn on the laser pefore proceeding! Press any key to continue.")
        self.SMU.output_on()
        I = []
        for v in self.V:
            I.append(self.update_norm(v, 0))
        plt.plot(range(len(self.V)),np.asarray(I)*1e6, label = self.name)
        plt.xlabel("Voltage [V]")
        plt.ylabel("Current [uA]")
        plt.legend()
        plt.show()
        self.SMU.output_off()
        #return V,I
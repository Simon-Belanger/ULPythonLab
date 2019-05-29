import numpy as np
import matplotlib.pyplot as plt
from Instruments.Instrument_pyvisa import Instrument_pyvisa
from Instruments.hp816x_instr import hp816x

# Power sensor class
class Agilent_81635A(Instrument_pyvisa):
    """Creates a detector object to enable measurements using the Agilent 81635A Power Sensor"""

    gpib_address = 'GPIB0::20::INSTR'

    def __init__(self, gpib_num, COMPort, slot, channel):
        
        self.gpib_address = 'GPIB'+str(gpib_num)+'::'+str(COMPort)+'::INSTR'
        self.slot = slot
        self.channel = channel

    def measure_power(self):
        """Fetch the power measured by the power sensor"""
        power = np.squeeze(self.inst.query_ascii_values("fetch" + str(self.slot) + ":channel" + str(self.channel) + ":pow?"))
        if power >= 0:
            power = -90
        return power

    def measure_power_manual(self, slot, channel):
        """Fetch the power measured by the power sensor"""
        power = np.squeeze(self.inst.query_ascii_values("fetch" + str(slot) + ":channel" + str(channel) + ":pow?"))
        if power >= 0:
            power = -90
        return power

    def laser_on(self):
        """Turn the laser on"""
        self.inst.write("sour0:pow:stat 1")

    def laser_off(self):
        """Turn the laser off"""
        self.inst.write("sour0:pow:stat 0")

    def get_wavelength(self):
        """Return the wavelength of the source"""
        return np.squeeze(self.inst.query_ascii_values("sour0:channel1:wav?")) * 1e9

    def set_wavelength(self, wavelength):
        """Set the wavelength of the source"""
        self.inst.write("sour0:wav " + str(wavelength) + "NM")

    def sweep(self, wavelength_start=1530, wavelength_stop=1565, wavelength_step=0.02, plot_sweep=True, filename=""):
        """"""
        obj1 = hp816x()
        obj1.connect('GPIB0::20::INSTR')
        
        # Sweep parameters
        obj1.sweepUnit = 'dBm'
        obj1.sweepLaserOutput = 'lowsse' # lowsse ou highpower
        obj1.sweepStartWvl = wavelength_start * 1e-9
        obj1.sweepStopWvl = wavelength_stop * 1e-9
        obj1.sweepStepWvl = wavelength_step * 1e-9

        # Perform the sweep
        wvl_sweep,pow_sweep = obj1.sweep()
        
        # Plot the results
        if plot_sweep == True:
            
            plt.plot(wvl_sweep*1e9,pow_sweep.transpose()[0], label='Detector1')
            plt.plot(wvl_sweep*1e9,pow_sweep.transpose()[1], label='Detector2')
            plt.xlabel('Wavelength (nm)')
            plt.ylabel('Power (dBm)')
            plt.legend()
            plt.show()
        
        # Save the results
        if not(filename==""):
            np.savetxt(filename, (wvl_sweep,pow_sweep.transpose()[0],pow_sweep.transpose()[1]))
      
        # Set power unit back to normal
        #obj1.setAutorangeAll()
        obj1.setPWMPowerUnit(2, 0, 'dBm')
        obj1.setPWMPowerUnit(2, 1, 'dBm')
        obj1.setPWMPowerRange(2, 0, rangeMode='auto')
        obj1.setPWMPowerRange(2, 1, rangeMode='auto')
        
        obj1.setTLSOutput('lowsse', slot=0)
        obj1.setTLSState('off' , slot=0)
        

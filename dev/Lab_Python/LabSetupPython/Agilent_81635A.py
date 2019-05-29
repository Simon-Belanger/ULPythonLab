import numpy as np
import matplotlib.pyplot as plt
from Instrument_pyvisa import Instrument_pyvisa

# Power sensor class
class Agilent_81635A(Instrument_pyvisa):
    """Creates a detector object to enable measurements using the Agilent 81635A Power Sensor"""

    gpib_address = 'GPIB0::20::INSTR'

    def __init__(self, slot, channel):
        self.slot = slot
        self.channel = channel

    def measure_power(self):
        """Fetch the power measured by the power sensor"""
        power = np.squeeze(
            self.inst.query_ascii_values("fetch" + str(self.slot) + ":channel" + str(self.channel) + ":pow?"))
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

    def check_sweep(self):
        return self.inst.query("sour0:wav:swe:chec?")

    def set_sweep(self, wavelength_start=1530, wavelength_stop=1565, wavelength_step=0.02, sweep_speed=10):
        """"""
        self.inst.write("wav:swe:star " + str(wavelength_start) + "nm")  # Set the start wavelength
        self.inst.write("wav:swe:stop " + str(wavelength_stop) + "nm")  # Set the stop wavelength
        self.inst.write("wav:swe:step " + str(wavelength_step) + "nm")  # Set the wavelength step
        self.inst.write("wav:swe:spe " + str(sweep_speed) + "nm/s")  # Set the sweep speed

    def run_sweep(self):
        self.inst.write("wav:swe START")

    def cancel_sweep(self):
        self.inst.write("wav:swe STOP")

    def manual_sweep(self, wavelength_start=1530, wavelength_stop=1565, wavelength_step=0.02):

        wvl = np.arange(wavelength_start, wavelength_stop, wavelength_step)
        power1 = [];
        power2 = []
        self.laser_on()
        for wvl_i in wvl:
            self.set_wavelength(wvl_i)
            power1.append(self.measure_power_manual(2, 1))
            power2.append(self.measure_power_manual(2, 2))
        self.laser_off()

        plt.plot(wvl, power1, '--r', wvl, power2, 'b')
        plt.xlabel('Wavelength, $\lambda$ [nm]', fontsize=18)
        plt.ylabel('Power [dBm]', fontsize=18)
        plt.legend(['Thru', 'Drop'])
        plt.show()
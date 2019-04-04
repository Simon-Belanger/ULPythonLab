import visa

# DC source class
class CoBriteDX1(object):
    """Creates a laser object to use the CoBrite Laser."""
    
    def __init__(self, COM):
        self.COM = COM
        
        self.min_freq = 191.5000
        self.max_freq = 196.2500
        self.FTF_limit = 0.0000
        self.min_power = 6.00
        self.max_power = 18.00
        
    def connect(self):
        rm = visa.ResourceManager()
        self.inst = rm.open_resource("COM" + str(self.COM))
        self.inst.baud_rate = 115200
        self.inst.data_bits = 8
        #x.parity = visa.constants.no_parity
        #x.stop_bits = visa.constants.VI_ASRL_STOP_ONE
        self.inst.flow_control = visa.constants.VI_ASRL_FLOW_NONE
        self.inst.timeout=10000
        
    def laser_on(self):
        """ Turn the output of the laser on."""
        self.inst.write("STAT 1;",encoding="utf-8")
        print("Laser is turned on. Settling ...")
        
    def laser_off(self):
        """ Turn the output of the laser off."""
        self.inst.write("STAT 0;",encoding="utf-8")
        print("Laser is turned off.")
        
    def set_power(self, power):
        self.inst.write("POW " + str(power) + ";")
        
    def set_wavelength(self, wavelength):
        self.inst.write("WAV " + str(wavelength) + ";")
        
    def set_frequency(self, frequency):
        self.inst.write("FRE" + str(frequency) + ";")
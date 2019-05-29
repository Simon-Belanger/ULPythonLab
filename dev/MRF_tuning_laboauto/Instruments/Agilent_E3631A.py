from Instrument_pyvisa import Instrument_pyvisa


# DC source class
class Agilent_E3631A(Instrument_pyvisa):
    """Creates a detector object to enable the operation of the Keithley 2612B SMU."""    
    
    def __init__(self, COMPort, channel):
        self.channel = self.format_chan_name(channel)
        self.gpib_address = 'GPIB0::'+str(COMPort)+'::INSTR'
        self.resolution = self.getresolution(self.format_chan_name(channel))

    @staticmethod
    def format_chan_name(chan_name):
        """Function used to format the input channel name to something valid."""
        if chan_name in [6, '6', '+6', 'p6', 'P6', 'P6V']:
            chan_name = 'P6V'
        elif chan_name in [25, '+25', 'p25', 'P25', 'P25V']:
            chan_name = 'P25V'
        elif chan_name in [-25, '-25', 'n25', 'n25', 'n25V']:
            chan_name = 'N25V'
        else:
            print('Error: Channel name is not valid.')
        return chan_name
    
    @staticmethod
    def getresolution(chan_name):
        """Get the resolution for each channel."""
        if chan_name == 'P6V':
            resolution = 0.001
        elif chan_name == 'P25V':
            resolution = 0.01
        elif chan_name == 'N25V':
            resolution = 0.01
        return resolution

    def output_on(self):
        """Turn on the output corresponding to the source's channel."""
        self.inst.write('OUTPut:STATe ON')

    def output_off(self):
        """Turn off the output corresponding to the source's channel."""
        self.inst.write('OUTPut:STATe OFF')

    def source_voltage(self, bias):
        """Source the voltage by the corresponding output."""
        self.inst.write('APPL ' + self.channel + ', ' + str(bias) + ', ' + str(1))
        if bias != 0.:
            self.output_on()
            
    def set_range_low(self):
        self.inst.write('VOLTage:RANGe LOW')
        
    def set_range_high(self):
        self.inst.write('VOLTage:RANGe HIGH')
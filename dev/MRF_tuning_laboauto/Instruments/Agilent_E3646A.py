from Instrument_pyvisa import Instrument_pyvisa


# DC source class
class Agilent_E3646A(Instrument_pyvisa):
    """Creates a detector object to enable the operation of the Keithley 2612B SMU."""

    chan_resolution = [0.01, 0.01]
    
    def __init__(self, COMPort, channel):
        self.channel = self.format_chan_name(channel)
        self.gpib_address = 'GPIB0::'+str(COMPort)+'::INSTR'
        self.resolution = self.getresolution(self.format_chan_name(channel))

    @staticmethod
    def format_chan_name(chan_name):
        """Function used to format the input channel name to something valid."""
        if chan_name in ['1', 1, 'out1', 'OUT1', 'output1']:
            chan_name = 'OUT1'
        elif chan_name in ['2', 2, 'out2', 'OUT2', 'output2']:
            chan_name = 'OUT2'
        else:
            print('Error: Channel name is not valid.')
        return chan_name

    @staticmethod
    def getresolution(chan_name):
        """Get the resolution for each channel."""
        if chan_name == 'OUT1':
            resolution = 0.01
        elif chan_name == 'OUT2':
            resolution = 0.01
        return resolution
    
    def output_on(self):
        """Turn on the output corresponding to the source's channel."""
        self.inst.write('output on')

    def output_off(self):
        """Turn off the output corresponding to the source's channel."""
        self.inst.write('output off')

    def source_voltage(self, bias):
        """Source the voltage by the corresponding output."""
        self.inst.write('INST:SEL ' + self.channel)
        self.inst.write('APPL ' + str(bias))
        if bias != 0.:
            self.output_on()
            
    def set_range_low(self):
        self.inst.write('VOLTage:RANGe LOW')
        
    def set_range_high(self):
        self.inst.write('VOLTage:RANGe HIGH')
        
if __name__=='__main__':
    pass
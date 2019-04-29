from Instrument_pyvisa import Instrument_pyvisa

# DC source class
class Keithley_2612B(Instrument_pyvisa):
    """Creates a detector object to enable the operation of the Keithley 2612B SMU."""

    def __init__(self, COMPort, channel):
        self.channel = self.format_chan_name(channel)
        self.gpib_address = 'GPIB0::'+str(COMPort)+'::INSTR'

    def format_chan_name(self, chan_name):
        """Function used to format the input channel name to something valid."""
        if chan_name in ['a', 'A', 0, 'chan a']:
            chan_name = 'a'
        elif chan_name in ['b', 'B', 1, 'chan b']:
            chan_name = 'b'
        else:
            print('Error: Channel name is not valid.')
        return chan_name

    def output_on(self):
        """Turn on the output corresponding to the source's channel."""
        self.inst.write("smu" + self.channel + ".source.output = 1")

    def output_off(self):
        """Turn off the output corresponding to the source's channel."""
        self.inst.write("smu" + self.channel + ".source.output = 0")

    def set_range(self,range_v):
        self.inst.write("smu" + self.channel + ".source.rangev = " + str(range_v))
        
    def source_voltage(self, bias):
        """Source the voltage by the corresponding output."""
        self.inst.write("smu" + self.channel + ".source.levelv = " + str(bias))  # max 203V
        if bias != 0:
            self.output_on()
        else:
            self.output_off()
        
    def set_range_high(self):
        self.inst.write("smu" + self.channel + ".source.rangev = " + str(20))
from Instrument_pyvisa import Instrument_pyvisa


# DC source class
class Agilent_E3646A(Instrument_pyvisa):
    """Creates a detector object to enable the operation of the Keithley 2612B SMU."""

    gpib_address = 'GPIB0::6::INSTR'

    def __init__(self, channel):
        self.channel = self.format_chan_name(channel)

    def format_chan_name(self, chan_name):
        """Function used to format the input channel name to something valid."""
        if chan_name == ('1' or 1 or 'out1' or 'OUT1' or 'output1'):
            chan_name = 'OUT1'
        elif chan_name == ('2' or 2 or 'out2' or 'OUT2' or 'output2'):
            chan_name = 'OUT2'
        else:
            print('Error: Channel name is not valid.')
        return chan_name

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
        if bias != 0:
            self.output_on()
        else:
            self.output_off()
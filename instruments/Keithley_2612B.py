from Instruments.Instrument_pyvisa import Instrument_pyvisa

# DC source class
class Keithley_2612B(Instrument_pyvisa):
    """
    Creates a detector object to enable the operation of the Keithley 2612B SMU.
    
    example: DC = Keithley_2612B(0,20,'a')
    """

    voltage_range = [200e-3, 2, 20, 200]
    current_range = [100e-9, 1e-6, 10e-6, 100e-6, 1e-3, 10e-3, 100e-3, 1, 1.5, 10]

    def __init__(self, gpib_num, COMPort, channel):
        self.channel        = self.format_chan_name(channel)
        self.gpib_address   = 'GPIB'+str(gpib_num)+'::'+str(COMPort)+'::INSTR'
        self.name           = 'Keithley2612B::' + str(COMPort) +  '::' + str(self.channel)
        self.connect()

    def format_chan_name(self, chan_name):
        """Function used to format the input channel name to something valid."""
        if chan_name in ['a', 'A', 0, 'chan a']:
            chan_name = 'a'
        elif chan_name in ['b', 'B', 1, 'chan b']:
            chan_name = 'b'
        else:
            print('Error: Channel name is not valid.')
        return chan_name


    # Range commands

    # Measure
    def measure_current_autorange_on(self):
        """Enable current measure autorange."""
        self.inst.write("smu" + self.channel + ".measure.autorangei = smu" + self.channel + ".AUTORANGE_ON")

    def measure_current_autorange_off(self):
        """Disable current measure autorange."""
        self.inst.write("smu" + self.channel + ".measure.autorangei = smu" + self.channel + ".AUTORANGE_OFF")

    def measure_voltage_autorange_on(self):
        """Enable voltage measure autorange."""
        self.inst.write("smu" + self.channel + ".measure.autorangev = smu" + self.channel + ".AUTORANGE_ON")

    def measure_voltage_autorange_off(self):
        """Disable voltage measure autorange."""
        self.inst.write("smu" + self.channel + ".measure.autorangev = smu" + self.channel + ".AUTORANGE_OFF")

    def measure_range_current(self,rangeval):
        """Set current measure range."""
        self.inst.write("smu" + self.channel + ".measure.rangei = " + str(rangeval))

    def measure_range_voltage(self,rangeval):
        """Set voltage measure range."""
        self.inst.write("smu" + self.channel + ".measure.rangev = " + str(rangeval))

    # Source
    def source_current_autorange_on(self):
        """Enable current measure autorange."""
        self.inst.write("smu" + self.channel + ".source.autorangei = smu" + self.channel + ".AUTORANGE_ON")

    def source_current_autorange_off(self):
        """Disable current measure autorange."""
        self.inst.write("smu" + self.channel + ".source.autorangei = smu" + self.channel + ".AUTORANGE_OFF")

    def source_voltage_autorange_on(self):
        """Enable voltage measure autorange."""
        self.inst.write("smu" + self.channel + ".source.autorangev = smu" + self.channel + ".AUTORANGE_ON")

    def source_voltage_autorange_off(self):
        """Disable voltage measure autorange."""
        self.inst.write("smu" + self.channel + ".source.autorangev = smu" + self.channel + ".AUTORANGE_OFF")

    def source_range_current(self,rangeval):
        """Set current measure range."""
        self.inst.write("smu" + self.channel + ".source.rangei = " + str(rangeval))

    def source_range_voltage(self,rangeval):
        """Set voltage measure range."""
        self.inst.write("smu" + self.channel + ".source.rangev = " + str(rangeval))

    def limit_current(self, level):
        """Set current limit."""
        self.inst.write("smu" + self.channel + ".source.limiti = " + str(level))

    def limit_voltage(self, level):
        """Set voltage limit."""
        self.inst.write("smu" + self.channel + ".source.limitv = " + str(level))

    def limit_power(self, level):
        """Set power limit."""
        self.inst.write("smu" + self.channel + ".source.limitp = " + str(level))


    # Measure commands
    def measure_current(self):
        """Request a current reading."""
        return self.inst.query_ascii_values("print(smu" + self.channel + ".measure.i())")[0]

    def measure_voltage(self):
        """Request a voltage reading."""
        return self.inst.query_ascii_values("print(smu" + self.channel + ".measure.v())")

    def measure_currentvoltage(self):
        """Request a current and voltage reading."""
        return self.inst.query_ascii_values("print(smu" + self.channel + ".measure.iv())")

    def measure_resistance(self):
        """Request a resistance reading."""
        return self.inst.query_ascii_values("print(smu" + self.channel + ".measure.r())")

    def measure_power(self):
        """Request a power reading."""
        return self.inst.query_ascii_values("print(smu" + self.channel + ".measure.p())")


    # Source commands
    def function_voltage(self):
        """Select voltage source function."""
        return self.inst.write("smu" + self.channel + ".source.func = smu" + self.channel + ".OUTPUT_DCVOLTS")

    def function_current(self):
        """Select current source function."""
        return self.inst.write("smu" + self.channel + ".source.func = smu" + self.channel + ".OUTPUT_DCAMPS")

    def source_current(self, bias):
        """Set current source value."""
        self.inst.write("smu" + self.channel + ".source.leveli = " + str(bias))

    def source_voltage(self, bias):
        """Set voltage source value."""
        self.inst.write("smu" + self.channel + ".source.levelv = " + str(bias))

    def output_on(self):
        """Turn on source output."""
        self.inst.write("smu" + self.channel + ".source.output = 1")

    def output_off(self):
        """Turn off source output."""
        self.inst.write("smu" + self.channel + ".source.output = 0")


    # Misc commands
    def factory_reset(self):
        """Restore Series 2600B defaults."""
        self.inst.write("smu" + self.channel + ".reset()")
        
    def set_filter(self, count, filter_type):
        self.inst.write("smu" + self.channel + ".measure.filter.count = " + str(count))
        if filter_type == "median":
            self.inst.write("smu" + self.channel + ".measure.filter.type = smua.FILTER_MEDIAN")
        elif filter_type == "moving average":
            self.inst.write("smu" + self.channel + ".measure.filter.type = smua.FILTER_MOVING_AVG")
        elif filter_type == "repeat average":
            self.inst.write("smu" + self.channel + ".measure.filter.type = smua.FILTER_REPEAT_AVG")
        
    def filter_on(self):
        self.inst.write("smu" + self.channel + ".measure.filter.enable = smua.FILTER_ON")
        
    def filter_off(self):
        self.inst.write("smu" + self.channel + ".measure.filter.enable = smua.FILTER_OFF")
        
    def filter_state(self):
        print(self.inst.query_ascii_values("print(smu" + self.channel + ".measure.filter.enable)"))
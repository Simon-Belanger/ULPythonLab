import visa

class Instrument_pyvisa(object):
    """
    General VISA instrument
    
    Attributes
        gpib_address : Remote address for GPIB connection in the format 'GPIB'+str(gpib_num)+'::'+str(COMPort)+'::INSTR"
    """

    echo = False

    def connect(self):
        """Connect to the instrument's remote interface."""
        rm = visa.ResourceManager()
        self.inst = rm.open_resource(self.gpib_address)
        if self.echo: print("Connected to the instrument.")

    def disconnect(self):
        """Disconnect the device and mark the handle as invalid."""
        self.inst.close()
        if self.echo: print("Disconnected to the instrument.")

    def identify(self):
        """Print the instrument's identification."""
        print(self.inst.query('*IDN?'))

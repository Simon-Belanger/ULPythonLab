import visa
from Instruments.Instrument import Instrument


class Instrument_pyvisa(Instrument):
    """
    General VISA instrument
    
    Attributes
        gpib_address : Remote address for GPIB connection in the format 'GPIB'+str(gpib_num)+'::'+str(COMPort)+'::INSTR"
    """

    def connect(self):
        """Connect to the instrument's remote interface."""
        rm = visa.ResourceManager()
        self.inst = rm.open_resource(self.gpib_address)
        print("Connected to the instrument.")

    def identify(self):
        """Print the instrument's identification."""
        print(self.inst.query('*IDN?'))

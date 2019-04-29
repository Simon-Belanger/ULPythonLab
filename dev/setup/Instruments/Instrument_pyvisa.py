import visa
from Instrument import Instrument


class Instrument_pyvisa(Instrument):
    """"""

    def connect(self):
        """Connect to the instrument's remote interface."""
        rm = visa.ResourceManager()
        self.inst = rm.open_resource(self.gpib_address)

    def identify(self):
        """Print the instrument's identification."""
        print(self.inst.query('*IDN?'))

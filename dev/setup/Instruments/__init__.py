"""
This package contains all the instruments required by the software.
"""

# modules imported with the " from Instruments import * " statement
__all__ = ["Agilent_81635A","Agilent_E3646A","Agilent_E3631A","hp816x_instr","Instrument","Instrument_pyvisa","Keithley_2612B","laser"]

# directly import classes from modules
from Instruments.Agilent_81635A import Agilent_81635A
from Instruments.Agilent_E3646A import Agilent_E3646A
from Instruments.Agilent_E3631A import Agilent_E3631A
from Instruments.hp816x_instr import hp816x
from Instruments.Instrument import Instrument
from Instruments.Instrument_pyvisa import Instrument_pyvisa
from Instruments.Keithley_2612B import Keithley_2612B
from Instruments.laser import laser
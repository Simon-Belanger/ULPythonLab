#Simon Belanger-de Villers
#4th November 2019
#Characterize the JDS OPtical Switch.
#
# Use case
#
# switch = opticalSwitch(0, 7)
# switch.connect()
# switch.identify()
# 
# switch.setChannel(1)



from Instruments.Instrument_pyvisa import Instrument_pyvisa

class opticalSwitch(Instrument_pyvisa):

    def __init__(self, gpib_num, COMPort):
        
        self.gpib_address = 'GPIB'+str(gpib_num)+'::'+str(COMPort)+'::INSTR'

    def identify(self):
    	"""Print the instrument's identification."""
    	print(self.inst.query('IDN?'))

    def setChannel(self, channelNumber):
    	"""Closes the optical path represented by integer channelNumber. Makes an optical path with Common."""
    	self.inst.write('CLOSE {}'.format(channelNumber))
    	print('Switch path is now closed with channel {}.'.format(channelNumber))

    def getChannel(self):
    	"""Returns the current optical path number."""
    	return self.inst.query('CLOSE?')

    def isOperationComplete(self):
    	"""Returns the status of the input buffer. True means that last operation is complete. """
    	operationComplete = False
    	if int(self.inst.query('OPC?')) == 1: operationComplete = True
    	return operationComplete

    def reset(self):
    	"""Returns the switch to power up state, for example, channel 0, relay drivers off."""
    	self.inst.write('RESET')
    	print('The switch has been reset to it\'s original state.')

    def readStatusRegister(self):
    	return self.inst.query('STB?')

    def readConditionRegister(self):
    	return self.inst.query('CNB?')


OS = opticalSwitch(0,7)
OS.connect()

OS.identify()
OS.reset()


OS.setChannel(5)
print(OS.getChannel())
from Instruments.hp816x_instr_py3 import hp816x
import sys
from tkinter import *
import time
import matplotlib.pyplot as plt
from data.wvlsweep import wvlsweep

def dummyPowerGauge():
	""" Show the power measured on the detector in order to perform optical alignment. """

	# Initialize the laser
	LMS = hp816x()
	LMS.connect('GPIB0::20::INSTR')
	LMS.setTLSOutput('lowsse')
	LMS.setTLSWavelength(1568e-9)
	LMS.setTLSPower(0)
	LMS.setPWMAveragingTime(1, 0, 1)
	LMS.setPWMAveragingTime(4, 0, 1)
	LMS.setPWMPowerUnit(1, 0, 'dBm')
	LMS.setPWMPowerUnit(4, 0, 'dBm')
	LMS.setPWMPowerRange(1, 0, 'manual', 0)
	LMS.setPWMPowerRange(4, 0, 'manual', 0)
	LMS.setTLSState('on')

	# Setup the GUI
	root = Tk()	
	l1 = Label(root)
	l1.pack()
	l2 = Label(root)
	l2.pack()
	
	def clock():
		l1.config(text='P {0:0.4f} dBm'.format(LMS.readPWM(1, 0)))
		l2.config(text='P {0:0.4f} dBm'.format(LMS.readPWM(4, 0)))
		root.after(1000, clock) 

	# run first time
	clock()
	root.mainloop()

def measureAlignmentThermalDrift(mrf):
	""" Measure the time response of the thermal drift of the optical alignment. """

	# Turn on the laser
	mrf.activePort = 'Drop'
	mrf.LMS.setTLSWavelength(1568e-9)
	mrf.LMS.setTLSPower(0)
	mrf.LMS.setTLSState('on')
	time.sleep(2)
	
	# loop
	loopStartTime = time.time()
	timer, power = [],[]
	for iter in range(3000):
		timer.append(time.time()-loopStartTime)
		time.sleep(0.1)
		#measure the current every second
		power.append(mrf.measurePower())

		if iter==100: # Turn on the voltage
			mrf.apply_bias(1, 2)
		if iter==1500: # Turn off the voltage
			mrf.apply_bias(1, 0)

	# Plot the drift
	plt.plot(timer, power)
	plt.xlabel('Time [s]')
	plt.ylabel('Power [dB]')
	plt.grid()
	plt.show()

if __name__ == '__main__':
	dummyPowerGauge()
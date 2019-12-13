"""
Functions used to characterise both the drop and through port of an add drop filter using the OVA + can optical switch.

Author: Simon Belanger-de Villers
Date created: 20 November 2019
Last edited: 20 November 2019
"""
import matplotlib.pyplot as plt
from data.sweepobj import sweepobj
import numpy as np
import time
import os
import pickle

def measureFilterTransmission(switch, luna):
	'''Measure the Thru/Drop port transmission spectrum.'''

	# Dicts with parameters
	osPorts 	= {'Thru': 2, 'Drop': 1} 			# Optical switch ports
	dutLength 	= {'Thru': 28.162, 'Drop': 22.557} 	# DUT Length of the scans
	
	# Measure the thru port spectrum
	switch.setChannel(osPorts['Thru'])
	luna.dutLength = dutLength['Thru']
	luna.scan()
	thru = luna.fetchResult('0')
	
	# Measure the drop port spectrum
	switch.setChannel(osPorts['Drop'])
	luna.dutLength = dutLength['Drop']
	luna.scan()
	drop = luna.fetchResult('0')
	
	# Fetch the X axis data
	wvl = luna.fetchXAxis()

	return wvl, thru, drop

def plotTransmission(wvl, thru, drop):
	'''Plot the Thru/Drop transmission spectrum.'''

	plt.plot(wvl, thru, color='b', label='Through Port')
	plt.plot(wvl, drop, color='r', label='Drop Port')
	plt.xlabel('Wavelength [nm]'), plt.ylabel('Transmission [dB]')
	plt.title('OVA Scan')
	plt.xlim([min(wvl), max(wvl)]), plt.ylim([-70, -10])
	plt.grid(), plt.legend(), plt.show()

def saveTransmission(wvl, thru, drop, filename):
	'''Save the spectrum in a pickle file.'''

	swobj = sweepobj()
	swobj.filename          = ""
	swobj.device            = ""
	swobj.info              = ""
	swobj.wavelength_start  = min(wvl)
	swobj.wavelength_stop   = max(wvl)
	swobj.wavelength_step   = (max(wvl)-min(wvl))/len(wvl)
	swobj.xlims             = [min(wvl)*1e9, max(wvl)*1e9] # Defaults
	swobj.ylims             = [-100, 0] # Defaults
	
	# Put the data 
	swobj.wavelength = np.asarray(wvl, dtype=object)
	swobj.detector_1 = np.asarray(thru, dtype=object)
	swobj.detector_2 = np.asarray(drop, dtype=object)
	
	# Save the datafile
	swobj.save(filename)
	print("Saving the data to " + filename + " ...")

def checkParams():
	''' Measure the actual central wavelength vs different programmed central wavelengths.'''
	luna.rangeWav = 0.63
	target, meas = [],[]
	for ran in np.linspace(1500, 1600, 100):
		luna.centerWav = ran
		target.append(ran)
		meas.append(luna.centerWav)

	plt.plot(target, meas)
	plt.show()

if __name__ == '__main__':

	# Connect to the Optical Switch
	switch = JDSopticalSwitch(0, 7)
	switch.connect()

	# Connect to the OVA
	luna = Luna("10.9.32.234", 8888)

	# Perform a scan using the OVA
	luna.rangeWav 	= 5
	luna.centerWav 	= 1553
	luna.disableAverage()

	wvl, thru, drop = measureFilterTransmission(switch, luna)
	plotTransmission(wvl, thru, drop)
	filename = os.getcwd() + '//measures//die11_v2_zoom'
	saveTransmission(wvl, thru, drop, filename)
	sweepobj(filename).show()
	luna.close()
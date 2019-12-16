"""
Perform IV curves testing in python and save the results.

Author: Simon Belanger-de Villers
Date created: 25 November 2019
Last edited: 26 November 2019
"""
import numpy as np
import matplotlib.pyplot as plt
import os, pickle

def measureIVCurve(powerSupply, voltage, doPlot=False):
	'''Measure and plot the IV curve of a given heater/actuator.'''
	current = []
	powerSupply.source_voltage(0)
	powerSupply.output_on()
	for v in voltage:
		powerSupply.source_voltage(v)
		current.append(powerSupply.measure_current())
	if doPlot:
		plt.plot(voltage, np.asarray(current)*1e3, label=powerSupply.name)
		plt.xlabel("Voltage [V]"), plt.ylabel("Current [mA]"), plt.legend(), plt.grid(), plt.show()
	powerSupply.output_off()
	return np.asarray(voltage), np.asarray(current)

def acquireIVCurveMultiple(powerSuppliesList, voltage, filename=None):
	'''Measure the current, resistance and applied power vs voltage and plot everything in the same plot.'''

	V, IAll, labels = measureMultipleIVCurve(powerSuppliesList, voltage)
	plotMultipleIVCurve(V, IAll, labels)

	if filename != None:
		# check if the file exists
		if os.path.exists(filename):
			decision = input('Warning: The file already exists. Press x to overwrite...\n')
			if decision != 'x':
				print('The file will not be saved.')
				exit()

		# Save the file
		print('saving file as ' + filename + '\n')
		outfile = open(filename,'wb')
		data = {'voltage [V]': V, 'current [A]': IAll, 'labels': labels}
		pickle.dump(data, outfile)
		outfile.close()

def measureMultipleIVCurve(powerSuppliesList, voltage):
	''' measure the IV curve for all heaters.'''

	IAll 	= []
	labels 	= []
	for powerSupply in powerSuppliesList:
		V, I = measureIVCurve(powerSupply, voltage)
		IAll.append(I)
		labels.append(powerSupply.name)
	return V, IAll, labels

def plotMultipleIVCurve(V, IAll, labels):
	'''Plot the IV curve for all heaters.'''

	figure = plt.figure(figsize=(15,7.5))
	IVplot = figure.add_subplot(3,1,1)
	plt.ylabel("Current [mA]"), plt.grid()
	Rplot = figure.add_subplot(3,1,2, sharex=IVplot)
	plt.ylabel("Resistance [ohms]"), plt.grid(), plt.ylim([100, 200])
	Pplot = figure.add_subplot(3,1,3, sharex=IVplot)
	plt.xlabel("Voltage [V]"), plt.ylabel("Power [mW]"), plt.grid()
	for I, label in zip(IAll, labels):
		IVplot.plot(V, I*1e3, label=label)
		Rplot.plot(V, V/I, label=label)
		Pplot.plot(V, I*V*1e3, label=label)
	handles, labels = Pplot.get_legend_handles_labels()
	figure.legend(handles, labels, loc='upper right')
	plt.show()

def loadIVCurveMultiple(filename):
	''' Open a file containing an IV curve and plot it.'''
	infile = open(filename,'rb')
	data = pickle.load(infile)
	infile.close()

	plotMultipleIVCurve(data['voltage [V]'], data['current [A]'], data['labels'])

def analyzeBreadownIVCurve(filename, treshold = 0.015):
	''' Open a file containing a breadown test and extract the breakdown current, the breakdown power 
	 and the average resistance of the heater.'''

	# Open the file
	infile = open(filename,'rb')
	data = pickle.load(infile)
	infile.close()

	# Extract the breakdown current for each curve
	for I in data['current [A]']: # for each dataset
		previous = 0
		print('Breakdown current = \t{:0.3f} mA'.format(np.max(I)*1e3))
		P = I * data['voltage [V]']
		index = I.tolist().index(np.max(I))
		print('Breakdown power = \t{:0.3f} mW'.format(1e3*P[index]))
		plt.show()

if __name__ == '__main__':

	# Set the voltage that will be swept
	voltage = np.linspace(0, 4, 40)

	# Name the output file
	import os
	filename = os.getcwd() + '\\measures\\ElectricalCharacterisation\\die03\\SC_DP_GC_v1_breakdown.pickle'

	# Acquire the data
	V1 = Keithley_2612B(0, 24,'a')
	V2 = Keithley_2612B(0, 24,'b')
	acquireIVCurveMultiple([V1, V2], voltage, filename)

	# Load and plot the data
	loadIVCurveMultiple(filename)

	# Analyze the data
	analyzeBreadownIVCurve(filename)
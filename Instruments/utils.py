"""
Miscellaneous methods regarding the remote control of instruments in the Lab.

Author: Simon Belanger-de Villers
Date: November 19th 2019
"""

import visa

def checkRessources():
	" List the ressources currently connected to the computer."
	rm = visa.ResourceManager()

	for i in rm.list_resources():
		try:
			x = rm.open_resource(i)
			print(i + '\n' + x.query('*IDN?') + '\n')
		except visa.VisaIOError:
			print(i + '\nInstrument Not found\n')

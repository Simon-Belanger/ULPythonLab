"""
General all-purpose script

Author		 : Simon Belanger-de Villers
Date created : 13 November 2019
Last edited	 : 3 December 2019
"""
from Instruments.Keithley_2612B import Keithley_2612B
from Instruments.Agilent_E3631A import Agilent_E3631A
from Instruments.hp816x_instr_py3 import hp816x
from Instruments.utils import *
from dev.MRF_FBL.MRF import RealMRF
from dev.MRF_FBL.Algo import *
import matplotlib.pyplot as plt
plt.switch_backend('TkAgg')
import numpy as np
import time, os
from AddDropOVA import *
from IVcurves import *
from data.sweepobj import sweepobj
from utils import *

print('code start...\n')
scanStartTime = time.time()

# Agilent LightWave Measurement System
LMS = hp816x()

# Connect to the DC Sources
V1 = Keithley_2612B(0, 24,'a')
V2 = Keithley_2612B(0, 24,'b')
V3 = Keithley_2612B(0, 26,'a')
V4 = Keithley_2612B(0, 26,'b')
V5 = Agilent_E3631A(0, 6, 25)
V1.source_range_voltage(20)
V2.source_range_voltage(20)
V3.source_range_voltage(20)
V4.source_range_voltage(20)

# Init System
instruments = {'LMS': LMS,
			   'dropChan': (4,0),
			   'thruChan': (1,0),
               'DCsources': [V1, V2, V3, V4, V5],
               'LowerLimitDC': [0]*5,
               'UpperLimitDC': [3]*5}
data_dir = os.getcwd() + '\\measures\\FilterTuning\\die03\\'
mrf = RealMRF(instruments, 0.01, data_dir)

# Check if heaters have a trouble# if the optical alignment is good
#acquireIVCurveMultiple([V1, V2, V3, V4, V5], np.linspace(0, 3, 40), None)
#mrf.wavelengthSweep(1565e-9, 1572e-9, 0.012e-9, True, True, None)

#mrf.apply_bias(1, 2)
#mrf.wavelengthSweep(1500e-9, 1570e-9, 0.06e-9,False, True, None)

#wavelength = np.linspace(1500e-9, 1600e-9, 1000)
#mrf.LMS.setTLSPower(0)
#mrf.LMS.setTLSState('on')
#power = []
#for wvl in wavelength:
#	mrf.LMS.setTLSWavelength(wvl)
#	power.append(mrf.LMS.readPWM(4, 0))
#plt.plot(wavelength, power)
#plt.show()
#from data.sweepobj import sweepobj
#swobj = sweepobj()
#swobj.wavelength = wavelength
#swobj.detector_1 = power
#data_dir = os.getcwd() + '\\measures\\laserPowerCalib\\'
#swobj.save(data_dir + 'laserCurve')

maxPow1500_1600 = mrf.LMS.getTLSMaxPower(1500e-9, 1600e-9)
#maxPow1525_1575 = mrf.LMS.getTLSMaxPower(1525e-9, 1575e-9)
#maxPow1540_1560 = mrf.LMS.getTLSMaxPower(1540e-9, 1560e-9)


mrf.wavelengthSweep(maxPow1500_1600, 1500e-9, 1600e-9, 0.012e-9, True, True, None)
#mrf.wavelengthSweep(maxPow1500_1600, 1525e-9, 1575e-9, 0.012e-9,False, True, None)
#mrf.wavelengthSweep(maxPow1500_1600, 1540e-9, 1560e-9, 0.012e-9,False, True, None)



# End of code
scanStopTime = time.time()
print('code done in {0:0.3f}.'.format(scanStopTime-scanStartTime))
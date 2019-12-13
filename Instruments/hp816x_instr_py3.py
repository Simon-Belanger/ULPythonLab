#
# Copyright 2015, Michael Caverley
#
# 2019, Conversion to python 3
# Simon Bélanger-de Villers

from ctypes import *
import numpy as np
import numpy.ctypeslib as npct
from itertools import repeat
import math
import string

class hp816x(object):
    
    # Constants
    name    = 'hp816x'
    isMotor = False
    isLaser = True
    # Slot info
    hp816x_UNDEF                = 0
    hp816x_SINGLE_SENSOR        = 1
    hp816x_DUAL_SENSOR          = 2
    hp816x_FIXED_SINGLE_SOURCE  = 3
    hp816x_FIXED_DUAL_SOURCE    = 4
    hp816x_TUNABLE_SOURCE       = 5
    hp816x_SUCCESS              = 0
    hp816x_ERROR                = int('0x80000000', 16)
    hp816x_INSTR_ERROR_DETECTED = -1074000633 # 0xBFFC0D07
    
    maxPWMPoints        = 4001 # 20001
    
    sweepStartWvl       = 1530e-9   # Starting wavelength for the wavelength sweep.                                                 [dBm]
    sweepStopWvl        = 1570e-9   # Stopping wavelength for the wavelength sweep.                                                 [dBm]
    sweepStepWvl        = 1e-9      # Step wavelength for the wavelength sweep.                                                     [dBm]
    sweepSpeed          = 'auto'    # Sweeping speed.                                                                               [nm s-1]
    sweepUnit           = 'dBm'     # Power units used for the wavelength sweep.                                                    [-]
    sweepPower          = 0         # Laser power at which the sweep will be performed.                                             [dBm]
    sweepLaserOutput    = 'lowsse'  # Laser output that will be used to perform sweeps                                              [-]
    sweepNumScans       = 1         # Number of sweep cycles that will be performed (to sweep different ranges)                     [-]
    sweepPWMChannel     = 'all'     # 
    sweepInitialRange   = -20       # Power range for the initial scan.                                                             [dBm]
    sweepRangeDecrement = 20        # Power range decrement for subsequent scans.                                                   [dBm]
    sweepUseClipping    = 1         # Turns the clipping function on or off
    sweepClipLimit      = -100      # Power value to which a power measurement will be clipped to if it is less than the limit.     [dBm]

    rangeModeDict       = {'auto': 1, 'manual': 0}
    sweepSpeedDict      = {'80nm': -1, '40nm': 0, '20nm': 1, '10nm': 2, '5nm': 3, '0.5nm': 4, 'auto': 5}
    laserOutputDict     = {'highpower': 0, 'lowsse': 1}
    laserStateDict      = {'off': 0, 'on': 1}
    sweepUnitDict       = {'dBm': 0, 'W':1}
    sweepNumScansDict   = {1: 0, 2: 1, 3: 2}
    laserSelModeDict    = {'min': 0, 'default': 1, 'max': 2, 'manual': 3}
    mainframePortDict   = {'8163': 3, '8164': 5, 'none': 1}
    
    
    def __init__(self, libLocation='hp816x_32.dll'):
        """ Initializes the driver.
        libLocation -- Location of hp816x_32.dll library. It will search the system's PATH variable by default.
        """
        self.hLib = WinDLL(libLocation)
        self.createPrototypes()
        self.connected = False
        
    def __del__(self):
        """ Finalizer for the class. Executes when object is cleared from memory. """
        if self.connected:
            self.disconnect()

    def connect(self, visaAddr, reset = 0, forceTrans=1, autoErrorCheck=1):
        """ Connects to the instrument.
        visaAddr -- VISA instrument address e.g. GPIB0::20::INSTR
        reset -- Reset instrument after connecting
        """
        if self.connected:
            print('Already connected to the laser. Aborting connection.')
            return
        self.hDriver = c_int32() # Handle to the driver.
        queryID = 1 # The instrument ignores this value.
        res = self.hp816x_init(visaAddr.encode('utf-8'), queryID, reset, byref(self.hDriver))
        self.checkError(res)
        # Set force transaction mode
        self.setForceTransaction(forceTrans)
        # Set error checking mode
        self.setErrorCheckMode(autoErrorCheck)
        
        # Get the mainframe type
        deviceIdnStr = self.gpibQueryString('*IDN?').strip().split(',')
        print('The mainframe is: {}'.format(deviceIdnStr[1]))
        
        if '8164' in deviceIdnStr[1]:
            mainframeType = '8164'
        elif '8163' in deviceIdnStr[1]:
            mainframeType = '8163'
        else:
            mainframeType = 'none'

        self.numSlots = self.mainframePortDict[mainframeType]
        # Get the slot info
        self.slotInfo = self.getSlotInfo()
        self.pwmSlotIndex,self.pwmSlotMap = self.enumeratePWMSlots()
        self.activeSlotIndex = self.pwmSlotIndex
        # Register the mainframe so it can do sweeps
        self.registerMainframe(self.hDriver)
        print('Connected to the laser')
        self.connected = True
        
    def setForceTransaction(self, force):
        """ When force is true, always send commands to the instrument, even if the commands
            do not change the instrument's state. If false, only send commands which would change
            the instrument's state.
        """
        res = self.hp816x_forceTransaction(self.hDriver, force)
        self.checkError(res)
        return
        
    def setErrorCheckMode(self, check):
        """ When check is true, enables auto error checking. When false, disables error
            checking which could make the driver execute faster
        """
        res = self.hp816x_errorQueryDetect(self.hDriver, check)
        self.checkError(res)
        return
        
    def getSlotInfo(self):
        slotInfoArr = (c_int32*self.numSlots)()
        slotInfoArrPtr = cast(slotInfoArr, POINTER(c_int32))
        res = self.hp816x_getSlotInformation_Q(self.hDriver, self.numSlots, slotInfoArrPtr)
        self.checkError(res)
        return slotInfoArrPtr[:self.numSlots]
        
    def enumeratePWMSlots(self):
        """ Returns two lists:
            pwmSlotIndex - List containing index for each detector
            pwmSlotMap - List of tuples containing the index and detector number for each detector
        """
        pwmSlotIndex = list()
        pwmSlotMap = list()
        slotIndex = 0 # Slot index
        enumeratedIndex = 0 # PWM index starting from zero
        for slot in self.slotInfo:
            if slot == self.hp816x_SINGLE_SENSOR:
                pwmSlotIndex.append(enumeratedIndex)
                pwmSlotMap.append((slotIndex,0))
                #slotIndex += 1;
                enumeratedIndex += 1
            elif slot == self.hp816x_DUAL_SENSOR:
                pwmSlotIndex.append(enumeratedIndex)
                pwmSlotMap.append((slotIndex,0))
                #slotIndex += 1;
                enumeratedIndex += 1
                pwmSlotIndex.append(enumeratedIndex)
                pwmSlotMap.append((slotIndex,1))
                #slotIndex += 1;
                enumeratedIndex += 1
            slotIndex += 1
        return pwmSlotIndex, pwmSlotMap
                                    
    
    def registerMainframe(self, handle):
        """ Registers a mainframe so it can participate in a sweep """
        res = self.hp816x_registerMainframe(handle)
        self.checkError(res)
        return
        
    def unregisterMainframe(self, handle):
        res = self.hp816x_unregisterMainframe(handle)
        self.checkError(res)
        return
        
    def extractSweepParametersFromDict(self):
        """ Convert values from string representation to integers for the driver. """
        unitNum         = self.sweepUnitDict[self.sweepUnit]            # Power unit for sweep (dBm or W)
        outputNum       = self.laserOutputDict[self.sweepLaserOutput]   # Laser to use for the sweep (lowSSE or HP)
        numScans        = self.sweepNumScansDict[self.sweepNumScans]    # Number of sweep cycles that will be performed.
        numChan         = len(self.pwmSlotIndex)                        # Total number of channels
        numActiveChan   = len(self.activeSlotIndex)                     # Number of active channels
        return unitNum, outputNum, numScans, numChan, numActiveChan

    def calculateTotalNumberOfSweepPoints(self):
        """ From the sweep range and step, calculate the total number of sweep points. """
        return int(round((self.sweepStopWvl-self.sweepStartWvl)/self.sweepStepWvl+1))

    def calculateMaxNumberOfPointsPerSweep(self):
        """ The laser reserves 100 pm of spectrum which takes away from the maximum number of datapoints per scan
            Also, we will reserve another 100 datapoints as an extra buffer. """
        laserBuffer = 100e-12   # [m]
        extraBuffer = 100       # [# points]
        return int(round(self.maxPWMPoints-math.ceil(laserBuffer/self.sweepStepWvl))) - extraBuffer

    def stitching(self):
        """ Divide the full scan in different stitches that will be scanned independantly. """

        numTotalPoints    = self.calculateTotalNumberOfSweepPoints()    # Number of points in the total sweep
        maxPWMPointsTrunc = self.calculateMaxNumberOfPointsPerSweep()   # Max number of points per sweep (stitch)


        numFullScans, stitchNumber, numRemainingPts = self.divideIntoStitches(numTotalPoints, maxPWMPointsTrunc)
        print('Total number of datapoints: {}\nNumber of stitches: {}'.format(numTotalPoints, stitchNumber))

        # Create a list of the number of points per stitch and corresponding start and stop wavelengths
        numPointsLst            = self.listPointsPerStitch(maxPWMPointsTrunc, numFullScans, numRemainingPts)
        startWvlLst, stopWvlLst = self.listStartAndStopWavelength(self.sweepStartWvl, self.sweepStepWvl, numPointsLst)
        return numPointsLst, startWvlLst, stopWvlLst, numTotalPoints

    def sweep(self):
        """ Performs a wavelength sweep.
            Split the total range in different scans (stitches) and then perform all sweeps. 

            frame - Can be either single or multi, for single frame scan vs multi frame scan.""" 

        self.setSweepSpeed(self.sweepSpeed)

        unitNum, outputNum, numScans, numChan, numActiveChan = self.extractSweepParametersFromDict()
        numPointsLst, startWvlLst, stopWvlLst, numTotalPoints = self.stitching()
                
        # Loop over all the stitches
        wavelengthArrPWM, powerArrPWM = np.zeros(int(numTotalPoints)), np.zeros((int(numTotalPoints), numActiveChan))
        pointsAccum = 0
        for points, startWvl, stopWvl in zip(numPointsLst, startWvlLst, stopWvlLst):
            print('Sweeping from {} nm to {} nm'.format(startWvl*1e9, stopWvl*1e9))
            
            # Prepare the sweep
            startWvlAdjusted, stopWvlAdjusted = self.formatWavelengthForSweep(startWvl, 'below'), self.formatWavelengthForSweep(stopWvl, 'above')
            c_numPts, c_numChanRet = c_uint32(), c_uint32()
            res = self.hp816x_prepareMfLambdaScan(self.hDriver, unitNum, self.sweepPower, outputNum, numScans, numChan, \
                            startWvlAdjusted, stopWvlAdjusted, self.sweepStepWvl, byref(c_numPts), byref(c_numChanRet))
            self.checkError(res)
            numPts = int(c_numPts.value)

            # Check parameters
            self.getLambdaScanParameters('multiFrame')
            
            # Set range params
            for PWMslot in self.activeSlotIndex:
                self.setRangeParams(PWMslot, self.sweepInitialRange, self.sweepRangeDecrement)

            # Execute the sweep
            wavelengthArr = np.zeros(int(numPts))
            res = self.hp816x_executeMfLambdaScan(self.hDriver, wavelengthArr)
            self.checkError(res)
            for zeroIdx, chanIdx in enumerate(self.activeSlotIndex):
                wavelengthArrTemp, powerArrTemp = self.getLambdaScanResult(chanIdx, self.sweepUseClipping, self.sweepClipLimit, numPts)
                wavelengthArrTemp, powerArrTemp = self.stripOutputArrays(wavelengthArrTemp, powerArrTemp, startWvl, stopWvl)
                powerArrPWM[pointsAccum:pointsAccum + points, zeroIdx] = powerArrTemp

            wavelengthArrPWM[pointsAccum:pointsAccum + points] = wavelengthArrTemp
            pointsAccum += points

        return (wavelengthArrPWM, powerArrPWM)

    def stripOutputArrays(self, wavelengthArrTemp, powerArrTemp, startWvl, stopWvl):
        """ The driver sometimes doesn't return the correct starting wavelength for a sweep. We will search the returned 
            wavelength results to see the index at which the deired wavelength starts at, and take values starting from there. """
        wavelengthStartIdx = self.findClosestValIdx(wavelengthArrTemp, startWvl)
        wavelengthStopIdx  = self.findClosestValIdx(wavelengthArrTemp, stopWvl)

        wavelengthArrTemp   = wavelengthArrTemp[wavelengthStartIdx:wavelengthStopIdx+1]
        powerArrTemp        = powerArrTemp[wavelengthStartIdx:wavelengthStopIdx+1]
        return wavelengthArrTemp, powerArrTemp

    def executeLambdaSweep(self, numPts):
        """ Execute a singleFrame wavelength sweep. """
        wavelengthArr = np.zeros(int(numPts))
        powerArr1, powerArr2, powerArr3, powerArr4 = np.zeros(int(numPts)), np.zeros(int(numPts)), np.zeros(int(numPts)), np.zeros(int(numPts))
        powerArr5, powerArr6, powerArr7, powerArr8 = np.zeros(int(numPts)), np.zeros(int(numPts)), np.zeros(int(numPts)), np.zeros(int(numPts))
        res = self.hp816x_executeLambdaScan(self.hDriver, wavelengthArr, powerArr1, powerArr2, powerArr3, powerArr4, powerArr5, powerArr6, powerArr7, powerArr8)
        self.checkError(res)
        return wavelengthArr, np.stack((powerArr1, powerArr2, powerArr3, powerArr4, powerArr5, powerArr6, powerArr7, powerArr8))

    def getLambdaScanParameters(self, scan='singleFrame'):
        """ Returns all parameters that the Prepare Lambda Scan function adjusts or automatically calculates. """
        paramStartWavelength, paramStopWavelength, paramAveragingTime, paramSweepSpeed = c_double(), c_double(), c_double(), c_double()
        if scan == 'singleFrame':
            res = self.hp816x_getLambdaScanParameters_Q(self.hDriver, byref(paramStartWavelength), byref(paramStopWavelength), byref(paramAveragingTime), byref(paramSweepSpeed))
            print('\nParameter verification (single frame)')
        elif scan == 'multiFrame':
            res = self.hp816x_getMFLambdaScanParameters_Q(self.hDriver, byref(paramStartWavelength), byref(paramStopWavelength), byref(paramAveragingTime), byref(paramSweepSpeed))
            print('\nParameter verification (multi frame)')
        else:
            print('Warning: scan type %s is not valid.'% scan)
        self.checkError(res)
        print('Sweeping from {} nm to {} nm'.format(paramStartWavelength.value*1e9, paramStopWavelength.value*1e9))
        print('Averaging time is {} s'.format(paramAveragingTime.value))
        print('Sweep speed is {} nm/s'.format(paramSweepSpeed.value*1e9))
        print('Sweep time is {} s'.format(self.sweepNumScans*(paramStopWavelength.value-paramStartWavelength.value)/paramSweepSpeed.value))
    
    def getLambdaScanResult(self, chan, useClipping, clipLimit, numPts):
        """ Gets the optical power results from a sweep. """
        wavelengthArr, powerArr = np.zeros(int(numPts)), np.zeros(int(numPts))
        res = self.hp816x_getLambdaScanResult(self.hDriver, chan, useClipping, clipLimit, powerArr, wavelengthArr)
        self.checkError(res)
        return wavelengthArr, powerArr

    def disconnect(self):
        self.setTLSState('off')
        self.unregisterMainframe(self.hDriver)
        res = self.hp816x_close(self.hDriver)
        self.checkError(res)
        self.connected = False
        print('Disconnected from the laser')
           
    def getNumPWMChannels(self):
        """ Returns the number of registered PWM channels """
        
        # The driver function to do this doesn't seem to work... It always returns zero
        #numChan = c_uint32();
        #res = self.hp816x_getNoOfRegPWMChannels_Q(self.hDriver, byref(numChan));
        numPWMChan = 0
        for slot in self.slotInfo:
            if slot == self.hp816x_SINGLE_SENSOR:
                numPWMChan += 1
            elif slot == self.hp816x_DUAL_SENSOR:
                numPWMChan += 2
        
        return numPWMChan
        
    def getNumSweepChannels(self):
        return len(self.pwmSlotIndex)
        
    def setRangeParams(self, chan, initialRange, rangeDecrement, reset=0):
        res = self.hp816x_setInitialRangeParams(self.hDriver, chan, reset, initialRange, rangeDecrement)
        self.checkError(res)
        return
        
    def setAutorangeAll(self):
        """ Turns on autorange for all detectors and sets units to dBm """
        for slotinfo in self.pwmSlotMap:
            detslot = slotinfo[0]
            detchan = slotinfo[1]
            
            self.setPWMPowerUnit(detslot, detchan, 'dBm')
            self.setPWMPowerRange(detslot, detchan, rangeMode='auto')
        
    def checkError(self, errStatus):
        ERROR_MSG_BUFFER_SIZE = 256
        if errStatus < self.hp816x_SUCCESS:
            if errStatus == self.hp816x_INSTR_ERROR_DETECTED:
                instErr,instErrMsg = self.checkInstrumentError()
                raise InstrumentError('Error '+str(instErr)+': '+instErrMsg)
            else:
                c_errMsg = (c_char*ERROR_MSG_BUFFER_SIZE)()
                c_errMsgPtr = cast(c_errMsg, c_char_p)

                self.hp816x_error_message(self.hDriver, errStatus, c_errMsgPtr)
                raise InstrumentError(c_errMsg.value.decode('utf-8'))
        return 0
        
    def checkInstrumentError(self):
        """ Reads error messages from the instrument"""
        ERROR_MSG_BUFFER_SIZE = 256
        instErr = c_int32()
        c_errMsg = (c_char*ERROR_MSG_BUFFER_SIZE)()
        c_errMsgPtr = cast(c_errMsg, c_char_p)
        self.hp816x_error_query(self.hDriver, byref(instErr), c_errMsgPtr)
        return instErr.value,c_errMsg.value.decode('utf-8')
        
    def setSweepSpeed(self, speed):
        speedNum = self.sweepSpeedDict[speed]
        res = self.hp816x_setSweepSpeed(self.hDriver, speedNum)
        self.checkError(res)
        return
        
    def readPWM(self, slot, chan):
        """ read a single wavelength """
        powerVal = c_double()
        res = self.hp816x_PWM_readValue(self.hDriver, slot, chan, byref(powerVal))
        # Check for out of range error
        if res == self.hp816x_INSTR_ERROR_DETECTED:
            instErr,instErrMsg = self.checkInstrumentError()
            if instErr == -231 or instErr == -261:
                return self.sweepClipLimit # Assumes unit is in dB
            else:
                raise InstrumentError('Error '+str(instErr)+': '+instErrMsg)
        self.checkError(res)
        return float(powerVal.value)
        
    def setPWMAveragingTime(self, slot, channel, avgTime):
        """ Set the averaging time for the power meter. 
        Longer averaging times increase the accuracy and improve the noise rejection of the measurement. 
        Longer averaging times also decrease sensitivity."""
        res = self.hp816x_set_PWM_averagingTime(self.hDriver, slot, channel, avgTime)
        self.checkError(res)

    def getPWMAveragingTime(self, slot, channel):
        """ Get the averaging time for the power meter. """
        avgTime = c_double()
        res = self.hp816x_get_PWM_averagingTime_Q(self.hDriver, slot, channel, byref(avgTime))
        self.checkError(res)
        return avgTime.value

    def getAutoTLSSlot(self):
        """ Returns the slot number of the first found tunable laser source in the mainframe """
        for slot in self.slotInfo:
            if slot == self.hp816x_TUNABLE_SOURCE:
                return self.slotInfo.index(slot)
        raise Exception('Error: No tunable laser source found.')
        
    def findTLSSlots(self):
        """ Returns a list of all tunable lasers in the mainframe """
        tlsSlotList = []
        for ii,slot in enumerate(self.slotInfo):
            if slot == self.hp816x_TUNABLE_SOURCE:
                tlsSlotList.append(ii)
        if tlsSlotList == []:
            raise Exception('Error: No tunable laser source found.')
        return tlsSlotList
        
    def setTLSOutput(self, output, slot='auto'):
        if slot == 'auto':
            slot = self.getAutoTLSSlot()

        res = self.hp816x_set_TLS_opticalOutput(self.hDriver, int(slot), self.laserOutputDict[output])
        self.checkError(res)

    def getTLSOutput(self, slot='auto'):
        """ Get the active output for the TLS. """
        if slot == 'auto':
            slot = self.getAutoTLSSlot()
            
        output = c_int32()
        res = self.hp816x_get_TLS_opticalOutput_Q(self.hDriver, int(slot), byref(output))
        self.checkError(res)
        return self.returnKeyByBValue(self.laserOutputDict, output.value)
        
    def setPWMPowerUnit(self, slot, chan, unit):
        res = self.hp816x_set_PWM_powerUnit(self.hDriver, slot, chan, self.sweepUnitDict[unit])
        self.checkError(res)
          
    def setPWMPowerRange(self, slot, chan, rangeMode = 'auto', range=0):
        res = self.hp816x_set_PWM_powerRange(self.hDriver, slot, chan, self.rangeModeDict[rangeMode], range)
        self.checkError(res)

    def getPWMWavelength(self, slot, chan):
        """ Get the wavelength of the power meter. """
        minimumWavelength, maximumWavelength, currentWavelength = c_double(), c_double(), c_double()
        res = self.hp816x_get_PWM_wavelength_Q(self.hDriver, int(slot), int(chan), byref(minimumWavelength), byref(maximumWavelength), byref(currentWavelength))
        self.checkError(res)
        return minimumWavelength.value, maximumWavelength.value, currentWavelength.value
        
    def setTLSState(self, state, slot='auto'):
        """ turn on or off"""
        if slot == 'auto':
            slot = self.getAutoTLSSlot()
            
        res = self.hp816x_set_TLS_laserState(self.hDriver, int(slot), self.laserStateDict[state])
        self.checkError(res)

    def getTLSState(self, slot='auto'):
        """ check the state of the laser. """
        if slot == 'auto':
            slot = self.getAutoTLSSlot()

        return self.gpibQueryString('sour{:d}:pow:stat?'.format(int(slot)))
        
    def setTLSWavelength(self, wavelength, selMode='manual', slot='auto'):
        """ Set the wavelength of the laser. """
        if slot == 'auto':
            slot = self.getAutoTLSSlot()
        
        res = self.hp816x_set_TLS_wavelength(self.hDriver, int(slot), self.laserSelModeDict[selMode], wavelength);
        self.checkError(res)

    def getTLSWavelength(self, slot='auto'):
        """ Get the wavelength of the laser. """
        if slot == 'auto':
            slot = self.getAutoTLSSlot()
        minimumWavelength, defaultWavelength, maximumWavelength, currentWavelength = c_double(), c_double(), c_double(), c_double()
        res = self.hp816x_get_TLS_wavelength_Q(self.hDriver, int(slot), byref(minimumWavelength), byref(defaultWavelength), byref(maximumWavelength), byref(currentWavelength))
        self.checkError(res)
        return minimumWavelength.value, defaultWavelength.value, maximumWavelength.value, currentWavelength.value
        
    def setTLSPower(self, power, slot='auto', selMode='manual', unit='dBm'):
        if slot == 'auto':
            slot = self.getAutoTLSSlot()
        
        res = self.hp816x_set_TLS_power(self.hDriver, int(slot), self.sweepUnitDict[unit], self.laserSelModeDict[selMode],\
              power)
        self.checkError(res)

    def getTLSMaxPower(self, startofRange=None, endofRange=None, slot='auto'):
        """ This function returns the maximum permitted power for a given wavelength interval. It is used to 
            calculate the maximum permitted power for a wavelength sweep."""
        if slot == 'auto':
            slot = self.getAutoTLSSlot()
        if startofRange == None:
            startofRange = self.sweepStartWvl
        if endofRange == None:
            endofRange = self.sweepStopWvl
        maxPower = c_double()
        res = self.hp816x_get_TLS_powerMaxInRange_Q(self.hDriver, slot, startofRange, endofRange, byref(maxPower))
        self.checkError(res)
        return maxPower.value

    def sendGpibCmd(self, cmd):
        """ Sends a GPIB command to the mainframe
            cmd -- Command to send to the device """
        self.hp816x_cmd(self.hDriver, cmd.encode('utf-8'))
        
    def gpibQueryString(self, cmd):
        """ Sends a GPIB command to the mainframe and reads a string result"""
        MSG_BUFFER_SIZE = 256;
        c_Msg = (c_char*MSG_BUFFER_SIZE)()
        c_MsgPtr = cast(c_Msg, c_char_p)
        res = self.hp816x_cmdString_Q(self.hDriver, cmd.encode('utf-8'), MSG_BUFFER_SIZE, c_MsgPtr)
        self.checkError(res)
        return c_MsgPtr.value.decode("utf-8")
        
    def getSlotInstruments(self):
        """ Gets the name of each instrument in the slots """
        instStr = self.gpibQueryString('*OPT?')
        return map(string.strip,instStr[:-1].split(','))
        
    def findClosestValIdx(self, array, value):
        idx = (abs(array-value)).argmin()
        return idx 
        
    def sweepReturnEquidistantData(self, value):
        """ Specifies whether or not a laser sweep returns equidistant wavelength values
            Default is on. This may need to be disbled on some lasers when the step size is
            very small"""
        res = self.hp816x_returnEquidistantData(self.hDriver, value)  
        return res

    def setTLSlambdaLoggingState(self, lambdaLoggingState):
        """ Get the state of lambda logging condition. """
        res = self.hp816x_set_TLS_lambdaLoggingState(self.hDriver, lambdaLoggingState)
        self.checkError(res)

    def getTLSlambdaLoggingState(self):
        """ Get the state of lambda logging condition. """
        lambdaLoggingState = c_bool()
        res = self.hp816x_get_TLS_lambdaLoggingState_Q(self.hDriver, byref(lambdaLoggingState))
        self.checkError(res)
        return lambdaLoggingState.value

    # Misc functions
    @staticmethod
    def listStartAndStopWavelength(startWavelength, stepWavelength, numPointsLst):
        """ Create a list of the start and stop wavelengths per stitch. """
        startWvlLst, stopWvlLst = [], []
        pointsAccum = 0
        for points in numPointsLst:
            startWvlLst.append(startWavelength+pointsAccum*stepWavelength)
            stopWvlLst.append(startWavelength+(pointsAccum+points-1)*stepWavelength)
            pointsAccum += points
        return startWvlLst, stopWvlLst

    @staticmethod
    def listPointsPerStitch(ptsPerFullScan, numFullScans, numRemainingPts):
        """ Create a list of the number of points per stitch. """
        numPointsLst = []
        for x in repeat(ptsPerFullScan, numFullScans):
            numPointsLst.append(int(x))    
        numPointsLst.append(int(round(numRemainingPts)))
        return numPointsLst

    @staticmethod
    def divideIntoStitches(totalPoints, maxPoints):
        """ Divide the total number of points into stitches with a max number of points. """
        numScans = int(totalPoints//maxPoints)
        stitchNumber = numScans+1 
        numRemainingPts = totalPoints % maxPoints
        return numScans, stitchNumber, numRemainingPts

    @staticmethod
    def formatWavelengthForSweep(wavelength, option):
        """ Round the wavelength to the nearest multiple of 1 pm above or below. Format the start and 
            stop wvl to 13 digits of accuracy (otherwise the driver will sweep the wrong range)."""
        wavelengthAdjusted = wavelength
        if (wavelength*1e12-int(wavelength*1e12) > 0) and (option=='below'):
            wavelengthAdjusted = math.floor(wavelength*1e12)/1e12
        elif (wavelength*1e12-int(wavelength*1e12) > 0) and (option=='above'):
            wavelengthAdjusted = math.ceil(wavelength*1e12)/1e12
        wavelengthAdjusted = float('%.13f'%(wavelengthAdjusted))
        return wavelengthAdjusted

    @staticmethod
    def returnKeyByBValue(myDict, value): 
        for key, val in myDict.items(): 
            if value == val: 
                return key 

    def createPrototypes(self):
        """ Creates function prototypes for the C function calls to the driver library. """

        array_1d_double = npct.ndpointer(dtype=np.double, ndim=1, flags='CONTIGUOUS')

        # Function prototype definitions

        # ViStatus _VI_FUNC hp816x_init(ViRsrc resourceName, ViBoolean IDQuery, ViBoolean reset, ViPSession ihandle);
        self.hp816x_init = self.hLib.hp816x_init
        self.hp816x_init.argtypes = [c_char_p, c_uint16, c_uint16, POINTER(c_int32)];
        self.hp816x_init.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_close(ViSession ihandle);
        self.hp816x_close = self.hLib.hp816x_close
        self.hp816x_close.argtypes = [c_int32]
        self.hp816x_close.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_set_TLS_parameters(ViSession ihandle, ViInt32 TLSSlot, ViInt32 powerUnit, ViInt32 opticalOutput, ViBoolean turnLaser, ViReal64 power, ViReal64 attenuation, ViReal64 wavelength);
        self.hp816x_set_TLS_parameters = self.hLib.hp816x_set_TLS_parameters
        self.hp816x_set_TLS_parameters.argtypes = [c_int32, c_int32, c_int32, c_int32, c_uint16, c_double, c_double, c_double]
        self.hp816x_set_TLS_parameters.restype = c_int32

        # ViStatus _VI_FUNC hp816x_get_TLS_wavelength_Q(ViSession ihandle, ViInt32 TLSSlot, ViPReal64 minimumWavelength, ViPReal64 defaultWavelength, ViPReal64 maximumWavelength, ViPReal64 currentWavelength);
        self.hp816x_get_TLS_wavelength_Q = self.hLib.hp816x_get_TLS_wavelength_Q
        self.hp816x_get_TLS_wavelength_Q.argtypes = [c_int32, c_int32, POINTER(c_double), POINTER(c_double), POINTER(c_double), POINTER(c_double)]
        self.hp816x_get_TLS_wavelength_Q.restype = c_int32

        # ViStatus _VI_FUNC hp816x_registerMainframe(ViSession ihandle);
        self.hp816x_registerMainframe = self.hLib.hp816x_registerMainframe
        self.hp816x_registerMainframe.argtypes = [c_int32]
        self.hp816x_registerMainframe.restype = c_int32

        # ViStatus _VI_FUNC hp816x_prepareLambdaScan(ViSession ihandle, ViInt32 powerUnit, ViReal64 power, ViInt32 opticalOutput, ViInt32 numberofScans, ViInt32 PWMChannels, ViReal64 startWavelength, ViReal64 stopWavelength, ViReal64 stepSize, ViUInt32 numberofDatapoints, ViUInt32 numberofChannels);
        self.hp816x_prepareLambdaScan = self.hLib.hp816x_prepareLambdaScan
        self.hp816x_prepareLambdaScan.argtypes = [c_int32, c_int32, c_double, c_int32, c_int32, c_int32, c_double, c_double, c_double, POINTER(c_int32), POINTER(c_int32)]
        self.hp816x_prepareLambdaScan.restype = c_int32

        # ViStatus _VI_FUNC hp816x_getLambdaScanParameters_Q(ViSession ihandle, ViPReal64 startWavelength, ViPReal64 stopWavelength, ViPReal64 averagingTime, ViPReal64 sweepSpeed);
        self.hp816x_getLambdaScanParameters_Q = self.hLib.hp816x_getLambdaScanParameters_Q;
        self.hp816x_getLambdaScanParameters_Q.argtypes = [c_int32, POINTER(c_double), POINTER(c_double), POINTER(c_double), POINTER(c_double)]
        self.hp816x_getLambdaScanParameters_Q.restype = c_int32

        # ViStatus _VI_FUNC hp816x_executeLambdaScan(ViSession ihandle, ViReal64wavelengthArray[ ], ViReal64powerArray1[ ], ViReal64powerArray2[ ], ViReal64powerArray3[ ], ViReal64powerArray4[ ], ViReal64powerArray5[ ], ViReal64powerArray6[ ], ViReal64powerArray7[ ], ViReal64powerArray8[ ]);
        self.hp816x_executeLambdaScan = self.hLib.hp816x_executeLambdaScan
        self.hp816x_executeLambdaScan.argtypes = [c_int32, array_1d_double, array_1d_double, array_1d_double, array_1d_double, array_1d_double, array_1d_double, array_1d_double, array_1d_double, array_1d_double]
        self.hp816x_executeLambdaScan.restype = c_int32

        # ViStatus _VI_FUNC hp816x_prepareMfLambdaScan(ViSession ihandle, ViInt32 powerUnit, ViReal64 power, ViInt32 opticalOutput, ViInt32 numberofScans, ViInt32 PWMChannels, ViReal64 startWavelength, ViReal64 stopWavelength, ViReal64 stepSize, ViUInt32 numberofDatapoints, ViUInt32 numberofChannels);
        self.hp816x_prepareMfLambdaScan = self.hLib.hp816x_prepareMfLambdaScan;
        self.hp816x_prepareMfLambdaScan.argtypes = [c_int32, c_int32, c_double, c_int32, c_int32, c_int32, c_double, c_double, c_double, POINTER(c_uint32), POINTER(c_uint32)]
        self.hp816x_prepareMfLambdaScan.restype = c_int32

        # ViStatus _VI_FUNC hp816x_getMFLambdaScanParameters_Q(ViSession ihandle, ViPReal64 startWavelength, ViPReal64 stopWavelength, ViPReal64 averagingTime, ViPReal64 sweepSpeed);
        self.hp816x_getMFLambdaScanParameters_Q = self.hLib.hp816x_getMFLambdaScanParameters_Q
        self.hp816x_getMFLambdaScanParameters_Q.argtypes = [c_int32, POINTER(c_double), POINTER(c_double), POINTER(c_double), POINTER(c_double)]
        self.hp816x_getMFLambdaScanParameters_Q.restype = c_int32

        # ViStatus _VI_FUNC hp816x_executeMfLambdaScan(ViSession ihandle, ViReal64wavelengthArray[]);
        self.hp816x_executeMfLambdaScan = self.hLib.hp816x_executeMfLambdaScan
        self.hp816x_executeMfLambdaScan.argtypes = [c_int32, array_1d_double]
        self.hp816x_executeMfLambdaScan.restype = c_int32

        # ViStatus _VI_FUNC hp816x_setSweepSpeed(ViSession ihandle, ViInt32 Sweep_Speed);
        self.hp816x_setSweepSpeed = self.hLib.hp816x_setSweepSpeed
        self.hp816x_setSweepSpeed.argtypes = [c_int32, c_int32]
        self.hp816x_setSweepSpeed.restype = c_int32

        # ViStatus _VI_FUNC hp816x_getLambdaScanResult(ViSession ihandle, ViInt32 PWMChannel, ViBoolean cliptoLimit, ViReal64 clippingLimit, ViReal64powerArray[], ViReal64lambdaArray[]);
        self.hp816x_getLambdaScanResult = self.hLib.hp816x_getLambdaScanResult
        self.hp816x_getLambdaScanResult.argtypes = [c_int32, c_int32, c_uint16, c_double, array_1d_double, array_1d_double]
        self.hp816x_getLambdaScanResult.restype = c_int32

        # ViStatus _VI_FUNC hp816x_forceTransaction(ViSession ihandle, ViBoolean forceTransaction);
        self.hp816x_forceTransaction = self.hLib.hp816x_forceTransaction
        self.hp816x_forceTransaction.argtypes = [c_int32, c_uint16]
        self.hp816x_forceTransaction.restype = c_int32

        # ViStatus _VI_FUNC hp816x_errorQueryDetect(ViSession ihandle, ViBoolean automaticErrorDetection);
        self.hp816x_errorQueryDetect = self.hLib.hp816x_errorQueryDetect
        self.hp816x_errorQueryDetect.argtypes = [c_int32, c_uint16]
        self.hp816x_errorQueryDetect.restype = c_int32

        # ViStatus _VI_FUNC hp816x_error_query(ViSession ihandle, ViPInt32 instrumentErrorCode, ViChar errorMessage[]);
        self.hp816x_error_query = self.hLib.hp816x_error_query
        self.hp816x_error_query.argtypes = [c_int32, POINTER(c_int32), c_char_p]
        self.hp816x_error_query.restype = c_int32

        # ViStatus _VI_FUNC hp816x_error_message(ViSession ihandle, ViStatus errorCode, ViString errorMessage);
        self.hp816x_error_message = self.hLib.hp816x_error_message
        self.hp816x_error_message.argtypes = [c_int32, c_int32, c_char_p]
        self.hp816x_error_message.restype = c_int32

        # ViStatus _VI_FUNC hp816x_set_PWM_parameters(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViBoolean rangeMode, ViBoolean powerUnit, ViBoolean internalTrigger, ViReal64 wavelength, ViReal64 averagingTime, ViReal64 powerRange);
        self.hp816x_set_PWM_parameters = self.hLib.hp816x_set_PWM_parameters
        self.hp816x_set_PWM_parameters.argtypes = [c_int32, c_int32, c_int32, c_uint16, c_uint16, c_uint16, c_double, c_double, c_double]
        self.hp816x_set_PWM_parameters.restype = c_int32

        # ViStatus _VI_FUNC hp816x_set_PWM_averagingTime(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViReal64 averagingTime);
        self.hp816x_set_PWM_averagingTime = self.hLib.hp816x_set_PWM_averagingTime
        self.hp816x_set_PWM_averagingTime.argtypes = [c_int32, c_int32, c_int32, c_double]
        self.hp816x_set_PWM_averagingTime.restype = c_int32

        # ViStatus _VI_FUNC hp816x_get_PWM_averagingTime_Q(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViPReal64 averagingTime);
        self.hp816x_get_PWM_averagingTime_Q = self.hLib.hp816x_get_PWM_averagingTime_Q
        self.hp816x_get_PWM_averagingTime_Q.argtypes = [c_int32, c_int32, c_int32, POINTER(c_double)]
        self.hp816x_get_PWM_averagingTime_Q.restype = c_int32        

        # ViStatus _VI_FUNC hp816x_set_PWM_wavelength(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViReal64 wavelength);
        self.hp816x_set_PWM_wavelength = self.hLib.hp816x_set_PWM_wavelength
        self.hp816x_set_PWM_wavelength.argtypes = [c_int32, c_int32, c_int32, c_double]
        self.hp816x_set_PWM_wavelength.restype = c_int32

        # ViStatus _VI_FUNC hp816x_get_PWM_wavelength_Q(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViPReal64 minWavelength, ViPReal64 maxWavelength, ViPReal64 currentWavelength);
        self.hp816x_get_PWM_wavelength_Q = self.hLib.hp816x_get_PWM_wavelength_Q
        self.hp816x_get_PWM_wavelength_Q.argtypes = [c_int32, c_int32, c_int32, POINTER(c_double), POINTER(c_double), POINTER(c_double)]
        self.hp816x_get_PWM_wavelength_Q.restype = c_int32

        # ViStatus _VI_FUNC hp816x_set_PWM_powerRange(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViBoolean rangeMode, ViReal64 powerRange);
        self.hp816x_set_PWM_powerRange = self.hLib.hp816x_set_PWM_powerRange
        self.hp816x_set_PWM_powerRange.argtypes = [c_int32, c_int32, c_int32, c_uint16, c_double]
        self.hp816x_set_PWM_powerRange.restype = c_int32

        # ViStatus _VI_FUNC hp816x_set_PWM_powerUnit(ViSession ihandle, ViInt32 PWMSlot, ViInt32 channelNumber, ViInt32 powerUnit);
        self.hp816x_set_PWM_powerUnit = self.hLib.hp816x_set_PWM_powerUnit
        self.hp816x_set_PWM_powerUnit.argtypes = [c_int32, c_int32, c_int32, c_int32]
        self.hp816x_set_PWM_powerUnit.restype = c_int32

        # ViStatus _VI_FUNC hp816x_PWM_readValue(ViSession ihandle, ViInt32 PWMSlot, ViUInt32 channelNumber, ViPReal64 measuredValue);
        self.hp816x_PWM_readValue = self.hLib.hp816x_PWM_readValue
        self.hp816x_PWM_readValue.argtypes = [c_int32, c_int32, c_uint32, POINTER(c_double)]
        self.hp816x_PWM_readValue.restype = c_int32

        # ViStatus _VI_FUNC hp816x_set_TLS_opticalOutput(ViSession ihandle, ViInt32 TLSSlot, ViInt32 setOpticalOutput);
        self.hp816x_set_TLS_opticalOutput = self.hLib.hp816x_set_TLS_opticalOutput
        self.hp816x_set_TLS_opticalOutput.argtypes = [c_int32, c_int32, c_int32]
        self.hp816x_set_TLS_opticalOutput.restype = c_int32

        # ViStatus _VI_FUNC hp816x_get_TLS_opticalOutput_Q(ViSession ihandle, ViInt32 TLSSlot, ViPInt32 opticalOutput);
        self.hp816x_get_TLS_opticalOutput_Q = self.hLib.hp816x_get_TLS_opticalOutput_Q
        self.hp816x_get_TLS_opticalOutput_Q.argtypes = [c_int32, c_int32, POINTER(c_int32)]
        self.hp816x_get_TLS_opticalOutput_Q.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_getSlotInformation_Q(ViSession ihandle, ViInt32 arraySize, ViInt32 slotInformation[]);
        self.hp816x_getSlotInformation_Q = self.hLib.hp816x_getSlotInformation_Q
        self.hp816x_getSlotInformation_Q.argtypes = [c_int32, c_int32, POINTER(c_int32)]
        self.hp816x_getSlotInformation_Q.restype = c_int32

        # ViStatus _VI_FUNC hp816x_getNoOfRegPWMChannels_Q(ViSession ihandle, ViUInt32 numberofPWMChannels);
        self.hp816x_getNoOfRegPWMChannels_Q = self.hLib.hp816x_getNoOfRegPWMChannels_Q
        self.hp816x_getNoOfRegPWMChannels_Q.argtypes = [c_int32, POINTER(c_uint32)]
        self.hp816x_getNoOfRegPWMChannels_Q.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_setInitialRangeParams(ViSession ihandle, ViInt32 PWMChannel, ViBoolean resettoDefault, ViReal64 initialRange, ViReal64 rangeDecrement);
        self.hp816x_setInitialRangeParams = self.hLib.hp816x_setInitialRangeParams
        self.hp816x_setInitialRangeParams.argtypes = [c_int32, c_int32, c_uint16, c_double, c_double]
        self.hp816x_setInitialRangeParams.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_unregisterMainframe(ViSession ihandle);
        self.hp816x_unregisterMainframe = self.hLib.hp816x_unregisterMainframe
        self.hp816x_unregisterMainframe.argtypes = [c_int32]
        self.hp816x_unregisterMainframe.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_set_TLS_laserState(ViSession ihandle, ViInt32 TLSSlot, ViBoolean laserState);
        self.hp816x_set_TLS_laserState = self.hLib.hp816x_set_TLS_laserState
        self.hp816x_set_TLS_laserState.argtypes = [c_int32, c_int32, c_uint16]
        self.hp816x_set_TLS_laserState.restype = c_int32;
        
        # ViStatus _VI_FUNC hp816x_set_TLS_wavelength(ViSession ihandle, ViInt32 TLSSlot, ViInt32 wavelengthSelection, ViReal64 wavelength);
        self.hp816x_set_TLS_wavelength = self.hLib.hp816x_set_TLS_wavelength
        self.hp816x_set_TLS_wavelength.argtypes = [c_int32, c_int32, c_int32, c_double]
        self.hp816x_set_TLS_wavelength.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_set_TLS_power(ViSession ihandle, ViInt32 TLSSlot, ViInt32 unit, ViInt32 powerSelection, ViReal64 manualPower);
        self.hp816x_set_TLS_power = self.hLib.hp816x_set_TLS_power
        self.hp816x_set_TLS_power.argtypes = [c_int32, c_int32, c_int32, c_int32, c_double]
        self.hp816x_set_TLS_power.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_cmd(ViSession ihandle, ViCharcommandString[]);
        self.hp816x_cmd = self.hLib.hp816x_cmd
        self.hp816x_cmd.argtypes = [c_int32, c_char_p]
        self.hp816x_cmd.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_cmdString_Q(ViSession ihandle, ViCharinputQuery[ ], Integer stringSize, ViCharresult[ ]);
        self.hp816x_cmdString_Q = self.hLib.hp816x_cmdString_Q
        self.hp816x_cmdString_Q.argtypes = [c_int32, c_char_p, c_int32, c_char_p]
        self.hp816x_cmdString_Q.restype = c_int32
        
        # ViStatus _VI_FUNC hp816x_returnEquidistantData(ViSession ihandle, ViBoolean equallySpacedDatapoints);
        self.hp816x_returnEquidistantData = self.hLib.hp816x_returnEquidistantData
        self.hp816x_returnEquidistantData.argtypes = [c_int32, c_uint16]
        self.hp816x_returnEquidistantData.restype = c_int32

        # ViStatus _VI_FUNC hp816x_set_TLS_lambdaLoggingState(ViSession ihandle, ViBoolean lambdaLoggingState);
        self.hp816x_set_TLS_lambdaLoggingState = self.hLib.hp816x_set_TLS_lambdaLoggingState
        self.hp816x_set_TLS_lambdaLoggingState.argtypes = [c_int32, c_bool]
        self.hp816x_set_TLS_lambdaLoggingState.restype = c_int32

        # ViStatus _VI_FUNC hp816x_get_TLS_lambdaLoggingState_Q(ViSession ihandle, ViPBoolean lambdaLoggingState);
        self.hp816x_get_TLS_lambdaLoggingState_Q = self.hLib.hp816x_get_TLS_lambdaLoggingState_Q
        self.hp816x_get_TLS_lambdaLoggingState_Q.argtypes = [c_int32, POINTER(c_bool)]
        self.hp816x_get_TLS_lambdaLoggingState_Q.restype = c_int32

        # ViStatus _VI_FUNC hp816x_get_TLS_powerMaxInRange_Q(ViSession ihandle, ViInt32 TLSSlot, ViReal64 startofRange, ViReal64 endofRange, ViPReal64 maximumPower);
        self.hp816x_get_TLS_powerMaxInRange_Q = self.hLib.hp816x_get_TLS_powerMaxInRange_Q
        self.hp816x_get_TLS_powerMaxInRange_Q.argtypes = [c_int32, c_int32, c_double, c_double, POINTER(c_double)]
        self.hp816x_get_TLS_powerMaxInRange_Q.restype = c_int32

class InstrumentError(Exception):
    pass;
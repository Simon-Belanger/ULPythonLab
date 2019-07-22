# Configuration commands

measurementTypeDict = dict('reflection': 0 ,'transmission': 1)
operationTypeDict   = dict('measurement': 0, 'fullCalibration': 1, 'internalCalibration': 2)

def setCentralWavelength(self, wavelength, operationType):
    """
    Description:    Sets the Center Wavelength (nm) and for the specified operationType. 
                    The wavelength parameter must be within the operating range of the 
                    instrument. For the OVA only, the operationType is 0 for measurement, 
                    1 for full calibration, or 2 for internal calibration. If no operationType is 
                    specified,the Center Wavelength will be set for measurement (0).

    Response:       None.

    Notes:          Every time the center wavelength is changed for full calibration or 
                    internal calibration, the system will go out of calibration, so the user must 
                    then recalibrate the system (using SYST:FCAL or SYST:ICAL, respectively). 
                    Failure to do so can result in system malfunction. If the center wavelength 
                    and wavelength range settings for an internal calibration fall outside the most 
                    recent full calibration, the internal calibration wavelength settings will be 
                    coerced to fit within the most recent full calibration. Likewise, if the range of 
                    wavelengths chosen for a measurement fall outside of the internal calibration range, 
                    they will be coerced to fit within the internal calibration range.

    Examples:       “CONF:CWL 1550.0” or “CONF:CWL 1550.0,0”
                    Either command sets the Center Wavelength to 1550.0nm for the next measurement.
                    “CONF:CWL 1550.0,2” sets the Center Wavelength for internal calibration to 1550.0 nm.
    """
    self.inst.write("CONF:CWL " + string(wavelength) + "," + string(operationTypeDict[operationType]))

def getCentralWavelength(self, operationType):
    """
    Description:    Queries the current Center Wavelength. In the OVA, operationType must 
                    be specified. The operationType is 0 for measurement, 1 for full calibration, 
                    or 2 for internal calibration. If no operationType is specified, the query will 
                    return the Center Wavelength for measurement (0).

    Response:       Returns the current Center Wavelength in nanometers.

    Examples:       “CONF:CWL?” or “CONF:CWL? 0” returns the Center Wavelength for measurement 
                    in the form “1550.00” nm.
                    “CONF:CWL? 1” returns the Center Wavelength for full calibration in the 
                    form “1550.00” nm.
    """
    self.inst.query("CONF:CWL? " + string(operationTypeDict[operationType]))

def setWavelengthRange(self, scanRange, operationType):
    """
    Description:    Sets the Scan Range in nanometers for the specified operationType. 
                    The OVA only allows scan ranges that have a number of data points equal 
                    to a power of two, so the actual value of the Scan Range will be set to the 
                    valid value closest to x. The operationType is 0 for measurement, 1 for full 
                    calibration, or 2 for internal calibration. If no operationType is specified, 
                    the Scan Range will be set for measurement (0).

    Response:       None.

    Notes:          Every time the wavelength range is changed for full calibration or internal 
                    calibration, the system will go out of calibration, so the user must then recalibrate 
                    the system (using SYST:FCAL or SYST:ICAL, respectively). Failure to do so can result 
                    in system malfunction. If the center wavelength and wavelength range settings for an 
                    internal calibration fall outside the most recent full calibration, the internal 
                    calibration wavelength settings will be coerced to fit within the most recent full 
                    calibration. Likewise, if the range of wavelengths chosen for a measurement fall 
                    outside of the internal calibration range,

    Examples:       CONF:RANG 5.0 or CONF:RANG 5.0,0 sets the Scan Range for the next measurement to 
                    the valid range closest to 5.0 nm.
                    CONF:RANG 5.0,2 sets the Scan Range for internal calibration to the valid range 
                    closest to 5.0 nm.
    """
    self.inst.write("CONF:RANG " + string(scanRange) + "," + string(operationTypeDict[operationType]))

def getRange(self, operationType):
    """
    Description:    Queries the OVA for the current Scan Range for the specified 
                    operationType: 0 for measurement or 1 for internal calibration. If no 
                    operationType is specified, the query will return the Scan Range for measurement (0).

    Response:       Returns the current Scan Range in nanometers.

    Examples:       “CONF:RANG?” or “CONF:RANG? 0” returns the Scan Range for measurement in nanometers.
                    “CONF:RANG? 1” returns the Scan Range for internal calibration in nanometers.
                    Returns a message in the form “20.0” nm.
    """
    self.inst.query("CONF:RANG? " + string(operationTypeDict[operationType]))

def setTest(self, measurementType, operationType):
    """
    Description:    Sets the Type of Measurement to reflection (0) or transmission (1) for the 
                    specified operationType. The operationType is 0 for device measurement, 1 for 
                    full calibration, or 2 for internal calibration. If no operationType is specified, 
                    the instrument will be set for scanning, or measurement (0).

    Response:       None.

    Examples:          “CONF:TEST 0” or “CONF:TEST 0,0” sets the Type of Measurement for device measurement 
                    (scanning) to reflection.
                    “CONF:TEST 1,1” sets the Type of Measurement for full calibration to transmission.
    """
    self.inst.write("CONF:TEST " 
                    + string(measurementTypeDict[measurementType]) 
                    + ','  string(operationTypeDict[operationType]))
    
def getTest(self, operationType):
    """
    Description:    Queries the OVA for the current Type of Measurement for the specified 
                    operationType: 0 for device measurement, 1 for full calibration, or 2 for 
                    internal calibration. If no operationType is specified, the query will return 
                    the Type of Measurement for device measurement.

    Response:       Returns “0” if the Type of Measurement is set for reflection, or “1” for transmission.

    Examples:       “CONF:TEST?” or “CONF:TEST? 0” returns the Type of Measurement for device 
                    measurement in the form “0” for reflection or “1” for transmission.
                    “CONF:TEST? 1” returns the Type of Measurement for full calibration in the 
                    form “0” for reflection or “1” for transmission.
    """
    self.inst.query("CONF:TEST? " + string(operationTypeDict[operationType]))
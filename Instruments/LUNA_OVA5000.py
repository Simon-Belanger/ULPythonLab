"""
Remote control functions for the LUNA OVA5000 Optical Vector Analyzer.

Author      : Simon Bélanger-de Villers
Created     : July 20th 2019
Last Edited : August 1st 2019
"""
from Instrument_pyvisa import Instrument_pyvisa

class LUNA_OVA(Instrument_pyvisa):

    measurementTypeDict     = {'reflection': 0 ,'transmission': 1}
    operationTypeDict       = {'measurement': 0, 'fullCalibration': 1, 'internalCalibration': 2}
    jonesMatrixParamDict    = {'Insertion Loss': 0, 'Group Delay': 1, 'Chromatic Dispersion': 2,
                            'Polarization Dependent Loss': 3, 'Polarization Mode Dispersion': 4,
                            'Linear Phase Deviation': 5, 'Quadratic Phase Deviation': 6,
                            'Jones Matrix Element Amplitudes': 7, 'Jones Matrix Element Phases': 8,
                            'Time Domain (Amplitude)': 9, 'Time Domain (Wavelength)': 10, 'Min/Max Loss': 11,
                            'Second Order PMD': 12, 'Phase Ripple Linear': 13, 'Phase Ripple Quadratic': 14}
    DUTLenthFindMethodDict  = {'Narrowband': 0, 'Broadband': 1}
    resolutionBandwidthUnitsDict = {'picometers': 0, 'gigahertz': 1}
    XDataLabelDict          = {'nm': 0, 'GHz': 1, 'Thz': 2, 'ns': 3, 'm': 4}
    
    def __init__(self):

        self.name           = None
        self.gpib_address   = None

        # connect to the instrument through GPIB or TCP/IP

    # System commands
    def isWarm(self):
        """ 
        Description:    Queries if the laser is at operating temperature.

        Response:       Returns the digit “1” if the laser is at operating temperature, 
                    or “0” if it is not at operating temperature.
        """
        return self.inst.query("SYSTem:WARM?")
    def warmupTimeRemaining(self):
        """
        Description:    Retrieves the time remaining on the system one hour warm- up timer.

        Response:       Returns the current warm-up time left in minutes.
                        If the OVA instrument and PC have warmed-up for the specified hour, 
                        this command will return zero, “0”, meaning no warm-up time is left.

        Note:           It is always recommended to query the warm-up timer
                        before calibrating and taking measurements. The OVA must
                        be at a stable temperature in order to consistently perform
                        accurate measurements according to published
        """
        return self.inst.query("SYST:WTIM?")
    def scan(self):
        """
        Description:    Tells the OVA to execute an optical scan based on the configured system 
                        parameters. Dependin    g on the wavelength range setting and the number of 
                        averages, this command may take up to several minutes to complete.

        Response:       None.

        Note:           It is advisable to use the SYST:ERR? query after each SCAN command and 
                        before attempting to retrieve the data with FETC queries. This will reveal 
                        any errors that occurred during the scan.  
        """
        self.inst.write("SCAN")
    def align(self):
        """
        Description:    Aligns the optics.

        Response:       None.

        Note:           This process may take several minutes. Adjust the time-outs for your application 
                        accordingly. After a successful alignment, the system will automatically perform 
                        an internal calibration. Poll for *OPC? to see whether the operation is completed 
                        or not.
        """
        self.inst.write("SYST:ALIG")
    def isAligned(self):
        """
        Description:    Queries the OVA if the optics are aligned.

        Response:       Returns “1” if the optics are aligned, or “0” if they are not aligned.

        Note:           The validity of alignment is checked with every scan. If it is determined 
                        that the alignment is no longer valid, then this status switches to “0.” 
                        Thus it is prudent to issue this query periodically after intervals of scanning 
                        to verify that the alignment was valid during the last scan.
        """
        return self.inst.query("SYST:ALIG?")
    def isCalibrated(self):
        """
        Description:    Queries the system calibration status.   

        Response:       Returns “1” if the system is in calibration or “0” if it is not.

        Note:           The validity of calibration is checked with every scan. If it is 
                        determined that the calibration is no longer valid, then this status 
                        switches to “0.” In this case, the user may either recalibrate 
                        (by using the SYST:FCAL, SYST:ICAL, or SYST:QCAL commands described above), 
                        or reload a previous calibration file (by using the SYST:RLDC command described below).       
        """
        return self.inst.query("SYST:CAL?")
    def reloadCalibration(self):
        """
        Description:    Reloads a calibration file into memory. The OVA software looks for 
                        an appropriate calibration file based on the Type of Measurement set 
                        using the CONF:TEST command. (See “CONFigure:TEST” on page 149.)  

        Response:       None.  

        Note:           The user may send this command if SYST:CAL? returns a “0,” indicating 
                        that the calibration failed. Alternately, the user may recalibrate using 
                        the SYST:FCAL, SYST:ICAL, or SYST:QCAL commands described above.
        """
        self.inst.write("SYST:RLDC")
    def getError(self):
        """
        Description:    Queries the OVA for the error status of the most recent command or query.

        Response:       Returns an error code followed by a text description of the error. Zero (0) 
                        indicates no error; i.e. the last command or query completed successfully. 
                        Any non-zero number indicates that an error has occurred. A description of the 
                        8 error may be retrieved with the query SYST:ERRD?

                        The numeric field ranges from -32767 to +32767, with “0” indicating that the last 
                        command or query completed successfully. The total length of the error message will 
                        be less than 512 bytes. Two examples of error messages are:
                            10: The optics must first be aligned before a scan can be executed
                            0: No error  

        Response:       Returns a numeric error code. A code of 0 indicates no error; i.e. the last command 
                        or query completed successfully. Any non-zero number indicates that an error has occurred. 
                        A description of the error may be retrieved with the query SYST:ERRD?          
        """
        self.inst.query("SYST:ERR?")
    def getErrorDescription(self):
        """
        Description:    Retrieves the detailed error description for the most recent remote operation. 

        Response:       Retrieves a string explaining the results of the most recent operation. The total 
                        length of the error message will be less than 512 bytes. Two examples of error 
                        messages are:       
                            Not a valid trace: W
                            Missing parameter: <center wavelength>          
        """
        self.inst.query("SYST:ERRD?")
    def setLaserState(self, laserState):
        """
        Description:    Turns on the laser if the parameter is “1”, or turns it off if the parameter is “0”.

        Response:       None.          
        """
        self.inst.write("SYST:LASE " + string(laserState))
    def getLaserState(self):
        """
        Description:    Queries if the laser is on.

        Response:       Returns “1” if the laser is on, or “0” if the laser is not on.        
        """
        self.inst.query("SYST:LASE?")
    def isReadyForScan(self):
        """
        Description:    Queries if the OVA is ready to scan.

        Response:       Returns “1” if the OVA is ready to scan, or “0” if it is not ready to scan.         
        """
        self.inst.query("SYST:RDY?")
    def loadReferenceData(self, filename):
        """
        Description:    Loads the external file specified in quotes as a source of data reference for 
                        the measurement. If the file format is not correct, an error flag will be set. 
                        The cause of the error can be determined by using the SYST:ERR? query.  

        Response:       None.    

        Note:           The entire file path must be in quotes. Only load “.bin” type files. This command 
                        always loads the data into Matrix A.   

        Example:        SYST:LOAD “C:\SavedFiles\test.bin” loads the data contained in the file “test.bin” 
                        into Matrix A.  
        """
        self.inst.write("SYST:LOAD " + string(filename))
    def getLastCommand(self):
        """
        Description:    Queries the last remote command or query processed by the device. This query can 
                        be used to determine whether a command was received and processed. 

        Response:       Returns the name of the last remote command or query processed by the device.

        Example:        CONF:INTW 1.5 SYST:LAST?
                        This query returns “CONF:INTW”. Note that SYST:LAST? only returns the name of 
                        the last command and does not report any parameters included with the command.           
        """
        self.inst.query("SYST:LAST?")
    def get_SystemVersion(self):
        """
        Description:    Queries the software version.

        Response:       Returns a string containing the OVA software version.  

        Example:        3.8.1     
        """
        return self.inst.query("SYST:VER?")

    # Configuration commands
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
    
    # Fetch Commands
    def fetchFrequency(self):
        """
        Description:    Queries the OVA for the starting frequency and the increment size, 
                        both in units of GHz.

        Response:       Returns two numeric values delimited by a comma. The first value is 
                        the starting frequency (GHz), and the second value is the frequency 
                        increment size/sample spacing (GHz). 

                        If a successful scan has not been made before this query, the OVA will 
                        respond with a 0, indicating that there is no data available. The cause 
                        of error can be retrieved by using the SYST:ERR? query.

        Examples:       FETC:FREQ?
                        This query returns a message in the form “195000,0.321073,” meaning the 
                        starting frequency is 195000 GHz and the frequency increment size/Sample 
                        Spacing is 0.321073 GHz.
        """
        fetchedFrequencyData = self.inst.query("FETC:FREQ?")

        return [fetchedFrequencyData.split(',')[0], fetchedFrequencyData.split(',')[1]]
    def fetchTimeDomainIncrement(self):
        """
        Description:    Queries the OVA for the time increment of the Time Domain Window X-axis in 
                        nanoseconds (ns). 

        Response:       Returns the time increment of the Time Domain Window X-axis in nanoseconds (ns).
                        If a successful scan has not been made before this query, the OVA will respond 
                        with a 0, indicating that there is no data available.    

        Examples:       FETC:TINC?
                        This query returns a message in the form “0.000567” ns.
        """
        return self.inst.query("FETC:TINC?")
    def fetchFSize(self):
        """
        Description:    Queries the OVA for the size of the data arrays. This query should be called 
                        before retrieving the X-axis or the optical test results (insertion loss, group 
                        delay, etc.) if the controller program needs to pre-allocate space for the data.  

        Response:       The response is an integer indicating the number of data samples to expect from 
                        the FETC:XAXI? and FETC:MEAS? queries. If a successful scan has not been made 
                        before this query, the OVA responds with 65536, the largest data array size available. 
                        The cause of error can be retrieved by using the SYST:ERR? query.

        Examples:       FETC:FSIZ?
                        This query returns a message in the form “4096” data points.
        """
        return self.inst.query("FETC:FSIZ?")
    def fetchMeasurement(self, jonesMatrixParameter):
        """
        Description:    Queries the OVA for the measured data array for the Jones matrix parameter specified 
                        by x. The parameter x can take values from 0 to 14: (see jonesMatrixParamDict for names).

                        This query is usually preceded by the FETC:FSIZ? query to determine the number of data 
                        points that will be returned.

        Response:       Returns an array with each element in floating point format with ten significant digits 
                        and possible exponent field of the form [?]d.ddddddddd[e[?]ddd].

                        If space needs to be allocated for the receiving buffer, the amount required for each 
                        element is 18, including a carriage return as the delimiter.
                        If a successful scan has not been made before this query, the OVA will respond, 
                        “An attempt was made to retrieve data, when no data was acquired or loaded.” The 
                        cause of error can be retrieved by using the SYST:ERR? query.


        Examples:       
        """
        return self.inst.query("FETC:MEAS? " + string(jonesMatrixParamDict[jonesMatrixParameter]))
    def fetchMeasurementDetails(self):
        """
        Description:    Queries the OVA for current measurement details for Matrix A.

        Response:       Returns a string of information (shown below) about the current Matrix A data.

                        If a successful scan has not been made before this query, the OVA will respond, 
                        “An attempt was made to retrieve data, when no data was acquired or loaded.” 
                        The cause of error can be retrieved by using the SYST:ERR? query.    
        """

        fields = self.inst.query("FETC:MDET?").split('\n') # Split for each newline

        # Split the output string in it's different fields


        return measurementDetailsDict = dict('DUT Length (m)': float(fields[0]),
                                            'End Wavelength (nm)': float(fields[1]),
                                            'Segment Size': float(fields[2]),
                                            'Measurement Type': fields[3],
                                            'Sample Spacing (GHz)': float(fields[4]),
                                            'Start Frequency (ns)': float(fields[5]),
                                            'Time Increment (ns)': float(fields[6]),
                                            'TD Windowed RSBW (GHz)': float(fields[7]),
                                            'Number of Averages': float(fields[8]),
                                            'Measurement Time Stamp': fields[9]) 

    # OVA-only system commands 
    def systemFullCalibration(self):
        """
        Description:    Performs a full calibration of the OVA with the PDL calibration option on.
                        The OVA control software will prompt the user to connect and move the supplied 
                        polarization controller paddles.

        Response:       None.

        Notes:          Do not use this command in automated test scripts because this command requires 
                        user interaction with the OVA software and hardware.
                        This process may take several minutes to complete, so 8 adjust application 
                        time-outs accordingly.
                        A full calibration should be performed every 72 hours.
                        Poll for *OPC? to see whether the operation is completed or not.
        """
        self.inst.write("SYST:FCAL")
    def systemInternalCalibration(self):
        """
        Description:    Performs an internal calibration.

        Response:       None.

        Notes:          This command does not perform a full calibration of the system. A full 
                        calibration should be performed every 72 hours using the SYST:FCAL command, 
                        or as described under “Calibrating the System” on page 34. Internal calibrations 
                        should be performed more frequently, as described under “Conditions that Require 
                        Calibration” on page 35.
                        This process may take several minutes to complete, so adjust application time-outs 
                        accordingly. Poll for *OPC? to see whether the operation is completed or not.
        """
        self.inst.write("SYST:ICAL")
    def systemQCalibration(self):
        """
        Description:    Performs a full calibration of the OVA with the PDL calibration option off.
                        A reference patchcord or gold reflector [depending on the Type of Measurement 
                        set using the CONF:TEST command. (See “CONFigure:TEST” on page 149.)] must be 
                        connected to the OVA before issuing this command.

        Response:       None.

        Notes:          This process may take several minutes to complete, so adjust application 
                        time-outs accordingly. Poll for *OPC? to see whether the operation is completed or not.
        """
        self.inst.write("SYST:QCAL")
    def applySmoothingFilter(self):
        """
        Description:    Applies the smoothing filter to all data currently in the memory of the OVA PC.

        Response:       None.

        Notes:          This command applies the filter to data stored in Matrices A, B, and C, but only 
                        data in Matrix A is available for retrieval through a remote interface.
        """
        self.inst.write("SYST:FILT")
    def sweepWavelength(self):
        """
        Description:    Opens the laser Source switch and sweeps the laser through the user-specified 
                        wavelengths without performing a scan. This command allows the OVA to function 
                        as a tunable light source. Depending on the wavelength range setting, this command 
                        can take up to 15 seconds to complete.


        Response:       None.

        Notes:          Use the CONF:WAVE command (page 172) to set the wavelength for this command.
                        It is necessary to close the Source switch (using the CONF:SOUR 1” command, page 172) 
                        ater a sweep before performing a measurement scan. It is not necessary to open the 
                        Source switch (using “CONF:SOUR 0” command) before performing a sweep, as the 
                        SYST:SWEE command begins by opening the Source switch.
        """
        self.inst.write("SYST:SWEE")
    def saveJonesMatrix(self, filename):
        """
        Description:    Saves the current Jones matrix data in Matrix A as binary data in the filename.bin 
                        specified.
                        An error flag will be set if no data is available to save. The cause of error can 
                        be determined by using the SYST:ERR? query.

        Response:       None.

        Notes:          The entire file path must be in quotes, and the file type “.bin” must be specified. 
                        This command always saves the data from Matrix A.

        Example:        SYST:SAVJ “C:\SavedFiles\JM.bin” saves the data from Matrix A into the file “JM.bin.”
        """
        self.inst.write("SYST:SAVJ \"" +  filename + "\"")
    def saveSelectedCurvesToTextFile(self, filename):
        """
        Description:    Saves the current data in Matrix A as text data in the filename.txt specified. 
                        The spreadsheet will contain all parameters.
                        An error flag will be set if no data is available to save. The cause of error 
                        can be determined by using the SYST:ERR? query.

        Response:       None.

        Notes:          The entire file path must be in quotes, and the file type “.bin” must be specified. 
                        This command always saves the data from Matrix A.

        Example:        SYST:SAVS “C:\SavedFiles\measData.txt” saves the data from Matrix A into the 
                        file “measData.txt.”
        """
        self.inst.write("SYST:SAVS \"" +  filename + "\"")
    def saveAllCurvesToTextFile(self):
        """
        Description:    Writes the OVA spreadsheet file to the given name. The file name must 
                        be in quotes, and the file type “.txt” must be specified.
                        SYST:SAVT writes only the curves selected in the “Select Save Options” 
                        dialog in the OVA software. This command is similar to SYST:SAVS, except 
                        that SYST:SAVS saves all available curve types, not just the selected curves.

        Response:       None.

        Examples:       SYST:SAVT “C:\data.txt”
                        Saves the selected curves to the file “C:\data.txt”
        """
        self.inst.write("SYST:SAVT \"" +  filename + "\"")

    #OVA only config commands
    def AlwaysApplyFilter(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass
    def getAlwaysApplyFilter(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass
    def enableMatrixAveraging(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass
    def disableMatrixAveraging(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass
    def setNumberAverages(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass
    def getNumberAverages(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass   
    def toggleTimeDomainWindow(self, enabled):
        """
        Description:

        Response:

        Notes: 
        """
        pass     
    def isTimeDomainWindowEnabled(self):
        """
        Description:

        Response:

        Notes: 
        """
        pass   
    def findDUTLengthAutomatically(self, enabled):
        """
        Description:

        Response:

        Notes: 
        """
        pass
    def isFindDUTLengthAutomaticallyEnabled(self):
        pass
    def setDUTLength(self, DUTLength):
        pass
    def getDUTLength(self):
        pass
    def setDUTLenthFindMethod(self, DUTLenthFindMethod):
        pass
    def getDUTLenthFindMethod(self, DUTLenthFindMethod):
        pass
    def setDUTName(self, DUTName):
        pass
    def getDUTName(self):
        pass
    def placePhaseDeviationCursors(self, x1, x2):
        pass
    def setupPulseCompression(self, enabled, averageDispersion, referenceWL, dispersionSlope):
        pass
    def getPulseCompressionParameters(self):
        pass
    def setDispersion(self, averageDispersion):
        pass
    def getDispersion(self):
        pass
    def setResolutionBandwidthUnits(self):
        pass
    def getResolutionBandwidthUnits(self):
        pass
    def setFilterResolutionbandwidth(self, resolutionBandwidth):
        pass
    def getFilterResolutionbandwidth(self):
        pass
    def getTimedomainWindowResolutionBandwidth(self):
        pass
    def getConvolvedResolutionBandwidth(self):
        pass
    def getSampleResolution(self):
        pass
    def setTimeDomainSigmaValue(self, sigma);
        pass
    def getTimeDomainSigmaValue(self);
        pass
    def setTimeLimits(self, TimeLimits):
        pass
    def getTImeLimits(self):
        pass
    def enableTimeDomainRetainSettings(self, enabled):
        pass
    def isEnabledTimeDomainRetainSettings(self):
        pass
    def enableTimeDomainHanning(self, enabled):
        pass
    def isEnabledTimeDomainHanning(self):
        pass
    def setSourceSwitchPosition(self, sourceSwitch):
        pass
    def getSourceSwitchPosition(self):
        pass
    def setWavelengthForSweep(self, wavelength):
        pass
    def getWavelengthForSweep(self):

    # OVA only data commands
    def getPolarizationDependantFrequency(self):
	    pass
    def getJonesElements(self):
    	pass
    def getXData(self, XDataLabel):s
    	pass

        """ Format of commands: 
            <category>:<command><operator> <parameter>

            <category>  : either SYST, CONF or FETC 
            <command>   : the command to send, either e.g QCAL, FILT, etc 
            <operator>  : ? or nothing
            <parameter> : for functions that receive a parameter
        """
        if operator is "?":
            self.query(category + ":" + command + operator)
        elif command is None:
            self.write(category + ":" + command + operator + " " + parameter)

# Testing
if __name__ == "__main__":
    
    ins = LUNA_OVA()

    ins.isWarm()



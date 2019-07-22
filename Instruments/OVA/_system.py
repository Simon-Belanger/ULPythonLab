# System Level Commands

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
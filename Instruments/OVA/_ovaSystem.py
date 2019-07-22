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
# Data capture and retrieval commands

jonesMatrixParamDict = dict('Insertion Loss': 0, 'Group Delay': 1, 'Chromatic Dispersion': 2,
                            'Polarization Dependent Loss': 3, 'Polarization Mode Dispersion': 4,
                            'Linear Phase Deviation': 5, 'Quadratic Phase Deviation': 6,
                            'Jones Matrix Element Amplitudes': 7, 'Jones Matrix Element Phases': 8,
                            'Time Domain (Amplitude)': 9, 'Time Domain (Wavelength)': 10, 'Min/Max Loss': 11,
                            'Second Order PMD': 12, 'Phase Ripple Linear': 13, 'Phase Ripple Quadratic': 14)

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
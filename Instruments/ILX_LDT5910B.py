from Instruments.Instrument_pyvisa import Instrument_pyvisa

# DC source class
class ILX_LDT5910B(Instrument_pyvisa):
    """Code to use the ILX-5910B Thermoelectric Temperature Controller remotely via GPIB."""

    def __init__(self, gpib_num, COMPort):
        self.gpib_address = 'GPIB'+str(gpib_num)+'::'+str(COMPort)+'::INSTR'
        
        self.temp_setpoint = 25
        self.auto_on = False
        
    def set_temp(self, temperature):
        """Set the temperature set point for the TEC."""
        self.inst.write("T " + str(temperature))
        self.temp_setpoint = temperature
    
    def get_actual_temp(self):
        """Get the actual temperature measured by the TEC."""
        return self.inst.query_ascii_values("T?")[0]
    
    def output_on(self):
        """Turn the TEC output on."""
        self.inst.write("output 1")
        print("TEC output is on.")
    
    def output_off(self):
        """Turn the TEC output off."""
        self.inst.write("output 0")
        print("TEC output is off.")
        
    def set_tolerance(self):
        pass
    
    def get_tolerance(self):
        tol = self.inst.query_ascii_values("TOL?")
        # temperature tolerance, time window
        return tol[0], tol[1]
    
    def sweep_temp(self):
        pass
    
    def display(self, mode):
        if mode == "actual temp":
            self.inst.write("DISplay:T")
            print("Display mode is now set to ACTUAL TEMP.")
        elif mode == "set temp":
            self.inst.write("DISplay:SET")
            print("Display mode is now set to SET TEMP.")
        else:
            print("Error: Invalid display mode.")
            
    def auto(self):
        """Toggles auto mode on and off."""
        if self.auto_on == True:
            self.auto_on == False
            self.inst.write("DISplay:AUTO 0")
            print("AUTO mode is off.")
        elif self.auto_on == False:
            self.auto_on == True
            self.inst.write("DISplay:AUTO 1")
            print("AUTO mode is on.")
            
            
            
        

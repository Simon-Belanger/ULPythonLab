from Instrument_pyvisa import Instrument_pyvisa

"""
Notes

necessary to do OOP?

non-OOP
DO :    
    function(VISA_RESSOURCE)
WRITE : 
    function(VISA_RESSOURCE, args)
READ : 
    returnValue = function(VISA_RESSOURCE)
QUERY:
    returnValue = function(VISA_RESSOURCE, args)
"""

class LUNA_OVA(Instrument_pyvisa):

    def __init__(self):
        self.name = 'Simon';

    # Import functions from the different submodules
    #from OVA._system    import 
    #from OVA._config    import 
    #from OVA._data      import 
    #from OVA._ovaSystem import 
    #from OVA._ovaConfig import 
    #from OVA._ovaData   import 

    # Put setters and getters or property to access the object properties instead of the instrument properties

if __name__ == "__main__":
    ins = LUNA_OVA()
    print(ins.name)
    ins.test()
    print(ins.name)



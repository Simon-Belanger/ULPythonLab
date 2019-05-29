class Instrument(object):
    """ Instrument Class, all instruments are inherited from this class. Runs standalone as a virtual instrument. """

    def __init__(self):
        self.name = "Virtual Instrument"
        self.group = "Virtual Instrument Group"
        self.model = "Virtual Instrument Model"
        self.caldate = "DD-MM-YYYY"
        self.busy = False
        self.connected = False

    # Methods
    def connect(self):
        if self.isconnected():
            print("Warning : Instrument is already connected!")
        else:
            self.connected = True
            self.inst = "Virtual Instrument Object"
            print(self.name + " is now connected.")

    def disconnect(self):
        if self.isconnected():
            self.connected = False
            print(self.name + " is now disconnected.")
        else:
            print("Warning : Instrument is already disconnected!")

    def isconnected(self):
        return self.connected

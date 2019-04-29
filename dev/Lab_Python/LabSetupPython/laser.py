from Instrument import Instrument

class laser(Instrument):

    def __init__(self):
        super(laser, self).__init__()

        self.lasing = "False"

    def islasing(self):
        return self.las
        ing
import math
import matplotlib.pyplot as plt
import numpy as np

class Microring(object):

    carrier = 1550e-9

    def __init__(self, R, neff, losses, k, gamma):

        self.L 		= 2 * math.pi * R                       # Length [m]
        self.neff   = neff                                  # Effective index []
        self.alpha 	= 23 * losses                           # attenuation constant [1/m]
        self.eps 	= (1 - math.exp(-self.alpha * self.L))  # round-trip loss []
        self.k 		= k                                     # power cross-coupling coefficient []
        self.gamma  = gamma                                 # carrier generation efficiency []


        self.heat_phase = 0

    def get_phase(self, lambda_0):
        return 2 * math.pi * self.neff * self.L / lambda_0 + self.heat_phase

    def apply_power(self, heater_power):
        """
        Apply power to the heater, which will result in a temperature increase
        in the waveguide.

        """
        if heater_power > 0:
            # heaterr can only produce heat, not cold
        return self.wg_temp


    def get_powerin(self, lambda_0):
        x = (1 - self.eps) * (1 - self.k)
        phi = self.get_phase(lambda_0)
        return self.k / (1 + x - 2 * x**0.5 * math.cos(phi)) * 1/ self.max_powerin()

    def max_powerin(self):
        x = (1 - self.eps) * (1 - self.k)
        return self.k / (1 + x - 2 * x**0.5)

    def get_photocurrent(self, lambda_0):
        """ Measure the defect-mediated photocurrent. """
        return self.get_powerin(lambda_0) * self.gamma * self.eps/self.alpha

    def update(self, heater_power):
        """ Apply the heater power and measure the defect-mediated photocurrent. """
        # Apply the heater power
        self.apply_power(heater_power)
        # Return the photocurrent
        return self.get_photocurrent(self.carrier)

    def sweep(self, wvl_vec):
        """ Sweep the input wavelength and return the measured power in the ring. """
        P = []
        for wvl in wvl_vec:
            P.append(self.powerdB(self.get_powerin(wvl)))

        plt.plot(wvl_vec * 1e9,P)
        plt.xlabel("Wavelength, $\lambda$ [nm]")
        plt.ylabel("Power [rel]")
        plt.show()

    def sweep_photocurrent(self, wvl_vec):
        """ Sweep the input wavelength and return the measured defect-mediated
        photocurrent in the ring. """
        P = []
        for wvl in wvl_vec:
            P.append(self.get_photocurrent(wvl))

        plt.plot(wvl_vec * 1e9,P)
        plt.xlabel("Wavelength, $\lambda$ [nm]")
        plt.ylabel("Photocurrent [A]")
        plt.show()

    @staticmethod
    def powerdB(P):
        """ Return the power in dB. """
        return 10 * math.log(P)

if __name__ == "__main__":
    mrr = Microring(10e-6, 2.5, 35, 0.01, 10)
    print(mrr.update(100))
    mrr.sweep(np.linspace(1540e-9,1560e-9,1000))
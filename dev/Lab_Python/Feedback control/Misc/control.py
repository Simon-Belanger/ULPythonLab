import numpy as np
from microring import Microring
import matplotlib.pyplot as plt
from simple_pid import PID

class control_algo(object):
    def __init__(self, Pmin, Pmax):

        self.mrr = Microring(10e-6, 2.5, 35, 0.01, 10)

        # Power ratings
        self.Pmin = Pmin # Pre-defined minimal power rating [W]
        self.Pmax = Pmax # Pre-defined maximal power rating [W]
        self.Ppoints = 100 # Number of points in the power sweeps

        self.lambda_0 = 1550e-9

    def heater_red(self, err_min):
        """Sweep for Isp on the red side."""
        Pvec = np.linspace(self.Pmin, self.Pmax, self.Ppoints)
        for P in Pvec:
            self.mrr.apply_power(P)
            err = abs(self.mrr.get_photocurrent(self.lambda_0) - self.Isp)
            if err <= err_min:
                break
        return P

    def heater_blue(self, err_min):
        """Sweep for Isp on the blue side."""
        Pvec = np.linspace(self.Pmax, self.Pmin, self.Ppoints)
        for P in Pvec:
            self.mrr.apply_power(P)
            err = abs(self.mrr.get_photocurrent(self.lambda_0) - self.Isp)
            if err <= err_min:
                break
        return P

    def heater_power_scan(self):
        """Sweep the heater power from pre-defined Pmin to Pmax."""
        Pvec = np.linspace(self.Pmin, self.Pmax, self.Ppoints)
        iph = []
        for P in Pvec:
            self.mrr.apply_power(P)
            iph.append(self.mrr.get_photocurrent(self.lambda_0))

        plt.plot(Pvec, iph)
        plt.xlabel("Heater Power [mW]")
        plt.ylabel("Photocurrent [nA]")
        plt.show()

    def set_Isp(self, I):
        """Set the Set-Point current."""
        self.Isp = I

    def PID_loop(self):
        """"""
        pass

    def error_current(self):
        """ Compute the error current as Err = I(k∆t) - I_sp """
        pass

    def PID_control(self):
        """Apply the PID on the error"""
        pass

    def slope_check(self):
        """ Increase the power check if photocurrent increases (is_red), if not exception."""
        pass

    def power_check(self):
        pass


if __name__ == "__main__":

    CA = control_algo(1200, 1400)

    # 1) Heater power scan (Calibration)
    CA.heater_power_scan()

    # 2) Choose Isp
    CA.set_Isp(0.0003)

    # 3) Red shift tuning
    print(CA.heater_red(0.00015))

    # 4) Blue shift tuning
    print(CA.heater_blue(0.00015))
import numpy as np
import matplotlib.pyplot as plt
from simple_pid import PID
import time


class WaterBoiler:
    """
    Simple simulation of a water boiler which can heat up water
    and where the heat dissipates slowly over time
    """
    def __init__(self, heating_efficiency, temp_loss ):

        self.heating_efficiency = heating_efficiency        # Thermal efficiency of the heater [J/s]
        self.temp_loss = temp_loss                          # Temperature leak [celsius/s]

        self.water_temp = 20 # Initial water temperature [celsius]

    def update(self, boiler_power, dt):
        """ Apply the heat and return the measured temperature of the water boiler. """
        if boiler_power > 0:
            # boiler can only produce heat, not cold
            self.water_temp += self.heating_efficiency * boiler_power * dt

        # some heat dissipation
        self.water_temp -= self.temp_loss * dt

        return self.water_temp

""" Identify the system via step response"""
identify = True
if identify == True:
    # System under test
    boiler = WaterBoiler(1.0 ,0.2)
    power = 0. # Initial power applied

    # keep track of values for plotting
    x, y, t = [], [], []

    # time step between each iteration
    dt = 0.01  # [s]
    k = 0
    while k*dt <= 10:

        # power (command) for desired water_temp
        water_temp = boiler.update(power, dt)

        # Update values for plotting
        t += [k*dt]
        y += [water_temp]
        x += [power]

        # Step response
        if k*dt > 1:
            power = 1

        k += 1 # Increase k

    #  Plot results
    fig, ax1 = plt.subplots()
    ax1.plot(t, y, 'b-')
    ax1.set_xlabel('time (s)')
    # Make the y-axis label, ticks and tick labels match the line color.
    ax1.set_ylabel('temperature', color='b')
    ax1.tick_params('y', colors='b')

    ax2 = ax1.twinx()
    ax2.plot(t, x, 'r-')
    ax2.set_ylabel('heater power', color='r')
    ax2.tick_params('y', colors='r')

    fig.tight_layout()
    plt.show()

""" Control the system with PID controller. """
control = False
if control == True:
    boiler = WaterBoiler(1, 0.02)
    water_temp=boiler.water_temp


    pid = PID(1., 0.0, 0.0, setpoint=water_temp)
    pid.output_limits = (0, 100)
    #pid.sample_time = 0.1 # Sampling time of the PID in real time.  A new output will only be calculated when sample_time seconds has passed

    # keep track of values for plotting
    setpoint, y, x, t = [], [], [], []

    # time step between each iteration
    dt = 0.1  # [s]
    k = 0
    while k*dt <= 10:

        # power (command) for desired water_temp
        power = pid(water_temp)
        water_temp = boiler.update(power, dt)
        time.sleep(dt)

        # Update values for plotting
        t += [k*dt]
        x += [power]
        y += [water_temp]
        setpoint += [pid.setpoint]

        # Step response
        if k*dt > 1:
            pid.setpoint = 100

        k += 1 # Increase k

    # Plot results
    fig, ax1 = plt.subplots()
    ax1.plot(t, y, 'b-',label="measured")
    ax1.plot(t, setpoint, 'b--', label="target")
    ax1.set_xlabel('time (s)')
    # Make the y-axis label, ticks and tick labels match the line color.
    ax1.set_ylabel('temperature', color='b')
    ax1.tick_params('y', colors='b')

    ax2 = ax1.twinx()
    ax2.plot(t, x, 'r-')
    ax2.set_ylabel('heater power', color='r')
    ax2.tick_params('y', colors='r')

    fig.tight_layout()
    fig.legend()
    plt.show()
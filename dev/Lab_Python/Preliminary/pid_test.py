import time
import matplotlib.pyplot as plt
from simple_pid import PID


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


boiler = WaterBoiler(1, 0.0)

power = 0.

start_time = time.time()
last_time = start_time

# keep track of values for plotting
input, y, x = [], [], []

while time.time() - start_time < 10:
    current_time = time.time()
    dt = current_time - last_time

    # power (command) for desired water_temp
    water_temp = boiler.update(power, dt)

    # Update values for plotting
    x += [current_time-start_time]
    y += [water_temp]
    input += [power]

    if current_time - start_time > 1:
        power = 10

    last_time = current_time

plt.plot(x, y, label='temperature')
plt.plot(x, input, label='input')
plt.xlabel('time')
plt.legend()
plt.show()

"""
if __name__ == '__main__':
    boiler = WaterBoiler(1, 0.02)
    water_temp=boiler.water_temp


    pid = PID(5, 0.01  , 0.1, setpoint=water_temp)
    pid.output_limits = (0, 100)

    start_time = time.time()
    last_time = start_time

    # keep track of values for plotting
    setpoint, y, x = [], [], []

    while time.time() - start_time < 10:
        current_time = time.time()
        dt = current_time - last_time

        # power (command) for desired water_temp
        power = pid(water_temp)
        water_temp = boiler.update(power, dt)

        # Update values for plotting
        x += [current_time-start_time]
        y += [water_temp]
        setpoint += [pid.setpoint]

        if current_time - start_time > 1:
            pid.setpoint = 100

        last_time = current_time

    plt.plot(x, y, label='measured')
    plt.plot(x, setpoint, label='target')
    plt.xlabel('time')
    plt.ylabel('temperature')
    plt.legend()
    plt.show()
"""
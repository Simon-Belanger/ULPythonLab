import time
import matplotlib.pyplot as plt
from simple_pid import PID


class WaterBoiler:
    """
    Simple simulation of a water boiler which can heat up water
    and where the heat dissipates slowly over time
    """
    def __init__(self):
        self.water_temp = 20

    def update(self, boiler_power, dt):
        if boiler_power > 0:
            # boiler can only produce heat, not cold
            self.water_temp += 1*boiler_power*dt

        # some heat dissipation
        self.water_temp -= 0.02*dt
        return self.water_temp


if __name__ == '__main__':
    boiler = WaterBoiler()
    water_temp=boiler.water_temp


    pid = PID(5, 0.01, 0.1, setpoint=water_temp)
    pid.output_limits = (0, 100)

    start_time = time.time()
    last_time = start_time

    # keep track of values for plotting
    setpoint, y, x, t = [], [], [], []

    while time.time() - start_time < 10:
        current_time = time.time()
        dt = current_time - last_time

        # power (command) for desired water_temp
        power = pid(water_temp)
        water_temp = boiler.update(power, dt)

        # Update values for plotting
        t += [current_time-start_time]
        x += [power]
        y += [water_temp]
        setpoint += [pid.setpoint]

        if current_time - start_time > 1:
            pid.setpoint = 100

        last_time = current_time

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
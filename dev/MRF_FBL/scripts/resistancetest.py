"""
resistancetest.py

Type : Test sequence

Description: This script file performs the resistance test which consists in 
             measuring the increase in resistance due to to a resistance heating closeby.

Instruments required : Requires a Qontrol system with Q8iv card.


Author : Simon Bélanger-de Villers (simon.belanger-de-villers.1@ulaval.ca)
Date created : October 10th 2019
Last Edited : October 10th 2019 
"""
from Instruments.qontrol import *
import numpy as np

# Setup Qontroller
serial_port_name = "/dev/tty.usbserial-FT06QAZ5"
q = qontrol.QXOutput(serial_port_name = serial_port_name, response_timeout = 0.1)

# Parameters
actuators           = [1, 2, 3, 4, 5]       # List of the SMU channels (E.g. qontrol system)
numberOfActuators   = len(actuators)        # Number of different actuators present
voltageRange        = np.linspace(0, 4, 20) # Voltage points to sweep 

# TODO : Measure base resistance in order to find resistance offset

# Sweep the different actuators
for activeActuator in actuators:

    # Sweep the voltage range
    for currentVoltage in voltageRange:

        # Apply the voltage to the active actuator
        q.v[activeActuator] = currentVoltage

        # Measure the applied electrical power to the heater
        power = q.v[activeActuator] * q.i[activeActuator]

        # Sweep all the actuators and measure their resistance offset
        # TODO: passive = all except the active
        for passiveActuator in actuators:

            # Measure voltage and current
            # TODO : need to apply a small bias in order to measure the resistance
            # TODO : how to take this into account (remove this bias)
            measured_voltage = q.v[passiveActuator]
            measured_current = q.i[passiveActuator]

            # Compute resistance
            measured_resistance = measured_voltage/measured_current

            # Save the voltage sweep for this actuator


# TODO : Check if the resistance increase for the other heaters is proportional to the applied power
# TODO : Measure the crosstalk matrix in order to see the crosstalk power vs increasing distance (what is the relationship)
# TODO : Find a way to compare this value to the actual crosstalk between rings vs crosstalk between heaters (pythagorean, etc.)



        
"""
This Jupyter-like file allows to pass commands interactively to the
Qontrol System using vsCode. (https://code.visualstudio.com/docs/python/jupyter-support)

Run the different code cells interactively in order to send commands to the device.

Author          : Simon Bélanger-de Villers
Created         : July 28th 2019
Last Edited     : July 31st 2019
"""


#%% Initialize the Qontrol
def listSerialPorts():
    " List all serial ports on this computer. "

    from serial.tools.list_ports import comports

    for ports in comports():
        print(ports.device)

#listSerialPorts()

# NOTE : Jupyter Server's current working directory is in ULPythonLab
from Instruments.qontrol import QXOutput
#from qontrol import QXOutput
import time
q = QXOutput(serial_port_name = "/dev/cu.usbserial-FT2ZGKOF", response_timeout = 0.1)

#%% Low level Write Command

q.transmit('V16 = 1.'+'\n')

#%% Low level query command

q.transmit('ID?'+'\n')          # Identity of the driver @ Slot 0
q.transmit('NCHAN?'+'\n')       # Number of channels of the driver @ Slot 0
q.transmit('NUPALL?'+'\n')      # Information on the daisychain
message = q.receive()[0]
for line in message: 
    print(line) 

#%%
print(q.chain)

#%% Very low level command
command_string = 'V0 = 0.'+'\n'
q.serial_port.write(command_string.encode('ascii'))

#%% Check if binary solves the issue

q.binary_mode = True

q.v[:] = 1

#%% Do Stuff

q.v[16] = 2
#q.i[] = 1

print(q.i[16])

#%% Set voltage limit 

q.vmax[:] = q.v_full
print(q.vmax)

#%% Turn off all channels
q.i[:] = 0
q.v[:] = 0
#%% Close the serial port
q.close()

#%%

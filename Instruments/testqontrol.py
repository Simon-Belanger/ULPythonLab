def listSerialPorts():
    " List all serial ports on this computer. "

    from serial.tools.list_ports import comports

    for ports in comports():
        print(ports.device)

#listSerialPorts()




from qontrol import QXOutput

q = QXOutput(serial_port_name = "/dev/cu.usbserial-FT2ZGKOF", response_timeout = 0.1)

q.close()


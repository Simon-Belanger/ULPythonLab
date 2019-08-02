from Instruments.TCPinterface import TCP
from Instruments.ova5000 import Luna

#device IP
ip = {
    'host' : "10.13.11.254", 
    'port' : 1
    }

luna = Luna(ip['host'], ip['port'])
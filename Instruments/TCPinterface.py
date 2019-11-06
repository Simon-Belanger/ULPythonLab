# /usr/bin/env python
# -*- coding : utf-8 -*-

__author__ = 'Sizhan Liu'
__version__ = "1.0"

'''
This class is for TCP/IP interface.
Including:
1. Creating/Close TCP connection.
2. Basic TCP writing, reading, querying.

reference:
1. https://bitbucket.org/martijnj/telepythic Copyright 2014 by Martijn Jasperse

'''
import socket
import select
import time

class TCP(object):
    def __init__(self, host, port):
        self.__host = host
        self.__port = port
        
        # === Connect ===

        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP)
        self.sock.settimeout(10)
        try:
            self.sock.connect((self.__host,self.__port))
        except:
            raise socket.timeout("Fail to connect to %s:%i" %(self.__host,self.__port))
        
    def TCP_close(self):
        '''close TCP connection '''
        self.sock.close()
        print(self.__class__.__name__ + ' connection is closed.')
        

    def has_reply(self, timeout=0):
        '''check whether a replay is waiting to be read'''
        socklist = select.select([self.sock], [], [], timeout)
        return len(socklist[0])>0
    
    def write(self, cmd):
        strtmp = str(cmd)
        self.sock.send(strtmp.encode())
        time.sleep(0.5)
        
    def read_raw(self):
        '''
        Read data more than 1024B, return fromat is strings.
        Add 300ms delay to avoid TCP transfer data miss.
        '''
        data = self.sock.recv(256)
        time.sleep(0.3)
        try:
            while self.has_reply(timeout=0):
                data += self.sock.recv(256)
            return data
        except:
            print ("Recv time out")


    def clearbuffer(self):
        '''clear TCP buffer if type wrong command'''
        n = 0
        while self.has_reply(timeout=0):
            n += len(self.sock.recv(1024))
        return n              
           
    def query(self,cmd):
        '''query result from Luna'''
        self.write(cmd)
        data =  self.read_raw()
        return data

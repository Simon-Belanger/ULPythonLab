# /usr/bin/env python
# -*- coding : utf-8 -*-

__author__ = 'Sizhan Liu'
__version__ = "1.0"

'''
Luna OVA5000 interface
'''

import sys
sys.path.append('D:\\work\\coding\\python\\inf_optics\\interface\\')

import time
import re
import pylab as pl

# debug only
# luna = Luna(ip['host'], ip['port'])
#ip = {
#    'host' : "10.13.51.252", 
#    'port' : 1
#    }

#testplan = {
#    'center': {'C':1549.0,'C+L':1569.0},
#    'range':{'C': 41.67,'C+L':85.69}
#    }


############### --Connectiong -- ###############
class Luna(TCP):
    def __init__(self, host, port):
        '''Setup a remote connection for OVA5000'''
        self._host = host
        self._port = port
        super().__init__(self._host, self._port)
        time.sleep(1)
       
        command = "*CLS"
        self.write(command)
        time.sleep(1)

        #check if you expect result
        A = self.deviceID.decode().replace("\x00","").lower()
        if A=='optical vector analyzer':
            print("--> Welcome to passive test platform :) --")
        else:
            print('Wrong connection!')
            self.close()

    def close(self):
        '''Close remote connection for OVA5000'''
        self.write("*QUIT")
        self.TCP_close()
        print(self.__class__.__name__ + ' had been disconnected!')

########## --data parse for luna only -- ###############
    def data_pasre(self, command):
        return command.decode().replace("\x00",'')

########## --super class alternative method --- #######
    def write(self, cmd):
        '''
        rewrtie a 'write' command for Luna
        '''
        cmd = str(cmd)
        TCP.write(self,cmd)
    
    def read(self):
        '''
        The Luna response time may larger than TCP time out time.
        Luna will response a binary list with EOS "\x00". 
        '''
        data = TCP.read_raw(self)
        while True:
            try:
                if len(data) <= 1 or data[-1]!=0:
                    data += TCP.read_raw(self)
                else:
                    break
                #return data    
            except:
                pass
        return data       
    
    def query(self,cmd):
        '''query result from Luna'''
        self.write(cmd)
        #time.sleep(1)
        data = self.read()
        return data

    def inspection(self,command ="SYST:ERR?" ,exception = '0'):
        while True:
            try:
                Q = self.query(command)
                #print (type(Q))
                #print (Q)
                if self.data_pasre(Q) == exception:
                    break
                else:
                    print("--> Verifing, or use Ctrl+C to end this process.")
            except:
                pass


#################---Basic Field ---###############
    @property
    def deviceID(self):
        return self.query("*IDN?")
    
    @property
    def centerWav(self):
        '''center wavelength config'''
        command = "CONF:CWL?"
        return self.query(command)
    @centerWav.setter
    def centerWav(self,center):
        command="CONF:CWL"+ " "+ "%s" % center
        self.write(command)

    @property
    def startWav(self):
        '''get start wavelength'''
        command = "CONF:STAR?"
        return self.query(command)
    @startWav.setter
    def startWav(self,start):
        '''get start wavelength'''
        command = "CONF:STAR"+" "+ "%s" % start
        self.write(command)

    @property
    def rangeWav(self):
        '''get wavelength range'''
        command = "CONF:RANG?"
        return self.query(command)
    @rangeWav.setter
    def rangeWav(self,rangewav):
        '''wavelength range config '''
        command = "CONF:RANG"+" "+"%s" % rangewav
        self.write(command)

    @property
    def stopWav(self):
        '''get stop wavelength'''
        command = 'CONF:END?'
        return self.query(command)
    
    @property
    def measInfor(self):
        '''get OVA current meassurement detials for Matrix A P166'''
        command = "FETC:MDET?"
        return self.query(command)

################ -- pre-Measurement Setting-- ###############
    def measType(self):
        '''set measure type as transmission'''
        command = "CONF:TEST 1,1"
        self.write(command)
        self.inspection(command = "CONF:TEST? 0", exception = "1")
        print("--> Measurement type is set to transmission with full calibration.")

    def measAverage(self, number = 10):
        '''Enable Matrix average and set average times '''
        #eanble matrix average
        command = "CONF:AVGE 1"
        self.write(command)
        self.inspection(command = "CONF:AVGE? 0", exception = "1")
        print("--> Matrix Average is enabled.")

        #set average number = 10
        command = "CONF:AVGS" +" " + "%s" % number
        self.write(command)
        self.inspection(command = "CONF:AVGS? 0", exception = str(number))
        print("--> Matrix Average 10 times.")
        

    def measFindDutLength(self):
        '''Enable auto find dutlength, set find dut length method to broadband'''
        #Eable auto find DUT length
        command = "CONF:FDUT 1"
        self.inspection(command = "CONF:FDUT?", exception = "1")
        print("--> Auto find DUT lenght is enabled.")

        #Set find DUT length using broadband method
        self.write(command)
        command = "CONF:DUTM 0"
        self.write(command)
        self.inspection(command = "CONF:DUTM?", exception = "0")
        print ("--> Using broadband method to find DUT length.")

    def measApplyFilter(self):
        '''Always apply filter on'''
        command = "CONF:AAF 1"
        self.write(command)
        self.inspection(command = "CONF:AAF?", exception = "1")
        print("--> Always apply filter ON.")

        
    def measTimeDomainWindow(self):
        '''Apply time domann window'''
        command = "CONF:TDW 1"
        self.write(command)


################# --Measurement method-- ####################

    def measDetail(self):
        '''Get measurement deail from OVA5000'''
        command = "FETC:MDET?"
        lbuffer = self.query(command)
        print (lbuffer.decode())

    def setDUTName(self, dutname = ""):
        '''set DUT name'''
        command = "CONF:DUTN"+" "+"\""+dutname+"\""
        self.write(command)
        self.inspection(command = "CONF:DUTN?", exception = dutname)
        print('--> DUT name is %s.' % dutname)

    def scan(self):
        '''Tells the OVA to execute an optical scan based on the
            configured system parameters. Depending on the
            wavelength range setting and the number of averages, this
            command may take up to several minutes to complete.
        '''
        command = "SYST:RDY?"
        self.inspection(command, exception = "1")
        print ("--> It's ready to start scan..")
        #input("--> Press Enter to start scan...")
 
        command = "SCAN"
        scanStartTime = time.time()
        self.write(command)
        
        self.inspection()
        scanStopTime = time.time()
        print ("--> Scan is completed!  It takes %s secods." % (scanStopTime-scanStartTime))


################# --Filter setting -- ###################

#smoothing filter setting
    def setSmoothFilter(self):
        '''set smoothing filter bandwidth uint to gigahertz P179'''
        command = "CONF:RSBU 1"
        self.write(command)
        self.inspection(command = "CONF:RSBU?", exception= '1')
        print ("--> Smoothing filter bandwidth unit is GHz.")

        
    
    def setSmoothFiltertoMatirxA(self):
        #set smoothing filter bandwidth value to 5pm
        command = "CONF:FRBW 0.62"
        self.write(command)
        self.inspection(command = "CONF:FRBW?", exception = '0.620000')
        print("--> Smoothing filter resolution bandwidth is setted to 5pm/0.62GHz")

        '''Apply smoothing filter to Matrix A P168'''
        command = "SYST:FILT"
        self.write(command)
        
       

#Time domain filter
    def setTimeDomain(self):
        '''Confige time domain window, Hanning window must be set first because the setting would affect time
            domain setting, i don't know why. Just do it.
        '''
        
        #diable Hanning window
        '''diable hanning window for narrow band component, 1: enable, 0: disable'''
        ''''''
        command = "CONF:THAN 1"
        self.write(command)
        self.inspection(command = "CONF:THAN?", exception = '1')
        print("--> Hanning window is enabled.")

        #Enable time domain filter
        command  = "CONF:TDW 1"
        self.write(command)
        self.inspection(command = "CONF:TDW?", exception = '1')
        print("--> Time domain filter is Enabled.")

        #Retain Settings in Time Domain Window
        command = "CONF:TRET 1"
        self.write(command)
        self.inspection(command = "CONF:TRET?", exception = "1")
        print("--> Time domain setting is maintained. ")


################# --Save result -- ####################


    def savetxtResult(self, filename='D:\\ch1'):
        '''save txt file to local computer path'''
        command = 'SYST:SAVT'
        self.write(command+" "+filename+'.txt')
        time.sleep(8)
    def savebinResult(self, filename='D:\\ch1'):
        command = 'SYST:SAVJ'
        self.write(command+" "+filename+'.bin')
        time.sleep(8)

################# --data fetch -- ####################    
    def fetchresult(self, items = 0):
        '''0: IL; 1: GD; 3: PDL; 4:PMD; 11: Min/Max Loss; P153'''
        command = 'FETC:MEAS? '+str(items)
        IL = self.query(command)
        IL = self.data_pasre(IL)
        IL = re.split(r"\r|\t",IL)
        IL = [float(i) for i in IL if i!='']
        
        if items == 0:
            pl.ylim(-20,0), pl.grid(),pl.plot(IL), pl.show()
        else:
            pass
    
        strtmp = input("input 'n' to disconnet to re-calibrate or \npress any key to continue..")
        if strtmp.lower()=='n':
            self.close()
        else:
            pass
        return IL
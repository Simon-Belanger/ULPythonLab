"""
Luna OVA5000 interface

luna = Luna("192.168.0.4", 1)


Credits:

Created by Sizhan Liu (feyd-rautha13) at Infinera 
Original code can be found here https://github.com/feyd-rautha13/inf_optics

Edited by Simon Belanger-de Villers (simon.belanger-de-villers.1@ulaval.ca)
on 19 November 2019
"""

from Instruments.TCPinterface import TCP
import matplotlib.pyplot as plt
import time, re

############### --Connecting -- ###############
class Luna(TCP):

    echo = False

    def __init__(self, host, port):
        '''Setup a remote connection for OVA5000'''
        self._host = host
        self._port = port
        super(Luna, self).__init__(self._host, self._port)
        time.sleep(1)
       
        command = "*CLS"
        self.write(command)
        time.sleep(1)

        #check if you expect result
        A = self.deviceID
        if A=='Optical Vector Analyzer':
            pass
        #    if self.echo : print("--> Connected to %s version %s." % (self.deviceID, self.version))
        else:
            print('Wrong connection!')
            self.close()

    def close(self):
        '''Close remote connection for OVA5000'''
        self.write("*QUIT")
        self.TCP_close()
        print(self.__class__.__name__ + ' had been disconnected!')

    def reset(self):
        '''Reset the OVA to it's power on defaults'''
        self.write('*RST')

########## --data parse for luna only -- ###############
    def dataParse(self, command):
        return command.decode().replace("\x00",'')

########## --super class alternative method --- #######
    def write(self, cmd):
        '''
        rewrite a 'write' command for Luna
        '''
        cmd = str(cmd)
        TCP.write(self, cmd)
    
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
    
    def query(self, cmd):
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
                if self.dataParse(Q) == exception:
                    break
                else:
                    print("--> Verifing, or use Ctrl+C to end this process.")
            except:
                pass


#################---Basic Field ---###############
    @property
    def deviceID(self):
        command = "*IDN?"
        return self.query(command).decode().replace("\x00","")

    @property
    def version(self):
        '''OVA software version.'''
        command = 'SYST:VER?'
        return self.query(command).decode().replace("\x00","")
    
    @property
    def dutLength(self):
        '''Length of device under test (DUT)'''
        command = "CONF:DUTL?"
        return self.query(command)
    @dutLength.setter
    def dutLength(self, length):
        command = "CONF:DUTL" + " " + "%s" % length
        self.write(command)

    @property
    def centerWav(self):
        '''center wavelength config'''
        command = "CONF:CWL?"
        return self.query(command)
    @centerWav.setter
    def centerWav(self, center):
        command="CONF:CWL"+ " "+ "%s" % center
        self.write(command)

    @property
    def startWav(self):
        '''get start wavelength'''
        command = "CONF:STAR?"
        return self.query(command)
    @startWav.setter
    def startWav(self, start):
        '''get start wavelength'''
        command = "CONF:STAR"+" "+ "%s" % start
        self.write(command)

    @property
    def rangeWav(self):
        '''get wavelength range. Allowed ranges [0.63, 1.27, 2.54, 5.09, 10.22, 20.57, 41.7, 85.76] nm.'''
        command = "CONF:RANG?"
        return float(self.dataParse(self.query(command)))
    @rangeWav.setter
    def rangeWav(self, rangewav):
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

    @property
    def nAverages(self):
        '''Number of averages. Averaging must be enabled in order to work.'''
        command = "CONF:AVGS? 0"
        return int(self.dataParse(self.query(command)))
    @nAverages.setter
    def nAverages(self, number):
        command = 'CONF:AVGS %s,0' % number
        self.write(command)


    

################ -- pre-Measurement Setting-- ###############
    def measType(self):
        '''set measure type as transmission'''
        command = "CONF:TEST 1,1"
        self.write(command)
        self.inspection(command = "CONF:TEST? 0", exception = "1")
        if self.echo: print("--> Measurement type is set to transmission with full calibration.")

    def enableAverage(self, nAverages):
        '''Enable matrix averaging.'''
        command = 'CONF:AVGE 1'
        self.write(command)
        self.nAverages = nAverages
        if self.echo: print("--> Matrix Averaging is enabled and set to %s." % nAverages)

    def disableAverage(self):
        '''Disable matrix averaging.'''
        command = 'CONF:AVGE 0'
        self.write(command)
        self.nAverages = 1
        if self.echo: print("--> Matrix Averaging is disabled.")

    def measAverage(self, number = 10):
        '''Enable Matrix average and set average times '''
        #eanble matrix average
        command = "CONF:AVGE 1"
        self.write(command)
        self.inspection(command = "CONF:AVGE? 0", exception = "1")
        if self.echo: print("--> Matrix Average is enabled.")

        #set average number = 10
        command = "CONF:AVGS" +" " + "%s" % number
        self.write(command)
        self.inspection(command = "CONF:AVGS? 0", exception = str(number))
        if self.echo: print("--> Matrix Average 10 times.")

    def measFindDutLength(self):
        '''Enable auto find dutlength, set find dut length method to broadband'''
        #Eable auto find DUT length
        command = "CONF:FDUT 1"
        self.inspection(command = "CONF:FDUT?", exception = "1")
        if self.echo: print("--> Auto find DUT lenght is enabled.")

        #Set find DUT length using broadband method
        self.write(command)
        command = "CONF:DUTM 0"
        self.write(command)
        self.inspection(command = "CONF:DUTM?", exception = "0")
        if self.echo: print ("--> Using broadband method to find DUT length.")

    def measApplyFilter(self):
        '''Always apply filter on'''
        command = "CONF:AAF 1"
        self.write(command)
        self.inspection(command = "CONF:AAF?", exception = "1")
        if self.echo: print("--> Always apply filter ON.")

        
    def measTimeDomainWindow(self):
        '''Apply time domann window'''
        command = "CONF:TDW 1"
        self.write(command)


################# --Measurement method-- ####################

    def setDUTName(self, dutname = ""):
        '''set DUT name'''
        command = "CONF:DUTN"+" "+"\""+dutname+"\""
        self.write(command)
        self.inspection(command = "CONF:DUTN?", exception = dutname)
        if self.echo: print('--> DUT name is %s.' % dutname)

    def scan(self):
        '''Tells the OVA to execute an optical scan based on the
            configured system parameters. Depending on the
            wavelength range setting and the number of averages, this
            command may take up to several minutes to complete.
        '''
        command = "SYST:RDY?"
        self.inspection(command, exception = "1")
        if self.echo: print ("--> It's ready to start scan..")
 
        command = "SCAN"
        scanStartTime = time.time()
        self.write(command)
        
        self.inspection()
        scanStopTime = time.time()
        if self.echo: print ("--> Scan was completed in {0:0.2f} seconds.".format(scanStopTime-scanStartTime))


################# --Filter setting -- ###################

#smoothing filter setting
    def setSmoothFilter(self):
        '''set smoothing filter bandwidth uint to gigahertz P179'''
        command = "CONF:RSBU 1"
        self.write(command)
        self.inspection(command = "CONF:RSBU?", exception= '1')
        if self.echo: print ("--> Smoothing filter bandwidth unit is GHz.")

        
    
    def setSmoothFiltertoMatirxA(self):
        #set smoothing filter bandwidth value to 5pm
        command = "CONF:FRBW 0.62"
        self.write(command) 
        self.inspection(command = "CONF:FRBW?", exception = '0.620000')
        if self.echo: print("--> Smoothing filter resolution bandwidth is setted to 5pm/0.62GHz")

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
        if self.echo: print("--> Hanning window is enabled.")

        #Enable time domain filter
        command  = "CONF:TDW 1"
        self.write(command)
        self.inspection(command = "CONF:TDW?", exception = '1')
        if self.echo: print("--> Time domain filter is Enabled.")

        #Retain Settings in Time Domain Window
        command = "CONF:TRET 1"
        self.write(command)
        self.inspection(command = "CONF:TRET?", exception = "1")
        if self.echo: print("--> Time domain setting is maintained. ")


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
    def fetchResult(self, items = 0):
        '''0: IL; 1: GD; 3: PDL; 4:PMD; 11: Min/Max Loss; P153'''
        command = 'FETC:MEAS? '+str(items)
        IL = self.query(command)
        IL = self.dataParse(IL)
        IL = re.split(r"\r|\t",IL)
        IL = [float(i) for i in IL if i!='']
        return IL

    def fetchXAxis(self, x=0):
        '''Return the wavelength in units of
        0: nm, 1: GHz, 2: THz, 3: ns, 4: m
        '''
        command = 'FETC:XAXI? ' + str(x)
        wvl = self.query(command)
        wvl = self.dataParse(wvl)
        wvl = re.split(r"\r|\t",wvl)
        wvl = [float(i) for i in wvl if i!='']
        return wvl

    def fetchDataLength(self):
        '''Queries the OVA for the size of the data array.'''
        command = 'FETC:FSIZ?'
        fsize = self.query(command)
        return int(self.dataParse(fsize))

    def fetchMeasurementDetails(self):
        '''Queries the OVA for measurement details and prints the output.'''
        command = 'FETC:MDET?'
        message = self.query(command)
        print(self.dataParse(message))


################# --alignment/calibration -- ####################
    def align(self):
        pass

    def isAligned(self):
        '''Ask the system if it is aligned'''
        command = 'SYST:ALIG?'
        return self.query(command)

################# --OVA as tunable light source -- ####################
    def sweep(self):
        command = 'SYST:SWEE'
        self.write(command)


    def continousScan(self):
        '''Coninuously scan the OVA and plot the Insertion Loss.'''

        # draw the plot
        fig,ax = plt.subplots(1,1)

        import numpy as np
        self.scan()
        wvl = self.fetchXAxis()
        #wvl = np.linspace(self.startWav, self.stopWav, self.fetchDataLength())

        # Feedback loop    
        for i in range(100):
        
            #time.sleep(0.1)
               
            # Actuate values
            self.scan()
            
            #wvl = self.fetchXAxis()
            #wvl = np.linspace(self.startWav, self.stopWav, self.fetchDataLength())

            plt.cla()
            ax.plot(wvl, self.fetchResult('0'), color='b')
            plt.xlabel('Wavelength [nm]'), plt.ylabel('IL [dB]')
            plt.title('OVA Scan')
            plt.xlim([min(wvl), max(wvl)]), plt.ylim([-70, -15])
            ax.grid()
            
        
            plt.pause(0.001)
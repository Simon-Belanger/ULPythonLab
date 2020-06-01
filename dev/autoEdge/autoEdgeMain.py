"""
Main code for the auto-alignment feature for the edge coupler.

-Includes randomwalk, PID.
-Works with the Agilent TLS only.
TODO : Needs some cleanup.

Author : Simon Belanger-de Villers
Created : January 6th 2020
Last edited : January 8th 2020

"""

import matplotlib.pyplot as plt
import time, os
from Instruments.smarPod.smarPodClass import *
from Instruments.hp816x_instr_py3 import hp816x
from Instruments.Keithley_2612B import Keithley_2612B

def autoEdge(LMS, smarPod):
    """Feedback look for alignment of the edge coupler position."""

    # Parameters
    powerMeter          = (4, 0)                        # Slot number & Channel number of the photodetector
    numberIterations    = 10000                            # Number of iterations that will be performed
    actuatorON          = True                   # Perform control over the system with the actuator
    zPos                = smarPod.getPosition()[2]      # Initial Z position of the transposer
    deltaZPos           = 0.1                          # Position increament at every iteration [um]
    averagingTime       = 0.05                        # Averaging time of the photodetector
    #Execute the code while no interruption
    try:

        # Init arrays
        #   iteration : Iteration number in the loop
        #   power     : Power measured at the PD for every iteration
        #   zPosition : Z position of the transposer for every iteration
        iteration, power, zPosition = [], [], []
    
        # Configure the plot for tracking
        fig, ax = plt.subplots(nrows=1, sharex=True)
        ax.set_title('autoEdge')
        ax.set_xlabel('Iteration')
        ax1 = ax.twinx()
        ax.set_ylabel('Optical Power [dB]', color='b'); ax.tick_params('y', colors='b')
        ax1.set_ylabel('Z position [um]', color='r'); ax1.tick_params('y', colors='r')

        # Turn the laser on
        LMS.setPWMAveragingTime(powerMeter[0], powerMeter[1], averagingTime)
        LMS.setTLSWavelength(1568e-9)
        LMS.setTLSPower(0)
        LMS.setTLSOutput('lowsse')
        LMS.setTLSState('on')
        time.sleep(5)

        # Feedback loop    
        for i in range(numberIterations):
            #time.sleep(0.5)

            X = LMS.readPWM(powerMeter[0], powerMeter[1])       # Measure the optical power before actuating -> X

            if actuatorON:    
                smarPod.moveZ(deltaZPos)                        # Increase the Z value of the transposer 

            Y = LMS.readPWM(powerMeter[0], powerMeter[1])       # Measure the optical power after actuating -> Y

            if Y<X:
                deltaZPos = -1 * deltaZPos

            # Actuate values
            iteration.append(i); power.append(Y); zPosition.append(smarPod.getPosition()[2])

            # Draw the plot
            ax.plot(iteration, power, 'b')     # Optical Power
            ax1.plot(iteration, zPosition, 'r') # Z position
            
            # Set the limits for the axes
            ax.set_xlim([min(iteration),max(iteration)+1])
            if len(iteration)>100:
                ax.set_xlim([max(iteration)-100,max(iteration)])
            ax.set_ylim([min(power), max(power)])
            ax1.set_ylim([min(zPosition), max(zPosition)])
            plt.pause(0.01)
        
            #Average
            ax.cla(); ax1.cla()
            #ax.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(V_inI)),np.average(np.asarray(V_inI))], 'b--')
            #ax1.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(I_outI)),np.average(np.asarray(I_outI))], 'r--')

        fig.tight_layout()
        ax.set_xlim([min(iteration), max(iteration)]); ax1.set_xlim([min(iteration), max(iteration)])
        fig.show()
        input('Press any key to continue...')
    
        # Save the data as text file
        np.savetxt('AE_' + time.strftime("%Y-%m-%d@%H_%M_%S") + '.txt', (iteration, power, zPosition))

        # Turn the laser off
        LMS.setTLSState('on')
        
    # To close the utilitary
    except KeyboardInterrupt:
        np.savetxt('AE_' + time.strftime("%Y-%m-%d@%H_%M_%S") + '.txt', (iteration, power, zPosition))


def computeRate(dLoss):
    dLossMin = 0.01
    dLossMax = 5
    rateMin = 0.01
    rateMax = 0.1

    slope, intercept = np.polyfit([dLossMin, dLossMax], [rateMin, rateMax], 1)
    rate = slope*dLoss + intercept

    if rate < rateMin:
        rate = rateMin
    elif rate > rateMax:
        rate = rateMax

    return rate

    #rate = (rateMax - rateMin)/(dlossMax - dLossMin) * dLoss + 

def proportionalRate(loss):
    LossMin = -14
    LossMax = -20
    rateMin = 0
    rateMax = 0.1

    slope, intercept = np.polyfit([LossMin, LossMax], [rateMin, rateMax], 1)
    rate = slope*loss + intercept

    if rate < rateMin:
        rate = rateMin
    elif rate > rateMax:
        rate = rateMax

    return rate


def randomWalk(LMS, smarPod, step, doPlot=False):
    """Feedback loop for alignment of the edge coupler position with X and Z position actuators."""

    # Parameters
    powerMeter          = (4, 0)                        # Slot number & Channel number of the photodetector
    numberIterations    = 200                            # Number of iterations that will be performed
    actuatorON          = True                   # Perform control over the system with the actuator
    xPos                = smarPod.getPosition()[0]      # Initial X position of the transposer
    zPos                = smarPod.getPosition()[2]      # Initial Z position of the transposer
    deltaXPos           = step                          # X Position increament at every iteration [um]
    deltaZPos           = step                          # Position increament at every iteration [um]
    averagingTime       = 0.05                        # Averaging time of the photodetector


    #Execute the code while no interruption
    try:

        # Init arrays
        #   iteration : Iteration number in the loop
        #   power     : Power measured at the PD for every iteration
        #   zPosition : Z position of the transposer for every iteration
        iteration, power, zPosition, xPosition = [], [], [], []
    
        if doPlot:
            # Configure the plot for tracking
            fig, ax = plt.subplots(nrows=1, sharex=True)
            ax.set_title('autoEdge')
            ax.set_xlabel('Iteration')
            ax1 = ax.twinx()
            ax.set_ylabel('Optical Power [dB]', color='b'); ax.tick_params('y', colors='b')
            ax1.set_ylabel('Position drift [um]', color='r'); ax1.tick_params('y', colors='r')

        # Turn the laser on
        LMS.setPWMAveragingTime(powerMeter[0], powerMeter[1], averagingTime)
        LMS.setTLSWavelength(1568e-9)
        LMS.setTLSPower(0)
        LMS.setTLSOutput('lowsse')
        LMS.setTLSState('on')
        time.sleep(5)

        xRate = []
        zRate = []

        maxPower = -30
        # Feedback loop    
        for i in range(numberIterations):
            #time.sleep(0.5)

            # Z tuning
            Xz = LMS.readPWM(powerMeter[0], powerMeter[1])       # Measure the optical power before actuating -> X

            if actuatorON:    
                smarPod.moveZ(deltaZPos)                        # Increase the Z value of the transposer 

            Yz = LMS.readPWM(powerMeter[0], powerMeter[1])       # Measure the optical power after actuating -> Y

            zRate.append(proportionalRate(Yz))

            if Yz<Xz:
                deltaZPos = -np.sign(deltaZPos)*zRate[-1]

            # X tuning
            Xx = LMS.readPWM(powerMeter[0], powerMeter[1])       # Measure the optical power before actuating -> X

            if actuatorON:    
                smarPod.moveX(deltaXPos)                        # Increase the Z value of the transposer 

            Yx = LMS.readPWM(powerMeter[0], powerMeter[1])       # Measure the optical power after actuating -> Y

            xRate.append(proportionalRate(Yx))

            if Yx<Xx:
                deltaXPos = -np.sign(deltaXPos)*xRate[-1]

            # for debugging:
            #print('xRate: '+str(xRate[-1]) + '\nzRate: ' + str(zRate[-1]))

            if Xx > maxPower:
                maxPower = Xx


            # Actuate values
            iteration.append(i); power.append(Yx); zPosition.append(smarPod.getPosition()[2]); xPosition.append(smarPod.getPosition()[0])

            # Normalised positions
            xNormed = (np.asarray(xPosition)-xPos).tolist()
            zNormed = (np.asarray(zPosition)-zPos).tolist()

            if doPlot:
                # Draw the plot
                ax.plot(iteration, power, 'b')     # Optical Power
                ax1.plot(iteration, zNormed, 'r', label='Z') # Z position
                ax1.plot(iteration, xNormed, 'g', label='X') # Z position
                plt.legend()
                
                # Set the limits for the axes
                ax.set_xlim([min(iteration),max(iteration)+1])
                if len(iteration)>100:
                    ax.set_xlim([max(iteration)-100,max(iteration)])
                ax.set_ylim([min(power), max(power)])
                #ax1.set_ylim([min([xNormed, zNormed]), max([xNormed, zNormed])])
                plt.pause(0.001)
            
                #Average
                ax.cla(); ax1.cla()
                #ax.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(V_inI)),np.average(np.asarray(V_inI))], 'b--')
                #ax1.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(I_outI)),np.average(np.asarray(I_outI))], 'r--')

            print(   'Fine alignemnt in progress. ' + str(round(((i+1)*100/numberIterations))) + '% complete.\n')


        if doPlot:
            fig.tight_layout()
            ax.set_xlim([min(iteration), max(iteration)]); ax1.set_xlim([min(iteration), max(iteration)])
            fig.show()
            input('Press any key to continue...')
    
        # Save the data as text file
        np.savetxt('AE_' + time.strftime("%Y-%m-%d@%H_%M_%S") + '.txt', (iteration, power, zNormed, xNormed, zRate, xRate))

        # Turn the laser off
        LMS.setTLSState('on')
        
    # To close the utilitary
    except KeyboardInterrupt:
        np.savetxt('AE_' + time.strftime("%Y-%m-%d@%H_%M_%S") + '.txt', (iteration, power, zNormed, xNormed, zRate, xRate))

    print('Fine alignment complete. Min. insertion loss: '+str(round(maxPower)) + 'dB.')
    return maxPower

def filteredDerivative(x, y, filterLength=5):
    """ Returns a filtered derivative that is calculated using the backward finite difference.
        x               : independant variable input 
        y               : dependant variable input
        filterLength    : length of the output 
        """
    xD= (np.diff(x)[-filterLength:]).tolist()
    yD= (np.diff(y)[-filterLength:]).tolist()
    deriv = (np.asarray(yD)/np.asarray(xD)).tolist()

    for i in range(filterLength-len(x)+1):
        deriv.insert(0,0)

    return np.mean(deriv)

print(filteredDerivative([1,2,3,4],[4,8,16,32]))

def calculatePidSignal(timeVec, error, Kp, Kd, Ki):
    """ Calculate the signal that should be applied to the process using a PID regulator. """
    P = Kp * error[-1]                                              # Proportionnal
    I = Ki * np.trapz(np.asarray(error), np.asarray(timeVec))       # Integral
    D = Kd * filteredDerivative(timeVec, error)                     # Differential
    signal = P + I + D
    return signal, P, I, D

def applyPidSignal(smarPod, axis, signal, initPos, actuatorON=True, commandIsDelta=False, spanMax=10):
    """ Apply the PID signal to move the actuator. """
    if axis in ['x', 'X']:
        _axis = 'x'
    elif axis in ['z', 'Z']:
        _axis = 'z'
    else:
        print('Axis is not valid.')
        raise KeyboardInterrupt

    if actuatorON:    
        # Relative move without knowing the position at i-1
        if commandIsDelta:
            if _axis =='x':
                commandIsWithinSpan(smarPod, signal, 0, initPos, spanMax)
                smarPod.moveX(signal)
            if _axis =='z':
                commandIsWithinSpan(smarPod, 0, signal, initPos, spanMax)
                smarPod.moveZ(signal)
        # Absolute move
        else:
            prePos = smarPod.getPosition()
            if _axis =='x':
                commandIsWithinSpanAbsolute(smarPod, initPos[0] + signal, prePos[2], initPos, spanMax)
                smarPod.moveAbsolute(initPos[0] + signal, prePos[1], prePos[2], prePos[3], prePos[4], prePos[5])
            if _axis =='z':
                commandIsWithinSpanAbsolute(smarPod, prePos[0], initPos[2] + signal, initPos, spanMax)
                smarPod.moveAbsolute(prePos[0], prePos[1], initPos[2] + signal, prePos[3], prePos[4], prePos[5])



def commandIsWithinSpan(smarPod, moveX, moveZ, initPos, spanMax=10):
    """ Check if the new target position is within the allowed span. """
    previousPosition        = smarPod.getPosition()
    nextPositionX           = previousPosition[0] + moveX
    nextPositionZ           = previousPosition[2] + moveZ
    commandIsWithinSpanAbsolute(smarPod, nextPositionX, nextPositionZ, initPos, spanMax)

def commandIsWithinSpanAbsolute(smarPod, newX, newZ, initPos, spanMax=10):
    if (abs(newX-initPos[0])>= spanMax) or (abs(newZ-initPos[2])>= spanMax):
        print('Position is exceeding the allowed span. dx = {}, dz = {}'.format(abs(newX-initPos[0]), abs(newZ-initPos[2])))
        raise KeyboardInterrupt

def updateScrollingPlot(xAxis, axes, bufferSize=100, pauseLength=0.00001):
    """ Scroll a plot to act as a time domain scope. 
        xAxis       : time or iteration number.
        axes        : all axes that should be updated or scrolled.
        bufferSize  : amount of points on the screen at any given time.
        pauseLength : refresh rate of the scrolling graph. """
    if len(xAxis)>bufferSize:
        plt.xlim([max(xAxis)-bufferSize, max(xAxis)])
    else:
        plt.xlim([min(xAxis), max(xAxis)+1])
    plt.pause(pauseLength)

    # Clear axes
    for ax in axes:
        ax.cla()

def pidAutoEdgeXZ(LMS, smarPod, command, Kp, Ki, Kd):
    """Feedback loop for alignment of the edge coupler position with X and Z position actuators.
        The rate is calculated using a PID controller."""
    print('Target stabilization: ' + str(np.round(command,2)) + ' dB.')
    # Parameters
    powerMeter          = (4, 0)                        # Slot number & Channel number of the photodetector
    actuatorON          = True                          # Perform control over the system with the actuator
    returnToInitPos     = True                          # Return the smarPod to it's inital position after the control has been turned off
    initPos             = smarPod.getPosition()         # Initial position of the smarPod
    averagingTime       = 0.05                          # Averaging time of the photodetector
    spanMax             = 10                            # Maximum position deviation from the initial position [um]
    polarPlot           = False                         # Plot the (X, Z) coordinates of the transposer 
    commandIsDelta      = False                          # The command (variable manipulee) is a relative move instead of an absolute one

    #Execute the code while no interruption
    try:

        # Init arrays
        iteration, power, zNormed, xNormed, timeVecZ, timeVecX, errorZ, errorX = [], [], [], [], [0], [0], [0], [0]
        Px_, Ix_, Dx_, Pz_, Iz_, Dz_                                    = [0], [0], [0], [0], [0], [0]
    
        # Configure the plot for tracking
        if polarPlot:
            fig, (ax, ax2) = plt.subplots(1,2)
            ax1 = ax.twinx()
            ax2.set_xlabel('X position [um]')
            ax2.set_ylabel('Z position [um]')
            axes = [ax, ax1, ax2]
        else:
            fig, ax = plt.subplots(nrows=1, sharex=True)
            ax1 = ax.twinx()
            axes = [ax, ax1]
        ax.set_title('autoEdge')
        ax.set_xlabel('Iteration')
        ax.set_ylabel('Optical Power [dB]', color='b'); ax.tick_params('y', colors='b')
        ax1.set_ylabel('Position drift [um]', color='r'); ax1.tick_params('y', colors='r')

        # Turn the laser on
        LMS.setPWMAveragingTime(powerMeter[0], powerMeter[1], averagingTime)
        LMS.setTLSWavelength(1568e-9)
        LMS.setTLSPower(0)
        LMS.setTLSOutput('lowsse')
        LMS.setPWMPowerUnit(powerMeter[0], powerMeter[1],'W')
        LMS.setTLSState('on')
        time.sleep(5)

        # Feedback loop
        i = 0
        initTime = time.time()
        time.sleep(1)
        while True:

            # Calculate input signal for the Z axis
            timeVecZ.append(time.time() - initTime)
            errorZ.append(command - LMS.readPWM(powerMeter[0], powerMeter[1]))
            signalZ,P,I,D = calculatePidSignal(timeVecZ, errorZ, Kp, Kd, Ki)
            Pz_.append(P);Iz_.append(I);Dz_.append(D)
            
            # Apply input signal to the Z axis actuator
            applyPidSignal(smarPod, 'z', signalZ, initPos, actuatorON, commandIsDelta, spanMax)

            # Calculate input signal for the X axis
            timeVecX.append(time.time()-initTime)
            errorX.append(command - LMS.readPWM(powerMeter[0], powerMeter[1]))
            signalX,P,I,D = calculatePidSignal(timeVecX, errorX, Kp, Kd, Ki)
            Px_.append(P);Ix_.append(I);Dx_.append(D)
            
            # Apply input signal to the X axis actuator
            applyPidSignal(smarPod, 'x', signalX, initPos, actuatorON, commandIsDelta, spanMax)

            # Actuate values
            iteration.append(i); power.append(LMS.readPWM(powerMeter[0], powerMeter[1]))
            xNormed.append(smarPod.getPosition()[0]-initPos[0]); zNormed.append(smarPod.getPosition()[2]-initPos[2])

            # Plot the power and the 2 control signals
            ax.plot(iteration, power,'b')
            ax1.plot(iteration, zNormed, 'r', label='Z') # Z position
            ax1.plot(iteration, xNormed, 'g', label='X') # X position
            if polarPlot:
                ax2.scatter(xNormed, zNormed)
            plt.legend()
            
            updateScrollingPlot(iteration, axes)

            i += 1
        
    # To close the utilitary and save the results
    except KeyboardInterrupt:
        # Turn the laser off
        LMS.setTLSState('off')
        filename = 'AE_' + time.strftime("%Y-%m-%d@%H_%M_%S") + '.txt'
        np.savetxt(filename, (iteration, power, zNormed, xNormed))
        if returnToInitPos:
            smarPod.moveAbsolute(initPos[0], initPos[1], initPos[2], initPos[3], initPos[4], initPos[5])
        plotAutoEdgeXZ(filename)
        plotPIDStatus(timeVecX, timeVecZ, errorX, errorZ, Px_, Pz_, Ix_, Iz_, Dx_, Dz_)

def plotAutoEdge(filename):
    """ Plot the auto edge results. """

    iteration, power, zPosition = np.loadtxt(filename)

    fig, ax = plt.subplots(nrows=1, sharex=True)
    ax.set_title('autoEdge')
    ax.set_xlabel('Iteration')
    ax1 = ax.twinx()
    ax.set_ylabel('Optical Power [dB]', color='b'); ax.tick_params('y', colors='b')
    ax1.set_ylabel('Z position [um]', color='r'); ax1.tick_params('y', colors='r')
    ax.plot(iteration, power, 'b')     # Optical Power
    ax1.plot(iteration, zPosition, 'r') # Z position
    plt.show()

def plotAutoEdgeXZ(filename):
    """ Plot the auto edge results. """

    iteration, power, zNormed, xNormed = np.loadtxt(filename)

    fig, ax = plt.subplots(nrows=1, sharex=True)
    ax.set_title('autoEdge')
    ax.set_xlabel('Iteration')
    ax1 = ax.twinx()
    ax.set_ylabel('Optical Power [dB]', color='b'); ax.tick_params('y', colors='b')
    ax1.set_ylabel('Position drift [um]', color='r'); ax1.tick_params('y', colors='r')
    ax.set_ylim([-35, max(power)])
    ax.plot(iteration, power, 'b')     # Optical Power
    ax1.plot(iteration, zNormed, 'r', label='Z') # Z position
    ax1.plot(iteration, xNormed, 'g', label='X') # Z position
    plt.legend()
    plt.show()

def plotPIDStatus(timeVecX, timeVecZ, eX, eZ, pX, pZ, iX, iZ, dX, dZ):
    """ Plot the P, I, D gain and the error after the acquisition is finished"""
    fig, (axE, axP, axI, axD) = plt.subplots(4,1, sharex=True)
    axE.set_ylabel('Error')
    axE.set_xlabel('Iteration')
    axP.set_ylabel('Proportionnal')
    axD.set_ylabel('Differential')
    axI.set_ylabel('Integral')

    #Plot the figures
    axE.plot(timeVecX, eX, label='X')
    axE.plot(timeVecZ, eZ, label='Z')

    axP.plot(timeVecX, pX, label='X')
    axP.plot(timeVecZ, pZ, label='Z')

    axI.plot(timeVecX, iX, label='X')
    axI.plot(timeVecZ, iZ, label='Z')

    axD.plot(timeVecX, dX, label='X')
    axD.plot(timeVecZ, dZ, label='Z')
    plt.legend()

    plt.show()

def sign(value):
    if value !=0:
        return abs(value)/value
    else:
        return 1

def isStable(power, threshold=0.2, bufferLength=10):
    """ Assess if power measured is stable """
    if len(power) < bufferLength:
        return False
    else:
        if np.std(np.asarray(power[-bufferLength:])) <= threshold:
            return True
        else:
            return False


def randomWalk2(LMS, smarPod, step):
    """Feedback loop for alignment of the edge coupler position with X and Z position actuators."""

    # Parameters
    powerMeter          = (4, 0)                        # Slot number & Channel number of the photodetector                           # Number of iterations that will be performed
    xPos                = smarPod.getPosition()[0]      # Initial X position of the transposer
    zPos                = smarPod.getPosition()[2]      # Initial Z position of the transposer
    LMS.setPWMAveragingTime(powerMeter[0], powerMeter[1], 50e-3)


    #Execute the code while no interruption
    try:
 
        fig, ax = plt.subplots(nrows=1, sharex=True)
        ax.set_title('autoEdge')
        ax.set_xlabel('Iteration')
        #ax1 = ax.twinx()
        ax.set_ylabel('Optical Power [dB]', color='b'); ax.tick_params('y', colors='b')
        #ax1.set_ylabel('Position drift [um]', color='r'); ax1.tick_params('y', colors='r')

        # Turn the laser on
        LMS.setTLSWavelength(1568e-9)
        LMS.setTLSPower(0)
        LMS.setTLSOutput('lowsse')
        LMS.setTLSState('on')
        time.sleep(5)

        Px = [LMS.readPWM(powerMeter[0], powerMeter[1])]
        Pz = [LMS.readPWM(powerMeter[0], powerMeter[1])]
        P = [LMS.readPWM(powerMeter[0], powerMeter[1])]
        directionX, directionZ = 1, 1
        iteration = [1]
        i = 1
        positionX = [smarPod.getPosition()[0]]
        positionZ = [smarPod.getPosition()[2]]
        variable = True # X
        direction = 1
        recentP = []


        while True:
            if isStable(recentP, threshold=.05):
                recentP = []
                variable = not variable

            P.append(LMS.readPWM(powerMeter[0], powerMeter[1]))
            recentP.append(P[-1])
            direction = direction if P[-1] > P[-2] else -1*direction

            if variable:
                pass
                #smarPod.moveX(direction*step)
                #positionX.append(smarPod.getPosition()[0])
                #time.sleep(.3)
            else:
                pass
                #Pz.append(LMS.readPWM(powerMeter[0], powerMeter[1]))
                #directionZ = directionZ if Pz[-1] > Pz[-2] else -1*directionZ
                #smarPod.moveZ(direction*step)
                #positionZ.append(smarPod.getPosition()[2])
            #print(directionX, directionZ)

            #time.sleep(.3)

            i += 1
            iteration.append(i)

            if i > 100:
                #ax.plot(iteration[-100:], Px[-100:],'b', label='X')
                ax.plot(iteration[-100:], P[-100:],'b')
                #ax1.plot(iteration[-100:], np.asarray(positionZ[-100:])-positionZ[0],'g',label='PositionZ')
            else:
                ax.plot(iteration, P,'b')
                #ax.plot(iteration, Pz,'r', label='Z')
                #ax1.plot(iteration, np.asarray(positionZ)-positionZ[0],'g',label='PositionX')

            ax.set_ylim((-30, -15))
            title = 'X' if variable else 'Z'
            ax.set_title(title)
            #plt.legend()
            
            plt.grid()
            plt.pause(1e-9)
            
            ax.cla()
    
    # To close the utilitary
    except KeyboardInterrupt:
        plt.figure()
        plt.plot(iteration, Px)
        plt.show()


if __name__ == '__main__':

    # Initiate the smarPod
    smarPod = SmarPodClass()
    smarPod.connect(0.1, 0.5, 1, 12500, 1, 0)

    # Initiate the tunable laser source
    LMS = hp816x()
    LMS.connect('GPIB0::20::INSTR')

    # Initiate the Keithley DC Power Supply
    powerSupply = Keithley_2612B(0, 24,'a')
    powerSupply.connect()

    # Parameters
    ivCurveTest                 = False  # Check if the IV curve is making sense (oxydation on the pads)
    opticalAlignmentInitial     = False # Check if the optical alignment is right
    thermalDrift                = False  # Measure the thermal drift         
    algoOn                      = False   # Do alignement tuning          

    #ivCurveTest                 = True  # Check if the IV curve is making sense (oxydation on the pads)
    #opticalAlignmentInitial     = True # Check if the optical alignment is right
    #thermalDrift                = True  # Measure the thermal drift         
    algoOn                      = True   # Do alignement tuning 



    from IVcurves import *
    from utils import *
    # Procedure
    ##  1) Place the DC probe on it's pads [MANUAL]
    ##  2) Test the DC probe for electrical conductivity before doing the test
    if ivCurveTest:
        acquireIVCurveMultiple([powerSupply], np.linspace(0, 2, 40), os.getcwd() + '\\measures\\Jan09\\IVCurve.pickle')
    
    ##  3) Align optically using the manual controls of the smarPod
    if opticalAlignmentInitial:
        if smarPod.connected:
            smarPod.disconnect()
        dummyPowerGauge()
        
    ##  4) Perform an optical alignment drift proc (should give the same result than last time)
    if thermalDrift:    
        measureAlignmentThermalDrift(LMS, powerSupply)
     ##  5) Perform auto alignment of the transposer with the code (manually set the voltage)
    if algoOn:
        randomWalk2(LMS, smarPod, .1)
        #command = randomWalk(LMS, smarPod, doPlot=False) - 1        # The command is the desired power value to be measured. The controller will attempt to reach that value
        #command = .009e-3
        #Kp      = 1000000#0.2  # proportionnal gain
        #Ki      = 0#5e-1     # integral gain
        #Kd      = 0#0.1     # differential gain
        #pidAutoEdgeXZ(LMS, smarPod, command, Kp, Ki, Kd)

     ##  6) Edit the parameters of the code in order to improve the performance of the algorithm [MANUAL]
     ##  7) Perform an optical alignment drift procedure with the algorithm on
    #measureAlignmentThermalDrift(mrf)
    #autoEdge(LMS, smarPod)
     ##  8) Done!

    #plotAutoEdgeXZ(os.getcwd() + '\\AE_2020-01-16@14_03_15.txt')

    print('Code Done!')
"""
Main code for the auto-alignment feature for the edge coupler.

Author : Simon Belanger-de Villers
Created : January 6th 2020
Last edited : January 6th 2020

"""

import matplotlib.pyplot as plt
import time

def autoEdge():
    """Feedback look for alignment of the edge coupler position."""

    # Parameters
    numberIterations    = 100                   # Number of iterations that will be performed
    actuatorON          = True                  # Perform control over the system with the actuator
    zPos                = hexapod.getZpos       # Initial Z position of the transposer

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
        ax1.set_ylabel('Z position [m]', color='r'); ax1.tick_params('y', colors='r')

        # Turn the laser on
        laser.output_on()

        # Feedback loop    
        for i in range(numberIterations):
            # time.sleep(0.2)

            hexapod.setPos(zPos)
            X = PD.measurePower()     # Measure the optical power before actuating -> X

            if actuatorON:    
                zPos += deltaZPos     # Increase the Z value of the transposer 

            hexapod.setPos(zPos)
            Y = PD.measurePower()     # Measure the optical power after actuating -> Y

            if Y>X:
                deltaZPos = -1 * deltaZPos

            # Actuate values
            iteration.append(i); power.append(Y); zPosition.append(zPos)

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
    
        # Save the data as text file
        np.savetxt('IQ_' + time.strftime("%Y-%m-%d@%H_%M_%S") + '.txt', (iteration, power, zPosition))

        # Turn the laser off
        laser.output_off()
        
    # To close the utilitary
    except KeyboardInterrupt:
        pass


import time
import matplotlib.pyplot as plt
import numpy as np
import os

def IQ_FBL(IQ, indexI, indexQ, d_indexI, d_indexQ, N_iter, I_on = True, Q_on = True, filter=True, filtertype="repeat average", count=3):
    """Feedback look for resonance alignment."""
    
    #Execute the code while no interruption
    try:
    
        # Configure options
        Iter = range(N_iter)
        Iteration, V_inI, I_outI, V_inQ, I_outQ = [], [], [], [], []
    
        # draw the plot
        fig, ax1, ax2, ax3, ax4 = draw_axes()
    
        # Open the DC sources and set the filters   
        IQ.I.SMU.output_on()
        IQ.Q.SMU.output_on()
        if filter==True:
            IQ.filter_on(count, filtertype)
        else:
            IQ.filter_off()
            
        # Feedback loop    
        for i in Iter:
    
        # time.sleep(0.2)
    
            X_I = IQ.I.measure_Id(indexI)     # Measure X
            X_Q = IQ.Q.measure_Id(indexQ)     # Measure X
    
            if I_on:    
                indexI += d_indexI            # Increase the voltage
            if Q_on:
                indexQ += d_indexQ            # Increase the voltage

            Y_I = IQ.I.measure_Id(indexI)     # Measure Y
            Y_Q = IQ.Q.measure_Id(indexQ)     # Measure Y

            if Y_I>X_I:
                d_indexI = -1 * d_indexI
            
            if Y_Q>X_Q:
                d_indexQ = -1 * d_indexQ  
            
            # Actuate values
            Iteration.append(i)
            V_inI.append(IQ.I.V[indexI])
            I_outI.append(Y_I*1e6)
            V_inQ.append(IQ.Q.V[indexQ])
            I_outQ.append(Y_Q*1e6)

            # Draw the plot
            ax1.plot(Iteration, V_inI, 'b') # Voltage I
            ax2.plot(Iteration, I_outI, 'r')# Current I
            ax3.plot(Iteration, V_inQ, 'b') # Voltage Q
            ax4.plot(Iteration, I_outQ, 'r')# CUrrent Q
            
            # Set the limits for the axes
            ax1.set_xlim([min(Iteration),max(Iteration)+1])
            if len(Iteration)>100:
                ax1.set_xlim([max(Iteration)-100,max(Iteration)])
            #ax1.set_ylim([min(V_inI),max(V_inI)])
            ax1.set_ylim([min(IQ.I.V),max(IQ.I.V)])
            ax2.set_ylim([min(I_outI)-1,max(I_outI)+1])
        
            ax3.set_xlim([min(Iteration),max(Iteration)+1])
            if len(Iteration)>100:
                ax3.set_xlim([max(Iteration)-100,max(Iteration)])
            #ax3.set_ylim([min(V_inQ),max(V_inQ)])
            ax3.set_ylim([min(IQ.Q.V),max(IQ.Q.V)])
            ax4.set_ylim([min(I_outQ)-1,max(I_outQ)+1])
            plt.pause(0.01)
        
            #Average
            ax1.cla(); ax2.cla(); ax3.cla(); ax4.cla()
            ax1.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(V_inI)),np.average(np.asarray(V_inI))], 'b--')
            ax2.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(I_outI)),np.average(np.asarray(I_outI))], 'r--')
            ax3.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(V_inQ)),np.average(np.asarray(V_inQ))], 'b--')
            ax4.plot([min(Iteration),max(Iteration)+1], [np.average(np.asarray(I_outQ)),np.average(np.asarray(I_outQ))], 'r--')
        
        fig.tight_layout()
        ax1.set_xlim([min(Iteration),max(Iteration)])
        ax3.set_xlim([min(Iteration),max(Iteration)])
        fig.show()
    
        # Save the data
        timestr = time.strftime("%Y-%m-%d@%H_%M_%S")
        np.savetxt('IQ_' + timestr + '.txt', (Iteration, V_inI, I_outI, V_inQ, I_outQ))
        
    # Save the data even if the program is closed    
    except KeyboardInterrupt:
        # Save the data
        timestr = time.strftime("%Y-%m-%d@%H_%M_%S")
        np.savetxt('IQ_' + timestr + '.txt', (Iteration, V_inI, I_outI, V_inQ, I_outQ))
        
def draw_axes():
    # Configure plot I
    fig, (ax1, ax3) = plt.subplots(nrows=2, sharex=True)
    ax1.set_title('I Tuning')
    ax3.set_title('Q Tuning')
    
    ax1.set_xlabel('Iteration')
    ax1.set_ylabel('Voltage [V]', color='b')
    ax1.tick_params('y', colors='b')
    ax2 = ax1.twinx()
    ax2.set_ylabel('Photocurrent [uA]', color='r')
    ax2.tick_params('y', colors='r')
    
    # Configure plot Q
    ax3.set_xlabel('Iteration')
    ax3.set_ylabel('Voltage [V]', color='b')
    ax3.tick_params('y', colors='b')
    ax4 = ax3.twinx()
    ax4.set_ylabel('Photocurrent [uA]', color='r')
    ax4.tick_params('y', colors='r')
        
    return fig, ax1, ax2, ax3, ax4
    

    
def average_measure_Id(MRR, index, count):
    l = []
    for i in range(count):
        l.append(MRR.measure_Id(index))
    return reduce(lambda x, y: x + y, l) / len(l)

def load_IQdat(filename):
    """Load a convergence plot from a previous experiment."""
    
    # draw the plot
    fig, ax1, ax2, ax3, ax4 = draw_axes()
    
    # Load the data from the text file
    Iteration, V_inI, I_outI, V_inQ, I_outQ = np.loadtxt(filename + '.txt')
    
    # Plot the data
    ax1.plot(Iteration, V_inI, 'b')
    ax2.plot(Iteration, I_outI, 'r')
    ax1.set_xlim([min(Iteration),max(Iteration)])
    ax1.set_ylim([min(V_inI),max(V_inI)])
    ax2.set_ylim([min(I_outI),max(I_outI)])
        
    ax3.plot(Iteration, V_inQ, 'b')
    ax4.plot(Iteration, I_outQ, 'r')
    ax3.set_xlim([min(Iteration),max(Iteration)])
    ax3.set_ylim([min(V_inQ),max(V_inQ)])
    ax4.set_ylim([min(I_outQ),max(I_outQ)])
    fig.tight_layout()
    fig.show()  
    
    plt.savefig(filename +  '.pdf')
    plt.close(fig)
    
def batch_IQdat(directory):

    for file in os.listdir(directory):
        if file.endswith(".txt"):
            load_IQdat(os.path.splitext(file)[0])
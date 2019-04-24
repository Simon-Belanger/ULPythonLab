"""
This file implements the sweepobj class.
This object is a Wavelength Sweep datafile containing all the relevant information fields and data fields to handle and archive.



Author : Simon Bélanger-de Villers
Date : April 18th 2019

"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import pickle
from pprint import pprint

class sweepobj(object):
    """
    Agilent Wavelength Sweep object datafile

    Contains several information fields:

    filename :
    aquisition date :
    device :
    chip name :
    detector_1_name :
    detector_2_name :
    wavelength_start :
    wavelength_stop :
    wavelength_step :
    info :

    Contains several data fields:

    wavelength :
    detector_1 :
    detector_2 :

    Extra :

    Normalisation data fields
    detector_1_norm:
    detector_2_norm:
    calibrated : (True or False)

    Visualisation params:
    xlims:
    ylims:

    """

    def __init__(self, filename=None):
        """ Constructor for the sweepobject class.

            If the filename is specified, the constructor will load the attributes of the datafile

            example : sweepobj(<filename>).show()
                this will plot the sweep contained in the datafile <filename>.pickle
        """

        if filename != None:
            self.load(filename)

    def load_from_textfile_agilent(self, filename):
        """ Open a textfile in the format it is save by the Agilent Mainframe and store the data in the
            sweepobject.
        """
        self.wavelength, self.detector_1, self.detector_2 = np.loadtxt(filename)

    def show(self):
        """ Plot the data in the sweepobject. """

        plt.figure(figsize=(10, 4))
        ax = plt.axes()
        ax.xaxis.set_major_locator(ticker.MultipleLocator(5))
        ax.xaxis.set_minor_locator(ticker.MultipleLocator(1))
        ax.yaxis.set_major_locator(ticker.MultipleLocator(10))
        ax.yaxis.set_minor_locator(ticker.MultipleLocator(2))
        ax.tick_params(which='major', direction='inout', length=8, width=2, colors='k',
                       labelsize=18, grid_alpha=0.5)
        ax.tick_params(which='minor', direction='in', length=4, width=1, colors='k',
                       labelsize=18, grid_alpha=0.5)

        plt.plot(self.wavelength * 1e9, self.detector_1, label="Through port", color="blue", linestyle='dashed')
        plt.plot(self.wavelength * 1e9, self.detector_2, label="Drop port", color="red")
        plt.xlabel("Wavelength [nm]", fontsize=18)
        plt.ylabel("Transmission [dB]", fontsize=18)
        plt.xlim(self.xlims)
        plt.ylim(self.ylims)
        # plt.legend(loc='upper right')
        plt.show()

    def save(self, filename):
        """ Save the content of a sweepobjct to a datafile. """

        outfile = open(filename +'.pickle', 'wb')
        pickle.dump(self.__dict__, outfile, 2)
        outfile.close()

    def load(self, filename):
        """ Load a sweepobject data from a datafile.

        """
        infile = open(filename +'.pickle', 'rb')
        tmp_dict = pickle.load(infile)
        infile.close()
        self.__dict__.update(tmp_dict)

    def info(self):
        """ Function that explicits all the parameters of the datafile. """

        pprint(self.__dict__, indent=2)


"""
Extra functions used by the previous instance of this code.
"""
def load_spectrum(filename):
    """Load the datafile."""
    wavelength, power_1, power_2 = np.loadtxt(filename)
    return wavelength, power_1, power_2

def plot_spectrum(wavelength, power_1, power_2):
    """Plot transmission data."""
    plt.figure(figsize=(10, 4))
    ax = plt.axes()
    ax.xaxis.set_major_locator(ticker.MultipleLocator(5))
    ax.xaxis.set_minor_locator(ticker.MultipleLocator(1))
    ax.yaxis.set_major_locator(ticker.MultipleLocator(10))
    ax.yaxis.set_minor_locator(ticker.MultipleLocator(2))
    ax.tick_params(which='major', direction='inout', length=8, width=2, colors='k',
                   labelsize=18, grid_alpha=0.5)
    ax.tick_params(which='minor', direction='in', length=4, width=1, colors='k',
                   labelsize=18, grid_alpha=0.5)

    plt.plot(wavelength*1e9, power_1, label="Through port", color="blue", linestyle='dashed')
    plt.plot(wavelength*1e9, power_2, label="Drop port", color="red")
    plt.xlabel("Wavelength [nm]", fontsize=18)
    plt.ylabel("Transmission [dB]", fontsize=18)
    plt.xlim([1515,1557])
    plt.ylim([-40,0])
    #plt.legend(loc='upper right')
    plt.show()

def load_and_plot(filename):
    """Load the datafile and plot the transmission from the data."""
    wavelength, power_1, power_2 = load_spectrum(filename)
    plot_spectrum(wavelength, power_1, power_2)

def normalise_data(filename, align_filename):
    """Normalise the data with alignment marks."""
    wavelength, power_1, power_2 = load_spectrum(filename)
    wavelength_align, power_1_align, power_2_align = load_spectrum(align_filename)
    plot_spectrum(wavelength, power_1-power_1_align, power_2-power_2_align)

def combine_alignment(align1_filename, align2_filename, merge_filename):
    """Combine both alignment marks."""
    #alignment mark 1
    wavelength, align1_det1, align1_det2 = load_spectrum(align1_filename)
    # alignment mark 2
    wavelength, align2_det1, align2_det2 = load_spectrum(align2_filename)
    # Combine and save
    np.savetxt(merge_filename,(wavelength, align1_det1, align2_det2))

def calibrate(calibration_sweepobj):
    """ Pass an input calibration sweepobject to the curent sweep datafile in order normalise the response."""

    # Interpolate the calibration data to the resolution of the sweep data points (resample the signal)
    pass


#TODO : Make a GUI for opening those files with a file explorer

if __name__ == "__main__":

    #1) load the raw data in textfile and save it as a sweepobj in a .pickle file
    sobj1 = sweepobj()
    sobj1.load_from_textfile_agilent('01 Passive_Response/alignment/02_1540_1560_0,001.txt')
    sobj1.device            = 'Alignment mark 2'
    sobj1.wavelength_start  = 154e-9
    sobj1.wavelength_stop   = 1560e-9
    sobj1.wavelength_step   = 0.001e-9
    sobj1.xlims             = [1540, 1560]
    sobj1.ylims             = [-80,-20]
    sobj1.info              = 'Spectrum of alignment mark #2 zoomed.'
    sobj1.show()
    sobj1.save('01 Passive_Response/alignment/pickle/align2_zoom')


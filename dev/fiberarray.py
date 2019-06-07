#TODO : Interaction with the lid and limitations due to it.
#TODO : Manage collisions between the fiber array and the chip (max angle)


import math
from matplotlib import pyplot as plt
from shapely.geometry.polygon import LinearRing, Polygon, LineString
from shapely import affinity
from matplotlib.widgets import Slider

class fiber_array(object):
    """ Class that implements a fiber array in order to calculate the array angle required for the right incidence angle
    to the grating coupler. 
    
    Simon Bélanger-de Villers
    August 2018

    Added graphical UI in June 2019
    """

    n_glass = 1.4       # Index of refraction of silica glass [-]
    n_air   = 1.        # Index of refraction of air [-]


    array_width     = 30    # Total thickness of the fiber array [µm]
    array_heigth    = 100   # Total height of the fiber array [µm]
    lid_thickness   = 10    # Thickness of the lid [µm]
    vertical_offset = 100    # Vertical offset between the corner of the top of the lid and the chip [µm]
    
    def __init__(self, name = "name", pol = 'TE', num_IO = 12, theta_offset = 330., theta_array = 10., theta_polish = 30., pitch = 127):
        self.name           = name
        self.pol            = pol
        self.num_IO         = num_IO
        self.pitch          = pitch

        self.theta_offset   = theta_offset
        self.theta_polish   = theta_polish # Between 0 and 45 degrees
        self.theta_array    = theta_array
        
        self.theta_refrac = self.theta_refrac()
        self.theta_inc_max = self.theta_incidence_max()

        self.theta_incidence = self.theta_array + self.theta_refrac
        
    def theta_refrac(self):
        """ Compute the refraction angle out of the fiber array the given polish angle and materials. """
        theta_refrac = math.degrees(math.asin((self.n_glass/self.n_air) * math.sin(math.radians(self.theta_polish)))) #- self.theta_polish
        return theta_refrac
    
    def measure_theta_array(self, theta_incidence):
        """ For a given incidence angle, compute the required array angle. """
        theta_array = theta_incidence - self.theta_refrac
        return theta_array
    
    def theta_incidence_max(self):
        """ Find the maximum allowable incidence angle for a given fiber polish. 
            Could find this geometrically using shapely also.
        """
        theta_inc_max = self.theta_polish + self.theta_refrac
        return theta_inc_max
    
    def measure_theta_measured(self, theta_incidence):
        """ For a given incidence angle, compute the required measured angle on the setup. """
        theta_measured = theta_incidence - self.theta_refrac + self.theta_offset
        return round(theta_measured,2)
    
    def measure_theta_incidence(self, theta_measured):
        """ For a given measured angle on the setup, compute the incidence angle on the chip. """
        theta_incidence = theta_measured - self.theta_offset + self.theta_refrac
        return theta_incidence

    def draw_shapes(self, axes):
        """ Draw the fiber array and the light ray from the fiber array to the chip. """
        
        # Build the fiber array from a rectangle with a polish angle (bevel)
        rect = Polygon([(0, 0), (self.array_width, 0), (self.array_width, self.array_heigth), (0, self.array_heigth)])
        bevel = Polygon([(0, 0), (self.array_width, 0), (0, self.array_width*math.tan(math.radians(self.theta_polish)))])
        if self.theta_polish != 0:
            far = rect.difference(bevel)
        else:
            far = rect
        far = affinity.rotate(far, self.theta_array, origin=(0, self.array_heigth)) # Rotate the array angle
        far = affinity.translate(far, yoff=self.vertical_offset) # Vertically offset the fiber array
        axes.plot(far.exterior.xy[0], far.exterior.xy[1], color="b")
        
        # Ray from the fiber
        ray = LineString([(self.array_width-self.lid_thickness, self.array_heigth), (self.array_width-self.lid_thickness, self.lid_thickness*math.tan(math.radians(self.theta_polish)))])
        ray = affinity.rotate(ray, self.theta_array,(0, self.array_heigth))
        ray = affinity.translate(ray, yoff=self.vertical_offset)
        axes.plot(ray.xy[0], ray.xy[1], color="r")
        
        # Ray free space
        ray2 = LineString([ray.coords[1], (ray.coords[1][0]+ray.coords[1][1]*math.tan(math.radians(self.theta_incidence)), 0)])
        axes.plot(ray2.xy[0], ray2.xy[1], color="r")
        
        # The chip
        chip = Polygon([(-100, 0), (100, 0), (100, -20), (-100, -20)])
        axes.plot(chip.exterior.xy[0], chip.exterior.xy[1], color="k")
        
        # Horizontal line
        hline = LineString([(0, self.array_heigth+self.vertical_offset), (0,-20)])
        axes.plot(hline.xy[0], hline.xy[1], color="k", linestyle="dashed")

    def show_util(self):

        fig, ax = plt.subplots()
        plt.subplots_adjust(left=0.25, bottom=0.35)

        ax.axis([-200, 200, -50, 200])

        ax_arrayangle = fig.add_axes([0.25, 0.25, 0.65, 0.03]) # [left, bottom, width, height] 
        ax_polishangle = fig.add_axes([0.25, 0.15, 0.65, 0.03]) 
        ax_verticaloff = fig.add_axes([0.25, 0.05, 0.65, 0.03]) 
        s_arrayangle = Slider(ax_arrayangle, 'Array\n angle [°]', 0, 30, valinit=self.theta_array)
        s_polishangle = Slider(ax_polishangle, 'Polish\n angle [°]', 0, 45, valinit=self.theta_polish)
        s_verticaloff = Slider(ax_verticaloff, 'Vertical\n offset [µm]', -100, 100, valinit=self.vertical_offset)

        self.draw_shapes(ax)

        def update(val):
            self.theta_array = s_arrayangle.val 
            self.theta_polish = s_polishangle.val 
            self.vertical_offset = s_verticaloff.val 
            self.draw_shapes(ax)
            del ax.lines[0:-6]
            fig.canvas.draw()

        s_arrayangle.on_changed(update)
        s_polishangle.on_changed(update)
        s_verticaloff.on_changed(update)

        plt.show()



    def __repr__(self):
        log = """Fiber Array object with properties:
        name : %s
        polarization : %s
        number of I/O : %d
        pitch : %d um
        polish angle : %2.2f deg
        array offset angle : %3.2f deg
        maximum incidence angle : %2.2f deg
        """ % (self.name, self.pol, self.num_IO, self.pitch, self.theta_polish, self.theta_offset, self.theta_inc_max)
        return log

if __name__ == '__main__':

    far = fiber_array(name = "Aeponyx_24", theta_array = 0., theta_polish = 0.)
    print(far)

    far.show_util()

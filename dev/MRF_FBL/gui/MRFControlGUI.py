# GUI used to control the MRF (and eventually the 4-channels ROADM) made with Tkinter

from tkinter import *
import visa

class MRFGUI:
    def __init__(self, master):
        self.master = master
        master.title("Microring control window")

        # Make gui appear in middle of screen
        w = 580 # width for the Tk root
        h = 480 # height for the Tk root
        ws = master.winfo_screenwidth() # width of the screen
        hs = master.winfo_screenheight() # height of the screen
        x = (ws/2) - (w/2)
        y = (hs/2) - (h/2)
        master.geometry('%dx%d+%d+%d' % (w, h, x, y))

        # Enable up to 5 phase shifters
        self.CheckVar = [IntVar() for i in range(5)]
        self.check_button1 = Checkbutton(master, text="Actuator 1", \
         variable=self.CheckVar[0], command=self.test)
        self.check_button1.pack()
        listbox1 = Listbox(master)
        listbox1.pack()
        listbox1.insert(END, "a list entry")

        for item in ["one", "two", "three", "four"]:
            listbox1.insert(END, item)

        self.check_button2 = Checkbutton(master, text="Actuator 2", \
            variable=self.CheckVar[1], command=self.test)
        self.check_button2.pack()

        self.check_button3 = Checkbutton(master, text="Actuator 3", \
            variable=self.CheckVar[2], command=self.test)
        self.check_button3.pack()

        self.check_button4 = Checkbutton(master, text="Actuator 4", \
            variable=self.CheckVar[3], command=self.test)
        self.check_button4.pack()

        self.check_button5 = Checkbutton(master, text="Actuator 5", \
            variable=self.CheckVar[4], command=self.test)
        self.check_button5.pack()

        # 

        self.greet_button = Button(master, text="Greet", command=self.get_list_gpib)
        self.greet_button.pack()

        self.close_button = Button(master, text="Close", command=master.quit)
        self.close_button.pack()

    def test(self):
        print("Testing!")

    def get_list_gpib(self):
        """
        Produce a list of all the connected components addresses
        """

        rm = visa.ResourceManager()
        
        for i in rm.list_resources():
            try:
                x = rm.open_resource(i)
                print(i + "\n" + x.query('*IDN?'))
            except visa.VisaIOError:
                print(i + "\n" + "Name not found"+ "\n")

root = Tk()
my_gui = MRFGUI(root)
root.mainloop()
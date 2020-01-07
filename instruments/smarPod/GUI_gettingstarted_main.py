#!/usr/bin/env python
# -*- coding: utf-8 -*-

# import tkinter as tk
# import webbrowser
#
#
# class MainAppView(tk.Frame):
#     """Encapsulates of all the GUI logic.
#
#     Attributes:
#         master: where to open the Frame, by deafult root window
#         title: Main Label
#
#         one: Button
#         two: Button
#         three: Button
#     """
#
#     def start_gui(self, ok=True):
#         """Starts the GUI, if everything ok , to change
#         """
#
#         if ok:
#             self.mainloop()
#         else:
#             self.master.destroy()
#
#     def createWidgets(self):
#         """Create the set of initial widgets.
#
#         """
#
#         # Create the label
#
#         self.title = tk.Label(
#             self, text=" What's up ?")
#         self.title.grid(
#             row=0, column=0, columnspan=4, sticky=tk.E + tk.W)
#
#         # Create the three buttons
#
#         self.one = tk.Button(self)
#         self.one["text"] = "Task 1"
#         self.one.grid(row=1, column=0)
#
#         self.two = tk.Button(self)
#         self.two["text"] = "Task 2"
#         self.two.grid(row=1, column=1)
#
#         self.three = tk.Button(self)
#         self.three["text"] = "Task 3"
#         self.three.grid(row=1, column=2)
#
#         self.four = tk.Button(self)
#         self.four["text"] = "Task 4"
#         self.four.grid(row=1, column=3)
#
#     def __init__(self, master=None):
#         tk.Frame.__init__(self, master)
#         self.grid()
#         # option is needed to put the main label in the window
#
#
#         self.createWidgets()
#
#
# ########################################################################################################################
# # from MainAppView import MainAppView
#
#
# class MainAppController(object):
#     def nothing(self):
#         pass
#
#     def init_view(self, root):
#         """Initializes GUI view
#             In addition it bindes the Buttons with the callback methods.
#
#         """
#         self.view = MainAppView(master=root)
#
#         # Bind buttons with callback methods
#         self.view.one["command"] = self.nothing
#         self.view.two["command"] = self.nothing
#         self.view.three["command"] = self.nothing
#         self.view.four["command"] = self.nothing
#
#         # Start the gui
#
#
#         self.view.start_gui()
#
# ########################################################################################################################
#
# def main():
#
#     controller = MainAppController()
#
#     # Build Gui and start it
#     root = tk.Tk()
#     root.title('Main Application')
#
#     controller.init_view(root)
#
#
#     print('Bye Bye')
#
#
#
# if __name__ == "__main__":
#     main()
#########################################################################################################################
#########################################################################################################################

#
# from tkinter import *
# """A button - what can we do with it?
# Well lets make it change the colour of the text label
# and change the style of the button when it is pressed"""
#
# class OnOffButton(Button):
#     def __init__(self,master=None,onText=None,offText=None):
#         self.onText = onText
#         self.offText = offText
#         Button.__init__(self,master,text=self.offText)
#         self['command'] = self._onButtonClick
#         self['width'] = max(len(self.onText),len(self.offText))
#     def _onButtonClick(self):
#         """This method is called when the start button is pressed.
#         If the button colour is the default, set it to red and sink the button
#         Otherwise set it to the default again and raise the button"""
#         if self['fg'] == "SystemButtonText":
#             self['fg'] = "red"
#             self['relief'] = "sunken"
#             self['text'] = self.onText
#         else:
#             self['fg'] = "SystemButtonText"
#             self['relief'] = "raised"
#             self['text'] = self.offText
#
# class App(Frame):
#     """Our Application. We inherit all the properties
#     and methods of a Tkinter Frame"""
#     def __init__(self,master=None):
#         Frame.__init__(self,master)
#         self.lblHello = Label(self,text="Hello World")
#         self.lblHello['fg'] = "red"
#         self.lblHello.grid()
#         self.btnStart = OnOffButton(self,onText="Click Me Again",offText="Click Me")
#         self.btnStart.grid()
#         self.btn2 = OnOffButton(self,onText="Disable",offText="Enable")
#         self.btn2.grid()
#
# def main():
#     root = Tk()
#     app = App(master=root)
#     app.grid()
#
# """This is the code that is executed by python when we run this .py file"""
# if __name__ == '__main__':
#     main()

#########################################################################################################################
########################################################################################################################
import tkinter as root


class Dashboard():
    def __init__(self, title, length, breadth):
        self.window = root.Tk()
        self.window.title(title)

        # get screen width and height
        ws = self.window.winfo_screenwidth()
        hs = self.window.winfo_screenheight()
        # calculate position x, y
        x = (ws / 2) - (length / 2)
        y = (hs / 2) - (breadth / 2)
        self.window.geometry('%dx%d+%d+%d' % (length, breadth, x, y))

        # To show the main window with widget like checkbox, buttons etc.

    def Display(self, choice=True):
        self.window.mainloop()
        return()

Dashboard('allo',1,1)

Dashboard.Display
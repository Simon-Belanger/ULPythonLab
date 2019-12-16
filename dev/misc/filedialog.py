from tkinter import *
from tkinter import filedialog

root = Tk()
root.filename = filedialog.askopenfilename(initialdir="/", title="Select file", filetypes=[('txt', '*.txt')])
print(root.filename)
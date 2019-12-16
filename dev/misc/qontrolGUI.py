"""
GUI for the Qontrol that allows to manually control the device instead of writing code.

Author      : Simon Bélanger-de Villers
Created     : July 31st 2019
Last Edited : July 31st 2019
"""
import sys
from PyQt5 import QtWidgets

class QontrolGUI(QtWidgets.QMainWindow):

    def __init__(self, parent=None):
        super(QontrolGUI, self).__init__(parent)

        window = QtWidgets.QWidget()

        # Text label widget
        label = QtWidgets.QLabel('Serial address : ')

        # Combo box widget
        self.cb = QtWidgets.QComboBox()
        self.cb.addItems(self.listSerialPorts())

        # Button widget
        but = QtWidgets.QPushButton('Connect')
        but.clicked.connect(self.selectSerialPort)

        # Layout containing the serial label, combobox and button
        serialLayout = QtWidgets.QHBoxLayout()
        serialLayout.addWidget(label)
        serialLayout.addWidget(self.cb)
        serialLayout.addWidget(but)
        print(serialLayout)

        window.setLayout(serialLayout)

        self.setCentralWidget(window)

    def listSerialPorts(self):
        " List all serial ports on this computer. "

        from serial.tools.list_ports import comports

        listPorts = []
        for ports in comports():
            listPorts.append(ports.device)
        return listPorts

    def selectSerialPort(self):

        from qontrol import QXOutput
        
        try:
            self.q = QXOutput(serial_port_name = str(self.cb.currentText()), response_timeout = 0.1)
        except RuntimeError:
            pass






if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    qg = QontrolGUI()
    qg.show()
    app.exec_()
    
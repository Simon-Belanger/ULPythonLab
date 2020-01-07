import wx

import SmarPodClass
import SmarPodFrame
import visa
import ctypes

# Panel in the Connect Instruments window which contains the connection settings for the Corvus Eco.
class SmarPodParameters(wx.Panel):
    name = 'Stage: SmarPod'

    def __init__(self, parent, connectPanel, **kwargs):
        super(SmarPodParameters, self).__init__(parent)
        self.connectPanel = connectPanel
        self.InitUI()


    def InitUI(self):
        sb = wx.StaticBox(self, label='SmarPod Connection Parameters');
        vbox = wx.StaticBoxSizer(sb, wx.VERTICAL)
        hbox = wx.BoxSizer(wx.HORIZONTAL)

        # First Parameter: Serial Port
        self.para1 = wx.BoxSizer(wx.HORIZONTAL)
        self.para1name = wx.StaticText(self, label='Serial Port')
        # self.para1tc = wx.ComboBox(self, choices=visa.ResourceManager().list_resources())
        self.para1tc = wx.TextCtrl(self, value="network:192.168.1.200:5000")
        self.para1.AddMany(
            [(self.para1name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para1tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # Second Parameter: Number of Axis
        self.para2 = wx.BoxSizer(wx.HORIZONTAL)
        self.para2name = wx.StaticText(self, label='Number of Axis')
        self.para2tc = wx.TextCtrl(self, value='6')
        self.para2.AddMany(
            [(self.para2name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para2tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 3e Parameter: Securty distance
        self.para3 = wx.BoxSizer(wx.HORIZONTAL)
        self.para3name = wx.StaticText(self, label=' Security distance [um]')
        self.para3tc = wx.TextCtrl(self, value='0')
        self.para3.AddMany(
            [(self.para3name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para3tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 4e Parameter: Max Freq
        self.para4 = wx.BoxSizer(wx.HORIZONTAL)
        self.para4name = wx.StaticText(self, label='Maximal Frequency  [Hz]')
        self.para4tc = wx.TextCtrl(self, value='18500')
        self.para4.AddMany(
            [(self.para4name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para4tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 5e Parameter: Speed
        self.para5 = wx.BoxSizer(wx.HORIZONTAL)
        self.para5name = wx.StaticText(self, label= 'Speed  [m/s]')
        self.para5tc = wx.TextCtrl(self, value='0.002')
        self.para5.AddMany(
            [(self.para5name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para5tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 6e Parameter: Acceleration
        self.para6 = wx.BoxSizer(wx.HORIZONTAL)
        self.para6name = wx.StaticText(self, label= 'Acceleration  [m/s]')
        self.para6tc = wx.TextCtrl(self, value='0.5')
        self.para6.AddMany(
            [(self.para6name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para6tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 7e Parameter: Pivot
        self.para7 = wx.BoxSizer(wx.HORIZONTAL)
        self.para7name = wx.StaticText(self, label= 'Pivot [m]')
        self.para7tc = wx.ComboBox(self, choices=['SMARPOD_PIVOT_RELATIVE','SMARPOD_PIVOT_FIXED'])
        self.para7.AddMany(
            [(self.para7name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para7tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 8e Parameter: Calibration
        self.para8 = wx.BoxSizer(wx.HORIZONTAL)
        self.para8name = wx.StaticText(self, label= 'Calibration')
        # self.para8tc = wx.StaticText(self, choices=['Yes', 'No'])
        self.para8tc = wx.ComboBox(self, choices=['Yes','No'])
        self.para8.AddMany(
            [(self.para8name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para8tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])

        # 9e Parameter: model
        self.S =SmarPodClass.SmarPodClass()
        self.para9 = wx.BoxSizer(wx.HORIZONTAL)
        self.para9name = wx.StaticText(self, label='Model' )
        self.para9tc = wx.StaticText(self, label= 'Model:'+str(self.S.model)+'      ' + 'Name:' + str(self.S.name) )
        # self.para9tc = wx.ComboBox(self, choices=['Yes','No'])
        self.para9.AddMany(
            [(self.para9name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para9tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])


        self.disconnectBtn = wx.Button(self, label='Disconnect')
        self.disconnectBtn.Bind(wx.EVT_BUTTON, self.disconnect)
        self.disconnectBtn.Disable()

        self.connectBtn = wx.Button(self, label='Connect')
        self.connectBtn.Bind(wx.EVT_BUTTON, self.connect)

        hbox.AddMany([(self.disconnectBtn, 0, wx.ALIGN_RIGHT), (self.connectBtn, 0, wx.ALIGN_RIGHT)])
        vbox.AddMany([(self.para1, 0, wx.EXPAND), (self.para2, 0, wx.EXPAND), (self.para3, 0, wx.EXPAND), (self.para4, 0, wx.EXPAND),
                      (self.para5, 0, wx.EXPAND),(self.para6, 0, wx.EXPAND), (self.para7, 0, wx.EXPAND), (self.para8, 0, wx.EXPAND), (self.para9, 0, wx.EXPAND), (hbox, 0, wx.ALIGN_BOTTOM)])

        self.SetSizer(vbox)

    def connect(self, event):
        self.stage = SmarPodClass.SmarPodClass()
        self.sensor_mode = self.stage.SMARPOD_SENSORS_ENABLED
        pivot = {}
        pivot['SMARPOD_PIVOT_RELATIVE'] = self.stage.SMARPOD_PIVOT_RELATIVE
        pivot['SMARPOD_PIVOT_FIXED'] = self.stage.SMARPOD_PIVOT_FIXED
        calibration = {'Yes':1, 'No':0}
        speed = float(self.para5tc.GetValue())
        acc = float(self.para6tc.GetValue())
        # self.stage.connect(str(self.para1tc.GetValue()), visa.ResourceManager(), 5, 500, self.sensor_mode,8000)  # int(self.para2tc.GetValue()))
        self.stage.connect(str(self.para1tc.GetValue()), speed, acc, self.sensor_mode, self.para4tc.GetValue(), pivot[str((self.para7tc.GetValue()))], calibration[str((self.para8tc.GetValue()))]) #int(self.para2tc.GetValue()))
        self.stage.panelClass = SmarPodFrame.topSmarpodPanel
        self.connectPanel.instList.append(self.stage)
        self.disconnectBtn.Enable()
        self.connectBtn.Disable()

    def disconnect(self, event):
        self.stage.disconnect()
        if self.stage in self.connectPanel.instList:
            self.connectPanel.instList.remove(self.stage)
        self.disconnectBtn.Disable()
        self.connectBtn.Enable()

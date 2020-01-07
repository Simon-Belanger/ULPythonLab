
import wx
import ctypes

# Panel that appears in the main window which contains the controls for the Corvus motor.
class topSmarpodPanel(wx.Panel):
    def __init__(self, parent, motor):
        super(topSmarpodPanel, self).__init__(parent)
        self.motor = motor
        self.maxaxis = motor.NumberOfAxis+1
        self.InitUI()
        # POS = motor.Pos

    def InitUI(self):
        sb = wx.StaticBox(self, label='SmarPod');
        vbox = wx.StaticBoxSizer(sb, wx.VERTICAL)
        btnStop = wx.Button(self, label='Stop', size=(50, 20))
        vbox.Add(btnStop, proportion=0, flag=wx.EXPAND | wx.ALIGN_RIGHT, border=8)
        btnStop.Bind(wx.EVT_BUTTON, self.stopsmarpod)
        self.SetSizer(vbox)

        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox1 = wx.BoxSizer(wx.HORIZONTAL)




        # hbox1.AddMany([(st1, 1, wx.EXPAND), (self.Setparam, 1, wx.EXPAND)])
        # st1 = wx.StaticText(self, label='Set')
        self.Setparam = wx.Button(self, label='Set', size=(50, 20))
        self.Setparam.Bind(wx.EVT_BUTTON, self.Setalign)
        self.para7 = wx.BoxSizer(wx.VERTICAL)
        self.para7name = wx.StaticText(self, label='Align method')
        self.para7tc = wx.ComboBox(self, choices=['PosXY', 'PosOXOZ','PosOXOY'])
        self.para7.AddMany([(self.para7name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para7tc, 1, wx.EXPAND | wx.ALIGN_CENTER),(self.Setparam, 1, wx.EXPAND | wx.ALIGN_LEFT)])

        # st2 = wx.StaticText(self, label='Set')
        self.Setparam2 = wx.Button(self, label='Set', size=(50, 20))
        self.Setparam2.Bind(wx.EVT_BUTTON, self.Setspeed)
        self.para5 = wx.BoxSizer(wx.VERTICAL)
        self.para5name = wx.StaticText(self, label='Speed  [m/s]')
        self.para5tc = wx.TextCtrl(self, value='0.002')
        self.para5.AddMany([(self.para5name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para5tc, 1, wx.EXPAND | wx.ALIGN_CENTER),(self.Setparam2, 1, wx.EXPAND | wx.ALIGN_LEFT)])


        # st3 = wx.StaticText(self, label='Set')
        self.Setparam3 = wx.Button(self, label='Set', size=(50, 20))
        self.Setparam3.Bind(wx.EVT_BUTTON, self.setpivot)

        self.para3 = wx.BoxSizer(wx.VERTICAL)
        self.para3n = wx.BoxSizer(wx.HORIZONTAL)
        self.para3name = wx.StaticText(self, label='Px')
        self.para33name = wx.StaticText(self, label='Py')
        self.para333name = wx.StaticText(self, label='Pz')
        self.para3v = wx.BoxSizer(wx.HORIZONTAL)
        self.para3tc = wx.TextCtrl(self, value='-466.884')
        self.para33tc = wx.TextCtrl(self, value='20633.60')
        self.para333tc = wx.TextCtrl(self, value='4988.999')
        self.para3v.AddMany([(self.para3tc, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para33tc, 1, wx.EXPAND | wx.ALIGN_CENTER),(self.para333tc, 1, wx.EXPAND | wx.ALIGN_LEFT)])
        self.para3n.AddMany([(self.para3name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para33name, 1, wx.EXPAND | wx.ALIGN_CENTER),(self.para333name, 1, wx.EXPAND | wx.ALIGN_LEFT)])
        self.para3.AddMany([(self.para3n, 1, wx.EXPAND), (self.para3v, 1, wx.EXPAND), (self.Setparam3, 1, wx.EXPAND)])


        vbox.AddMany([(self.para5, 0, wx.EXPAND),(self.para7, 0, wx.EXPAND), (self.para3, 0, wx.EXPAND)])
        hbox.AddMany([(self.Setparam, 0, wx.ALIGN_RIGHT)])
        self.SetSizer(vbox)
        axis = 1
        for motorCtrl in range(axis, self.maxaxis):
            motorPanel = SmarPodPanel(self, motorCtrl, axis)
            motorPanel.motor = self.motor
            vbox.Add(motorPanel, flag=wx.LEFT | wx.TOP | wx.ALIGN_LEFT, border=0, proportion=0)
            vbox.Add((-1, 2))
            sl = wx.StaticLine(self)
            vbox.Add(sl, flag=wx.EXPAND, border=0, proportion=0)
            vbox.Add((-1, 2))
            axis = axis + 1

        self.SetSizer(vbox)


    def Setspeed(self, event):
            self.motor.setVelocity(float(self.para5tc.GetValue()))

    def Setalign(self, event):
        align = {}
        align['PosXY'] = 0
        align['PosOXOZ'] = 1
        align['PosOXOY'] = 2
        self.motor.alignOption(align[self.para7tc.GetValue()])

    def stopsmarpod(self,event):
        self.motor.stopSmarpod

    def setpivot(self,event):
        self.motor.setPivot(float(self.para3tc.GetValue()), float(self.para333tc.GetValue()),float(self.para33tc.GetValue()))


class SmarPodPanel(wx.Panel):
    def __init__(self, parent, motorCtrl, axis):
        super(SmarPodPanel, self).__init__(parent)
        self.motorCtrl = motorCtrl;
        self.axis = axis;
        self.InitUI()

    def InitUI(self):
        hbox = wx.BoxSizer(wx.HORIZONTAL)
        st1 = wx.StaticText(self, label='Motor Control')#+' '+ Pos[self.axis-1])
        hbox.Add(st1, flag=wx.ALIGN_LEFT, border=8)
        st1 = wx.StaticText(self, label='')
        hbox.Add(st1, flag=wx.EXPAND, border=8, proportion=1)
        btn1 = wx.Button(self, label='-', size=(20, 20))
        hbox.Add(btn1, flag=wx.EXPAND | wx.RIGHT, proportion=0, border=8)
        btn1.Bind(wx.EVT_BUTTON, self.OnButton_MinusButtonHandler)

        self.tc = wx.TextCtrl(self, value='0')  #str(self.axis))  # change str(self.axis) to '0'
        hbox.Add(self.tc, proportion=2, flag=wx.EXPAND)

        st1 = wx.StaticText(self, label='um')
        hbox.Add(st1, flag=wx.ALIGN_LEFT, border=8)

        btn2 = wx.Button(self, label='+', size=(20, 20))
        hbox.Add(btn2, proportion=0, flag=wx.EXPAND | wx.LEFT | wx.RIGHT, border=8)
        btn2.Bind(wx.EVT_BUTTON, self.OnButton_PlusButtonHandler)
        self.SetSizer(hbox);

        # sb = wx.StaticBox(self, label='SmarPod Connection Parameters');
        # vbox = wx.StaticBoxSizer(sb, wx.VERTICAL)
        # self.para5 = wx.BoxSizer(wx.HORIZONTAL)
        # self.para5name = wx.StaticText(self, label= 'Speed  [m/s]')
        # self.para5tc = wx.TextCtrl(self, value='0.002')
        # self.para5.AddMany(
        #     [(self.para5name, 1, wx.EXPAND | wx.ALIGN_LEFT), (self.para5tc, 1, wx.EXPAND | wx.ALIGN_RIGHT)])
        # vbox.AddMany([self.para5, 0, wx.EXPAND])
        # self.SetSizer(vbox);


    def getMoveValue(self):
        try:
            val = float(self.tc.GetValue());
        except ValueError:
            self.tc.SetValue('0');
            return 0.0;
        return val;

    def OnButton_MinusButtonHandler(self, event):

        if self.axis == 1:
            self.motor.moveAbsoluteXY(-1 *(self.getMoveValue()),0,0,0,0,0)
            print("Axis X Moved")

        if self.axis == 2:
            self.motor.moveAbsoluteXY(0,-1* self.getMoveValue(),0,0,0,0)
            print("Axis Y Moved")
        if self.axis == 3:
            self.motor.moveAbsoluteXY(0,0,-1* self.getMoveValue(),0,0,0)
            print("Axis Z Moved")
        if self.axis == 4:
                self.motor.moveAbsoluteXY(0,0,0,-1* self.getMoveValue(),0,0)
                print("Angle Theta OX Moved")
        if self.axis == 5:
                self.motor.moveAbsoluteXY(0,0,0,0,-1* self.getMoveValue(),0)
                print("Angle Theta OY Moved")
        if self.axis == 6:
                self.motor.moveAbsoluteXY(0,0,0,0,0,-1*self.getMoveValue())
                print("Angle Theta OZ Moved")

    def OnButton_PlusButtonHandler(self, event):
        if self.axis == 1:
            self.motor.moveAbsoluteXY(self.getMoveValue(),0,0,0,0,0)
            print("Axis X Moved")
        if self.axis == 2:
            self.motor.moveAbsoluteXY(0,self.getMoveValue(),0,0,0,0)
            print("Axis Y Moved")
        if self.axis == 3:
            self.motor.moveAbsoluteXY(0,0,self.getMoveValue(),0,0,0)
            print("Axis Z Moved")
        if self.axis == 4:
            self.motor.moveAbsoluteXY(0,0,0,self.getMoveValue(),0,0)
            print("Angle Theta OX Moved")
        if self.axis == 5:
            self.motor.moveAbsoluteXY(0,0,0,0,self.getMoveValue(),0)
            print("Angle Theta OY Moved")
        if self.axis == 6:
            self.motor.moveAbsoluteXY(0,0,0,0,0,self.getMoveValue())
            print("Angle Theta OZ Moved")
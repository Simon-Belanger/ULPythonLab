
from __future__ import division
import time
import ctypes
from ctypes import *
import sys
import visa
import matplotlib.pyplot as plt
import numpy as np
import time
from func import*
# from Smarpod_status import*

class SmarPodStatus:
    def status(self, i):
        self.statuscode = {}
        self.statuscode[0] = "SMARPOD_OK"
        self.statuscode[1] = "SMARPOD_OTHER_ERROR"
        self.statuscode[2] = "SMARPOD_SYSTEM_NOT_INITIALIZED_ERROR"
        self.statuscode[3] = "SMARPOD_NO_SYSTEMS_FOUND_ERROR"
        self.statuscode[4] = "SMARPOD_INVALID_PARAMETER_ERROR"
        self.statuscode[5] = "SMARPOD_COMMUNICATION_ERROR"
        self.statuscode[6] = "SMARPOD_UNKNOWN_PROPERTY_ERROR"
        self.statuscode[7] = "SMARPOD_RESOURCE_TOO_OLD_ERROR"
        self.statuscode[8] = "SMARPOD_FEATURE_UNAVAILABLE_ERROR"
        self.statuscode[9] = "SMARPOD_INVALID_SYSTEM_LOCATOR_ERROR"
        self.statuscode[10] = "SMARPOD_QUERYBUFFER_SIZE_ERROR"
        self.statuscode[11] = "SMARPOD_COMMUNICATION_TIMEOUT_ERROR"
        self.statuscode[12] = "SMARPOD_DRIVER_ERROR"
        self.statuscode[500] = "SMARPOD_STATUS_CODE_UNKNOWN_ERROR"
        self.statuscode[501] = "SMARPOD_INVALID_ID_ERROR"
        self.statuscode[502] = "SMARPOD_INITIALIZED_ERROR"
        self.statuscode[503] = "SMARPOD_HARDWARE_MODEL_UNKNOWN_ERROR"
        self.statuscode[504] = "SMARPOD_WRONG_COMM_MODE_ERROR"
        self.statuscode[505] = "SMARPOD_NOT_INITIALIZED_ERROR"
        self.statuscode[506] = "SMARPOD_INVALID_SYSTEM_ID_ERROR"
        self.statuscode[507] = "SMARPOD_NOT_ENOUGH_CHANNELS_ERROR"
        self.statuscode[508] = "SMARPOD_INVALID_CHANNEL_ERROR"
        self.statuscode[509] = "SMARPOD_CHANNEL_USED_ERROR"
        self.statuscode[510] = "SMARPOD_SENSORS_DISABLED_ERROR"
        self.statuscode[511] = "SMARPOD_WRONG_SENSOR_TYPE_ERROR"
        self.statuscode[512] = "SMARPOD_SYSTEM_CONFIGURATION_ERROR"
        self.statuscode[513] = "SMARPOD_SENSOR_NOT_FOUND_ERROR"
        self.statuscode[514] = "SMARPOD_STOPPED_ERROR"
        self.statuscode[515] = "SMARPOD_BUSY_ERROR"
        self.statuscode[550] = "SMARPOD_NOT_REFERENCED_ERROR"
        self.statuscode[551] = "SMARPOD_POSE_UNREACHABLE_ERROR"
        self.statuscode[552] = "SMARPOD_COMMAND_OVERRIDDEN_ERROR"
        self.statuscode[553] = "SMARPOD_ENDSTOP_REACHED_ERROR"
        self.statuscode[554] = "SMARPOD_NOT_STOPPED_ERROR"
        self.statuscode[555] = "SMARPOD_COULD_NOT_REFERENCE_ERROR"
        self.statuscode[556] = "SMARPOD_COULD_NOT_CALIBRATE_ERROR"
        self.statuscode[1001] = "NOT CONNECTED"
        return self.statuscode[i]
class SmarPodPosition(Structure):
    _fields_ = [("positionX", c_double),
                ("positionY", c_double),
                ("positionZ", c_double),
                ("rotationX", c_double),
                ("rotationZ", c_double),
                ("rotationZ", c_double)
                ]

class SmarPodClass(SmarPodPosition, SmarPodStatus):
    NumberOfAxis = 6  # default the axis number @ 3 just in case.
    name = 'SmarPod'
    isMotor = True
    isLaser = False
    PosXY = {0: 'X', 1: 'Z', 2: 'Y', 3: 'OX', 4: 'OY', 5: 'OZ'}
    PosOXOZ = {0: 'OX', 1: 'OZ', 2: 'Z', 3: 'X', 4: 'OY', 5: 'Y'}
    PosOXOY = {0: 'OX', 1: 'OY', 2: 'Z', 3: 'X', 4: 'OZ', 5: 'Y'}
    # PosYOY = {0: 'Y', 1: 'OY', 2: 'Z', 3: 'X', 4: 'OZ', 5: 'Y'}

    def __init__(self,libraryDLL = 'lib\SmarPod.dll', LocatorAddress = "usb:id:1337339"):
        self.unit = {'nm': 1e-9, 'um': 1e-6, 'mm': 1e-3, 'm': 1e0}
        self.unitCoef = self.unit['um']


        # vars()[Pos[0]]=

        # self.id.value = id
        self.lib = np.ctypeslib.load_library(libraryDLL,'.')
        # self.lib = Windll(libraryDLL)
        self.loc = LocatorAddress
        self.loc_str = self.loc.encode('utf-8')
        self.loc_buffer = create_string_buffer(self.loc_str)
        self.createPrototypes()
        self.smarpodInfo()
        # self.MakeSeq()
        self.name,self.model,self.dll = self.smarpodInfo()
        self.connected = False
        self.holdtime = c_uint32(60000)  #self.SMARPOD_HOLDTIME_INFINITE
        self.waitForCompletion = c_uint32(1)
        self.err = ()

        self.id = c_uint32()
        self.id_p = pointer(self.id)
    def connect(self, Velocity, acceleration, SensorMode, MaxFreq, pivotmode, calibration):
        self.err = self.Smarpod_Open(self.id_p, c_uint32(10001), self.loc_buffer, " ")
        #self.alignOption(0)
        # SmarPodClass().__setattr__('self.id.value', id.value)
        # self.id.value = self.id.valued
        # print('Smarpod Connected \n')
        #self.alignO#ption(0)
        print(self.status(self.err))
        if self.status(self.err) != "SMARPOD_OK":
            self.showStatus()
        else:
            self.err = self.setSensorMode(SensorMode)
            if self.status(self.err) != "SMARPOD_OK":
                self.showStatus()
            else:
                self.err = self.setMaxFrequency(MaxFreq)
                if self.status(self.err) != "SMARPOD_OK":
                    self.showStatus()
                else:
                    self.err = self.setVelocity(Velocity)
                    if self.status(self.err) != "SMARPOD_OK":
                        self.showStatus()
                    else:
                        self.err = self.setAcceleration(acceleration)
                        self.err = self.setPivot(-466.884, 4988.999, 20633.60)
                        print('Smarpod Connected \n')
                        if calibration == 1:
                            self.err = self.setCalibration()
                            if self.status(self.err) != "SMARPOD_OK":
                                    self.showStatus()
                                    return
                            self.err = self.setReferenceMarks()
                            if self.status(self.err) != "SMARPOD_OK":
                                    self.showStatus()
                                    return

                        else:
                                     print('Smarpod Calibrate')
        return self.err
    def alignOption(self, opt):
        PosOption = [self.PosXY, self.PosOXOZ, self.PosOXOY]
        self.Pos = PosOption[opt]
        self.P0 = self.Pos.values().index('X')
        self.P1 = self.Pos.values().index('Y')
        self.P2 = self.Pos.values().index('Z')
        self.P3 = self.Pos.values().index('OX')
        self.P4 = self.Pos.values().index('OY')
        self.P5 = self.Pos.values().index('OZ')
        self.Pos_val_index = [self.P0, self.P1, self.P2, self.P3, self.P4, self.P5]
        self.unit_coef_vec = np.zeros(len(self.Pos_val_index))
        for i in self.Pos_val_index:
            if self.Pos_val_index[i] == 0 or self.Pos_val_index[i] == 1 or self.Pos_val_index[i] == 2:
                self.unit_coef_vec[i] = self.unit['um']
            else:
                self.unit_coef_vec[i] = 1

    def disconnect(self):
        self.Smarpod_Close(self.id.value)
        print('Smarpod Disconnected \n')
    def stopSmarpod(self):
        self.Smarpod_Stop(self.id.value)
        print('Smarpod Stop \n')

    def setMaxFrequency(self, MaxFrequency):
        freq = (MaxFrequency)
        # freq_p = pointer(MaxFrequency)
        self.Smarpod_SetMaxFrequency(self.id.value, freq)
        return self.err
    def setSensorMode(self, SensorMode):
        self.err = self.Smarpod_SetSensorMode(self.id.value, SensorMode)
        return self.err
    def setCalibration(self):
        self.calibrate = 1  # 0 = dont want calibration, 1= want calibration
        # if self.status(self.err) == "SMARPOD_OK":  # must be ==
        if self.calibrate == 1:
            self.err = self.Smarpod_Calibrate(self.id.value)
            if self.status(self.err) != "SMARPOD_OK":
                print("Smarpod_Calibrate :")
                self.showStatus()
            return self.err
        elif self.calibrate != 0:
            print("Select 1 to calibrate or 0 to continue ")
        else:
            print("Calibration OK \n ")
        return self.err
        # else:
        #     print("Calibration : \n")
        #     self.showStatus()
        # return self.err
    def setReferenceMarks(self):
        referenced = c_int()
        referenced_p = pointer(referenced)
        self.RefFreq = 18500
        self.RefMethod = self.SMARPOD_DEFAULT
        self.RefDirX = self.SMARPOD_DEFAULT
        self.RefDirY = self.SMARPOD_DEFAULT
        self.RefDirZ = self.SMARPOD_DEFAULT
        #Method
        self.Smarpod_Set_ui(self.id.value, self.SMARPOD_FREF_METHOD, self.RefMethod)
        #Direction
        # self.Smarpod_Set_ui(self.id.value, self.SMARPOD_FREF_XDIRECTION, self.RefDirX )
        # self.Smarpod_Set_ui(self.id.value, self.SMARPOD_FREF_YDIRECTION, self.RefDirY)
        # self.Smarpod_Set_ui(self.id.value, self.SMARPOD_FREF_ZDIRECTION, self.RefDirZ)
        #Frequence
        self.Smarpod_Set_ui(self.id.value, self.SMARPOD_FREF_AND_CAL_FREQUENCY, self.RefFreq)
        self.err = self.Smarpod_IsReferenced(self.id.value, referenced_p)
        if self.status(self.err) == "SMARPOD_OK":  # must be ==
            if referenced.value == 0:
                self.err = self.Smarpod_FindReferenceMarks(self.id.value)
                if self.status(self.err) == "SMARPOD_OK":  # must be ==
                    print("Referencing OK ")
                else:
                    print("Referencing : ", self.status(self.err))
            else:
                print("Referencing OK : ")
        else:
            print("Referencing : ", self.status(self.err))
        return self.err
    def setPivot(self, Px=0, Py=0, Pz=0):
        # self.Smarpod_Set_ui(self.id.value, self.SMARPOD_PIVOT_MODE, self.SMARPOD_PIVOT_RELATIVE)
        # self.PivotMode = self.SMARPOD_PIVOT_RELATIVE
        # SET PIVOT POSITION
        self.pivot = (c_double * 3)()
        self.pivot[0] = self.unitCoef*Px  # PX
        self.pivot[1] = self.unitCoef*Py # PY
        self.pivot[2] = self.unitCoef*Pz  # PZ
        self.err = self.Smarpod_SetPivot(self.id.value, self.pivot)
        self.showStatus()
        return self.err
    def setVelocity(self,Velocity):
        self.speedcontrol = 1
        self.Smarpod_SetSpeed(self.id.value, self.speedcontrol,c_double(Velocity))
        return self.err
    def setAcceleration(self,Acceleration):
        self.accelerationcontrol = 1
        self.err = self.Smarpod_SetAcceleration(self.id.value,self.accelerationcontrol,c_double(Acceleration))
        return self.err
    def moveX(self, distance):
        pose = (c_double * 6)()
        pose[0] = self.unitCoef*distance  # X
        pose[1] = 0  # Y
        pose[2] = 0  # Z
        pose[3] = 0  # OX
        pose[4] = 0  # OY
        pose[5] = 0  # OZ
        try:
            self.Smarpod_Move(self.id.value, pose, self.holdtime, self.waitForCompletion)
            print('Move complete')
        except:
            print('An Error has occured')
            # print(self.statuscode(self.Smarpod_Move(self.id.value_p,pose,self.holdtime,self.waitForCompletion)))
        return self.err
    def moveY(self, distance):
        pose = (c_double * 6)()
        pose[0] = 0 # X
        pose[1] = self.unitCoef*distance  # Y
        pose[2] = 0  # Z
        pose[3] = 0  # OX
        pose[4] = 0 # OY
        pose[5] = 0  # OZ
        try:
            self.Smarpod_Move(self.id.value,pose,self.holdtime,self.waitForCompletion)
            print('Move complete')
        except:
            print('An Error has occured')
            # print(self.statuscode(self.Smarpod_Move(self.id.value_p,pose,self.holdtime,self.waitForCompletion)))
        return self.err
    def moveZ(self, distance):
        pose = (c_double * 6)()
        pose[0] = 0 # X
        pose[1] = 0  # Y
        pose[2] = self.unitCoef*distance  # Z
        pose[3] = 0  # OX
        pose[4] = 0 # OY
        pose[5] = 0  # OZ
        try:
            self.Smarpod_Move(self.id.value,pose,self.holdtime,self.waitForCompletion)
            print('Move complete')
        except:
            print('An Error has occured')
        return self.err
            # print(self.statuscode(self.Smarpod_Move(self.id.value_p,pose,self.holdtime,self.waitForCompletion)))
    def moveThetaX(self, angle):
        pose = (c_double * 6)()
        pose[0] = 0 # X
        pose[1] = 0  # Y
        pose[2] = 0  # Z
        pose[3] = angle  # OX
        pose[4] = 0 # OY
        pose[5] = 0  # OZ
        try:
            self.Smarpod_Move(self.id.value, pose, self.holdtime, self.waitForCompletion)
            print('Move complete')
        except:
            self.err = self.Smarpod_Move(self.id.value, pose, self.holdtime, self.waitForCompletion)
            print('An Error has occured')
            self.showStatus()
        return self.err
    def moveThetaY(self, angle):
        pose = (c_double * 6)()
        pose[0] = 0 # X
        pose[1] = 0  # Y
        pose[2] = 0  # Z
        pose[3] = 0  # OX
        pose[4] = angle # OY
        pose[5] = 0  # OZ
        try:
            self.Smarpod_Move(self.id.value,pose)
            print('Move complete')
        except:
            self.err = self.Smarpod_Move(self.id.value, pose, self.holdtime, self.waitForCompletion)
            print('An Error has occured')
            self.showStatus()
        return self.err
    def moveThetaZ(self, angle):
        pose = (c_double * 6)()
        pose[0] = 0  # X
        pose[1] = 0  # Y
        pose[2] = 0  # Z
        pose[3] = 0  # OX
        pose[4] = 0  # OY
        pose[5] = angle  # OZ
        try:
            self.err = self.Smarpod_Move(self.id.value,pose,self.holdtime,self.waitForCompletion)
            print('Move complete')
        except:
            print('An Error has occured')
            self.showError()
        return self.err
    #def moveRelative(self, X, Y, Z, OX, OY, OZ):
    #    Y_setup = Z
    #    Z_setup = Y
    #    try:
#
    #        print(self.Pos)
    #        pose = (c_double * 6)()
    #        pose[self.P0] = X*self.unitCoef#self.unit_coef_vec[0]
    #        pose[self.P1] = Z_setup*self.unitCoef#self.unit_coef_vec[1]
    #        pose[self.P2] = Y_setup*self.unitCoef#self.unit_coef_vec[2]
    #        pose[self.P3] = OX#*self.unit_coef_vec[3]
    #        pose[self.P4] = OY#*self.unit_coef_vec[4]
    #        pose[self.P5] = OZ#*self.unit_coef_vec[5]
    #        self.err = self.Smarpod_Move(self.id.value, pose, self.SMARPOD_HOLDTIME_INFINITE, 1)
    #        if self.err == 0:
    #            time.sleep(0.5)
    #            self.Smarpod_StopAndHold(self.id.value, self.SMARPOD_HOLDTIME_INFINITE)
    #        return
    #        #
#
    #        print('Move complete')
    #    except:
    #        print('An Error has occured')
    #        self.showStatus()
    #    return
    def moveRelative(self, X, Y, Z, OX, OY, OZ):
        pose = (c_double * 6)()
        pose[0] = X*self.unitCoef  # X
        pose[1] = Y*self.unitCoef  # Y
        pose[2] = Z*self.unitCoef  # Z
        pose[3] = OX  # OX
        pose[4] = OY  # OY
        pose[5] = OZ  # OZ
        try:
            self.err = self.Smarpod_Move(self.id.value, pose, self.holdtime, self.waitForCompletion)
            print('Move complete')
        except:
            print('An Error has occured')
            self.showStatus()
        return self.err


    def getPosition(self):
        pose = (c_double * 6)()
        self.Smarpod_GetPose(self.id.value, pose)
        p = SmarPodPosition()
        p.positionX = pose[0]
        p.positionY = pose[1]
        p.positionZ = pose[2]
        p.rotationX = pose[3]
        p.rotationY = pose[4]
        p.rotationZ = pose[5]
        position_array = [1/(self.unitCoef)*p.positionX, 1/(self.unitCoef)*p.positionY, 1/(self.unitCoef)*p.positionZ, p.rotationX, p.rotationY, p.rotationZ]
        return position_array

 ##   def moveAbsoluteXY(self, x, y, z, ox, oy, oz):
  #      try:
  #          position_init = self.getPosition()
  #          x_CurrentPos = (position_init[self.P0])#        [self.Pos2.values().index('x')])
   #         y_CurrentPos = (position_init[self.P1])# [self.Pos2.values().index('y')])
   #         z_CurrentPos = (position_init[self.P2])# [self.Pos2.values().index('z')])
   #         ox_CurrentPos = (position_init[self.P3])# [self.Pos2.values().index('ox')])
   #         oy_CurrentPos = (position_init[self.P4])# [self.Pos2.values().index('oy')])
   #         oz_CurrentPos = (position_init[self.P5])# [self.Pos2.values().index('oz')])
   #         self.moveRelative(x_CurrentPos+x, y_CurrentPos+y, z_CurrentPos+z, ox_CurrentPos+ox, oy_CurrentPos+oy, oz_CurrentPos+oz)
#
   #         # print('Move complete')
   #         p=self.getPosition()
   #         print(p)
   #     except:
   #         print('An Error has occured')
   #         self.showStatus()
   #     return
    def moveAbsoluteXY(self, x, y, z, ox, oy, oz):
        position_init = self.getPosition()
        x_CurrentPos = position_init[0]
        y_CurrentPos = position_init[1]
        z_CurrentPos = position_init[2]
        ox_CurrentPos = position_init[3]
        oy_CurrentPos = position_init[4]
        oz_CurrentPos = position_init[5]
        self.moveRelative(x+x_CurrentPos, y+y_CurrentPos, z+z_CurrentPos,
                          ox+ox_CurrentPos, oy+oy_CurrentPos, oz+oz_CurrentPos)
    def waitMoveComplete(self, holdtime, waitForCompletion):
        self.holdtime = holdtime
        self.waitForCompletion = waitForCompletion
        return self.waitForCompletion, self.waitForCompletion, self.err
    def smarpodInfo(self):
        # Get DLL version
        self.createPrototypes()
        self.Minor = c_int32()
        self.Major = c_int32()
        self.Update = c_int32()
        self.Smarpod_GetDLLVersion = self.Smarpod_GetDLLVersion
        self.Smarpod_GetDLLVersion(pointer(self.Major), pointer(self.Minor), pointer(self.Update))
        self.dll = [self.Major.value, self.Minor.value, self.Update.value]
        # Get Model
        ModelList = (c_uint * 128)()
        listsize = c_uint32(128)
        self.Smarpod_GetModels(ModelList, pointer(listsize))
        self.model = ModelList[1]
        # Get model name
        Name = c_char_p()
        self.Smarpod_GetModelName(self.model, pointer(Name))
        self.name = Name.value
        return self.name, self.model, self.dll
    def showStatus(self):
        self.error = self.status(self.err)
        print('Status : ', self.error, '<', self.err, '>')
        return
        # raise ValueError('Status : ', self.error, '<', self.err, '>')
            # print('Status : ', self.error, '<', self.err, '>')
    def createPrototypes(self):

        # Smarpod_GetDLLVersion
        self.Smarpod_GetDLLVersion = self.lib.Smarpod_GetDLLVersion
        # self.Smarpod_GetDLLVersion.argtypes = [POINTER(c_int32), POINTER(c_int32), POINTER(c_int32)]  #(major, minor, update)
        # self.Smarpod_GetDLLVersion.restype = c_int32

        # Smarpod_Open
        self.Smarpod_Open = self.lib.Smarpod_Open
        # self.Smarpod_Open.argtypes=[POINTER(c_ulong), c_uint32, c_char, c_char]
        # self.Smarpod_Open.restype = c_uint32

        # Smarpod_Close
        self.Smarpod_Close = self.lib.Smarpod_Close
        # self.Smarpod_Close.argtypes = [c_uint32]
        # self.Smarpod_Close.restype = c_uint32

        # Smarpod_GetModels
        self.size = 128
        self.Smarpod_GetModels = self.lib.Smarpod_GetModels
        # self.Smarpod_GetModels.argtypes = [c_uint32, POINTER(c_uint32)]
        # self.Smarpod_GetModels.restype = c_uint32


        # Smarpod_GetModelName
        self.Smarpod_GetModelName = self.lib.Smarpod_GetModelName
        # self.Smarpod_GetModelName.argtypes = (c_uint32, POINTER(c_uint32))
        # self.Smarpod_GetModelName.restype = c_uint32

        # Smarpod_GetStatusInfo  --> remplace par la fonction statuscode[status]
        self.Smarpod_GetStatusInfo = self.lib.Smarpod_GetStatusInfo
        # self.Smarpod_GetStatusInfo.argtypes = [c_uint32, POINTER(c_char_p)]
        # self.Smarpod_GetStatusInfo.restype = c_uint32

        # Smarpod_FindSystems
        self.b_size = 4096
        self.Smarpod_FindSystems = self.lib.Smarpod_FindSystems
        # self.Smarpod_FindSystems.argtypes = [c_char, c_char, POINTER(c_uint)]
        # self.Smarpod_FindSystems.restype = c_uint32

        # Smarpod_GetSystemLocator
        self.Smarpod_GetSystemLocator = self.lib.Smarpod_GetSystemLocator
        # self.Smarpod_GetSystemLocator.argtypes = [c_uint, POINTER(c_char) , POINTER(c_uint)]
        # self.Smarpod_GetSystemLocator.restype = c_uint32

        # Smarpod_SetSensorMode
        self.Smarpod_SetSensorMode = self.lib.Smarpod_SetSensorMode
        # self.Smarpod_SetSensorMode.argtype = [c_uint32, c_uint32]
        # self.Smarpod_SetSensorMode.restype = c_uint32

        # Smarpod_GetSensorMode
        self.Smarpod_GetSensorMode = self.lib.Smarpod_GetSensorMode
        # self.Smarpod_GetSensorMode.argtype = [c_uint32, c_uint32]
        # self.Smarpod_GetSensorMode.restype = c_uint32

        self.Smarpod_Calibrate = self.lib.Smarpod_Calibrate

        # Smarpod_Set_ui
        self.Smarpod_Set_ui = self.lib.Smarpod_Set_ui
        # self.Smarpod_Set_ui.argtype = [c_uint32, c_uint32, c_uint32]
        # self.Smarpod_Set_ui.restype = c_uint32

        # Smarpod_Get_ui
        self.Smarpod_Set_ui = self.lib.Smarpod_Set_ui
        # self.Smarpod_Set_ui.argtype = [c_uint32, c_uint32, c_uint32]
        # self.Smarpod_Set_ui.restype = c_uint32

        # Smarpod_IsReferenced
        self.Smarpod_IsReferenced = self.lib.Smarpod_IsReferenced
        # self.Smarpod_IsReferenced.argtypes = [c_uint32, c_int32]
        # self.Smarpod_IsReferenced.restype = c_uint32

        # Smarpod_FindReferenceMarks
        self.Smarpod_FindReferenceMarks = self.lib.Smarpod_FindReferenceMarks
        # self.Smarpod_FindReferenceMarks.argtypes = [c_uint32]
        # self.Smarpod_FindReferenceMarks.restype = c_uint32

        # Smarpod_SetMaxFrequency
        self.Smarpod_SetMaxFrequency = self.lib.Smarpod_SetMaxFrequency
        # self.Smarpod_SetMaxFrequency.argtypes = [c_uint32, c_uint32]
        # self.Smarpod_SetMaxFrequency.restype= c_uint32

        # Smarpod_GetMaxFrequency
        self.Smarpod_GetMaxFrequency = self.lib.Smarpod_GetMaxFrequency
        # self.Smarpod_GetMaxFrequency.argtypes = [c_uint32, c_uint32]
        # self.Smarpod_GetMaxFrequency.restype= c_uint32

        # Smarpod_SetSpeed
        self.Smarpod_SetSpeed = self.lib.Smarpod_SetSpeed
        # self.Smarpod_SetSpeed.argtypes = [c_uint32, c_int, c_double]
        # self.Smarpod_SetSpeed.restype = c_uint32

        # Smarpod_GetSpeed
        self.Smarpod_GetSpeed = self.lib.Smarpod_GetSpeed
        # self.Smarpod_GetSpeed.argtypes = [c_uint , c_int, c_double]
        # self.Smarpod_GetSpeed.restype = c_uint32

        #  Smarpod_SetAccelaration
        self.Smarpod_SetAcceleration = self.lib.Smarpod_SetAcceleration
        # self.Smarpod_SetAcceleration.argtypes = [c_uint32, c_int, c_double]
        # self.Smarpod_SetAcceleration.restype = c_uint32

        # Smarpod_GetAcceleration
        self.Smarpod_GetAcceleration = self.lib.Smarpod_GetAcceleration
        # self.Smarpod_GetAcceleration.argtypes = [c_uint , c_int, c_double]
        # self.Smarpod_GetAcceleration.restype = c_uint32

        #  Smarpod_SetPivot
        self.Smarpod_SetPivot = self.lib.Smarpod_SetPivot
        # self.Smarpod_SetPivot.argtypes = [c_uint32, POINTER(c_double *3)]
        # self.Smarpod_SetPivot.restype = c_uint32

        # Smarpod_GetPivot
        self.Smarpod_GetSpeed = self.lib.Smarpod_GetSpeed
        # self.Smarpod_GetSpeed.argtypes = [c_uint32 ,POINTER(c_double *3)]
        # self.Smarpod_GetSpeed.restype = c_uint32

        # Smarpod_GetPose
        self.Smarpod_GetPose = self.lib.Smarpod_GetPose
        # self.Smarpod_GetPose.argtypes = [c_uint32 ,POINTER(c_double)]
        # self.Smarpod_GetPose.restype = c_uint32

        # Smarpod_IsPoseReachable
        self.Smarpod_IsPoseReachable = self.lib.Smarpod_IsPoseReachable
        # self.Smarpod_IsPoseReachable.argtypes = [c_uint32, POINTER(c_double),c_uint32]
        # self.Smarpod_IsPoseReachable.restype = c_uint32

        # Smarpod_GetMoveStatus
        self.Smarpod_GetMoveStatus = self.lib.Smarpod_GetMoveStatus
        # self.Smarpod_GetMoveStatus.argtypes = [c_uint32 ,c_uint32]
        # self.Smarpod_GetMoveStatus.restype = c_uint32

        # Smarpod_Move
        self.Smarpod_Move = self.lib.Smarpod_Move
        # self.Smarpod_Move.argtypes = [c_uint32, POINTER(c_double), c_uint32, c_int32]
        # self.Smarpod_Move.restype = c_uint32

        # Smarpod_Stop
        self.Smarpod_Stop = self.lib.Smarpod_Stop
        # self.Smarpod_Stop.argtypes = [c_uint32]
        # self.Smarpod_Stop.restype = c_uint32

        # Smarpod_StopAndHold
        self.Smarpod_StopAndHold = self.lib.Smarpod_StopAndHold
        # self.Smarpod_StopAndHold.argtypes = [c_uint32, c_uint32]
        # self.Smarpod_StopAndHold.restype = c_uint32

    # Constants from SmarPod.dll:
    SMARPOD_DEFAULT = 0
    # / *property symbols * /
    SMARPOD_FREF_METHOD = 1000
    SMARPOD_FREF_ZDIRECTION = 1002
    SMARPOD_FREF_XDIRECTION = 1003
    SMARPOD_FREF_YDIRECTION = 1004
    SMARPOD_PIVOT_MODE = 1010
    SMARPOD_FREF_AND_CAL_FREQUENCY = 1020
    # / * for backwardcompatibility.use SMARPOD_FREF_ZDIRECTIONinstead. * /
    SMARPOD_FREF_DIRECTION = SMARPOD_FREF_ZDIRECTION
    # / *axis and direction constants * /
    SMARPOD_X = 0x0001
    SMARPOD_Y = 0x0002
    SMARPOD_Z = 0x0004
    SMARPOD_POSITIVE = 0x0100
    SMARPOD_NEGATIVE = 0x0200
    SMARPOD_REVERSE = 0x1000
    # / *pivot - point modes * /
    SMARPOD_PIVOT_RELATIVE = 0
    SMARPOD_PIVOT_FIXED = 1
    # / *find - ref methods * /
    SMARPOD_METHOD_SEQUENTIAL = 1
    SMARPOD_METHOD_ZSAFE = 2
    SMARPOD_METHOD_XYSAFE = 3
    # / *sensor power - modes * /
    SMARPOD_SENSORS_DISABLED = 0
    SMARPOD_SENSORS_ENABLED = 1
    SMARPOD_SENSORS_POWERSAVE = 2
    # / *infinite actuator position holdtime * /
    SMARPOD_HOLDTIME_INFINITE = 60000
    # / *move - status constants * /
    SMARPOD_STOPPED = 0
    SMARPOD_HOLDING = 1
    SMARPOD_MOVING = 2
    SMARPOD_CALIBRATING = 3
    SMARPOD_REFERENCING = 4
    # / *DEPRECATED CONSTANTS, INCLUDED FOR BACKWARD OMPATIBILITY * /
    # SMARPOD_MOVING_ERROR       =   SMARPOD_BUSY_ERROR

    def MakeSeq(self, xinit, yinit, zinit, oxinit, oyinit, ozinit, xspan, yspan, zspan, oxspan, oyspan, ozspan, dx, dy, dz):
        # Coordonnees limites
        xmin, xmax = (xinit - xspan/2), (xinit+xspan/2)
        ymin, ymax = (yinit - yspan/2), (yinit + yspan/2)
        zmin, zmax = (zinit - zspan/2), (zinit + zspan/2)
        oxmin, oxmax = (oxinit - oxspan/2), (oxinit + oxspan/2)
        oymin, oymax = (oyinit - oyspan/2), (oyinit + oyspan/2)
        ozmin, ozmax = (ozinit - ozspan/2), (ozinit + ozspan/2)
        if dz == 0:
            z = [zinit]
        else:
            z = np.linspace(zmin, zmax, round(zspan/dz))
        if dx == 0:
            x = [xinit]
        else:
            x = np.linspace(xmin, xmax, round(xspan/dx))
        if dy == 0:
            y = [yinit]
        else:
            y = np.linspace(ymin, ymax, round(yspan/dy))
        ox = oxinit  # np.linspace(oxinit, oxinit, round(oxspan / dox))
        oy = oyinit  # np.linspace(oyinit, oyinit, round(oyspan / doy))
        oz = ozinit  # np.linspace(ozinit, ozinit, round(ozspan / doz))
        I = {}
        n = 0
        for j in range(len(z) * len(y)):
            if j % 2 == 0:
                I[j] = x[::1]
            else:
                I[j] = x[::-1]

        A = [0] * (len(I) * len(x))
        n = 0
        for h in range(len(I)):
            for k in range(len(I[1])):
                A[n] = I[h][k]
                n = n + 1
        p = {}
        n = 0
        for k in range(len(z)):
            for j in range(len(y)):
                for i in range(len(A)):
                    x = A
                    p[n] = [x[i], y[j], z[k], ox, oy, oz]
                    n = n + 1
        p = [v for v in p.values()]
        print(np.array(p))
        # print(len(p) == len(x)*len(z)*len(y))
        # print(len(x))
        # print(len(y))
        # print(len(z))
        return p


#
S = SmarPodClass()
# # !|/$%?&$$print(S.Pos)
#
# # # # # print(S.id.value)
# # # # print(S.id)
S.connect(0.1, 0.5, 1, 12500, 1, 0)
# S.SMARPOD_PIVOT_RELATIVE
#
# # S.setPivot(0,0,0)
S.moveRelative(100,100,0,0,0,0)
S.moveAbsoluteXY(100,0,0,0,0,0)
print(S.getPosition())
S.moveAbsoluteXY(100,0,0,0,0,0)
print(S.getPosition())
S.moveAbsoluteXY(100,0,0,0,0,0)
print(S.getPosition())

# print(S.SMARPOD_PIVOT_RELATIVE)
# S.moveRelative(10,0,0,0,0,0)
# S.disconnect()

#print(S.SMARPOD_PIVOT_RELATIVE)
# # # # print(S.getPosition())
# # # # S.moveAbsoluteXY(-2000,100,0,0,0,0)
# # # # print(S.getPosition())
# # # # S.setVelocity(0.001)
# # # # S.moveRelative(100,0,0,0,0,0)
# # # # print(S.getPosition())
# # # # S.moveAbsoluteXY(-500,100,0,0,0,0)
# # # # print(S.getPosition())
# # S.moveAbsoluteXY(0,0.10,0,0,0,-900)
# # print(S.getPosition())
# # # # S.moveAbsoluteXY(200,100,0,0,0,0)
# # # # print(S.getPosition())
# S.moveAbsoluteXY(0.5,0.5,100,0,0,0)
# print(S.getPosition())
# # # print(S.Smarpod_GetPose.positionX)
# #
# # # S.moveRelative(-130.8496666708898,604.6843402761843,-8556.34195923024,0,0,0)
# # # print(S.getPosition())
# # # S.moveAbsoluteXY(0,-50,0,0,0,1)
# # # print(S.getPosition())

#
# pos = S.getPosition()
# xinit = pos[0]
# yinit = pos[1]
# zinit = pos[2]
# oxinit = pos[3]
# oyinit = pos[4]
# ozinit = pos[5]
# # Position Y Max (security)
# Ymax_security = 1
#
# # Incrementation
# dx = 3
# dox = 0
# dy = 3
# doy = 0
# dz = 0
# doz = 0
#
# # Span
# xspan = 15
# yspan = 15
# zspan = 15
# oxspan = 0
# oyspan = 0
# ozspan = 0
#
# # Sequence balayage  XYZ (Angles fixes)
# p1 = S.MakeSeq(xinit, yinit, zinit, oxinit, oyinit, ozinit, xspan, yspan, ozspan, oxspan, oyspan, zspan, dx, dy, dz)
# # print(p1[:])
# # #
# for i in range(len(p1)):
#     S.moveRelative(p1[i][0],p1[i][1],p1[i][2],p1[i][3],p1[i][4],p1[i][5])
#     # S.Smarpod_StopAndHold(S.id.value,1000)
#     # print(S.getPosition())
#     # result = lib.Smarpod_Move(SmarpodId,pose,"SMARPOD_HOLDTIME_INFINITE", 1)
#     # print(result)
#
# # print(len(p1))
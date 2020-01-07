
# importing the libraries

import ctypes
from ctypes import *
import sys
import visa
import matplotlib.pyplot as plt
import numpy as np
from func import*
# from Smarpod_status import*

from ctypes import *
import numpy as np
import numpy.ctypeslib as npct;
from itertools import repeat;
import math;
import string

#######################################################################################################################
#   LOAD LIBRARY
#######################################################################################################################
# lib1 = ctypes.WinDLL("SmarPod.dll")
# print(lib1)
# lib = np.ctypeslib.load_library('SmarPod.dll','.')
# print("Smarpod Library .DLL :", "SmarPod.dll : ", lib)
# print(lib)

#######################################################################################################################
# CLASS
#######################################################################################################################

# class Smapod:
#     def __init__(self, loc = "network:192.168.1.200:5000", lib = np.ctypeslib.load_library('SmarPod.dll', '.')):
#         (model, name, dll) = SmarpodInfo(lib)
#         # Locator adress
#         loc_str = loc.encode('utf-8')
#         loc_buffer = create_string_buffer(loc_str)
#         SmarpodId = c_ulong()
#         SmarpodId_p = pointer(SmarpodId)
#         locator = loc_buffer
#         # Open Smarpod
#         lib.Smarpod_Open(SmarpodId_p, model, locator, " ")
#         SmarpodId_val = SmarpodId.value
#         self.model = model
#         self.name = name
#         self.dll = dll
#         self.loc = loc
#         self.loc_buffer = loc_buffer
#         self.id = SmarpodId_val
#         self.id_p= SmarpodId

# class SmapodConfigOptions:
#     def __init__(self, mode='Disable', freq_max=3000):
#         sensors_mode = {}
#         sensors_mode['Enable'] = "SMARPOD_SENSORS_ENABLED"
#         sensors_mode['Disable'] = "SMARPOD_SENSORS_DISABLED"
#         sensors_mode['Powersave'] = "SMARPOD_SENSORS_POWERSAVE"
#         self.mode = sensors_mode[mode]
#         self.freq_max = freq_max

# class SmapodRefOptions:
    # Referencing < METHOD > : Smarpod_Set_ui(SmarpodId, SMARPOD_FREF_METHOD, < METHOD >)
    # Referencing [ DIRECTION ] : Smarpod_Set_ui(SmarpodId, [ DIRECTION ] , ( OPTION ));
    #   - < DEFAULT >
    #   - < METHOD_SEQUENTIAL >
    #   - < METHOD_ZSAFE >
    #         - [ FREF_ZDIRECTION ]
    #   - < METHOD_XYSAFE >
    #         -  [ FREF_XDIRECTION, FREF_YDIRECTION ]
    # DIRECTION OPTIONS:
    #   - ( SMARPOD_NEGATIVE, SMARPOD_POSITIVE, SMARPOD_REVERSE )
    # Other properties : Smarpod_Set_ui(SmarpodId, < FREF_AND_CAL_FREQUENCY >, 8000);

    # def __init__(self, ref_method=0, direction=0, direction_option=0):
    #     method = {0: "DEFAULT", 1: " METHOD_SEQUENTIAL", 2: "METHOD_ZSAFE", 3: "METHOD_XYSAFE"}
    #     Dir = {0: " ", "z": "FREF_ZDIRECTION", "x": "FREF_XDIRECTION", "y": "FREF_YDIRECTION"}
    #     Dir_opt = {0: " ", "-": "SMARPOD_NEGATIVE", "+": "SMARPOD_POSITIVE", "r": "SMARPOD_REVERSE"}
    #     self.CAL_FREF_FREQUENCY = 8000
    #     self.method = method[ref_method]
    #     self.dir = Dir[direction]
    #     self.dir_opt = Dir_opt[direction_option]
    #     self.ref_max_freq = 8000

# class SmapodPivotOptions:
#     # SET PIVOT MODE
#
#     def __init__(self, pivot_mode='fixe', px=0, py=0, pz=0):
#         Pivot_mode = {}
#         Pivot_mode['relatif'] = 'PIVOT_RELATIVE'
#         Pivot_mode["fixe"] = "PIVOT_FIXED"
#         self.mode = Pivot_mode[pivot_mode]
#         self.px = px
#         self.py = py
#         self.pz = pz
#         Pivot=(c_double * 3)()
#         Pivot[0] = self.px
#         Pivot[1] = self.py
#         Pivot[2] = self.pz
#         self.pivot_c_double = Pivot
#
#         # class SmarpodMove:
#         #         def __init__(self):
#         #             self.sp =  0.001

class Smarpod_position:
        a = np.zeros(6)
        def __init__(self, X=a[0], Y=a[1], Z=a[2], OX=a[3], OY=a[4], OZ=a[5]):
            self.positionX = c_double(X)
            self.positionY = c_double(Y)
            self.positionZ = c_double(Z)
            self.rotationX = c_double(OX)
            self.rotationY = c_double(OY)
            self.rotationZ = c_double(OZ)
        def pose_c_double(self):
            pose1 = (c_double * 6)()
            pose1[0] = self.positionX  # X
            pose1[1] = self.positionY  # Y
            pose1[2] = self.positionZ  # Z
            pose1[3] = self.rotationX  # OX
            pose1[4] = self.rotationY  # OY
            pose1[5] = self.rotationZ  # OZ
            return pose1
        def pose_double(self):
            pose2 = [self.positionX.value,  # X
                     self.positionY.value,  # Y
                     self.positionZ.value,  # Z
                     self.rotationX.value,  # OX
                     self.rotationY.value,  # OY
                     self.rotationZ.value]  # OZ
            return pose2


#######################################################################################################################
# INITIALIZATION
    # 1. initialization of the SmarPod (see 2.4.1 Initializing a SmarPod).
    # 2. activation of the sensors operation mode (see 2.2 Sensor Modes).
    # 3. configuration of the SmarPod (2.4.3 Configuring the SmarPod).
    # 4. (if necessary) calibration of the positioner sensors (see 2.4.4 Calibrating the Sensors).
    # 5. (if necessary) finding the positioner's reference marks (see 2.4.5 Finding Reference Marks).
#######################################################################################################################

# print(" %%%%%%%%%%%%%%%% \n %INITIALIZATION% \n %%%%%%%%%%%%%%%%")
#
# SP = Smapod("network:192.168.1.200:5000")
# config = SmapodConfigOptions()
# ref = SmapodRefOptions()
# set_pivot =SmapodPivotOptions()
#
#
# # 1. Initialization
# # SmarPod info
#     # Open Smarpod
# status = lib.Smarpod_Open(SP.id_p, SP.model, SP.loc_buffer, " ")
#     #  Get id
# SmarpodId = SP.id
# if statuscode(status) == "SMARPOD_OK" :
#     print("Smarpod_Open : ", "Smarpod_Status : ", statuscode(status), "<", (status), ">")
# else:
#     print("Initialization OK \n     Next step is : Sensors activation")
#
# # 2.Sensors activation
#     config.mode = 'Enable'
#     # Mode selection:
#     Smarpod_SetSensorMode = lib.Smarpod_SetSensorMode
#     status = Smarpod_SetSensorMode(SmarpodId, config.mode)
#     if statuscode(status) == "SMARPOD_OK":
#         print("Smarpod_SetSensorMode :","Smapod_Status : ", statuscode(status),"<",status,">")
#     else:
#         print("Sensors activation OK \n     Next step is : Configuration")
#
# # 3. Configuration
#         #   - Smarpod_SetSensorMode -OK
#         #   - Smarpod_SetMaxFrequency (1 to 18500)
#         freq_max = 3000
#         Smarpod_SetMaxFrequency = lib.Smarpod_SetMaxFrequency
#         status = Smarpod_SetMaxFrequency(SmarpodId, freq_max)
#         if statuscode(status) == "SMARPOD_OK": # must be ==
#             print("Smarpod_SetMaxFrequency :","Smapod_Status : ", statuscode(status),"<",status,">")
#         else:
#         #   - Smarpod_SetSpeed
#             # Select speed control
#             speed_control = 1  # 1 = enable ou 0 = disable speed-control
#             # Select speed (max reachable speed is typically 1 to 5 mm/s)
#             speed = 0.001
#             Smarpod_SetSpeed = lib.Smarpod_SetSpeed
#             status = Smarpod_SetSpeed(SmarpodId, speed_control, c_double(speed))
#             if statuscode(status) == "SMARPOD_OK":  # must be !=
#                  print("Smarpod_SetSpeed :", "Smapod_Status : ", statuscode(status), "<", status, ">")
#             else:
#                 print("Configuration OK \n    Next step is : Calibration (if necessary)")
#
# # 4. Calibration (if necessary)
# calibrate = 0  # 0 = dont want calibration, 1= want calibration
# if statuscode(status) != "SMARPOD_OK":  # must be ==
#     if calibrate == 1:
#         Smarpod_Calibrate = lib.Smarpod_Calibrate
#         status = Smarpod_Calibrate(SmarpodId)
#         if statuscode(status) != "SMARPOD_OK":
#             print("Smarpod_Calibrate :", "Smapod_Status : ", statuscode(status), "<", status, ">")
#     elif calibrate != 0:
#         print("Select 1 to calibrate or 0 to continue ")
#     else:
#         print("Calibration OK \n    Next step is : Finding reference marks (if necessary)")
# else:
#     print("Calibration : ", statuscode(status))
#
# # 5. Finding reference marks (if necessary)
# referenced = c_int()
# referenced_p = pointer(referenced)
#
# lib.Smarpod_Set_ui(SmarpodId, "SMARPOD_FREF_METHOD", ref.method)
# lib.Smarpod_Set_ui(SmarpodId, "FREF_AND_CAL_FREQUENCY", ref.CAL_FREF_FREQUENCY)
# status = lib.Smarpod_IsReferenced(SmarpodId, referenced_p)
# if statuscode(status) != "SMARPOD_OK":  # must be ==
#     if referenced.value == 0:
#         status = lib.Smarpod_FindReferenceMarks(SmarpodId)
#         if statuscode(status) != "SMARPOD_OK":  # must be ==
#             print("Referencing OK : \n      Initialization completed")
#         else:
#             print("Referencing : ", statuscode(status))
#     else:
#         print("Referencing OK : \n      Initialization completed")
# else:
#     print("Referencing : ", statuscode(status))
#
# # PIVOT
# print("Pivot calibration : ")
# lib.Smarpod_Set_ui(SmarpodId, "PIVOT_MODE","PIVOT_RELATIVE" )
# # SET PIVOT POSITION
# pivot = (c_double *3)()
# pivot[0] = 0        # PX
# pivot[1] = 0        # PY
# pivot[2] = 0.001    # PZ
# status = lib.Smarpod_SetPivot(SmarpodId, pivot)
# print("     ", statuscode(status))

# MOVE
# SET position
########################################################################################################################

# Position initiale trouve manuellement
xinit, yinit,zinit = 0,0,0
oxinit,oyinit,ozinit = 0,0,0

# Position Y Max (security)
Ymax_security = 1

# Incrementation
dx = 0.5;    dox = 0.5
dy = 0.5;    doy = 0.5
dz = 0.5;    doz = 0.5

# Span
xspan, yspan, zspan = 2, 1, 1
oxspan, oyspan, ozspan = 1, 2, 3

# Sequence balayage  XYZ (Angles fixes)
p1 = MakeSeq(xinit, yinit, zinit, oxinit, oyinit, ozinit, xspan, yspan, ozspan, oxspan, oyspan, zspan, dx, dy, dz)
print(p1[:])

# for i in range(len(p1)):
#     SP = Smarpod_position(p1[i][0],p1[i][1],p1[i][2],p1[i][3],p1[i][4],p1[i][5])
#     pose = SP.pose_c_double()
#     result = lib.Smarpod_Move(SmarpodId,pose,"SMARPOD_HOLDTIME_INFINITE", 1)
#     # print(result)
#
#
#
# Minor = c_int32()
# Major = c_int32()
# Update = c_int32()
# # minor = pointer(Minor)
# # major = pointer(Major)
# # update = pointer(Update)
# Smarpod_GetDLLVersion = lib.Smarpod_GetDLLVersion
# Smarpod_GetDLLVersion.argtypes = [POINTER(c_int32), POINTER(c_int32), POINTER(c_int32)]
# Smarpod_GetDLLVersion.restype = c_uint32
# Smarpod_GetDLLVersion(Major, Minor, Update)
#
# # print("Smarpod_GetDLLVersion : ", Major.value, ".", Minor.value, ".", Update.value)
# #
# # class smarpodcclasstest(object):
# #     def __init__(self):
# #         self.lib = np.ctypeslib.load_library('SmarPod.dll','.')
# #         self.loc = "network:192.168.1.200:5000"
# #         # self.createPrototypes()
# #         self.connected = False
# #     # def createPrototypes(self):
# #         # Minor = c_int32()
# #         # Major = c_int32()
# #         # Update = c_int32()
# #         # minor = pointer(Minor)
# #         # major = pointer(Major)
# #         # update = pointer(Update)
# #         Smarpod_GetDLLVersion = self.lib.Smarpod_GetDLLVersion
# #         self.Smarpod_GetDLLVersion = Smarpod_GetDLLVersion
# #         # self.Smarpod_GetDLLVersion.argtypes = [POINTER(c_int32), POINTER(c_int32), POINTER(c_int32)]
# #         # self.Smarpod_GetDLLVersion.restype = POINTER()  #(major, minor, update)
# #         # print("Smarpod_GetDLLVersion : ", Major.value, ".", Minor.value, ".", Update.value)
# #
# # c = smarpodcclasstest.Smarpod_GetDLLVersion
# # print(lib.eggs('Smarpod_Status'))
# # lib.SMARPOD_SENSORS_ENABLED
# # info = (c_char_p*1)()
# # info_p = pointer(info)
# # print(lib.Smarpod_GetStatusInfo(0,info_p))
# # print(info[0])
# # class Pose(Structure):
# #      _fields_ = [("positionX", c_double),
# #                  ("positionY", c_double),
# #                  ("positionZ", c_double),
# #                  ("rotationX", c_double),
# #                  ("rotationZ", c_double),
# #                  ("rotationZ", c_double)
# #                  ]
# # pose_p = POINTER(Pose)
# # pp = Pose()
# # pose5 = (c_double*2)()
# # # pose5[0] = c_double(1)
# # # pose5[1] = c_double()
# # r =lib.Smarpod_GetPose(SmarpodId, pp)
# print(r)
# print(pose5[0])
# pose5.positionx = pose[0]
# print(pose5.positionx)
# print(pp[0])
# # print(pp._fields_[0][1])
#
# # pose = (c_double * 6)()
# class Pose(Structure):
#     _fields_ = [("positionX", c_double),
#                 ("positionY", c_double),
#                 ("positionZ", c_double),
#                 ("rotationX", c_double),
#                 ("rotationY", c_double),
#                 ("rotationZ", c_double)
#                 ]
# # positionx = pose[0]
# # positiony = pose[1]
# # positionz = pose[2]
# # rotationx = pose[3]
# # rotationy = pose[4]
# # rotationz = pose[5]
# pose = Pose()
# pose.positionX= 7
# pose.positionY = 5
# pose.positionZ = 3
# pose.rotationX = 1
# pose.rotationY = 2
# pose.rotationZ = 2
# # position_array = [pose[0], pose[1], pose[2], pose[3], pose[4], pose[5]]
# print(pose.)
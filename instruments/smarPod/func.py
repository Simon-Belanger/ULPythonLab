import numpy as np
import ctypes
# import multiprocessing as mp
# import time
from ctypes import *
def SmarpodInfo(lib):
    # Get DLL version
    Minor = c_int32()
    Major = c_int32()
    Update = c_int32()
    minor = pointer(Minor)
    major = pointer(Major)
    update = pointer(Update)
    Smarpod_GetDLLVersion = lib.Smarpod_GetDLLVersion
    Smarpod_GetDLLVersion(major, minor, update)
    # print("Smarpod_GetDLLVersion : ", Major.value, ".", Minor.value, ".", Update.value)
    dll = [Major.value, Minor.value,Update.value]
    # Get Model
    ModelList = (c_uint * 128)()
    listsize = c_uint(128)
    listsize_p = pointer(listsize)
    lib.Smarpod_GetModels(ModelList, listsize_p)
    model = ModelList[1]
    # Get model name
    Name = c_char_p()
    name = pointer(Name)
    lib.Smarpod_GetModelName(model, name)
    name = Name.value
    return name, model, dll

def MakeSeq(xinit,yinit,zinit,oxinit,oyinit,ozinit,xspan, yspan, zspan,oxspan,oyspan,ozspan,dx,dy,dz):
# Coordonnees limites
    xmin, xmax = (xinit - xspan / 2), (xinit + xspan / 2)
    ymin, ymax = (yinit - yspan / 2), (yinit + yspan / 2)
    zmin, zmax = (zinit - zspan / 2), (zinit + zspan / 2)
    oxmin, oxmax = (oxinit - oxspan / 2), (oxinit + oxspan / 2)
    oymin, oymax = (oyinit - oyspan / 2), (oyinit + oyspan / 2)
    ozmin, ozmax = (ozinit - ozspan / 2), (ozinit + ozspan / 2)
    x = np.linspace(xmin, xmax, round(xspan / dx))
    y = np.linspace(ymin, ymax, round(yspan / dy))
    z = np.linspace(zmin, zmax, round(zspan / dz))
    ox = oxinit  #np.linspace(oxinit, oxinit, round(oxspan / dox))
    oy = oyinit   #np.linspace(oyinit, oyinit, round(oyspan / doy))
    oz = ozinit  # np.linspace(ozinit, ozinit, round(ozspan / doz))
    I = {}
    n=0
    for j in range(len(z)*len(y)):
        if j % 2 == 0:
            I[j] = x[::1]
        else:
            I[j] = x[::-1]

    A=[0]*(len(I)*len(x))
    n=0
    for h in range(len(I)):
        for k in range(len(I[1])):
             A[n] = I[h][k]
             n=n+1
    p = {}
    n = 0
    for j in range(len(y)):
        for k in range(len(z)):
            for i in range(len(A)):
                    x = A
                    p[n] = [x[i], y[j], z[k],ox,oy,oz]
                    n= n+1
    p = [v for v in p.values()]
    # print(np.array(p))
    # print(len(p) == len(x)*len(z)*len(y))
    return p
# def MakePosTable():
#
#
# POS_DATA = [pos_data1, pos_data2, pos_data3]
# POS_DATA = np.reshape(POS_DATA,(len(POS_DATA),6))
#
#Create liste balayage hexapod
# n_init = 5
# key = np.arange(5)
# val = (np.zeros(3) * n_init)
# p_init = {key[i] : val[i] for i in range(5)}
# p_init = (np.zeros(3) * n_init)
# class  ListPos:
#     n_init = 1
#     p_init = {}
#     p_init = (np.zeros(3)*n_init)
#     def __init__(self, n = n_init, a = p_init):
#         self.n = n
#         self.p = a
#         self.vec_init = np.zeros(self.n * 3)
#         self.table = np.reshape(self.p, (self.n, 3))
#     def f(self):
#         # self.s = np.zeros(len(p)*3)
#         seq = self.table
#         # t = np.reshape(t,(len(p),3))
#         for i in range(len(self.p)):
#             seq[i][:] = seq[i]
#         return seq
# # L= ListPos(len(p), p)
# # print(L)
# # class ListPos:
# #     def __init__(self,n=1):
# #         self.p_mat = np.zeros((n,3), dtype=float)
# # POS = ListPos(len(p))
# # SEQ = POS.f
# # p_mat = np.reshape(p, (len(p), 3))
# # print(POS.p_mat_init)



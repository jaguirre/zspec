#!/usr/bin/env /usr/bin/python

#from Scientific.IO.NetCDF import NetCDFFile  # using older code from French mec
from netCDF4 import Dataset as NetCDFFile     # contemporary, maintained code from Google
from socket import socket, AF_INET, SOCK_DGRAM
import string
import os.path
import threading
import sys
import time
import datetime
from numpy import shape

##
## I've implemented the client using a Threading class. Unclear if this is really any better (probably not) than simply running N instances of the python interpreter
## 
## This is a helper function that can be called by other python programs, including the one at the end of this file.
##

class zspec_client_thread(threading.Thread):

    def __init__(self, host, port, directory, filename, boardNumber):
        self.host = host
        self.port = port + boardNumber - 1
        self.directory = directory
        self.filename = filename
        self.boardNumber = boardNumber
        threading.Thread.__init__(self)

    def run(self):
        bnString = '%02d' % self.boardNumber
        ncid = NetCDFFile(self.directory + '/' + self.filename + '_board' +
                          bnString + '.nc', 'ws', format='NETCDF3_CLASSIC',
                          clobber=False)
        ncid.createDimension('time', None)
        ncid.createDimension('packetBytes', 192)
        ncid.createDimension('boxLength', 2)
        ncid.createDimension('nChannels', 24)
        ncid.createDimension('timestampLength', 26)
        ncid.createDimension('stringLength', 4)

        dims = ('stringLength')
        tscope = ncid.createVariable('telescope', 'c', dims)
        tscope[:] = 'BEv1'
                        
        dims = ('time', 'nChannels')
        cos = ncid.createVariable('cos', 'f', dims)
        cos.matrix = 1
        sin = ncid.createVariable('sin', 'f', dims)
        sin.matrix = 1

        dims = ('time')
        seq = ncid.createVariable('sequenceNumber', 'h', dims)
        vcc = ncid.createVariable('vcc', 'f', dims)
        vee = ncid.createVariable('vdd', 'f', dims)
        vdd = ncid.createVariable('vee', 'f', dims)
        temp = ncid.createVariable('boardTemperature', 'f', dims)
        crc = ncid.createVariable('crc_checksum', 'i', dims)
        last_cmd = ncid.createVariable('last_cmd', 'c', dims)
        last_lia_cmd = ncid.createVariable('last_lia_cmd', 'c', dims)
        guard = ncid.createVariable('guard', 'i', dims)
        box = ncid.createVariable('box', 'h', dims)

	dims = ('time', 'timestampLength')
        timestamp = ncid.createVariable('timestampUDP', 'c', dims)
        timestamp.epoch = 'GPS'

        lockfile = self.directory + '/' + self.filename + '_lock'
        takeData = os.path.isfile(lockfile)
        counter = 0
        firstPacket = True
        while takeData:
            if firstPacket:
                id = 'BICEP002'
                sn = float(1)
                rev = float(1.02)
                ncid.id =  id
                ncid.sn = sn
                ncid.rev = rev
                firstPacket = False
            tsstring = datetime.datetime.utcnow().isoformat()
            last_index = min(len(tsstring), 26)
            timestamp[counter,0:last_index] = tsstring[0:last_index]
            seq[counter] = counter + (self.boardNumber % 10000)
#             seq[counter] = counter % 10000
#             bolosig[counter, :] = 32
            cos[counter,:] = -3.5
            sin[counter,:] = +3.5
            vcc[counter] = 5.0
            vee[counter] = 4.0
            vdd[counter] = 3.0
            temp[counter] = 40.0
            box[counter] = self.boardNumber
            crc[counter] = 999
            last_cmd[counter] = 23
            last_lia_cmd[counter] = 32
            guard[counter] = 0
            # I think this sync should be unnecessary with NC_SHARE enabled
            # if (counter % 20) == 0:
            #     ncid.sync()
            time.sleep(0.030)
            counter += 1
            takeData = os.path.isfile(lockfile)

        ncid.close()

##
## Code that calls the helper client function above (int main-ish)
##

directory = sys.argv[1]
filenameRoot = sys.argv[2]
host = sys.argv[3]
port = int(sys.argv[4])
firstBoard = int(sys.argv[5])
lastBoard = int(sys.argv[6])
nboards = lastBoard - firstBoard + 1

for j in range(nboards):
    zspec_client_thread(host, port, directory, filenameRoot,
                        j+firstBoard).start()

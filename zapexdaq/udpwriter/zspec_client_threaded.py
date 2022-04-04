#!/usr/bin/env /usr/bin/python

# the problem with this syntax is that the packets are 192 bytes in size while this represent 194 bytes. In C, struct alignment issues cause sizeof to report 196 bytes.
#struct DataSystemBox {  
#
#      unsigned char id[8];
#      unsigned char sn[4];
#      unsigned char rev[4];
#      unsigned char seq[4];
#      unsigned char vcc[4];
#      unsigned char vee[4];
#      unsigned char vdd[4];
#      unsigned char temp[4];
#      unsigned char sdata[NCHAN][BYTES_PER_WORD];
#      unsigned char box[2];
#      unsigned int  crc;
#      unsigned char last_cmd;
#      unsigned char last_lia_cmd;
#      unsigned char guard[6];
#
#  } *box;


#from Scientific.IO.NetCDF import NetCDFFile  # using older code from French mec
from netCDF4 import Dataset as NetCDFFile     # contemporary, maintained code from Google
from socket import socket, AF_INET, SOCK_DGRAM
import string
import os.path
import threading
import sys
import datetime
from numpy import array, int32, uint32, double
from struct import unpack

##
## I've implemented the client using a Threading class. Unclear if this is really any better (probably not) than simply running N instances of the python interpreter
## 
## This is a helper function that can be called by other python programs, including the one at the end of this file.
##

def decodeBolosig(bolosigEncoded):
    bitmax= 2**23
    vmax = 4.0
    sinMSBencoded = array(bolosigEncoded[0:144:6])
    sinISBencoded = array(bolosigEncoded[1:144:6])
    sinLSBencoded = array(bolosigEncoded[2:144:6])
    cosMSBencoded = array(bolosigEncoded[3:144:6])
    cosISBencoded = array(bolosigEncoded[4:144:6])
    cosLSBencoded = array(bolosigEncoded[5:144:6])
    sinMSB = unpack('24b', sinMSBencoded)
    sinISB = unpack('24B', sinISBencoded)
    sinLSB = unpack('24B', sinLSBencoded)
    cosMSB = unpack('24b', cosMSBencoded)
    cosISB = unpack('24B', cosISBencoded)
    cosLSB = unpack('24B', cosLSBencoded)
    sin = []
    cos = []
    for j in range(24):
        s = int32(sinMSB[j] << 16)
        s += uint32(sinISB[j] << 8)
        s += uint32(sinLSB[j])
        sin.append(double(s) * vmax / bitmax)
        c = int32(cosMSB[j] << 16)
        c += uint32(cosISB[j] << 8)
        c += uint32(cosLSB[j])
        cos.append(double(c) * vmax / bitmax)
    return (sin, cos)

def decodeTemperatures(temperaturesEncoded):
    hk_vin = 5.0
    bitmax = 2**12
    sinMSBencoded = array(temperaturesEncoded[1:144:6])
    sinLSBencoded = array(temperaturesEncoded[2:144:6])
    cosMSBencoded = array(temperaturesEncoded[3:144:6])
    cosLSBencoded = array(temperaturesEncoded[4:144:6])
    sinMSB = unpack('24B', sinMSBencoded)
    sinLSB = unpack('24B', sinLSBencoded)
    cosMSB = unpack('24B', cosMSBencoded)
    cosLSB = unpack('24B', cosLSBencoded)
    sin = []
    cos = []
    for j in range(24):
        s = uint32(sinMSB[j]*256 + sinLSB[j])
        sin.append(double(s) * hk_vin / (bitmax-1))
        c = uint32(cosMSB[j]*256 + cosLSB[j])
        cos.append(double(c) * hk_vin / (bitmax-1))
    return (sin, cos)

class zspec_client_thread(threading.Thread):

    def __init__(self, host, port, directory, filename, boardNumber):
        self.host = host
        self.port = port + boardNumber
        self.directory = directory
        self.filename = filename
        self.boardNumber = boardNumber
        threading.Thread.__init__(self)

    def run(self):
        # setup netCDF file
        bnString = '%02d' % self.boardNumber
        ncid = NetCDFFile(self.directory + '/' + self.filename + '_board' +
                          bnString + '.nc', 'ws', format='NETCDF3_CLASSIC',
                          clobber=False)
        ncid.createDimension('time', None)
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

	# setup the UDP listener on the port for this board
        s = socket(AF_INET, SOCK_DGRAM)
        s.settimeout(5)
        s.bind((self.host, self.port))

        firstPacket = True
        lockfile = self.directory + '/' + self.filename + '_lock'
        takeData = os.path.isfile(lockfile)
        counter = 0
        while takeData:
            data = s.recv(192)
            if len(data) != 192:
                print 'Received short or long packet!'

            # Sending a command will cause invalid sequence numbers to
            # be sent. Check for this and write data only if valid
            try:
                sqno = int(data[16:20])
            except ValueError:
                print 'Bad cast to seq. #'
                continue
            else:
                if sqno >= 0 and sqno <= 9999:
                    seq[counter] = sqno
                else:
                    print 'Successful seq. # cast, but out of range: ', sqno
                    continue
            
            tstamp = datetime.datetime.utcnow().isoformat()
            #  tstamp = tstamp[0:24] + 'UTC'

            #
            # I should probably confirm that 192 bytes were read!
            #

#            packets[counter, :] = data
            
            if firstPacket:
            	ncid.id = data[0:8]
            	ncid.sn = float(data[8:12])
            	ncid.rev = float(data[12:16])
            	firstPacket = False
            
            bolosigEncoded = data[36:180]
            if self.boardNumber == 9:
                (bolosigSin, bolosigCos) = decodeTemperatures(bolosigEncoded)
            else:
                (bolosigSin, bolosigCos) = decodeBolosig(bolosigEncoded)
            sin[counter, :] = bolosigSin
            cos[counter, :] = bolosigCos
            vcc[counter] = float(data[20:24])/100
            vdd[counter] = float(data[28:32])/100
            vee[counter] = float(data[24:28])/100
            try:
                temp[counter] = float(data[32:36])/10
            except ValueError:
                temp[counter] = -1
            box[counter] = unpack('h', data[180:182])
            crc[counter] = unpack('I', data[182:186])
            last_cmd[counter] = data[186]
            last_lia_cmd[counter] = data[187]
            guard[counter] = unpack('i',data[188:192])
            last_index = min(len(tstamp), 26)
            timestamp[counter,0:last_index] = tstamp[0:last_index]

            # I think this sync should be unnecessary with NC_SHARE enabled
            #            if (counter % 20) == 0:
            #                ncid.sync()
            counter += 1
            takeData = os.path.isfile(lockfile)

        ncid.close()
        s.close()

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

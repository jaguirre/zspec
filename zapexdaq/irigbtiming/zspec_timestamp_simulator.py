#!/usr/bin/env /usr/bin/python
import os.path
import datetime
import time
import sys
from netCDF4 import Dataset as NetCDFFile

directory = sys.argv[1]
filenameroot = sys.argv[2]

ncid = NetCDFFile(directory + '/' + filenameroot + '_timestamps.nc', 'ws',
                  format='NETCDF3_CLASSIC', clobber=False)
ncid.createDimension('time', None)
ncid.createDimension('timestampLength', 26)
dims = ('time', 'timestampLength')
timestamps = ncid.createVariable('timestampIRIGB', 'c', dims)

# zspecbe's clock is in GPS epoch when tied to IRIG-B through NTP
# and in TAI epoch when tied to APEX through NTP. Check by running:
# /usr/bin/ntpq -p
# all numbers in msec, locked servers have asterisk to the left
ncid.epoch = "GPS"

counter = 0
lockfile = directory + '/' + filenameroot + '_lock'
takeData = os.path.isfile(lockfile)
while takeData:
    timestamps[counter,:] = datetime.datetime.utcnow().isoformat()
    time.sleep(0.030)
    counter += 1
    takeData = os.path.isfile(lockfile)

#!/usr/bin/env python

# for FITS netCDF converter
from boa import BoaMBFits
from netCDF4 import Dataset as NetCDFFile
from numpy import uint16, int16, sqrt, modf, array, sort, ix_
from sys import argv, exit, stderr

# for file matching function defined at end
from fnmatch import fnmatch
from os import listdir, makedirs, path

# finds the most appropriate backend file for an APECS scan that begins
# at MJD. Searches backward in time.
def find_backend_file(mjd, firstSeqNo):
    rootdir = path.expanduser('~/data/backend/')

    # On Oct. 22nd, 2010 around noon, we tied the ZSPECBE clock to GPS
    # epoch through the IRIG-B card. The MBFITS timestamps are in TAI
    # epoch which is offset from GPS by 19 seconds.  This conversion
    # will never change even if leap seconds are added to UTC.
    # Do not adjust the MJD for previous dates, because the ZSPECBE
    # clock operated in both TAI and UTC modes at times.
    if mjd > 55491.75:
        mjd = mjd - 19./86400.

    # round up on seconds, in case of precision error
    mjd = mjd + 1./86400.
    (year, month, day, hours, minutes, seconds) = j2g(mjd)

    found = False
    attemptedMatches = 0
    while not found:
        dateString = '%04i%02i%02i' % (year, month, day)
        timeString = '%02i%02i%02i' % (hours, minutes, seconds)
        datetimeString = dateString + '_' + timeString

        potentialMatch = False
        dir = rootdir + dateString
        for file in listdir(dir):
            if fnmatch(file, datetimeString + '*merged.nc'):
                attemptedMatches += 1
                potentialMatch = True
                break # only out of for loop

        # decrement time. Important to do even if there was a match
        # because the seq. # match may not succeed
        if seconds > 0:
            seconds = seconds - 1
        else:
            seconds = 59
            if minutes > 0:
                minutes = minutes - 1
            else:
                minutes = 59
                hours = hours - 1

        # confirm sequence number match. sometimes this fails and crashes.
        if potentialMatch:
            benc = NetCDFFile('%s/%s' % (dir, file), 'r')
            seqNo = benc.variables['sequenceNumber'][0,0]
            benc.close()

            if firstSeqNo == seqNo:
                found = True
            else:
                found = False

        if attemptedMatches >= 5:
            break

    if found:
        return (dir, file)
    else:
        return ('', '')

# Convert Modified Julian Date (floating) to Gregorian date and time
def j2g(mjd):
    try:
        jd=float(mjd)
    except ValueError:
        print 'Provide numeric argument'
        return -1
    j = mjd + 2400001  # this choices results in MJD conversion
    (fracday, Z) = modf(j)
    alpha=int((Z-1867216.25)/36524.25)
    A=Z + 1 + alpha - int(alpha/4)

    B = A + 1524
    C = int( (B-122.1)/365.25)
    D = int( 365.25*C )
    E = int( (B-D)/30.6001 )

    dd = int(B - D - int(30.6001*E))

    if E<13.5:
        mm=E-1

    if E>13.5:
        mm=E-13

    if mm>2.5:
        yyyy=C-4716

    if mm<2.5:
        yyyy=C-4715

    daylist=[31,28,31,30,31,30,31,31,30,31,30,31]
    daylist2=[31,29,31,30,31,30,31,31,30,31,30,31]

    hours = int(fracday*24.)
    minutes = int(((fracday*24)-hours)*60.)
    seconds = 86400.*(fracday) - hours*3600. - minutes*60.

    # Now calculate the fractional year. Do we have a leap year?
    if (yyyy%4 != 0):
        days=daylist2
    elif (yyyy%400 == 0):
        days=daylist2
    elif (yyyy%100 == 0):
        days=daylist
    else:
        days=daylist2

    return (yyyy, mm, dd, hours, minutes, seconds)

if len(argv) == 2:
    fits = argv[1]
    ncdirectory = '.'
elif len(argv) == 3:
    fits = argv[1]
    ncdirectory = argv[2]
else:
    print 'Supply 2 arguments: FITS scan and output directory'
    exit(-1)

mjdRevision2 = 55545

# put the names of MBFITS variables that you want on the left
# and names of netCDF variables on the right and then you can
# use the left as an index variable to access the right side
# (in the parlance of CS, it's called a "hash table")
# see, e.g. p. 60 of APEX-MPI-ICD-0002 rev. 1.62
fitsncmap = dict({
    "LST": "sidereal_time",
    "AZIMUTH": "azimuth",
    "ELEVATIO": "elevation",
    "RA": "right_ascension",
    "DEC": "declination",
    "PARANGLE": "parallactic_angle",
    "WOBDISLN": "chopper_throw_longitude",
    "WOBDISLT": "chopper_throw_latitude",
    "LONGOFF": "longoff",
    "LATOFF": "latoff",
    "CBASLONG": "right_ascension_commanded",
    "CBASLAT": "declination_commanded"
    })

unitsmap = dict({
    "LST": "seconds",
    "AZIMUTH": "degrees",
    "ELEVATIO": "degrees",
    "RA": "degrees",
    "DEC": "degrees",
    "PARANGLE": "degrees",
    "WOBDISLN": "degrees",
    "WOBDISLT": "degrees",
    "LONGOFF": "degrees",
    "LATOFF": "degrees",
    "CBASLONG": "degrees",
    "CBASLAT": "degrees"
    })

## Open the FITS file
if fits[-1] == '/':
    fits = fits[:-1]
try:
    dataset = BoaMBFits.importDataset(fits)
except BoaMBFits.MBFitsError:
    print >> stderr, 'Failed to open: ' + fits
    exit(-1)

## get APECS scan number
try:
    scanTable = dataset.getTables(EXTNAME='SCAN-MBFITS')[0]
except IndexError:
    print >> stderr, 'Couldn\'t open scan table from: ' + fits
    exit(-2)

scanTable.open()
scanNumber = scanTable.getKeyword('SCANNUM').getValue()
object = scanTable.getKeyword('OBJECT').getValue()
tai2utc = -scanTable.getKeyword('TAI2UTC').getValue()
gps2utc = tai2utc + 19
print 'Scan #: ' + str(scanNumber)
print 'Object: ' + object
scanTable.close()

## find out how many scans comprise the FITS file
teldataTables = dataset.getTables(EXTNAME='DATAPAR-MBFITS')
nsubscans = len(teldataTables)

for j in range(0,nsubscans):
    print 'Subscan #: ' + str(j+1)
    # reset value of empty boolean on every subscan
    emptySubscan = False

    ## CREATE OUTPUT NETCDF FILE
    dr = ncdirectory + '/' + object + '/'
    fl = path.basename(fits) + '_subscan%02d' % (j+1) + '.nc'
    try:
        makedirs(dr)
    except OSError, e:
        pass
    ncfilename = dr + fl
    ncid = NetCDFFile(ncfilename, 'w', format='NETCDF3_CLASSIC', clobber=False)
    ncid.createDimension('nBoxes', 10)

    # record APECS scan # to file
    scannc = ncid.createVariable('apecsScanNumber', 'i', ())
    scannc[:] = scanNumber

    # record APECS object to file
    objdim = 'objectLength'
    ncid.createDimension(objdim, len(object))
    objnc = ncid.createVariable('object', 'c', objdim)
    objnc[:] = object

    # record epoch conversion factors
    tainc = ncid.createVariable('tai2utc', 'b', ())
    tainc[:] = tai2utc

    # record epoch conversion factors
    gpsnc = ncid.createVariable('gps2utc', 'b', ())
    gpsnc[:] = gps2utc

    # note telescope as netCDF data format differs in minor ways from CSO

    stringDim = 'stringLength'
    if stringDim not in ncid.dimensions:
        ncid.createDimension(stringDim, 4)
        tsnc = ncid.createVariable('telescope', 'c', 'stringLength')
    tsnc[:] = 'APEX'

    # get data from the FITS file
    arraydataTables = dataset.getTables(EXTNAME='ARRAYDATA-MBFITS',
                                        OBSNUM=(j+1))
    teldataTables = dataset.getTables(EXTNAME='DATAPAR-MBFITS',
                                      OBSNUM=(j+1))
    monitorTables = dataset.getTables(EXTNAME='MONITOR-MBFITS',
                                      OBSNUM=(j+1))

    try:
        monitorTable = monitorTables[0]
    except:
        print >> stderr, fl + ': Failed to open monitor table'
        ncid.close()
        open(ncfilename + '.empty', 'w').close()
        continue # goes to next subscan
    monitorTable.open()
    monpoints = monitorTable.getColumn('MONPOINT').read()
    pwvix = monpoints.index('PWV')
    monvalues = monitorTable.getColumn('MONVALUE').read()
    monunits = monitorTable.getColumn('MONUNITS').read()
    monitorTable.close()
    pwvnc = ncid.createVariable('pwv', 'f', ())
    pwvnc[:] = monvalues[pwvix]
    pwvnc.units = monunits[pwvix]
    ncid.sync()

    for arraydataTable in arraydataTables:
        febe = arraydataTable.getKeyword('FEBE').getValue()
        baseband = arraydataTable.getKeyword('BASEBAND').getValue()
        arraydataTable.open()

        mjdmb = arraydataTable.getColumn('MJD').read()

        # get the actual data from FITS. This could be the bolometer data
        # or the sequence number and UDP timestamps. If nbackends == 1,
        # then it's the latter. If not, then it's bolometer data.
        data = arraydataTable.getColumn('DATA').read()
        arraydataTable.close()
        try:
            nbackends = len(data[0])
            nsamples = len(data)
        except IndexError:
            print >> stderr, fl + ': couldn\'t open data from subscan.'
            emptySubscan = True
            break # exits arraydataTable for loop

        if(nsamples == 0):
            print >> stderr, fl + ': empty subscan.'
            emptySubscan = True
            break # exits arraydataTable for loop

        # create time dimension and associated variables. Should execute
        # only once the first time through the scan loop
        timedim = 'time'
        if timedim not in ncid.dimensions:
            ncid.createDimension(timedim, nsamples)
            dims = (timedim)
            mjdnc = ncid.createVariable('mjd', 'i', dims)
            ticksnc = ncid.createVariable('ticks', 'd', dims)
            ticksnc.units = "seconds since midnight (TAI epoch)"
            dims = (timedim, 'nBoxes')
            ticksudpnc = ncid.createVariable('ticksudp', 'd', dims)
            ticksudpnc.units = "seconds since midnight (GPS epoch)"
            seqnonc = ncid.createVariable('sequenceNumber', 'h', dims)
            (ticks, epoch_day) = modf(mjdmb)
            mjdnc[:] = uint16(epoch_day)
            ticksnc[:] = ticks*86400.

        # Either sequence # data or bolometer data
        if nbackends == 1:
            if len(mjdmb) == 0:
                print >> stderr, fl + ': problem with MJD.'
                emptySubscan = True
                break # exits arraydataTable for loop

            if mjdmb[0] <= mjdRevision2:
                seqnonc[:] = int16(data[:,0,0::3])
                seconds = data[:,0,1::3]
                useconds = data[:,0,2::3]
                ticksudpnc[:] = seconds + (useconds / 1E6)
                del seconds, useconds
                # use MJD (in TAI) out of FITS and use to match to backend file
                befiledim = 'befilename'
                if befiledim not in ncid.dimensions:
                    (bedir, befile) = find_backend_file(mjdmb[0], seqnonc[0,0])
                    if befile != '':
                        print 'Matched to: ' + befile
                        ncid.createDimension(befiledim, len(befile))
                        befnc = ncid.createVariable('backendFile', 'c', befiledim)
                        befnc[:] = befile
                    else:
                        print >> stderr, fl + ': failed to match subscan to backend data.'
                        open(ncfilename + '.nobe', 'w').close()
            else:
                seqnonc[:] = int16(data[:,0,0:30:3]) # indices 0,3...27
                seconds = data[:,0,1:30:3]           # indices 1,4...28
                useconds = data[:,0,2:30:3]          # indices 2,5...29
                ticksudpnc[:] = seconds + (useconds / 1E6)
                del seconds, useconds

                extraDim = 'nextra'
                nextra = 16
                if extraDim not in ncid.dimensions:
                    ncid.createDimension(extraDim, nextra)
                    dims = (timedim, extraDim)
                    sinexnc = ncid.createVariable('sin_extra', 'f', dims)
                    sinexnc.matrix = 1
                    sinexnc.units = "Volts"
                    cosexnc = ncid.createVariable('cos_extra', 'f', dims)
                    cosexnc.matrix = 1
                    cosexnc.units = "Volts"
                    acbexnc = ncid.createVariable('ac_bolos_extra', 'd', dims)
                    acbexnc.matrix = 1
                    acbexnc.units = "Volts"
                sinexnc[:] = data[:,0,30:46] # 31st to 46th elements (N=16)
                cosexnc[:] = data[:,0,46:62] # 47th to 62nd elements (N=16)
                acbexnc[:] = sqrt(sinexnc[:]**2 + cosexnc[:]**2)
                ncid.sync()

        else: # nbackend sections == 10 (1 for each board)
            nbolo = len(data[0,0,:])
            if 'nbolo' not in ncid.dimensions:
                ncid.createDimension('nbolo', nbolo)
                dims = (timedim, 'nbolo')
                sinnc = ncid.createVariable('sin', 'f', dims)
                sinnc.matrix = 1
                sinnc.units = "Volts"
                cosnc = ncid.createVariable('cos', 'f', dims)
                cosnc.matrix = 1
                cosnc.units = "Volts"
                acb = ncid.createVariable('ac_bolos', 'd', dims)
                acb.matrix = 1
                acb.units = "Volts"
            sinnc[:] = data[:,0,:]
            cosnc[:] = data[:,1,:]
            acb[:] = sqrt(data[:,0,:]**2 + data[:,1,:]**2)
        # END if/else for backend extra info versus bolo data
        del data
        ncid.sync()
    # END ARRAYDATA LOOP

    # If scan was empty we broke out of arraydata for loop.
    # Continue on to next scan in FITS file. Sometimes all
    # scans are empty, sometimes not.
    if emptySubscan:
        ncid.close()
        # simple log of this problem
        open(ncfilename + '.empty', 'w').close()
        continue # go to next subscan

    # if this data is from the first run, we have to get some extra
    # information from the backend file. Subsequent runs will store
    # this in MBFITS and write it inside the arraydata loop
    if mjdmb[0] <= mjdRevision2 and befile != '':
        backendnc = NetCDFFile('%s/%s' % (bedir,befile), 'r')
        cosbe = backendnc.variables['cos'][:]
        sinbe = backendnc.variables['sin'][:]

        extraChannelsBoard = array([6, 6, 3, 3, 0, 9, 9, 9, 9, 9, 9, 9, 9])
        extraChannelsNum = array([9, 23, 2, 23, 12, 1, 8, 10, 11, 18, 19, 20, 21])
        extraChannels = sort(extraChannelsBoard*24 + extraChannelsNum)
        extraDim = 'nextra'
        if extraDim not in ncid.dimensions:
            ncid.createDimension(extraDim, len(extraChannels))
            dims = (timedim, extraDim)
            sinexnc = ncid.createVariable('sin_extra', 'f', dims)
            sinexnc.matrix = 1
            sinexnc.units = "Volts"
            cosexnc = ncid.createVariable('cos_extra', 'f', dims)
            cosexnc.matrix = 1
            cosexnc.units = "Volts"
            acbexnc = ncid.createVariable('ac_bolos_extra', 'd', dims)
            acbexnc.matrix = 1
            acbexnc.units = "Volts"

        # Should not need to align first data points (seq. #s) from a
        # merged file as it has already been done in the same manner
        # as is done when presenting data to the MBFITS writer. We
        # also checked for matching in find_backend_file. It is
        # possible possible that the number of samples may be smaller
        # in FITS, so just ask for how many samples the FITS has.
        sinexnc[:] = sinbe[ix_(range(0,nsamples), extraChannels)]
        cosexnc[:] = cosbe[ix_(range(0,nsamples), extraChannels)]
        acbexnc[:] = sqrt(sinexnc[:]**2 + cosexnc[:]**2)
        ncid.sync()

    for teldataTable in teldataTables:
        teldataTable.open()
        names = teldataTable.getColumnNames()
        dims = ('time')
        for name in names:
            if name == 'MJD':
                continue #already got it
            if name in fitsncmap:
                data = teldataTable.getColumn(name).read()
                var = ncid.createVariable(fitsncmap[name], 'd', dims)
                var.units = unitsmap[name]
                var[:] = data
                ncid.sync()
## Assume that we are only chopping in longitude. Copy the MBFITS
## chopper longitude displacement in degrees into chop_enc
## in addition to having it stored in chopper_throw_longitude
            if name == 'WOBDISLN':
                var = ncid.createVariable('chop_enc', 'd', dims)
                var.units = "degrees"
                var[:] = data
        teldataTable.close()

    # A number of variables have to be created so that the reduction
    # can succeed.
    dims = ('time')
    var = ncid.createVariable('nodding', 'b', dims)
    var[:] = 1
    var = ncid.createVariable('on_beam', 'b', dims)
    var[:] = 1
    var = ncid.createVariable('off_beam', 'b', dims)
    var[:] = 0
    var = ncid.createVariable('acquired', 'b', dims)
    var[:] = 1
    var = ncid.createVariable('observing', 'b', dims)
    var[:] = 1

    dims = ('nbolo')
    var = ncid.createVariable('bolo_flags', 'b', dims)
    var[:] = 1

    dims = ('time', 'nbolo')
    var = ncid.createVariable('time_flags', 'b', dims)
    var[:] = 1
    ncid.sync()
    ncid.close()
# END LOOP OVER SUBSCANS


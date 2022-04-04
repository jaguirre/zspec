#!/usr/bin/env python

# for FITS netCDF converter
from boa import BoaMBFits
from sys import argv

filename = argv[1]

## Open the FITS file
dataset = BoaMBFits.importDataset(filename)

## get APECS scan number
scanTable = dataset.getTables(EXTNAME='SCAN-MBFITS')[0]
scanTable.open()
scanNumber = scanTable.getKeyword('SCANNUM').getValue()
scanTable.close()

print 'APEX scan #: ' + str(scanNumber)

## find out how many scans comprise the FITS file
teldataTables = dataset.getTables(EXTNAME='DATAPAR-MBFITS')
nsubscans = len(teldataTables)

print '# subscans: ' + str(nsubscans)
for j in range(0,nsubscans):

    # get data from the FITS file
    arraydataTables = dataset.getTables(EXTNAME='ARRAYDATA-MBFITS',
                                        OBSNUM=(j+1))

    for arraydataTable in arraydataTables:
        arraydataTable.open()
        data = arraydataTable.getColumn('DATA').read()
        arraydataTable.close()

        try:
            nbackends = len(data[0])
            nsamples = len(data)
        except IndexError:
            print >> stderr, fl + ': couldn\'t open data from subscan.'
            emptySubscan = True
            break # exits arraydataTable for loop

        if nbackend !=1:
            continue
        else:
            seqnonc[:] = int16(data[:,0,0:30:3]) # indices 0,3...27
            seconds = data[:,0,1:30:3]           # indices 1,4...28
            useconds = data[:,0,2:30:3]          # indices 2,5...29
            sin_extra = data[:,0,30:46] # 31st to 46th elements (N=16)
            cos_extra = data[:,0,46:62] # 47th to 62nd elements (N=16)
            print "sin_extra for subscan " + str(j)
            print sin_extra
            print "cos_extra for subscan " + str(j)
            print cos_extra

#!/usr/bin/env python

# for FITS netCDF converter
from boa import BoaMBFits
from sys import argv, stderr, exit

filename = argv[1]

## Open the FITS file
dataset = BoaMBFits.importDataset(filename)

## get APECS scan number
## get APECS scan number
try:
    scanTable = dataset.getTables(EXTNAME='SCAN-MBFITS')[0]
except IndexError:
    print >> stderr, 'Couldn\'t open scan table from: ' + filename
    print >> stderr, 'File is hosed.'
    exit(-1)

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
        febe = arraydataTable.getKeyword('FEBE').getValue()
        baseband = arraydataTable.getKeyword('BASEBAND').getValue()
        arraydataTable.open()
        data = arraydataTable.getColumn('DATA').read()
        arraydataTable.close()
        nsamples = len(data)
        print 'Subscan #' + str(j+1) + ': ' + str(nsamples) + ' samples'

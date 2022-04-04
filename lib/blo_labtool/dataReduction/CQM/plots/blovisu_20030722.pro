path = '/data1/SPIRE_CQM/20030722/'


filename = '200307221041_coadd'
psinit, /letter, /full
blovisu, path+filename+'.fits', $
ndx=4, ndy=8, /ylog
psterm, file=path+filename+'.ps'


filename = '200307220045_coadd'
psinit, /letter, /full
blovisu, path+filename+'.fits', $
ndx=4, ndy=8, /ylog
psterm, file=path+filename+'.ps'

